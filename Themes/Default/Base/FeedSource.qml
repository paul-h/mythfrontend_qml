import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import SortFilterProxyModel 0.2
import mythqml.net 1.0
import Models 1.0

Item
{
    id: root

    property string feedName:  ""
    property string currentFilter: ""
    property int currentFeed: -1
    property int feedCount: feedProxyModel.count
    property alias feedList: feedProxyModel
    property alias filters: feedProxyModel.filters
    property alias sorters: feedProxyModel.sorters

    // Live TV
    property alias sourceId: channelsModel.sourceId
    property alias channelGroupId: channelsModel.channelGroupId

    // Webcams/WebVideos
    property int webcamListIndex: 0
    property int webvideoListIndex: 0
    property string category: ""
    property string sort: "title"
    property string  webcamFilterFavorite: "Any"
    property string  webvideoFilterFavorite: "Any"

    // IPTV
    property string country: ""
    property string language: ""
    property string genre: ""

    // private
    property bool _switchingFeed: false

    signal feedModelLoaded()
    signal feedModelLoading()
    signal feedModelError()

    onCategoryChanged: { categoryFilter.category = category; vidCategoryFilter.category = category;}
    onGenreChanged: iptvGenre.pattern = genre
    onCountryChanged: iptvCountry.pattern = country
    onLanguageChanged: iptvLanguage.pattern = language

    onWebcamListIndexChanged:
    {
        if (!_switchingFeed)
        {
            var filter = webcamListIndex + "," + category + "," + sort;
            switchToFeed(feedName, filter, currentFeed);
        }
    }

    onSortChanged:
    {
        if (!_switchingFeed)
        {
            var filter = "";

            if (feedName === "Live TV")
                switchToLiveTV(filter, currFeed);
            else if (feedName === "Webcams")
                filter = webcamListIndex + "," + category + "," + sort;
            else if (feedName === "Web Videos")
                filter = webvideoListIndex + "," + category + "," + sort;
            else if (feedName === "Videos")
                filter = ""
            else if (feedName === "Recordings")
                filter = ""
            else if (feedName === "ZoneMinder Cameras")
                filter = ""
            else if (feedName === "Adhoc")
                filter = ""
            else if (feedName === "Advent Calendar")
                filter = ""
            else if (feedName === "IPTV")
                filter = sort + "," + genre + "," + country + "," + language;
            else
                log.error(Verbose.PLAYBACK, "FeedSource: onSortChanged Error - unknown feed: " + feedName);

            switchToFeed(feedName, filter, currentFeed);
        }
    }

    property list<QtObject> channelFilter:
    [
        AllOf
        {
            ValueFilter
            {
                id: sourceFilter
                roleName: "SourceId"
                enabled: (value != "-1")
            }

            ValueFilter
            {
                id: channelGroupFilter
                roleName: "ChannelGroups"
            }
        }
    ]

    property list<QtObject> webcamFilter:
    [
        AllOf
        {
            ExpressionFilter
            {
                id: categoryFilter
                property string category: ""
                expression:
                {
                    var catList = categories.split(",");
                    for (var x = 0; x < catList.length; x++)
                    {
                        if (catList[x].trim() == root.category)
                            return true;
                    }

                    return false;
                }
                enabled: root.category !== ""
            }

            ValueFilter
            {
                enabled: (webvideoFilterFavorite !== "Any")
                roleName: "favorite"
                value: (webvideoFilterFavorite === "Yes")
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

    property list<QtObject> webvideoFilter:
    [
        AllOf
        {
            ExpressionFilter
            {
                id: vidCategoryFilter
                property string category: ""
                expression:
                {
                    var catList = categories.split(",");
                    for (var x = 0; x < catList.length; x++)
                    {
                        if (catList[x].trim() == root.category)
                            return true;
                    }

                    return false;
                }
                enabled: root.category !== ""
            }

            ValueFilter
            {
                enabled: (webvideoFilterFavorite !== "Any")
                roleName: "favorite"
                value: (webvideoFilterFavorite === "Yes")
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

    property list<QtObject> iptvFilter:
    [
        AllOf
        {
            RegExpFilter
            {
                id: iptvCountry
                roleName: "countries"
                pattern: ""
                caseSensitivity: Qt.CaseInsensitive
            }
            RegExpFilter
            {
                id: iptvLanguage
                roleName: "languages"
                pattern: ""
                caseSensitivity: Qt.CaseInsensitive
            }
            RegExpFilter
            {
                id: iptvGenre
                roleName: "genre"
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

    property list<QtObject> idSorter:
    [
        RoleSorter { roleName: "id"; ascendingOrder: true}
    ]

    property list<QtObject> countrySorter:
    [
        RoleSorter { roleName: "countries"; ascendingOrder: true},
        RoleSorter { roleName: "title" }
    ]

    property list<QtObject> languageSorter:
    [
        RoleSorter { roleName: "languages"; ascendingOrder: true},
        RoleSorter { roleName: "title" }
    ]

    property list<QtObject> genreSorter:
    [
        RoleSorter { roleName: "genre"; ascendingOrder: true},
        RoleSorter { roleName: "title" }
    ]

    ChannelsModel
    {
        id: channelsModel
        groupByCallsign: true;
    }

    SortFilterProxyModel
    {
        id: feedProxyModel
    }

    function switchToFeed(feed, filter, currFeed)
    {
        _switchingFeed = true;

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
        else if (feed === "IPTV")
            switchToIPTV(filter, currFeed);
        else
            log.error(Verbose.PLAYBACK, "FeedSource: switchToFeed Error - unknown feed: " + feed);

        _switchingFeed = false;
    }

    function switchToLiveTV(filterList, currFeed)
    {
        log.debug(Verbose.PLAYBACK, "FeedSource: switchToLiveTV - filterList: " + filterList + ", currFeed: " + currFeed )

        feedName = "Live TV";
        currentFeed = currFeed;
        currentFilter = filterList;

        var list = filterList.split(",");
        var channelGroupId = -1;
        var sourceId = -1;

        if (list.length === 2)
        {
            sourceId = list[0];
            channelGroupId = list[1];
        }

        channelsModel.sourceId = parseInt(sourceId, 10);
        channelsModel.channelGroupId = parseInt(channelGroupId, 10);

        filters = [];
        sorters = [];

        if (feedList.sourceModel !== channelsModel)
        {
            if (feedList.sourceModel && feedList.sourceModel.loadingStatus)
                feedList.sourceModel.loadingStatus.disconnect(handleModelStatusChange);

            feedList.sourceModel = channelsModel;
            channelsModel.loadingStatus.connect(handleModelStatusChange);
        }
    }

    function switchToRecordings(category, currFeed)
    {
        // FIXME:
    }

    function switchToWebcams(filterList, currFeed)
    {
        feedName = "Webcams";
        currentFeed = currFeed;
        currentFilter = filterList;

        var list = filterList.split(",");
        var index = 0;
        var _category = "";
        var _sort = "title";

        if (list.length === 3)
        {
            index = list[0];
            _category = list[1];
            _sort = list[2];
        }

        webcamListIndex = index;
        category = _category;
        filters = webcamFilter;
        sorters = _sort === "title" ? titleSorter : [];

        if (feedList.sourceModel !== playerSources.webcamList.models[webcamListIndex].model)
        {
            if (feedList.sourceModel)
                feedList.sourceModel.loadingStatus.disconnect(handleModelStatusChange);

            feedList.sourceModel = playerSources.webcamList.models[webcamListIndex].model;

            if (feedList.sourceModel.status === XmlListModel.Ready)
                handleModelStatusChange(XmlListModel.Ready);
            else
                feedList.sourceModel.loadingStatus.connect(handleModelStatusChange);
        }
    }

    function switchToWebvideos(filterList, currFeed)
    {
        feedName = "Web Videos";
        currentFeed = currFeed;
        currentFilter = filterList;

        var list = filterList.split(",");
        var index = 0;
        var _category = "";
        var _sort = "title";

        if (list.length === 3)
        {
            index = list[0];
            _category = list[1];
            _sort = list[2];
        }

        webvideoListIndex = index;
        category = _category;
        filters = webvideoFilter;
        sorters = _sort === "title" ? titleSorter : [];

        if (feedList.sourceModel !== playerSources.webvideoList.models[webvideoListIndex].model)
        {
            if (feedList.sourceModel)
                feedList.sourceModel.loadingStatus.disconnect(handleModelStatusChange);

            feedList.sourceModel = playerSources.webvideoList.models[webvideoListIndex].model;

            if (feedList.sourceModel.status === XmlListModel.Ready)
                handleModelStatusChange(XmlListModel.Ready);
            else
                feedList.sourceModel.loadingStatus.connect(handleModelStatusChange);
        }
    }

    function switchToZMCameras(category, currFeed)
    {
        feedName = "ZoneMinder Cameras";
        currentFeed = currFeed;
        currentFilter = category;
        filters = enabledFilter;
        sorters = [];

        if (feedList.sourceModel !== playerSources.zmCameraList)
        {
            if (feedList.sourceModel)
                feedList.sourceModel.loadingStatus.disconnect(handleModelStatusChange);

            feedList.sourceModel = playerSources.zmCameraList;

            if (playerSources.zmCameraList.status === XmlListModel.Ready)
                handleModelStatusChange(XmlListModel.Ready);
            else
                playerSources.zmCameraList.loadingStatus.connect(handleModelStatusChange);
        }
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

        if (feedList.sourceModel !== playerSources.videoList)
        {
            if (feedList.sourceModel)
                feedList.sourceModel.loadingStatus.disconnect(handleModelStatusChange);

            feedList.sourceModel = playerSources.videoList;
            handleModelStatusChange(XmlListModel.Ready);
            // playerSources.videoList.loadingStatus.connect(handleModelStatusChange);
        }
    }

    function switchToAdventCalendar(day, currFeed)
    {
        feedName = "Advent Calendar";
        currentFeed = currFeed;
        currentFilter = day;
        filters = [];
        sorters = [];

        if (feedList.sourceModel !== playerSources.adhocList)
        {
            if (feedList.sourceModel && feedList.sourceModel.loadingStatus)
                feedList.sourceModel.loadingStatus.disconnect(handleModelStatusChange);

            feedList.sourceModel = playerSources.adhocList;
            handleModelStatusChange(XmlListModel.Ready);
        }
    }

    function switchToIPTV(filterList, currFeed)
    {
        feedName = "IPTV";
        currentFeed = currFeed;
        currentFilter = filterList;

        var list = filterList.split(",");

        if (list.length === 4)
        {
            sort = list[0];
            iptvGenre.pattern = list[1];
            iptvCountry.pattern = list[2];
            iptvLanguage.pattern = list[3];
        }

        filters = iptvFilter;

        if (sort === "Title")
            sorters = titleSorter;
        else if (sort === "Genre")
            sorters = genreSorter;
        else if (sort === "Country")
            sorters = countrySorter;
        else if (sort === "Language")
            sorters = languageSorter;
        else
            sorters = idSorter;

        if (feedList.sourceModel !== playerSources.iptvList)
        {
            if (feedList.sourceModel)
                feedList.sourceModel.loadingStatus.disconnect(handleModelStatusChange);

            feedList.sourceModel = playerSources.iptvList;
            handleModelStatusChange(XmlListModel.Ready);
            //playerSources.iptvList.loadingStatus.connect(handleModelStatusChange);
        }
    }

    function switchToAdhoc(filter, currFeed)
    {
        feedName = "Adhoc";
        currentFeed = currFeed;
        currentFilter = filter;
        filters = [];
        sorters = [];

        if (feedList.sourceModel !== playerSources.adhocList)
        {
            if (feedList.sourceModel && feedList.sourceModel.loadingStatus)
                feedList.sourceModel.loadingStatus.disconnect(handleModelStatusChange);

            feedList.sourceModel = playerSources.adhocList;
            handleModelStatusChange(XmlListModel.Ready);
        }
    }

    function handleModelStatusChange(status)
    {
        if (status == XmlListModel.Ready)
            feedModelLoaded();
        else if (status == XmlListModel.Loading)
            feedModelLoading();
        else if (status == XmlListModel.Error)
            feedModelError();
        else if (status == XmlListModel.Null)
            feedModelError();
    }

    function findById(Id)
    {
        for (var x = 0; x < feedList.count; x++)
        {
            if (feedList.get(x).id == Id)
                return x;
        }

        return -1;
    }
}
