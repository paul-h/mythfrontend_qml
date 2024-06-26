import QtQuick 2.7
import Models 1.0
import Base 1.0
import Dialogs 1.0
import SortFilterProxyModel 0.2
import mythqml.net 1.0

BaseScreen
{
    id: root

    defaultFocusItem: videoList

    property string filterTitle
    property string filterType
    property string filterGenres

    Component.onCompleted:
    {
        showTitle(true, "MythTV Videos Viewer");
        setHelp("https://mythqml.net/help/videos_mythtv.php#top");
        showTime(false);
        showTicker(false);
    }

    SortFilterProxyModel
    {
        id: videosProxyModel
        sourceModel: playerSources.videosList.model
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
        x: xscale(15); y: yscale(50); width: parent.width - xscale(30); height: yscale(655)
    }

    InfoText
    {
        x: parent.width - xscale(230); y: yscale(5); width: xscale(200);
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
                width: videoList.width - coverImage.width - xscale(20); height: parent.height
                x: coverImage.width + xscale(20)
                text: SubTitle ? Title + ": " + SubTitle : Title
            }

            ListText
            {
                x: xscale(1000);
                width: xscale(200); height: parent.height
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
        x: xscale(25); y: yscale(65); width: parent.width - xscale(50); height: yscale(620)

        clip: true
        model: videosProxyModel
        delegate: listRow

        Keys.onPressed:
        {
            if (event.key === Qt.Key_E)
            {
                stack.push({item: Qt.resolvedUrl("MythVideoMetadataEditor.qml"), properties:{videosModel:  model, currentIndex: currentIndex}});
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
            var filterList = filterTitle + "," + filterType + "," + filterGenres;
            var item = stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{defaultFeedSource:  "Videos", defaultFilter:  filterList, defaultCurrentFeed: currentIndex}});
            item.feedChanged.connect(feedChanged);
            event.accepted = true;
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

    function feedChanged(feedSource, filter, index)
    {
        log.debug(Verbose.GENERAL, "VideosGrid: feedChanged - filter: " + filter + ", index: " + index);

        if (feedSource !== "Videos")
            return;

        var list = filter.split(",");

        if (list.length === 3)
        {
            filterTitle = list[0];
            filterType = list[1];
            filterGenres = list[2];
        }

        videoList.currentIndex = index;
    }
}
