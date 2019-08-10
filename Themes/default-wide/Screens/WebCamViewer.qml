import QtQuick 2.0
import Base 1.0
import Dialogs 1.0
import Models 1.0
import SortFilterProxyModel 0.2
import "../../../Util.js" as Util

BaseScreen
{
    defaultFocusItem: webcamGrid

    property string filterCategory
    property bool titleSorterActive: true

    Component.onCompleted:
    {
        showTitle(true, "WebCam Viewer");
        showTime(false);
        showTicker(false);

        while (stack.busy) {};

        filterCategory = dbUtils.getSetting("Qml_lastWebcamCategory", settings.hostName)

        if (filterCategory == "<All Webcams>" || filterCategory == "")
            footer.greenText = "Show (All Webcams)"
        else
            footer.greenText = "Show (" + filterCategory + ")"

        updateWebcamDetails();

        delay(1500, checkForUpdates);
    }

    Component.onDestruction:
    {
        dbUtils.setSetting("Qml_lastWebcamPath", settings.hostName, playerSources.webcamPaths[playerSources.webcamPathIndex])
        dbUtils.setSetting("Qml_lastWebcamCategory", settings.hostName, filterCategory)
    }

    property list<QtObject> titleSorter:
    [
        RoleSorter { roleName: "title"; ascendingOrder: true}
    ]

    property list<QtObject> idSorter:
    [
        RoleSorter { roleName: "id" }
    ]

    SortFilterProxyModel
    {
        id: webcamProxyModel
        sourceModel: playerSources.webcamList
        filters:
        [
            AllOf
            {
                RegExpFilter
                {
                    roleName: "categories"
                    pattern: filterCategory
                    caseSensitivity: Qt.CaseInsensitive
                }

                AnyOf
                {
                    ValueFilter
                    {
                        roleName: "status"
                        value: "Working"
                    }

                    ValueFilter
                    {
                        roleName: "status"
                        value: "Temporarily Offline"
                    }
                }
            }
        ]
        sorters: titleSorter
    }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_M)
        {
        }
        else if (event.key === Qt.Key_F1)
        {
            // RED
            if (titleSorterActive)
            {
                webcamProxyModel.sorters = idSorter;
                footer.redText = "Sort (No.)";
            }
            else
            {
                webcamProxyModel.sorters = titleSorter;
                footer.redText = "Sort (Name)";
            }

            titleSorterActive = !titleSorterActive;
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN
            searchDialog.model = playerSources.webcamList.categoryList
            searchDialog.show();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW
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

            event.accepted = true;
            returnSound.play();
        }
        else if (event.key === Qt.Key_F5)
        {
            playerSources.webcamPathIndex++;

            if (playerSources.webcamPathIndex >= playerSources.webcamPaths.length)
               playerSources.webcamPathIndex = 0;

            filterCategory = "";
            footer.redText = "Show (All Webcams)"

            titleSorterActive = true
            webcamProxyModel.sorters = titleSorter;
            footer.redText = "Sort (Name)";

            playerSources.webcamList.source = playerSources.webcamPaths[playerSources.webcamPathIndex] + "/webcams.xml"
        }
        else if (event.key === Qt.Key_F6)
        {
            playerSources.webcamList.reload();
        }
        else if (event.key === Qt.Key_R)
        {
            // for testing reset the last checked to now -4 weeks
            dbUtils.setSetting("Qml_lastWebcamCheck", settings.hostName, Util.addDays(Date(Date.now()), -28));
        }
    }

    BaseBackground
    {
        id: listBackground
        x: xscale(10); y: yscale(45); width: parent.width - x - xscale(10); height: yscale(410)
    }

    BaseBackground { x: xscale(10); y: yscale(465); width: parent.width - xscale(20); height: yscale(210) }

    InfoText
    {
        x: xscale(1050); y: yscale(5); width: xscale(200);
        text: (webcamGrid.currentIndex + 1) + " of " + webcamGrid.model.count;
        horizontalAlignment: Text.AlignRight
    }

    ButtonGrid
    {
        id: webcamGrid
        x: xscale(22)
        y: yscale(55)
        width: xscale(1280) - xscale(44)
        height: yscale(390)
        cellWidth: xscale(206)
        cellHeight: yscale(130)

        Component
        {
            id: webcamDelegate
            Item
            {
                x: 0;
                y: 0;
                width: webcamGrid.cellWidth;
                height: webcamGrid.cellHeight;
                Image
                {
                    opacity: 0.80
                    asynchronous: true
                    anchors.fill: parent
                    anchors.margins: xscale(5)
                    source: getIconURL(icon);
                    onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/webcam_noimage.png");
                }
                LabelText
                {
                    x: 5;
                    y: webcamGrid.cellHeight - yscale(40)
                    width: webcamGrid.cellWidth - xscale(10)
                    visible: (status === "Temporarily Offline" || status === "Not Working")
                    text: status
                    horizontalAlignment: Text.AlignHCenter;
                    fontPixelSize: xscale(14)
                }
            }
        }

        model: webcamProxyModel
        delegate: webcamDelegate
        focus: true

        Keys.onReturnPressed:
        {
            returnSound.play();
            var item = stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{defaultFeedSource:  "Webcams", defaultFilter:  filterCategory, defaultCurrentFeed: webcamGrid.currentIndex}});
            item.feedChanged.connect(feedChanged);
            event.accepted = true;
        }

        Keys.onPressed:
        {
            if (event.key === Qt.Key_M)
            {
                searchDialog.model = playerSources.webcamList.categoryList
                searchDialog.show();
            }
            else
            {
                event.accepted = false;
            }
        }

        onCurrentIndexChanged: updateWebcamDetails();
    }

    TitleText
    {
        id: title
        x: xscale(30); y: yscale(470)
        width: xscale(900); height: yscale(75)
        verticalAlignment: Text.AlignTop
        multiline: true
    }

    Image
    {
        id: webcamIcon
        x: xscale(950); y: yscale(480); width: xscale(300); height: yscale(178)
        asynchronous: true
        onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/webcam_noimage.png")
    }

    InfoText
    {
        id: description
        x: xscale(30); y: yscale(540)
        width: xscale(900); height: yscale(100)
        verticalAlignment: Text.AlignTop
        multiline: true
    }

    InfoText
    {
        id: category
        x: xscale(30); y: yscale(630); width: xscale(900)
        fontColor: "grey"
    }

    Image
    {
        id: websiteIcon
        x: xscale(900); y: yscale(630); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/website.png")
    }

    Footer
    {
        id: footer
        redText: "Sort (Name)"
        greenText: "Show (All Webcams)"
        yellowText: ""
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
                filterCategory = itemText;
                footer.greenText = "Show (" + itemText + ")"
            }
            else
            {
                filterCategory = "";
                footer.greenText = "Show (All Webcams)"

            }

            webcamGrid.focus = true;

            updateWebcamDetails()
        }
    }

    function feedChanged(filter, index)
    {
        if (filter !== filterCategory)
        {
            if (filter === "")
            {
                filterCategory = filter;
                footer.greenText = "Show (All Webcams)"
            }
            else
            {
                filterCategory = filter;
                footer.greenText = "Show (" + filter + ")"
            }
        }

        webcamGrid.currentIndex = index;
    }

    function getIconURL(iconURL)
    {
        if (iconURL)
        {
            if (iconURL.startsWith("file://") || iconURL.startsWith("http://") || iconURL.startsWith("https://"))
                return iconURL;
            else
                return playerSources.webcamPaths[playerSources.webcamPathIndex] + "/" + iconURL;
        }

        return ""
    }

    function updateWebcamDetails()
    {
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
        var defaultDate = Date(Date.now());
        var lastChecked = Date.parse(dbUtils.getSetting("Qml_lastWebcamCheck", settings.hostName, defaultDate));
        var x;
        var firstAdded = true;
        var firstModified = true;
        var firstOffline = true;
        var firstNotWorking = true;

        dbUtils.setSetting("Qml_lastWebcamCheck", settings.hostName, Date(Date.now()));

        updatesModel.clear();

        // add new webcams
        for (x = 0; x < playerSources.webcamList.count; x++)
        {
            var webcamAdded = Date.parse(playerSources.webcamList.get(x).dateadded);

            if (lastChecked < webcamAdded)
            {
                if (firstAdded)
                {
                    updatesModel.append({"heading": "yes", "title": "New WebCams"});
                    firstAdded = false;
                }

                updatesModel.append({"heading": "no", "title": playerSources.webcamList.get(x).title, "icon": playerSources.webcamList.get(x).icon});
            }
        }

        // add modified webcams
        for (x = 0; x < playerSources.webcamList.count; x++)
        {
            var webcamModified = Date.parse(playerSources.webcamList.get(x).datemodified);
            var webcamAdded = Date.parse(playerSources.webcamList.get(x).dateadded);
            var status = playerSources.webcamList.get(x).status

            if (lastChecked < webcamModified && !(lastChecked < webcamAdded) && status !== "Temporarily Offline" && status !== "Not Working")
            {
                if (firstModified)
                {
                    updatesModel.append({"heading": "yes", "title": "Updated/Fixed WebCams"});
                    firstModified = false;
                }

                updatesModel.append({"heading": "no", "title": playerSources.webcamList.get(x).title, "icon": playerSources.webcamList.get(x).icon});
            }
        }

        // add temporarily offline webcams
        for (x = 0; x < playerSources.webcamList.count; x++)
        {
            var webcamModified = Date.parse(playerSources.webcamList.get(x).datemodified);
            var webcamAdded = Date.parse(playerSources.webcamList.get(x).dateadded);
            var status = playerSources.webcamList.get(x).status

            if (lastChecked < webcamModified && !(lastChecked < webcamAdded) && status === "Temporarily Offline")
            {
                if (firstOffline)
                {
                    updatesModel.append({"heading": "yes", "title": "Temporarily Offline WebCams"});
                    firstOffline = false;
                }

                updatesModel.append({"heading": "no", "title": playerSources.webcamList.get(x).title, "icon": playerSources.webcamList.get(x).icon});
            }
        }

        // add not working webcams
        for (x = 0; x < playerSources.webcamList.count; x++)
        {
            var webcamModified = Date.parse(playerSources.webcamList.get(x).datemodified);
            var webcamAdded = Date.parse(playerSources.webcamList.get(x).dateadded);
            var status = playerSources.webcamList.get(x).status

            if (lastChecked < webcamModified && !(lastChecked < webcamAdded) && status === "Not Working")
            {
                if (firstNotWorking)
                {
                    updatesModel.append({"heading": "yes", "title": "Removed WebCams"});
                    firstNotWorking = false;
                }

                updatesModel.append({"heading": "no", "title": playerSources.webcamList.get(x).title, "icon": playerSources.webcamList.get(x).icon});
            }
        }

        // do we need to show any new or updated webcams
        if (updatesModel.count > 0)
        {
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
                    onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/webcam_noimage.png")
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
}
