import QtQuick 2.0
import SortFilterProxyModel 0.2

Item
{
    id: playerSources

    // feed lists
    property var channelList: channelsModel
    property var videoList: videosModel
    property var webcamList: webcamModel
    property var webvideoList: webvideoModel
    property var zmCameraList: zmMonitorsModel

    // webcam
    property string webcamFilterCategory
    property var webcamPaths
    property int webcamPathIndex: 0

    // webvideo
    property string webvideoFilterCategory
    property var webvideoPaths
    property int webvideoPathIndex: 0

    // zoneminder
    property alias zmAuth: zmLogin.auth

    Component.onCompleted:
    {
        var path;

        // get list of webcam paths
        webcamPaths =  settings.webcamPath.split(",")
        path = dbUtils.getSetting("Qml_lastWebcamPath", settings.hostName, webcamPaths[0])
        path = path.replace("/WebCam.xml", "")
        webcamPathIndex = webcamPaths.indexOf(path)
        webcamModel.source = path + "/WebCam.xml"

        webvideoPaths =  settings.webcamPath.split(",")
        path = dbUtils.getSetting("Qml_lastWebvideoPath", settings.hostName, webvideoPaths[0])
        path = path.replace("/WebVideo.xml", "")
        webvideoPathIndex = webvideoPaths.indexOf(path)
        webvideoModel.source = path + "/WebVideo.xml"
    }

    /* ----------------------------------------------- MythTV Channels --------------------------------------------------- */
    SortFilterProxyModel
    {
        id: channelsProxyModel

        property int sourceId: 6

        sourceModel: channelsModel
        filters:
        [
            ValueFilter
            {
                roleName: "SourceId"
                value: channelsProxyModel.sourceId
            }
        ]
    }

    CaptureCardModel
    {
        id: captureCardModel
    }

    EncodersModel
    {
        id: encodersModel
    }

    ChannelsModel
    {
        id: channelsModel
        groupByCallsign: false
    }

    VideosModel
    {
        id: videosModel
    }

    /* --------------------------------------------------- WebCams --------------------------------------------------- */
    WebCamModel
    {
        id: webcamModel
    }

    property list<QtObject> titleSorter:
    [
        RoleSorter { roleName: "title"; ascendingOrder: true}
    ]

    SortFilterProxyModel
    {
        id: webcamProxyModel

        sourceModel: webcamModel
        filters:
        [
            AllOf
            {
                RegExpFilter
                {
                    roleName: "categories"
                    pattern: webcamFilterCategory
                    caseSensitivity: Qt.CaseInsensitive
                }
            }
        ]
        sorters: titleSorter
    }

    /* --------------------------------------------------- WebVideo --------------------------------------------------- */
    WebVideoModel
    {
        id: webvideoModel
    }

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
                    pattern: webvideoFilterCategory
                    caseSensitivity: Qt.CaseInsensitive
                }
            }
        ]
        sorters: RoleSorter { roleName: "title"; ascendingOrder: true}
    }

    /* ------------------------------------------------ ZoneMinder Cameras --------------------------------------------------- */

    ZMLoginModel
    {
        id: zmLogin

        property string auth: ""

        Component.onCompleted: getLogin()

        onLoaded:
        {
            auth = get(0).credentials;
            zmMonitorsModel.auth = auth;
        }
    }

    ZMMonitorsModel
    {
        id: zmMonitorsModel
    }

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
        else if (feedSource === "Zoneminder Cameras")
            return zmCameraList;

        return channelList;
    }

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

    function addFeedMenu(popupMenu, feedSource, path, player)
    {
        if (feedSource === "Live TV")
            addChannelMenu(popupMenu, path, player);
        else if (feedSource === "Webcams")
            addWebcamMenu(popupMenu, path, player);
        else if (feedSource === "Web Videos")
            addWebvideoMenu(popupMenu, path, player);
        else if (feedSource === "Videos")
            addVideoMenu(popupMenu, path, player);
        else if (feedSource === "Recordings")
            addRecordingMenu(popupMenu, path, player);
        else if (feedSource === "ZoneMinder Cameras")
            addZMCameraMenu(popupMenu, path, player);
        else if (feedSource === "Advent Calendar")
            addAdventCalendarMenu(popupMenu, path, player);
    }

    function addChannelMenu(popupMenu, path, player)
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
                var data = "source=" + player + "\n" + y; //myth://type=livetv:server=" + captureCardModel.get(x).HostName + ":encoder=" + captureCardModel.get(x).CardId + ":channum=" + channelsProxyModel.get(y).ChanNum;
                popupMenu.addMenuItem(path + "," + x , title, data);
            }
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

    function addWebcamMenu(popupMenu, path, player)
    {
        var oldWebcamFilterCategory = webcamFilterCategory;

        for (var x = 0; x < webcamModel.categoryList.count; x++)
        {
            var category = webcamModel.categoryList.get(x).item;
            popupMenu.addMenuItem(path, category)

            // add the webcams for this category
            webcamFilterCategory = category === "<All Webcams>" ? "" : category

            for (var y = 0; y < webcamProxyModel.count; y++)
            {
                var title = webcamProxyModel.get(y).title;
                var data = "source=" + player + "\n" + webcamFilterCategory  + "\n" + y;//webcamProxyModel.get(y).id;
                popupMenu.addMenuItem(path + "," + x , title, data);
            }
        }

        webcamFilterCategory = oldWebcamFilterCategory;
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

    function addWebvideoMenu(popupMenu, path, player)
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
                var data = "source=" + player + "\n" + webvideoFilterCategory + "\n" + y; //webvideoProxyModel.get(y).id;
                popupMenu.addMenuItem(path + "," + x , title, data);
            }
        }

        webvideoFilterCategory = oldWebvideoFilterCategory;
    }

    function addVideoMenu(popupMenu, path, player)
    {
        for (var x = 0; x < videosModel.count; x++)
        {
            var title = videosModel.get(x).Title + " ~ " + videosModel.get(x).SubTitle;
            var data = "source=" + player + "\n" + x;
            popupMenu.addMenuItem(path, title, data);
        }
    }

    function addRecordingMenu(popupMenu, path, player)
    {

    }

    function addZMCameraMenu(popupMenu, path, player)
    {
        for (var x = 0; x < zmMonitorsModel.count; x++)
        {
            var title = zmMonitorsModel.get(x).name;
            var data = "source=" + player + "\n"  +  "\n" + x;
            popupMenu.addMenuItem(path, title, data);
        }
    }

    function addAdventCalendarMenu(popupMenu, path, player)
    {
        popupMenu.addMenuItem(path, "<NONE>", "");
    }

    function zmSettingsChanged()
    {
        zmLogin.reload();
        zmMonitorsModel.reload();
    }
}
