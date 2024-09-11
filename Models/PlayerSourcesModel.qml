import QtQuick 2.0
import SortFilterProxyModel 0.2
import Models 1.0
import mythqml.net 1.0

Item
{
    id: playerSources

    // feed lists
    property var channelList: channelsModel
    property var videosList: videosModel
    property var webcamList: webcamModel
    property var webvideoList: webvideoModel
    property var zmCameraList: zmMonitorsModel
    property var iptvList: iptvModel
    property var adhocList: undefined
    property var tivoChannelList: tivoChannelsModel
    property var tivoNowShowingList: tivoNowShowing
    property var youtubeSubsList: youtubeSubsModel
    property var youtubeFeedList: youtubeFeedModel
    property var recordingsList: recordingsModel
    property var browserBookmarksList: browserBookmarkModel
    property var videoFilesList: videoFilesModel
    property var radioStreamList: radioBrowserModel
    property var mediaItemsList: mediaItemsModel
    property var fileBrowserList: fileBrowserModel

    // live tv
    property var videoSourceList: videoSourceModel

    // program guide
    property alias channelGroups: channelGroupsModel

    // webvideo
    property string webvideoFilterCategory
    property string webvideoFilterFavorite: "Any"
    property bool webvideoTitleSorterActive: true
    property var webvideoProxyModel: webvideoProxyModel

    // zoneminder
    property alias zmToken: zmLogin.token

    // schedules direct API
    property alias sdAPI: sdAPI

    // home assistant API
    property alias haAPI: haAPI

    /* ---------------------------------- open the banking transactions database --------------------------------------- */
    QtObject
    {
        id: database
        property string name: "transactions"
        property string engine: "sqlite3"
        property string filename: settings.bankingDataDir.replace("file://", "") + "/transactions.db"
    }

    Component.onCompleted: dbUtils.addDatabase(database);


    /* ----------------------------------------------- Shared Sorters  --------------------------------------------------- */
    property list<QtObject> titleSorter:
    [
        RoleSorter { roleName: "title"; ascendingOrder: true}
    ]

    property list<QtObject> idSorter:
    [
        RoleSorter { roleName: "id" }
    ]

    /* ----------------------------------------------- MythTV Channels --------------------------------------------------- */
    SortFilterProxyModel
    {
        id: channelsProxyModel

        property int sourceId: 6

        sourceModel: channelsModel.model
        filters:
        [
            ValueFilter
            {
                roleName: "SourceId"
                value: channelsProxyModel.sourceId
            }
        ]
    }

    property list<QtObject> chanNumSorter:
    [
        RoleSorter { roleName: "ChanNum"; ascendingOrder: true}
    ]

    CaptureCardModel
    {
        id: captureCardModel
    }

    EncodersModel
    {
        id: encodersModel
    }

    ChannelGroupsModel
    {
        id: channelGroupsModel
    }

    ChannelsModel
    {
        id: channelsModel
        groupByCallsign: true
    }

    VideoSourceModel
    {
        id: videoSourceModel
    }

    WebCamModel
    {
        id: webcamModel
    }

    /* --------------------------------------------------- WebVideo --------------------------------------------------- */
    WebVideoModel
    {
        id: webvideoModel
    }


    onWebvideoTitleSorterActiveChanged:
    {
        if (webvideoTitleSorterActive)
        {
            webvideoProxyModel.sorters = titleSorter;
        }
        else
        {
            webvideoProxyModel.sorters = idSorter;
        }
    }

    SortFilterProxyModel
    {
        id: webvideoProxyModel

        //sourceModel: webvideoModel.models[0]
        filters:
        [
            AllOf
            {
                RegExpFilter
                {
                    roleName: "categories"
                    pattern: webvideoFilterCategory
                    caseSensitivity: Qt.CaseInsensitive
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
        sorters: titleSorter
    }

    /* --------------------------------------------------- Media Items -------------------------------------------------------------- */
    MediaItemsModel
    {
        id: mediaItemsModel
    }

    /* --------------------------------------------------- IPTV -------------------------------------------------------------- */
    IPTVModel
    {
        id: iptvModel
    }

    /* ------------------------------------------------ ZoneMinder Cameras --------------------------------------------------- */
    ZMLoginModel
    {
        id: zmLogin

        property string token: ""
        Component.onCompleted: getLogin()

        onLoaded:
        {
            token = get(0).access_token;
            zmMonitorsModel.token = token;
        }
    }

    ZMMonitorsModel
    {
        id: zmMonitorsModel
    }

    /* ------------------------------------------------ Videos -----------------------------------------------------------*/
    VideosModel
    {
        id: videosModel
    }

    /* ------------------------------------------------ Video Files -------------------------------------------------------*/
    FileBrowserModel
    {
        id: videoFilesModel
        folder: settings.videoPath
        nameFilters: ["*.mp4", "*.flv", "*.mp2", "*.wmv", "*.avi", "*.mkv", "*.mpg", "*.iso", "*.ISO", "*.mov", "*.webm"]
    }

    /* ------------------------------------------------ File Browser -------------------------------------------------------*/
    FileBrowserModel
    {
        id: fileBrowserModel
        folder: "file:///"
        nameFilters: ["*.*"]
    }

    /* ------------------------------------------------ Tivo TV -----------------------------------------------------------*/
    TivoChannelsDBModel
    {
        id: tivoChannelsModel
    }

    TivoNowShowingModel
    {
        id: tivoNowShowing
    }

    /* -----------------------------------------------------------------------------------------------------------------*/
    function findEncoder(sourceId)
    {
        for (var x = 0; x < encodersModel.count; x++)
        {
            // check encode state = kState_None
            if (encodersModel.get(x).State === 0)
            {
                // see if this encoder has an input with our sourceId
                var sourceIds = encodersModel.get(x).sourceIds.split(",");

                for (var y = 0; y < sourceIds.length; y++)
                {
                    var splitSourceId = sourceIds[y].trim();
                    if (splitSourceId === sourceId)
                        return x;
                }
            }
        }

        return -1;
    }

    /* -------------------------------------------- YouTube Subscriptions ----------------------------------------------------------*/
    YoutubeSubListModel
    {
        id: youtubeSubsModel
    }

    YoutubeFeedModel
    {
        id: youtubeFeedModel
    }

    /* --------------------------------------------------Browser Bookmarks----------------------------------------------------------*/
    BrowserBookmarksModel
    {
        id: browserBookmarkModel
    }

    /* ------------------------------------------------- MythTV Recordings ---------------------------------------------------------*/
    MythRecordingsModel
    {
        id: recordingsModel
    }

    /* --------------------------------------------- Schedules Direct JSON API ------------------------------------------------------*/
    SDJsonModel
    {
        id: sdAPI
    }

    /* -------------------------------------------- Home Assistant JSON REST API ----------------------------------------------------*/
    HAJsonModel
    {
        id: haAPI
    }

    /* ------------------------------------------------- Radio Browser Database -----------------------------------------------------*/
    RadioBrowserModel
    {
        id: radioBrowserModel
    }

    /*-------------------------------------------------------------------------------------------------------------------------------*/

    function getFeedList(feedSource)
    {
        if (feedSource === "Live TV")
            return channelList;
        else if (feedSource === "Webcams")
            return webcamList;
        else if (feedSource === "Web Videos")
            return webvideoList;
        else if (feedSource === "Videos")
            return videoList;
        else if (feedSource === "Recordings")
            return recordingList;
        else if (feedSource === "ZoneMinder Cameras")
            return zmCameraList;
        else if (feedSource === "Tivo TV")
            return tivoChannelList;

        return channelList;
    }

    function addFeedMenu(popupMenu, feed, path, player)
    {
        if (feed.feedName === "Live TV")
            addChannelMenu(popupMenu, feed, path, player);
        else if (feed.feedName === "IPTV")
            addIPTVMenu(popupMenu, feed, path, player);
        else if (feed.feedName === "Webcams")
            addWebcamMenu(popupMenu, feed, path, player);
        else if (feed.feedName === "Web Videos")
            addWebvideoMenu(popupMenu, feed, path, player);
        else if (feed.feedName === "Videos")
            addVideoMenu(popupMenu, feed, path, player);
        else if (feed.feedName === "Recordings")
            addRecordingMenu(popupMenu, feed, path, player);
        else if (feed.feedName === "ZoneMinder Cameras")
            addZMCameraMenu(popupMenu, feed, path, player);
        else if (feed.feedName === "Advent Calendar")
            addAdventCalendarMenu(popupMenu, feed, path, player);
    }

    function addChannelMenu(popupMenu, feed, path, player)
    {
        for (var x = 0; x < captureCardModel.count; x++)
        {
            var cardDisplayName = captureCardModel.get(x).DisplayName;
            popupMenu.addMenuItem(path, cardDisplayName)

            // add the channels for this card
            channelsProxyModel.sourceId = captureCardModel.get(x).SourceId

            for (var y = 0; y < channelsProxyModel.count; y++)
            {
                var title = channelsProxyModel.get(y).ChanNum + " - " + channelsProxyModel.get(y).ChannelName;
                var data = "player=" + player + "\nLive TV\n" + captureCardModel.get(x).SourceId + "\n" + y;
                popupMenu.addMenuItem(path + "," + x , title, data);
            }
        }
    }

    function addIPTVMenu(popupMenu, feed, path, player)
    {
        for (var x = 0; x < iptvList.model.count; x++)
        {
            var title = iptvList.model.get(x).title;
            var data = "player=" + player + "\nIPTV\n" + "Title,,," + "\n" + x;
            popupMenu.addMenuItem(path, title, data);
        }
    }

    function findWebcamIndex(id)
    {
        for (var x = 0; x < webcamModel.count; x++)
        {
            if (webcamModel.get(x).id === id)
                return x;
        }

        return 0;
    }

    function addWebcamMenu(popupMenu, feed, path, player)
    {
        var oldWebcamFilterCategory = feed.category;

        for (var x = 0; x < webcamModel.models[feed.webcamListIndex].categoryList.count; x++)
        {
            var category = webcamModel.models[feed.webcamListIndex].categoryList.get(x).item;
            popupMenu.addMenuItem(path, category);

            // add the webcams for this category
            feed.category = "";
            feed.category = category === "<All Webcams>" ? "" : category;

            for (var y = 0; y < feed.feedList.count; y++)
            {
                var title = feed.feedList.get(y).title;
                var filter = feed.webcamListIndex + ',' + feed.category + ',' + "title";
                var data = "player=" + player + "\nWebcams\n" + filter + "\n" + y;
                popupMenu.addMenuItem(path + "," + x , title, data);
            }
        }

        feed.category = oldWebcamFilterCategory;
    }

    function findWebvideoIndex(id)
    {
        for (var x = 0; x < webvideoModel.count; x++)
        {
            if (webvideoModel.get(x).id === id)
                return x;
        }

        return 0;
    }

    function addWebvideoMenu(popupMenu, feed, path, player)
    {
        var oldWebvideoFilterCategory = webvideoFilterCategory;

        for (var x = 0; x < webvideoModel.categoryList.count; x++)
        {
            var category = webvideoModel.categoryList.get(x).item;
            popupMenu.addMenuItem(path, category)

            // add the webvideos for this category
            webvideoFilterCategory = category === "<All Web Videos>" ? "" : category

            for (var y = 0; y < webvideoProxyModel.count; y++)
            {
                var title = webvideoProxyModel.get(y).title;
                var data = "player=" + player + "\nWeb Videos\n" + webvideoFilterCategory + "\n" + y;
                popupMenu.addMenuItem(path + "," + x , title, data);
            }
        }

        webvideoFilterCategory = oldWebvideoFilterCategory;
    }

    function addVideoMenu(popupMenu, feed, path, player)
    {
        for (var x = 0; x < videosModel.count; x++)
        {
            var title = videosModel.get(x).Title + " ~ " + videosModel.get(x).SubTitle;
            var data = "player=" + player + "\nVideos\n\n" + x;
            popupMenu.addMenuItem(path, title, data);
        }
    }

    function addRecordingMenu(popupMenu, feed, path, player)
    {

    }

    function addZMCameraMenu(popupMenu, feed, path, player)
    {
        for (var x = 0; x < zmMonitorsModel.count; x++)
        {
            var title = zmMonitorsModel.get(x).name;
            var data = "player=" + player + "\nZoneMinder Cameras\n\n" + x;
            popupMenu.addMenuItem(path, title, data);
        }
    }

    function addAdventCalendarMenu(popupMenu, feed, path, player)
    {
        popupMenu.addMenuItem(path, "<NONE>", "");
    }

    function zmSettingsChanged()
    {
        zmLogin.reload();
        zmMonitorsModel.reload();
    }
}
