import QtQuick

import Base 1.0
import Dialogs 1.0
import Models 1.0
import SortFilterProxyModel 0.2
import "../../../Util.js" as Util
import mythqml.net 1.0

BaseScreen
{
    id: root

    defaultFocusItem: webvideoGrid

    Component.onCompleted:
    {
        showTime(false);
        showTicker(false);

        while (stack.busy) {};

        if (isPanel)
            feedSource.category = "<All Web Videos>";
        else
            feedSource.category = dbUtils.getSetting("LastWebvideoCategory", settings.hostName);

        if (feedSource.category == "<All Web Videos>" || feedSource.category == "")
            footer.greenText = "Show (All Web Videos)"
        else
            footer.greenText = "Show (" + feedSource.category + ")"

        var index = dbUtils.getSetting("WebvideoListIndex", settings.hostName, "");

        if (index !== "")
            feedSource.webvideoListIndex = index;

        showTitle(true, "Web Video Viewer - " + playerSources.webvideoList.webvideoList.get(feedSource.webvideoListIndex).title);
        setHelp("https://mythqml.net/help/webvideo_viewer.php#top");

        var filter = feedSource.webvideoListIndex + "," + feedSource.category + "," + "title";
        feedSource.switchToFeed("Web Videos", filter, 0);

        feedSource.feedModelLoaded.connect(function() { webvideoGrid.currentIndex = 0; });

        webvideoGrid.currentIndex = 0;

        updateWebvideoDetails();

        if (!isPanel)
            delay(1500, checkForUpdates);
    }

    Component.onDestruction:
    {
        dbUtils.setSetting("WebvideoListIndex", settings.hostName, feedSource.webvideoListIndex);
        dbUtils.setSetting("LastWebvideoCategory", settings.hostName, feedSource.category)
        playerSources.webvideoList.models[feedSource.webvideoListIndex].model.saveFavorites();
    }

    FeedSource
    {
        id: feedSource
        objectName: "WebVideoViewer"
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_M)
        {
            popupMenu.clearMenuItems();

            popupMenu.addMenuItem("", "Switch Web Video List");
            for (var x = 0; x < playerSources.webvideoList.webvideoList.count; x++)
                popupMenu.addMenuItem("0", playerSources.webvideoList.webvideoList.get(x).title, x, (feedSource.webvideoListIndex == x ? true : false));

            popupMenu.show();
        }
        else if (event.key === Qt.Key_F1)
        {
            var id = webvideoGrid.model.get(webvideoGrid.currentIndex).id;

            if (feedSource.sort === "id")
            {
                feedSource.sort = "title";
                footer.redText = "Sort (Name)";
            }
            else
            {
                feedSource.sort = "id";
                footer.redText = "Sort (No.)";
            }

            var index = feedSource.findById(id);

            webvideoGrid.currentIndex = (index != -1 ? index : 0);
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN
            searchDialog.model = playerSources.webvideoList.models[feedSource.webvideoListIndex].categoryList
            searchDialog.show();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW
            var id = webvideoGrid.model.get(webvideoGrid.currentIndex).id;
            var index = playerSources.webvideoList.models[feedSource.webvideoListIndex].model.findById(id);

            if (index != -1)
                playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(index).favorite = !playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(index).favorite;
         }
        else if (event.key === Qt.Key_F4)
        {
            //BLUE
            if (webvideoGrid.model.get(webvideoGrid.currentIndex).website !== undefined)
            {
                var website = webvideoGrid.model.get(webvideoGrid.currentIndex).website;
                var zoom = xscale(webvideoGrid.model.get(webvideoGrid.currentIndex).zoom);
                stack.push(Qt.resolvedUrl("WebBrowser.qml"), url: website, zoomFactor: zoom});
            }

            returnSound.play();
        }
        else if (event.key === Qt.Key_F5)
        {
            playerSources.webvideoList.reload();
        }
        else if (event.key === Qt.Key_R)
        {
            // for testing reset the last checked to now -4 weeks
            dbUtils.setSetting("LastWebvideoCheck", settings.hostName, Util.addDays(Date(Date.now()), -28));
        }
        else if (event.key === Qt.Key_I)
        {
            infoDialog.infoText = description.text.replace(/\n/g, "<br>");
            infoDialog.show(webvideoGrid);
        }
        else
            event.accepted = false;
    }

    BaseBackground
    {
        id: listBackground
        x: xscale(10); y: yscale(45); width: parent.width - x - xscale(10); height: yscale(410)
    }

    BaseBackground { x: xscale(10); y: yscale(465); width: parent.width - xscale(20); height: yscale(210) }

    InfoText
    {
        x: parent.width - xscale(210); y: yscale(5); width: xscale(200);
        text: (webvideoGrid.currentIndex + 1) + " of " + webvideoGrid.model.count;
        horizontalAlignment: Text.AlignRight
    }

    ButtonGrid
    {
        id: webvideoGrid
        x: xscale(22)
        y: yscale(55)
        width: parent.width - xscale(44)
        height: yscale(390)
        cellWidth: width / (root.isPanel ? 4 : 5);
        cellHeight: yscale(130)

        Component
        {
            id: webvideoDelegate
            Item
            {
                x: 0;
                y: 0;
                width: webvideoGrid.cellWidth;
                height: webvideoGrid.cellHeight;
                Image
                {
                    opacity: 0.80
                    asynchronous: true
                    anchors.fill: parent
                    anchors.margins: xscale(5)
                    source: getIconURL(icon);
                    onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/no_image.png");
                }
                LabelText
                {
                    x: 5;
                    y: webvideoGrid.cellHeight - yscale(40)
                    width: webvideoGrid.cellWidth - xscale(10)
                    visible: (status === "Temporarily Offline" || status === "Not Working")
                    text: status
                    horizontalAlignment: Text.AlignHCenter;
                    fontPixelSize: xscale(14)
                }
                Image
                {
                    x: xscale(5)
                    y: yscale(5)
                    width: xscale(40)
                    height: yscale(40)
                    visible: favorite;
                    opacity: 1.0
                    source: mythUtils.findThemeFile("images/favorite.png");
                }
                Image
                {
                    x: webvideoGrid.cellWidth - xscale(45)
                    y: yscale(5)
                    width: xscale(40)
                    height: yscale(40)
                    visible: categories.startsWith("New,");
                    opacity: 1.0
                    source: mythUtils.findThemeFile("images/new.png");
                }
            }
        }

        model: feedSource.feedList
        delegate: webvideoDelegate
        focus: true

        Keys.onReturnPressed:
        {
            var filter = feedSource.webvideoListIndex + "," + feedSource.category + "," + feedSource.sort;

            returnSound.play();

            if (!root.isPanel)
            {
                var item = stack.push(Qt.resolvedUrl("InternalPlayer.qml"), {defaultFeedSource:  "Web Videos", defaultFilter:  filter, defaultCurrentFeed: webvideoGrid.currentIndex});
                item.feedChanged.connect(feedChanged);
            }
            else
            {
                internalPlayer.previousFocusItem = webvideoGrid;
                feedSelected("Web Videos", filter, webvideoGrid.currentIndex);
            }

            event.accepted = true;
        }

        Keys.onPressed:
        {
            if (event.key === Qt.Key_Left && ((currentIndex % 4) === 0 && previousFocusItem))
            {
                event.accepted = true;
                escapeSound.play();
                previousFocusItem.focus = true;
            }
            else
                event.accepted = false;
        }

        onCurrentIndexChanged: updateWebvideoDetails();
    }

    TitleText
    {
        id: title
        x: xscale(30); y: yscale(470)
        width: parent.width - _xscale(1280 - 900); height: yscale(75)
        verticalAlignment: Text.AlignTop
        multiline: true
    }

    Image
    {
        id: webvideoIcon
        x: parent.width - _xscale(1280 - 950); y: yscale(480); width: _xscale(300); height: _yscale(178)
        asynchronous: true
        onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/no_image.png")
    }

    InfoText
    {
        id: description
        x: xscale(30); y: yscale(540)
        width: parent.width - _xscale(1280 - 900); height: yscale(100)
        verticalAlignment: Text.AlignTop
        multiline: true
    }

    InfoText
    {
        id: category
        x: xscale(30); y: yscale(630); width: _xscale(900)
        fontColor: "grey"
    }

    Image
    {
        id: websiteIcon
        x: _xscale(900); y: yscale(630); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/website.png")
    }

    Footer
    {
        id: footer
        redText: "Sort (Name)"
        greenText: "Show (All Web Videos)"
        yellowText: "Toggle Favorite"
        blueText: "Go To Website"
    }

    SearchListDialog
    {
        id: searchDialog

        title: "Choose a category"
        message: ""

        onAccepted:
        {
            webvideoGrid.focus = true;

        }
        onCancelled:
        {
            webvideoGrid.focus = true;
        }

        onItemSelected:
        {
            if (itemText != "<All Web Videos>")
            {
                feedSource.category = ""; // this is needed to get the ExpressionFilter to re-evaluate
                feedSource.category = itemText;
                footer.greenText = "Show (" + itemText + ")"
            }
            else
            {
                feedSource.category = "";
                footer.greenText = "Show (All Web Videos)"

            }

            webvideoGrid.focus = true;

            updateWebvideoDetails()
        }
    }

    PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "Web Video Viewer Options"

        onItemSelected:
        {
            webvideoGrid.focus = true;

            if (itemText == "Reload")
            {
                playerSources.webvideoList.models[feedSource.webvideoListIndex].model.reload();
            }
            else if (itemData !== "")
            {
                playerSources.webvideoList.models[feedSource.webvideoListIndex].model.saveFavorites();
                feedSource.webvideoListIndex = itemData;

                showTitle(true, "Web Video Viewer - " + playerSources.webvideoList.webvideoList.get(feedSource.webvideoListIndex).title);

                feedSource.category = "";
                footer.greenText = "Show (All Web Videos)"
            }
        }

        onCancelled:
        {
            webvideoGrid.focus = true;
        }
    }

    InfoDialog
    {
        id: infoDialog
        width: xscale(800)
    }

    function createMenu(menu)
   {
       menu.clear();

       menu.append({"menutext": "All", "loaderSource": "WebVideoViewer.qml", "menuSource": ""});
       menu.append({"menutext": "Favourite", "loaderSource": "WebVideoViewer.qml", "menuSource": ""});
       menu.append({"menutext": "New", "loaderSource": "WebVideoViewer.qml", "menuSource": ""});
       menu.append({"menutext": "---", "loaderSource": "WebVideoViewer.qml", "loaderSource": "", "menuSource": ""});

       for (var x = 0; x < playerSources.webvideoList.models[feedSource.webvideoListIndex].categoryList.count; x++)
       {
           menu.append({"menutext": playerSources.webvideoList.models[feedSource.webvideoListIndex].categoryList.get(x).item, "loaderSource": "WebVideoViewer.qml", "menuSource": ""});
       }
   }

   function setFilter(filter)
   {
       var filterList;
       if (filter === "All" || filter === "<All Web Videos>")
       {
           filterList = feedSource.webvideoListIndex + ",," + feedSource.sort;
           feedChanged("Web Videos", filterList, 0);
           feedSource.webvideoFilterFavorite ="Any";
       }
       else if (filter === "Favourite")
       {
           filterList = feedSource.webvideoListIndex + ",," + feedSource.sort;
           feedChanged("Web Videos", filterList, 0);
           feedSource.webvideoFilterFavorite ="Yes";
       }
       else if (filter === "New")
       {
           filterList = feedSource.webvideoListIndex + ",New," + feedSource.sort;
           feedChanged("Web Videos", filterList, 0)
           feedSource.webvideoFilterFavorite ="Any";
       }
       else if (filter != "---" )
       {
           filterList = feedSource.webvideoListIndex + "," + filter + "," + feedSource.sort;
           feedChanged("Web Videos", filterList, 0);
           feedSource.webvideoFilterFavorite ="Any";
       }
   }

   function feedChanged(feed, filterList, currentIndex)
   {
       if (feed !== "Web Videos")
           return;

       var list = filterList.split(",");
       var index = 0;
       var category = "";
       var sort = "title";

       if (list.length === 3)
       {
           index = list[0];
           category = list[1];
           sort = list[2];
       }
       if (category !== feedSource.category)
       {
           feedSource.category = ""; // this is needed to get the ExpressionFilter to re-evaluate

           if (category === "")
           {
               feedSource.category = category;
               footer.greenText = "Show (All Web Videos )"
           }
           else
           {
               feedSource.category = category;
               footer.greenText = "Show (" + category + ")"
           }
       }

       webvideoGrid.currentIndex = currentIndex;
   }

    function getIconURL(iconURL)
    {
        if (iconURL)
        {
            if (iconURL.startsWith("file://") || iconURL.startsWith("http://") || iconURL.startsWith("https://"))
                return iconURL;
            else
            {
                // try to get the icon from the same URL the webvideo list was loaded from
                var url = playerSources.webvideoList.webvideoList.get(feedSource.webvideoListIndex).url
                var r = /[^\/]*$/;
                url = url.replace(r, '');
                return url + iconURL;
            }
        }

        return ""
    }

    function updateWebvideoDetails()
    {
        if (webvideoGrid.currentIndex === -1)
            return;

        title.text = webvideoGrid.model.get(webvideoGrid.currentIndex).title;

        // description
        if (webvideoGrid.model.get(webvideoGrid.currentIndex).description !== undefined)
            description.text = webvideoGrid.model.get(webvideoGrid.currentIndex).description
        else
            description.text = ""

        // category
        category.text = webvideoGrid.model.get(webvideoGrid.currentIndex).categories;

        // icon
        webvideoIcon.source = getIconURL(webvideoGrid.model.get(webvideoGrid.currentIndex).icon);

        websiteIcon.visible = ((webvideoGrid.model.get(webvideoGrid.currentIndex).website !== undefined && webvideoGrid.model.get(webvideoGrid.currentIndex).website !== "" ) ? true : false)
    }


    function checkForUpdates()
    {
        var defaultDate = Date(Date.now());
        var lastChecked = Date.parse(dbUtils.getSetting("LastWebvideoCheck", settings.hostName, defaultDate));
        var x;
        var firstAdded = true;
        var firstModified = true;
        var firstOffline = true;
        var firstNotWorking = true;

        updatesModel.clear();

        // add new webvideos
        for (x = 0; x < playerSources.webvideoList.models[feedSource.webvideoListIndex].model.count; x++)
        {
            var webvideoAdded = Date.parse(playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).dateadded);

            if (lastChecked < webvideoAdded)
            {
                if (firstAdded)
                {
                    updatesModel.append({"heading": "yes", "title": "New Web Videos"});
                    firstAdded = false;
                }

                updatesModel.append({"heading": "no", "title": playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).title, "icon": playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).icon});
            }
        }

        // add modified webvideos
        for (x = 0; x < playerSources.webvideoList.models[feedSource.webvideoListIndex].model.count; x++)
        {
            var webvideoModified = Date.parse(playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).datemodified);
            var webvideoAdded = Date.parse(playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).dateadded);
            var status = playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).status

            if (lastChecked < webvideoModified && !(lastChecked < webvideoAdded) && status !== "Temporarily Offline" && status !== "Not Working")
            {
                if (firstModified)
                {
                    updatesModel.append({"heading": "yes", "title": "Updated/Fixed Web Videos"});
                    firstModified = false;
                }

                updatesModel.append({"heading": "no", "title": playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).title, "icon": playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).icon});
            }
        }

        // add temporarily offline webvideos
        for (x = 0; x < playerSources.webvideoList.models[feedSource.webvideoListIndex].model.count; x++)
        {
            var webvideoModified = Date.parse(playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).datemodified);
            var webvideoAdded = Date.parse(playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).dateadded);
            var status = playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).status

            if (lastChecked < webvideoModified && !(lastChecked < webvideoAdded) && status === "Temporarily Offline")
            {
                if (firstOffline)
                {
                    updatesModel.append({"heading": "yes", "title": "Temporarily Offline Web Videos"});
                    firstOffline = false;
                }

                updatesModel.append({"heading": "no", "title": playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).title, "icon": playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).icon});
            }
        }

        // add not working webvideos
        for (x = 0; x < playerSources.webvideoList.models[feedSource.webvideoListIndex].model.count; x++)
        {
            var webvideoModified = Date.parse(playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).datemodified);
            var webvideoAdded = Date.parse(playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).dateadded);
            var status = playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).status

            if (lastChecked < webvideoModified && !(lastChecked < webvideoAdded) && status === "Not Working")
            {
                if (firstNotWorking)
                {
                    updatesModel.append({"heading": "yes", "title": "Removed Web Videos"});
                    firstNotWorking = false;
                }

                updatesModel.append({"heading": "no", "title": playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).title, "icon": playerSources.webvideoList.models[feedSource.webvideoListIndex].model.get(x).icon});
            }
        }

        // do we need to show any new or updated webvideos
        if (updatesModel.count > 0)
        {
            dbUtils.setSetting("LastWebvideoCheck", settings.hostName, Date(Date.now()));
            messageSound.play();
            updatesDialog.show();
        }
    }

    Timer
    {
        id: delayTimer
    }

    function delay(delayTime, cb)
    {
        delayTimer.interval = delayTime;
        delayTimer.repeat = false;
        delayTimer.triggered.connect(cb);
        delayTimer.start();
    }

    ListModel
    {
        id: updatesModel
    }

    BaseDialog
    {
        id: updatesDialog
        title: "Web Videos Update"
        width: xscale(700)
        height: yscale(600)

        onAccepted:
        {
            webvideoGrid.focus = true;

        }
        onCancelled:
        {
            webvideoGrid.focus = true;
        }

        Component
        {
            id: listRow
            ListItem
            {
                width: parent.width; height: (heading === "yes") ? yscale(50) : yscale(86)
                LabelText
                {
                    x: xscale(5); y: 0
                    width: parent.width - xscale(10)
                    visible: (heading === "yes")
                    horizontalAlignment: Text.AlignHCenter
                    text: title
                }
                Image
                {
                    x: xscale(3); y: yscale(3); width: xscale(144); height: yscale(80)
                    visible: (heading === "no")
                    source: getIconURL(icon);
                    onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/no_image.png")
                }
                ListText
                {
                    x: xscale(150); y: 5
                    width: parent.width - xscale(150)
                    height: yscale(76)
                    visible: (heading === "no")
                    verticalAlignment: Text.AlignVCenter
                    multiline: true
                    text: title
                }
            }
        }

        content: Item
        {
            anchors.fill: parent

            ButtonList
            {
                id: itemList
                delegate: listRow
                model: updatesModel
                x: xscale(20); y: yscale(5)
                width: parent.width - xscale(40);
                height: parent.height - yscale(10);
                spacing: yscale(4)
                focus: true
                KeyNavigation.up: acceptButton
                KeyNavigation.down: acceptButton
                KeyNavigation.left: acceptButton
                KeyNavigation.right: acceptButton
             }
        }

        buttons:
        [
            BaseButton
            {
                id: acceptButton
                text: "OK"
                visible: text != ""
                KeyNavigation.up: itemList
                KeyNavigation.down: itemList
                KeyNavigation.left: itemList
                KeyNavigation.right: itemList
                onClicked:
                {
                    updatesDialog.state = "";
                    updatesDialog.accepted()
                }
            }
        ]
    }

    function handleCommand(command)
    {
        log.debug(Verbose.GUI, "WebVideoViewer: handle command - " + command);
        return true;
    }

    function handleSearch(message)
    {
        log.debug(Verbose.GUI, "WebVideoViewer: handle seach - " + message);


        return true;
    }
}
