import QtQuick 2.0
import Base 1.0
import Dialogs 1.0
import Models 1.0
import SortFilterProxyModel 0.2

BaseScreen
{
    defaultFocusItem: webvideoGrid

    property string filterCategory
    property bool titleSorterActive: true

    Component.onCompleted:
    {
        var path;

        showTitle(true, "Web Video Viewer");
        showTime(false);
        showTicker(false);

        while (stack.busy) {};

        filterCategory = dbUtils.getSetting("Qml_lastWebvideoCategory", settings.hostName)

        if (filterCategory == "<All Web Videos>" || filterCategory == "")
            footer.greenText = "Show (All Web Videos)"
        else
            footer.greenText = "Show (" + filterCategory + ")"

        updateWebvideoDetails();
    }

    Component.onDestruction:
    {
        dbUtils.setSetting("Qml_lastWebvideoPath", settings.hostName, playerSources.webvideoPaths[playerSources.webvideoPathIndex])
        dbUtils.setSetting("Qml_lastWebvideoCategory", settings.hostName, filterCategory)
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
        id: webvideoProxyModel
        sourceModel: playerSources.webvideoList
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
                webvideoProxyModel.sorters = idSorter;
                footer.redText = "Sort (No.)";
            }
            else
            {
                webvideoProxyModel.sorters = titleSorter;
                footer.redText = "Sort (Name)";
            }

            titleSorterActive = !titleSorterActive;
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN
            searchDialog.model = playerSources.webvideoList.categoryList
            searchDialog.show();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW
        }
        else if (event.key === Qt.Key_F4)
        {
            //BLUE
            if (webvideoGrid.model.get(webvideoGrid.currentIndex).website !== undefined)
            {
                var website = webvideoGrid.model.get(webvideoGrid.currentIndex).website;
                var zoom = xscale(webvideoGrid.model.get(webvideoGrid.currentIndex).zoom);
                stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: website, zoomFactor: zoom}});
            }

            event.accepted = true;
            returnSound.play();
        }
        else if (event.key === Qt.Key_F5)
        {
            playerSources.webVideoPathIndex++;

            if (playerSources.webVideoPathIndex >= playerSources.webVideoPaths.length)
                playerSources.webVideoPathIndex = 0;

            filterCategory = "";
            footer.greenText = "Show (All Web Videos)"

            titleSorterActive = true
            webvideoProxyModel.sorters = titleSorter;
            footer.redText = "Sort (Name)";

            playerSources.webvideoList.source = playerSources.webVideoPaths[playerSources.webVideoPathIndex] + "/WebVideo.xml"
        }
        else if (event.key === Qt.Key_F6)
        {
            playerSources.webvideoList.reload();
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
        text: (webvideoGrid.currentIndex + 1) + " of " + webvideoGrid.model.count;
        horizontalAlignment: Text.AlignRight
    }

    ButtonGrid
    {
        id: webvideoGrid
        x: xscale(22)
        y: yscale(55)
        width: xscale(1280) - xscale(44)
        height: yscale(390)
        cellWidth: xscale(206)
        cellHeight: yscale(130)
        clip: true

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
                }
            }
        }

        model: webvideoProxyModel
        delegate: webvideoDelegate
        focus: true

        Keys.onReturnPressed:
        {
            returnSound.play();
            var item = stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{defaultFeedSource:  "Web Videos", defaultFilter:  filterCategory, defaultCurrentFeed: webvideoGrid.currentIndex}});
            item.feedChanged.connect(feedChanged);
            event.accepted = true;
        }

        Keys.onPressed:
        {
            if (event.key === Qt.Key_M)
            {
                searchDialog.model = playerSources.webvideoList.categoryList
                searchDialog.show();
            }
            else
            {
                event.accepted = false;
            }
        }

        onCurrentIndexChanged: updateWebvideoDetails();
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
        id: webvideoIcon
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
        greenText: "Show (All Web Videos)"
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
                filterCategory = itemText;
                footer.greenText = "Show (" + itemText + ")"
            }
            else
            {
                filterCategory = "";
                footer.greenText = "Show (All Web Videos)"

            }

            webvideoGrid.focus = true;

            updateWebvideoDetails()
        }
    }

    function feedChanged(filter, index)
    {
        console.log("WebVideoViewer feedChange - filter: " + filter + ", index: " + index);
        if (filter !== filterCategory)
        {
            if (filter === "")
            {
                filterCategory = filter;
                footer.greenText = "Show (All Web Videos)"
            }
            else
            {
                filterCategory = filter;
                footer.greenText = "Show (" + filter + ")"
            }
        }

        webvideoGrid.currentIndex = index;
    }

    function getIconURL(iconURL)
    {
        if (iconURL)
        {
            if (iconURL.startsWith("file://") || iconURL.startsWith("http://") || iconURL.startsWith("https://"))
                return iconURL;
            else
                return playerSources.webVideoPaths[playerSources.webVideoPathIndex] + "/" + iconURL;
        }

        return ""
    }

    function updateWebvideoDetails()
    {
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
}
