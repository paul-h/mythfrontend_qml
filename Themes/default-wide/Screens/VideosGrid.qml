import QtQuick 2.7
import "../../../Models"
import Base 1.0
import Dialogs 1.0
import SortFilterProxyModel 0.2

BaseScreen
{
    id: root

    defaultFocusItem: videoList

    property string filterTitle
    property string filterType
    property string filterGenres

    Component.onCompleted:
    {
        showTitle(true, "Videos Grid View");
        showTime(false);
        showTicker(false);
    }

    SortFilterProxyModel
    {
        id: videosProxyModel
        sourceModel: VideosModel {}
        filters:
        [
            AllOf
            {
                RegExpFilter
                {
                    roleName: "Title"
                    pattern: filterTitle
                    caseSensitivity: Qt.CaseInsensitive
                }
                RegExpFilter
                {
                    roleName: "ContentType"
                    pattern: filterType
                    caseSensitivity: Qt.CaseInsensitive
                }
                RegExpFilter
                {
                    roleName: "Genre"
                    pattern: filterGenres
                    caseSensitivity: Qt.CaseInsensitive
                }
            }
        ]
        sorters:
        [
            RoleSorter { roleName: "Title" },
            RoleSorter { roleName: "Season" },
            RoleSorter { roleName: "Episode" }
        ]
    }

    BaseBackground
    {
        x: xscale(15); y: yscale(50); width: xscale(1250); height: yscale(655)
    }

    InfoText
    {
        x: xscale(1050); y: yscale(5); width: xscale(200);
        text: (videoList.currentIndex + 1) + " of " + videosProxyModel.count;
        horizontalAlignment: Text.AlignRight
    }

    Component
    {
        id: listRow

        ListItem
        {
            height: yscale(62)

            Image
            {
                id: coverImage
                x: xscale(13); y: yscale(3); height: parent.height - yscale(6); width: height
                source: if (Coverart)
                            settings.masterBackend + "Content/GetImageFile?StorageGroup=Coverart&FileName=" + Coverart
                        else
                            mythUtils.findThemeFile("images/grid_noimage.png")
            }
            ListText
            {
                width: videoList.width - coverImage.width - xscale(20); height: xscale(50)
                x: coverImage.width + xscale(20)
                text: SubTitle ? Title + ": " + SubTitle : Title
            }

            ListText
            {
                x: xscale(1000);
                width: xscale(200); height: xscale(50)
                text:
                {
                    if (ContentType == "TELEVISION")
                        "s:" + Season + " e:" + Episode
                    else
                        ""
                }
            }
        }
    }

    ButtonList
    {
        id: videoList
        x: xscale(25); y: yscale(65); width: xscale(1230); height: yscale(620)

        clip: true
        model: videosProxyModel
        delegate: listRow

        Keys.onPressed:
        {
            if (event.key === Qt.Key_E)
            {
                stack.push({item: Qt.resolvedUrl("VideoMetadataEditor.qml"), properties:{videosModel:  model, currentIndex: currentIndex}});
                event.accepted = true;
            }
            else if (event.key === Qt.Key_M)
            {
                filterDialog.filterTitle = root.filterTitle;
                filterDialog.filterType = root.filterType;
                filterDialog.filterGenres = root.filterGenres;
                filterDialog.show();
                event.accepted = true;
            }
        }

        Keys.onReturnPressed:
        {
            stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{feedList:  model, currentFeed: currentIndex}});
            event.accepted = true;
            returnSound.play();
        }
    }

    VideoFilterDialog
    {
        id: filterDialog

        title: "Filter Videos"
        message: ""

        videosModel: videosProxyModel.sourceModel

        width: 600; height: 500

        onAccepted:
        {
            videoList.focus = true;

            root.filterTitle = filterTitle;
            root.filterType = filterType;
            root.filterGenres = filterGenres;
        }
        onCancelled:
        {
            videoList.focus = true;
        }
    }
}


