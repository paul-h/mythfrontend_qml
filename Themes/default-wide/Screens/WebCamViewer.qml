import QtQuick 2.0
import Base 1.0
import Dialogs 1.0
import Models 1.0
import SortFilterProxyModel 0.2

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

            playerSources.webcamList.source = playerSources.webcamPaths[playerSources.webcamPathIndex] + "/WebCam.xml"
        }
        else if (event.key === Qt.Key_F6)
        {
            playerSources.webcamList.reload();
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
                }
            }
        }

        model: webcamProxyModel
        delegate: webcamDelegate
        focus: true

        Keys.onReturnPressed:
        {
            returnSound.play();
            var url = webcamGrid.model.get(webcamGrid.currentIndex).url;
            var website = webcamGrid.model.get(webcamGrid.currentIndex).website;
            var zoomFactor = xscale(1.0)
            var item = stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{defaultFeedSource:  "Webcams", defaultFeedList:  webcamGrid.model, defaultCurrentFeed: webcamGrid.currentIndex}});
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
        if (filter !== undefined && filter !== filterCategory)
            filterCategory = filter;

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
}
