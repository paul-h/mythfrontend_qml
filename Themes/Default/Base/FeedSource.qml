import QtQuick 2.0
import SortFilterProxyModel 0.2
import mythqml.net 1.0

Item
{
    id: root

    property string feedName:  "Live TV"
    property string currentFilter: ""
    property int currentFeed: 0
    property int feedCount: feedProxyModel.count
    property alias feedList: feedProxyModel
    property alias filters: feedProxyModel.filters
    property alias sorters: feedProxyModel.sorters

    property list<QtObject> sourceIDFilter:
    [
        ValueFilter
        {
            id: sourceFilter
            roleName: "SourceId"
        }
    ]

    property list<QtObject> categoryFilter:
    [
        RegExpFilter
        {
            id: categoryFilter
            roleName: "categories"
            pattern: ""
            caseSensitivity: Qt.CaseInsensitive
        }
    ]

    property list<QtObject> enabledFilter:
    [
        ValueFilter
        {
            roleName: "monenabled"
            value: true
        }
    ]

    property list<QtObject> videoFilter:
    [
        AllOf
        {
            RegExpFilter
            {
                id: videoTitle
                roleName: "Title"
                pattern: ""
                caseSensitivity: Qt.CaseInsensitive
            }
            RegExpFilter
            {
                id: videoContentType
                roleName: "ContentType"
                pattern: ""
                caseSensitivity: Qt.CaseInsensitive
            }
            RegExpFilter
            {
                id: videoGenre
                roleName: "Genre"
                pattern: ""
                caseSensitivity: Qt.CaseInsensitive
            }
        }
    ]

    property list<QtObject> chanNumSorter:
    [
        RoleSorter { roleName: "ChanNum"; ascendingOrder: true}
    ]

    property list<QtObject> nameSorter:
    [
        RoleSorter { roleName: "Name"; ascendingOrder: true}
    ]

    property list<QtObject> titleSorter:
    [
        RoleSorter { roleName: "title"; ascendingOrder: true}
    ]

    property list<QtObject> videoSorter:
    [
        RoleSorter { roleName: "Title" },
        RoleSorter { roleName: "Season" },
        RoleSorter { roleName: "Episode" }
    ]

    SortFilterProxyModel
    {
        id: feedProxyModel
    }

    function switchToFeed(feed, filter, currFeed)
    {
        if (feed === "Live TV")
            switchToLiveTV(filter, currFeed);
        else if (feed === "Webcams")
            switchToWebcams(filter, currFeed);
        else if (feed === "Web Videos")
            switchToWebvideos(filter, currFeed);
        else if (feed === "Videos")
            switchToVideos(filter, currFeed);
        else if (feed === "Recordings")
            switchToRecordings(filter, currFeed);
        else if (feed === "ZoneMinder Cameras")
            switchToZMCameras(filter, currFeed);
        else if (feed === "Adhoc")
            switchToAdhoc(filter, currFeed);
        else if (feed === "Advent Calendar")
            switchToAdventCalendar(filter, currFeed);
        else
            log.error(Verbose.PLAYBACK, "FeedSource: switchToFeed Error - unknown feed: " + feed);
    }

    function switchToLiveTV(sourceId, currFeed)
    {
        log.debug(Verbose.PLAYBACK, "FeedSource: switchToLiveTV - sourceId: " + sourceId + ", currFeed: " + currFeed )

        feedName = "Live TV";
        currentFeed = currFeed;

        if (sourceId == -1) // Don't change == to ===
        {
            sourceFilter.enabled = false;
            currentFilter = "-1";
        }
        else
        {
            sourceFilter.value = sourceId;
            sourceFilter.enabled = true;
            currentFilter = sourceFilter.value;
        }

        filters = sourceIDFilter;
        sorters = chanNumSorter;
        feedList.sourceModel = playerSources.channelList;
    }

    function switchToRecordings(category, currFeed)
    {
        // FIXME:
//        feedName = "Web Videos";
//        currentFeed = currFeed;
//        currentFilter = category;
//        categoryFilter.pattern = category;
//        filters = categoryFilter;
//        sorters = titleSorter;
//        feedList.sourceModel = playerSources.webvideoList;
    }

    function switchToWebcams(category, currFeed)
    {
        feedName = "Webcams";
        currentFeed = currFeed;
        categoryFilter.pattern = category;
        currentFilter = category;
        filters = categoryFilter;
        sorters = titleSorter;
        feedList.sourceModel = playerSources.webcamList;
    }

    function switchToWebvideos(category, currFeed)
    {
        feedName = "Web Videos";
        currentFeed = currFeed;
        currentFilter = category;
        categoryFilter.pattern = category;
        filters = categoryFilter;
        sorters = titleSorter;
        feedList.sourceModel = playerSources.webvideoList;
    }

    function switchToZMCameras(category, currFeed)
    {
        feedName = "ZoneMinder Cameras";
        currentFeed = currFeed;
        currentFilter = category;
        filters = enabledFilter;
        sorters = [];
        feedList.sourceModel = playerSources.zmCameraList;
    }

    function switchToVideos(filterList, currFeed)
    {
        feedName = "Videos";
        currentFeed = currFeed;
        currentFilter = filterList;

        var list = filterList.split(",");

        if (list.length === 3)
        {
            videoTitle.pattern = list[0];
            videoContentType.pattern = list[1];
            videoGenre.pattern = list[2];
        }

        filters = videoFilter;
        sorters = videoSorter;
        feedList.sourceModel = playerSources.videoList;
    }

    function switchToAdventCalendar(day, currFeed)
    {
        feedName = "Advent Calendar";
        currentFeed = currFeed;
        currentFilter = day;
        filters = [];
        sorters = [];
        feedList.sourceModel = playerSources.adhocList;;
    }

    function switchToAdhoc(filter, currFeed)
    {
        feedName = "Adhoc";
        currentFeed = currFeed;
        currentFilter = filter;
        filters = [];
        sorters = [];
        feedList.sourceModel = playerSources.adhocList;
    }
}
