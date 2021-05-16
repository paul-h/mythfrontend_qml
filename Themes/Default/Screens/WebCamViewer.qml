import QtQuick 2.0
import Base 1.0
import Dialogs 1.0
import Models 1.0
import SortFilterProxyModel 0.2
import "../../../Util.js" as Util
import mythqml.net 1.0

BaseScreen
{
    id: root

    defaultFocusItem: webcamGrid

    property int savedID: -1

    signal feedSelected(string feedSource, string filter, int index)

    Component.onCompleted:
    {
        showTime(false);
        showTicker(false);

        while (stack.busy) {};

        if (isPanel)
            feedSource.category = "";
        else
            feedSource.category = dbUtils.getSetting("LastWebcamCategory", settings.hostName);

        if (feedSource.category == "<All Webcams>" || feedSource.category == "")
            footer.greenText = "Show (All Webcams)"
        else
            footer.greenText = "Show (" + feedSource.category + ")"

        var index = dbUtils.getSetting("WebcamListIndex", settings.hostName, "");

        if (index !== "")
            feedSource.webcamListIndex = index;

        showTitle(true, "WebCam Viewer - " + playerSources.webcamList.webcamList.get(feedSource.webcamListIndex).title);

        var filter = feedSource.webcamListIndex + "," + feedSource.category + "," + "title";
        feedSource.switchToFeed("Webcams", filter, 0);

        playerSources.webcamList.models[feedSource.webcamListIndex].loaded.connect(feedLoaded);

        webcamGrid.currentIndex = 0;

        updateWebcamDetails();

        if (!isPanel)
            delay(1500, checkForUpdates);
    }

    Component.onDestruction:
    {
        dbUtils.setSetting("WebcamListIndex", settings.hostName, feedSource.webcamListIndex);
        dbUtils.setSetting("LastWebcamCategory", settings.hostName, feedSource.category)
        playerSources.webcamList.models[feedSource.webcamListIndex].model.saveFavorites();
    }

    FeedSource
    {
        id: feedSource
        objectName: "WebCamViewer"
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_M)
        {
            popupMenu.clearMenuItems();

            popupMenu.addMenuItem("", "Switch WebCam List");
            popupMenu.addMenuItem("", "Reload");
            for (var x = 0; x < playerSources.webcamList.webcamList.count; x++)
                popupMenu.addMenuItem("0", playerSources.webcamList.webcamList.get(x).title, x, (feedSource.webcamListIndex == x ? true : false));

            popupMenu.show();
        }
        else if (event.key === Qt.Key_F1)
        {
            var id = webcamGrid.model.get(webcamGrid.currentIndex).id;

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
            webcamGrid.currentIndex = (index != -1 ? index : 0);
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN
            searchDialog.model = playerSources.webcamList.models[feedSource.webcamListIndex].categoryList
            searchDialog.show();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW
            var id = webcamGrid.model.get(webcamGrid.currentIndex).id;
            var index = playerSources.webcamList.models[feedSource.webcamListIndex].model.findById(id);

            if (index != -1)
                playerSources.webcamList.models[feedSource.webcamListIndex].model.get(index).favorite = !playerSources.webcamList.models[feedSource.webcamListIndex].model.get(index).favorite;
        }
        else if (event.key === Qt.Key_F4)
        {
            //BLUE
            if (webcamGrid.model.get(webcamGrid.currentIndex).website !== undefined)
            {
                var website = webcamGrid.model.get(webcamGrid.currentIndex).website;
                var zoom = xscale(webcamGrid.model.get(webcamGrid.currentIndex).zoom);
                stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: website, zoomFactor: zoom}});
            }

            returnSound.play();
        }
        else if (event.key === Qt.Key_F5)
        {
            playerSources.webcamList.reload();
        }
        else if (event.key === Qt.Key_F6)
        {
            var id = webcamGrid.model.get(webcamGrid.currentIndex).id;
            var index = feedSource.feedList.sourceModel.findById(id)

            if (index != -1)
                feedSource.feedList.sourceModel.get(index).offline = !feedSource.feedList.sourceModel.get(index).offline;
        }
        else if (event.key === Qt.Key_R)
        {
            // for testing reset the last checked to now -4 weeks
            dbUtils.setSetting("LastWebcamCheck", settings.hostName, Util.addDays(Date(Date.now()), -28));
        }
        else if (event.key === Qt.Key_I)
        {
            infoDialog.infoText = description.text.replace(/\n/g, "<br>");
            infoDialog.show(webcamGrid);
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
        text: (webcamGrid.currentIndex + 1) + " of " + webcamGrid.model.count;
        horizontalAlignment: Text.AlignRight
    }

    ButtonGrid
    {
        id: webcamGrid
        x: xscale(22)
        y: yscale(55)
        width: parent.width - xscale(44)
        height: yscale(390)
        cellWidth:  width / (root.isPanel ? 4 : 5);
        cellHeight: height / 3;

        Component
        {
            id: webcamDelegate
            Item
            {
                id: root

                property bool selected: GridView.isCurrentItem
                property bool focused: GridView.view.focus

                x: 0
                y: 0
                width: webcamGrid.cellWidth
                height: webcamGrid.cellHeight
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
                    x: xscale(5);
                    y: webcamGrid.cellHeight - yscale(40)
                    width: webcamGrid.cellWidth - xscale(10)
                    visible: (offline || status === "Temporarily Offline" || status === "Not Working")
                    text: offline ? "OFFLINE" : status
                    horizontalAlignment: Text.AlignHCenter;
                    fontPixelSize: xscale(14)
                }
                LabelText
                {
                    x: xscale(20);
                    y: yscale(20)
                    width: webcamGrid.cellWidth - xscale(40)
                    height: webcamGrid.cellHeight - yscale(40)
                    visible: root.selected
                    text: title
                    multiline: true
                    horizontalAlignment: Text.AlignHCenter;
                    fontPixelSize: xscale(14)
                    fontColor: "white"
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
                    x: webcamGrid.cellWidth - xscale(45)
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
        delegate: webcamDelegate
        focus: true

        Keys.onReturnPressed:
        {
            var filter = feedSource.webcamListIndex + "," + feedSource.category + "," + feedSource.sort;

            returnSound.play();

            if (!root.isPanel)
            {
                var item = stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{defaultFeedSource:  "Webcams", defaultFilter:  filter, defaultCurrentFeed: webcamGrid.currentIndex}});
                item.feedChanged.connect(feedChanged);
            }
            else
            {
                internalPlayer.previousFocusItem = webcamGrid;
                feedSelected("Webcams", filter, webcamGrid.currentIndex);
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

        onCurrentIndexChanged: updateWebcamDetails();
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
        id: webcamIcon
        x: parent.width - _xscale(1280 - 950); y: yscale(480); width: _xscale(300); height: _xscale(178)
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
        greenText: "Show (All Webcams)"
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
            webcamGrid.focus = true;

        }
        onCancelled:
        {
            webcamGrid.focus = true;
        }

        onItemSelected:
        {
            if (itemText != "<All Webcams>")
            {
                feedSource.category = ""; // this is needed to get the ExpressionFilter to re-evaluate
                feedSource.category = itemText;
                footer.greenText = "Show (" + itemText + ")"
            }
            else
            {
                feedSource.category = "";
                footer.greenText = "Show (All Webcams)"
            }

            webcamGrid.focus = true;

            updateWebcamDetails();
        }
    }

    PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "WebCam Viewer Options"

        onItemSelected:
        {
            webcamGrid.focus = true;

            if (itemText == "Reload")
            {
                savedID = webcamGrid.model.get(webcamGrid.currentIndex).id;
                playerSources.webcamList.models[feedSource.webcamListIndex].model.reload();
            }
            else if (itemData !== "")
            {
                playerSources.webcamList.models[feedSource.webcamListIndex].model.saveFavorites();
                feedSource.webcamListIndex = itemData;

                showTitle(true, "WebCam Viewer - " + playerSources.webcamList.webcamList.get(feedSource.webcamListIndex).title);

                webcamGrid.currentIndex = 0;
                feedSource.category = "";
                footer.greenText = "Show (All Webcams)"
                updateWebcamDetails();
            }
        }

        onCancelled:
        {
            webcamGrid.focus = true;
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

        menu.append({"menutext": "All", "loaderSource": "WebCamViewer.qml", "menuSource": ""});
        menu.append({"menutext": "Favourite", "loaderSource": "WebCamViewer.qml", "menuSource": ""});
        menu.append({"menutext": "New", "loaderSource": "WebCamViewer.qml", "menuSource": ""});
        menu.append({"menutext": "---", "loaderSource": "WebCamViewer.qml", "loaderSource": "", "menuSource": ""});

        for (var x = 0; x < playerSources.webcamList.models[feedSource.webcamListIndex].categoryList.count; x++)
        {
            menu.append({"menutext": playerSources.webcamList.models[feedSource.webcamListIndex].categoryList.get(x).item, "loaderSource": "WebCamViewer.qml", "menuSource": ""});
        }
    }

    function setFilter(filter)
    {
        var filterList;
        if (filter === "All" || filter === "<All Webcams>")
        {
            filterList = feedSource.webcamListIndex + ",," + feedSource.sort;
            feedChanged("Webcams", filterList, 0);
            feedSource.webcamFilterFavorite ="Any";
        }
        else if (filter === "Favourite")
        {
            filterList = feedSource.webcamListIndex + ",," + feedSource.sort;
            feedChanged("Webcams", filterList, 0);
            feedSource.webcamFilterFavorite ="Yes";
        }
        else if (filter === "New")
        {
            filterList = feedSource.webcamListIndex + ",New," + feedSource.sort;
            feedChanged("Webcams", filterList, 0)
            feedSource.webcamFilterFavorite ="Any";
        }
        else if (filter != "---" )
        {
            filterList = feedSource.webcamListIndex + "," + filter + "," + feedSource.sort;
            feedChanged("Webcams", filterList, 0);
            feedSource.webcamFilterFavorite ="Any";
        }
    }

    function feedChanged(feed, filterList, currentIndex)
    {
        if (feed !== "Webcams")
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
                footer.greenText = "Show (All Webcams)"
            }
            else
            {
                feedSource.category = category;
                footer.greenText = "Show (" + category + ")"
            }
        }

        webcamGrid.currentIndex = currentIndex;
    }

    function getIconURL(iconURL)
    {
        if (iconURL)
        {
            if (iconURL.startsWith("file://") || iconURL.startsWith("http://") || iconURL.startsWith("https://"))
                return iconURL;
            else
            {
                // try to get the icon from the same URL the webcam list was loaded from
                var url = playerSources.webcamList.webcamList.get(feedSource.webcamListIndex).url
                var r = /[^\/]*$/;
                url = url.replace(r, '');
                return url + iconURL;
            }
        }

        return ""
    }

    function updateWebcamDetails()
    {
        if (webcamGrid.currentIndex === -1)
            return;

        title.text = webcamGrid.model.get(webcamGrid.currentIndex).title;

        // description
        if (webcamGrid.model.get(webcamGrid.currentIndex).description !== undefined)
            description.text = webcamGrid.model.get(webcamGrid.currentIndex).description
        else
            description.text = ""

        // category
        category.text = webcamGrid.model.get(webcamGrid.currentIndex).categories;

        // icon
        webcamIcon.source = getIconURL(webcamGrid.model.get(webcamGrid.currentIndex).icon);

        websiteIcon.visible = ((webcamGrid.model.get(webcamGrid.currentIndex).website !== undefined && webcamGrid.model.get(webcamGrid.currentIndex).website !== "" ) ? true : false)
    }


    function checkForUpdates()
    {
        var x;
        var firstAdded = true;
        var firstModified = true;
        var firstOffline = true;
        var firstNotWorking = true;
        var lastCheckSetting = dbUtils.getSetting("LastWebcamCheck", settings.hostName, "");

        // if the setting is blank then must be new setup so don't show the updates dialog
        if (lastCheckSetting === "")
        {
            dbUtils.setSetting("LastWebcamCheck", settings.hostName, Date(Date.now()));
            return;
        }

        var lastChecked = Date.parse(lastCheckSetting);

        updatesModel.clear();

        // add new webcams
        for (x = 0; x < playerSources.webcamList.models[feedSource.webcamListIndex].model.count; x++)
        {
            var webcamAdded = Date.parse(playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).dateadded);

            if (lastChecked < webcamAdded)
            {
                if (firstAdded)
                {
                    updatesModel.append({"heading": "yes", "title": "New WebCams"});
                    firstAdded = false;
                }

                updatesModel.append({"heading": "no", "title": playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).title, "icon": playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).icon});
            }
        }

        // add modified webcams
        for (x = 0; x < playerSources.webcamList.models[feedSource.webcamListIndex].model.count; x++)
        {
            var webcamModified = Date.parse(playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).datemodified);
            var webcamAdded = Date.parse(playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).dateadded);
            var status = playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).status

            if (lastChecked < webcamModified && !(lastChecked < webcamAdded) && status !== "Temporarily Offline" && status !== "Not Working")
            {
                if (firstModified)
                {
                    updatesModel.append({"heading": "yes", "title": "Updated/Fixed WebCams"});
                    firstModified = false;
                }

                updatesModel.append({"heading": "no", "title": playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).title, "icon": playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).icon});
            }
        }

        // add temporarily offline webcams
        for (x = 0; x < playerSources.webcamList.models[feedSource.webcamListIndex].model.count; x++)
        {
            var webcamModified = Date.parse(playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).datemodified);
            var webcamAdded = Date.parse(playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).dateadded);
            var status = playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).status

            if (lastChecked < webcamModified && !(lastChecked < webcamAdded) && status === "Temporarily Offline")
            {
                if (firstOffline)
                {
                    updatesModel.append({"heading": "yes", "title": "Temporarily Offline WebCams"});
                    firstOffline = false;
                }

                updatesModel.append({"heading": "no", "title": playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).title, "icon": playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).icon});
            }
        }

        // add not working webcams
        for (x = 0; x < playerSources.webcamList.models[feedSource.webcamListIndex].model.count; x++)
        {
            var webcamModified = Date.parse(playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).datemodified);
            var webcamAdded = Date.parse(playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).dateadded);
            var status = playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).status

            if (lastChecked < webcamModified && !(lastChecked < webcamAdded) && status === "Not Working")
            {
                if (firstNotWorking)
                {
                    updatesModel.append({"heading": "yes", "title": "Removed WebCams"});
                    firstNotWorking = false;
                }

                updatesModel.append({"heading": "no", "title": playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).title, "icon": playerSources.webcamList.models[feedSource.webcamListIndex].model.get(x).icon});
            }
        }

        // do we need to show any new or updated webcams
        if (updatesModel.count > 0)
        {
            dbUtils.setSetting("LastWebcamCheck", settings.hostName, Date(Date.now()));
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
        title: "WebCams Update"
        width: xscale(700)
        height: yscale(600)

        onAccepted:
        {
            webcamGrid.focus = true;

        }
        onCancelled:
        {
            webcamGrid.focus = true;
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

    function feedLoaded()
    {
        if (savedID !== -1)
        {
            var index = feedSource.findById(savedID);
            webcamGrid.currentIndex = (index !== -1 ? index : 0);
            savedID = -1;
        }
        else
            webcamGrid.currentIndex = 0;

        updateWebcamDetails();
    }

    function handleCommand(command)
    {
        log.debug(Verbose.GUI, "WebCamViewer: handle command - " + command);
        return true;
    }

    function handleSearch(message)
    {
        log.debug(Verbose.GUI, "WebCamViewer: handle seach - " + message);


        return true;
    }
}
