import QtQuick 2.0
import Base 1.0
import Dialogs 1.0
import "../../../Models"
import SortFilterProxyModel 0.2

BaseScreen
{
    defaultFocusItem: webvideoGrid

    property var webVideoPaths
    property int webVideoPathIndex: 0

    property string filterCategory
    property bool titleSorterActive: true

    Component.onCompleted:
    {
        var path;

        showTitle(true, "Web Video Viewer");
        showTime(false);
        showTicker(false);

        while (stack.busy) {};

        // get list of webcam paths
        webVideoPaths =  settings.webcamPath.split(",")

        path = dbUtils.getSetting("Qml_lastWebvideoPath", settings.hostName, webVideoPaths[0])
        path = path.replace("/WebVideo.xml", "")
        webVideoPathIndex = webVideoPaths.indexOf(path)
        webVideoModel.source = path + "/WebVideo.xml"

        filterCategory = dbUtils.getSetting("Qml_lastWebvideoCategory", settings.hostName)

        if (filterCategory == "<All Web Videos>" || filterCategory == "")
            show.text = "Show (All Web Videos)"
        else
            show.text = "Show (" + filterCategory + ")"

        webvideoProxyModel.sourceModel = webVideoModel
    }

    Component.onDestruction:
    {
        dbUtils.setSetting("Qml_lastWebvideoPath", settings.hostName, webVideoPaths[webVideoPathIndex])
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

    WebVideoModel{ id: webVideoModel }

    SortFilterProxyModel
    {
        id: webvideoProxyModel
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
                sort.text = "Sort (No.)";
            }
            else
            {
                webvideoProxyModel.sorters = titleSorter;
                sort.text = "Sort (Name)";
            }

            titleSorterActive = !titleSorterActive;
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN
            searchDialog.model = webVideoModel.categoryList
            searchDialog.show();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW
        }
        else if (event.key === Qt.Key_F4)
        {
            //BLUE
            if (webvideoGrid.model.get(webvideoGrid.currentIndex).website != undefined)
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
            webVideoPathIndex++;

            if (webVideoPathIndex >= webVideoPaths.length)
                webVideoPathIndex = 0;

            filterCategory = "";
            show.text = "Show (All Web Videos)"

            titleSorterActive = true
            webvideoProxyModel.sorters = titleSorter;
            sort.text = "Sort (Name)";

            webVideoModel.source = webVideoPaths[webVideoPathIndex] + "/WebVideo.xml"
        }
    }

    BaseBackground
    {
        id: listBackground
        x: xscale(10); y: yscale(50); width: parent.width - x - xscale(10); height: yscale(400)
    }

    BaseBackground { x: xscale(10); y: yscale(465); width: parent.width - xscale(20); height: yscale(210) }

    InfoText
    {
        x: xscale(1050); y: yscale(5); width: xscale(200);
        text: (webvideoGrid.currentIndex + 1) + " of " + webvideoGrid.model.count;
        horizontalAlignment: Text.AlignRight
    }

    GridView
    {
        id: webvideoGrid
        x: xscale(22)
        y: yscale(60)
        width: xscale(1280) - xscale(44)
        height: yscale(390)
        cellWidth: xscale(206)
        cellHeight: yscale(130)
        clip: true

        Component
        {
            id: webvideoDelegate
            Image
            {
                id: wrapper
                //visible: opened
                x: xscale(5)
                y: yscale(5)
                opacity: 1.0
                asynchronous: true
                width: webvideoGrid.cellWidth - 10; height: webvideoGrid.cellHeight - 10
                source: getIconURL(icon);
            }
        }

        highlight: Rectangle { z: 99; color: "red"; opacity: 0.4; radius: 5 }
        model: webvideoProxyModel
        delegate: webvideoDelegate
        focus: true

        Keys.onReturnPressed:
        {
            returnSound.play();
            stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{feedList:  webvideoGrid.model, currentFeed: webvideoGrid.currentIndex}});

            event.accepted = true;
        }

        Keys.onPressed:
        {
            if (event.key === Qt.Key_M)
            {
                searchDialog.model = webVideoModel.categoryList
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
        width: xscale(900); height: yscale(65)
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

    Image
    {
        x: xscale(30); y: yscale(682); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/red_bullet.png")
    }

    InfoText
    {
        id: sort
        x: xscale(65); y: yscale(682); width: xscale(285); height: yscale(32)
        text: "Sort (Name)"
    }

    Image
    {
        x: xscale(350); y: yscale(682); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/green_bullet.png")
    }

    InfoText
    {
        id: show
        x: xscale(385); y: yscale(682); width: xscale(285); height: yscale(32)
        text: "Show (All Web Videos)"
    }

    Image
    {
        x: xscale(670); y: yscale(682); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/yellow_bullet.png")
    }

    InfoText
    {
        x: xscale(705); y: yscale(682); width: xscale(285); height: yscale(32)
        text: ""
    }

    Image
    {
        x: xscale(990); y: yscale(682); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/blue_bullet.png")
    }

    InfoText
    {
        x: xscale(1025); y: yscale(682); width: xscale(285); height: yscale(32)
        text: "Go To Website"
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
                show.text = "Show (" + itemText + ")"
            }
            else
            {
                filterCategory = "";
                show.text = "Show (All Web Videos)"

            }

            webvideoGrid.focus = true;

            updateWebvideoDetails()
        }
    }

    function getIconURL(iconURL)
    {
        if (iconURL)
        {
            if (iconURL.startsWith("file://") || iconURL.startsWith("http://") || iconURL.startsWith("https://"))
                return iconURL;
            else
                return webVideoPaths[webVideoPathIndex] + "/" + iconURL;
        }

        return ""
    }

    function updateWebvideoDetails()
    {
        title.text = webvideoGrid.model.get(webvideoGrid.currentIndex).title;

        // description
        if (webvideoGrid.model.get(webvideoGrid.currentIndex).description != undefined)
            description.text = webvideoGrid.model.get(webvideoGrid.currentIndex).description
        else
            description.text = ""

        // category
        category.text = webvideoGrid.model.get(webvideoGrid.currentIndex).categories;

        // icon
        webvideoIcon.source = getIconURL(webvideoGrid.model.get(webvideoGrid.currentIndex).icon);

        websiteIcon.visible = ((webvideoGrid.model.get(webvideoGrid.currentIndex).website != undefined && webvideoGrid.model.get(webvideoGrid.currentIndex).website != "" ) ? true : false)
    }
}
