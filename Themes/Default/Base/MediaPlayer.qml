import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0
import QtWebEngine 1.3
import Base 1.0
import Process 1.0
import Models 1.0
import QtAV 1.5
import SortFilterProxyModel 0.2
import mythqml.net 1.0

import "../../../Util.js" as Util

FocusScope
{
    id: root

    property alias feed: feedSource

    property int streamlinkPort: Util.randomIntFromRange(4000, 65536)
    property string streamlinkLog

    // one of VLC, FFMPEG, WebBrowser, YouTube, YouTubeTV, RailCam, StreamLink, Internal
    property string player: ""

    property bool showBorder: true
    property bool muteAudio: false
    property bool showRailcamApproach: false
    property bool showRailcamDiagram: false

    // private properties
    property bool _playbackStarted: false
    property double _wmult: width / 1280
    property double _hmult: height / 720

    signal playbackEnded()
    signal activeFeedChanged()

    function _xscale(x)
    {
        return x * _wmult
    }

    function _yscale(y)
    {
        return y * _hmult
    }

    FeedSource
    {
        id: feedSource
    }

    Process
    {
        id: streamLinkProcess
        onFinished:
        {
            if (exitStatus == Process.NormalExit)
            {
                //stack.pop();
            }
        }
    }

    Timer
    {
        id: checkProcessTimer
        interval: 1000; running: false; repeat: true
        onTriggered:
        {
            streamlinkLog = streamLinkProcess.readAll();

            if (streamlinkLog.includes("No playable streams found on this URL"))
            {
                showMessage("No playable streams found!", settings.osdTimeoutMedium);
                checkProcessTimer.stop();
            }
            else if (streamlinkLog.includes("Starting server, access with one of:"))
            {
                checkProcessTimer.stop();
                qtAVPlayer.visible = true;
                switchURL("http://127.0.1.1:" + streamlinkPort + "/");
            }
        }
    }

    Rectangle
    {
        id: playerRect
        anchors.fill: parent
        focus: true
        color: "black"
        radius: theme.bgRadius
    }

    WebEngineProfile
    {
        id: youtubeWebProfile
        storageName: "YouTube"
        offTheRecord: false
        httpCacheType: WebEngineProfile.DiskHttpCache
        persistentCookiesPolicy: WebEngineProfile.AllowPersistentCookies
        httpUserAgent: "Mozilla/5.0 (SMART-TV; Linux; Tizen 5.0) AppleWebKit/538.1 (KHTML, like Gecko) Version/5.0 NativeTVAds Safari/538.1"
    }

    WebEngineProfile
    {
        id: mythqmlWebProfile
        storageName: "MythQML"
        offTheRecord: false
        httpCacheType: WebEngineProfile.DiskHttpCache
        persistentCookiesPolicy: WebEngineProfile.AllowPersistentCookies
        //httpUserAgent: "Mozilla/5.0 (SMART-TV; Linux; Tizen 5.0) AppleWebKit/538.1 (KHTML, like Gecko) Version/5.0 NativeTVAds Safari/538.1"
    }

    WebEngineView
    {
        id: webPlayer
        visible: false
        enabled: visible
        anchors.fill: parent
        anchors.margins: playerBorder.border.width
        url: ""
        settings.pluginsEnabled: true
        settings.javascriptEnabled: true
        audioMuted: false;

        Component.onCompleted: settings.playbackRequiresUserGesture = false;

        profile: youtubeWebProfile

        onLoadingChanged:
        {
            if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus)
            {
                // hack to defeat Chrome's Web Audio autoplay policy
                if (feedSource.feedList.get(feedSource.currentFeed).url.includes("railcam.co.uk"))
                {
                     runJavaScript("document.getElementsByClassName(\"drawer-icon media-control-icon\")[0].click();");
                }
            }
        }
    }

    WebEngineView
    {
        id: browser
        x: 0
        y: 0
        width: 300;
        height: 720;
        z: 99
        zoomFactor: parent.width / xscale(1280)
        visible: false
        enabled: visible

        settings.pluginsEnabled: true

        profile:  WebEngineProfile
                  {
                      storageName: "YouTube"
                      offTheRecord: false
                      httpCacheType: WebEngineProfile.DiskHttpCache
                      persistentCookiesPolicy: WebEngineProfile.AllowPersistentCookies
                      httpUserAgent: "Mozilla/5.0 (SMART-TV; Linux; Tizen 5.0) AppleWebKit/538.1 (KHTML, like Gecko) Version/5.0 NativeTVAds Safari/538.1"
                  }
    }

    VideoPlayerYT
    {
        id: youtubePlayer
        visible: false
        enabled: visible
        anchors.fill: parent
        anchors.margins: playerBorder.border.width

        onPlaybackEnded:
        {
            root.playbackEnded()
        }

        onShowMessage:
        {
            root.showMessage(message, timeOut);
        }
    }

    VideoPlayerQmlVLC
    {
        id: vlcPlayer

        visible: false
        enabled: visible
        anchors.fill: parent
        anchors.margins: playerBorder.border.width

        onPlaybackEnded:
        {
            root.playbackEnded()
        }

        onShowMessage:
        {
            root.showMessage(message, timeOut);
        }
    }

    VideoPlayerQtAV
    {
        id: qtAVPlayer

        visible: false
        enabled: visible
        anchors.fill: parent
        anchors.margins: playerBorder.border.width

        fillMode: VideoOutput.Stretch

        onPlaybackEnded:
        {
            root.playbackEnded()
        }

        onShowMessage:
        {
            root.showMessage(message, timeOut);
        }
    }

    ListModel
    {
        id: browserURLList

        property int currentIndex: 0
    }

    RailcamModel
    {
        id: railcamModel
        mediaPlayer: root

        onMiniDiagramImageChanged: mediaPlayer.updateRailCamMiniDiagram(railcamImageFilename)
     }

    Item
    {
        id: railcamMiniDiagram
        property bool hasDiagram: true
        property alias source: diagram.source

        x: 0
        y: (parent.height / 2) - railcamApproaching.height - yscale(10)
        width: parent.width
        height: parent.height / 2
        visible: false

        Image
        {
            id: diagram

            x: _xscale(100)
            y: 0
            width: parent.width - _xscale(200)
            height: parent.height
            verticalAlignment: Image.AlignBottom
            opacity: 0.9
            visible: railcamMiniDiagram.hasDiagram
            cache: false
            fillMode: Image.PreserveAspectFit
            source: ""
        }

        Rectangle
        {
            id: noDiagrams
            x: (parent.width / 2) - _xscale(300)
            y: parent.height / 2
            width: _xscale(600)
            height: parent.height / 2
            color: "#000000"
            opacity: 0.75
            visible: !railcamMiniDiagram.hasDiagram

            InfoText
            {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                text: "This RailCam webcam does not provide any realtime diagrams"
            }
        }

        Tracer{}
    }

    Item
    {
        id: railcamApproaching

        property bool hasData: true

        x: showBorder ? xscale(5) : 0
        y: parent.height - _yscale(50) - (showBorder ? yscale(5) : 0)
        width: parent.width - (showBorder ? xscale(10) : 0)
        height: _yscale(50)
        visible: false

        Rectangle
        {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.75
        }

        InfoText
        {
            id: noAproachingData
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            visible: !railcamApproaching.hasData
            text: "This RailCam webcam does not provide any live data"
        }

        Item
        {
            anchors.fill: parent
            visible: railcamApproaching.hasData

            Image
            {
                x: _xscale(5)
                y: _yscale(5)
                width: _xscale(40)
                height: _yscale(40)
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                fillMode: Image.PreserveAspectFit
                source: railcamModel.approachLeftList.count === 0 ?  mythUtils.findThemeFile("images/grey_rewind.png") : mythUtils.findThemeFile("images/rewind.png")
            }

            InfoText
            {
                x: _xscale(50)
                y: _yscale(5)
                width: _xscale(200)
                height: _yscale(40)
                fontPixelSize: _xscale(20)
                text: "Nothing in-range"
                visible: (railcamModel.approachLeftList.count === 0)
            }

            Image
            {
                x: parent.width - _xscale(45)
                y: _yscale(5)
                width: _xscale(40)
                height: _yscale(40)
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                fillMode: Image.PreserveAspectFit
                source: railcamModel.approachRightList.count === 0 ?  mythUtils.findThemeFile("images/grey_fastforward.png") :mythUtils.findThemeFile("images/fastforward.png")
            }

            InfoText
            {
                x: parent.width - _xscale(250)
                y: _yscale(5)
                width: _xscale(200)
                height: _yscale(40)
                horizontalAlignment: Text.AlignRight
                fontPixelSize: _xscale(20)
                text: "Nothing in-range"
                visible: (railcamModel.approachRightList.count === 0)
            }

            Component
            {
                id: listRow

                Item
                {
                    width: _xscale(180); height: leftList.height

                    // background
                    Rectangle
                    {
                        anchors.fill: parent
                        color: "#000000"
                        opacity: 0.5
                        border.color: "grey"
                        border.width: _xscale(2)
                        radius: _xscale(5)
                    }

                    // signal
                    Rectangle
                    {
                        x: _xscale(5)
                        y: _yscale(8)
                        width: _xscale(14)
                        height: parent.height - _yscale(14)
                        color: "#000000"
                        opacity: 1.0
                        border.color: "white"
                        border.width: _xscale(1)
                        radius: _xscale(5)

                        Rectangle
                        {
                            x: _xscale(3)
                            y: _yscale(4)
                            width: _xscale(8)
                            height: width
                            radius: width / 2
                            color:
                            {
                                if (status == "Passing")
                                    return "green"
                                else if (status == "Passed")
                                    return "red"
                                else if (status == "At Platform")
                                    return "black"
                                else if (status == "Waiting")
                                    return "Orange"
                                else if (status == "Approaching")
                                {
                                    if (approach_ind === "<1" || approach_ind === ">1")
                                        return "yellow"
                                    else
                                        return "black"
                                }
                            }
                        }

                        Rectangle
                        {
                            x: _xscale(3)
                            y: _yscale(14)
                            width: _xscale(8)
                            height: width
                            radius: width / 2
                            color:
                            {
                                if (status == "Passing")
                                    return "black"
                                else if (status == "Passed")
                                    return "black"
                                else if (status == "At Platform")
                                    return "white"
                                else if (status == "Waiting")
                                    return "Orange"
                                else if (status == "Approaching")
                                    return "yellow"
                            }
                        }
                    }

                    InfoText
                    {
                        x: _xscale(23)
                        y: 0
                        width: _xscale(60)
                        height: parent.height
                        text: headcode
                        fontPixelSize: _xscale(20)
                        horizontalAlignment: Text.AlignHCenter
                        fontColor:
                        {
                            if (status == "Passing")
                                return "Green"
                            else if (status == "Approaching")
                                return "Yellow"
                            else if (status == "Passed")
                                return "red"
                            else if (status == "Waiting")
                                return "Orange"
                            else
                                return "white"
                        }
                    }

                    InfoText
                    {
                        x: _xscale(85)
                        y: 0
                        width: _xscale(100)
                        height: parent.height
                        text: status
                        fontColor: "white"
                        fontPixelSize: _xscale(16)
                    }
                }
            }

            ListView
            {
                id: leftList
                x: _xscale(55)
                y: _yscale(5)
                width: (parent.width / 2) - _xscale(60)
                height: _yscale(40)
                spacing: _xscale(5)
                orientation: ListView.Horizontal
                clip: true
                delegate: listRow
                model: railcamModel.approachLeftList
                Tracer {}
            }

            ListView
            {
                id: rightList
                x: (parent.width / 2) + _xscale(5)
                y: _yscale(5)
                width: (parent.width / 2) - _xscale(60)
                height: _yscale(40)
                spacing: _xscale(5)
                orientation: ListView.Horizontal
                layoutDirection: Qt.RightToLeft
                clip: true
                delegate: listRow
                model: railcamModel.approachRightList
                Tracer {}
            }
        }
    }

    Rectangle
    {
        id: playerBorder
        anchors.fill: parent
        focus: true
        color: "transparent"
        border.color: root.focus ? theme.lvBackgroundBorderColor : theme.bgBorderColor
        border.width: root.showBorder ? xscale(5) : 0
        radius: theme.bgRadius
    }

    Timer
    {
        id: infoTimer
        interval: settings.osdTimeoutMedium; running: false; repeat: false
        onTriggered: { infoPanel.visible = false; updateRailcamApproach(); }
    }

    BaseBackground
    {
        id: infoPanel
        x: xscale(10);
        y: parent.height - _yscale(160) - yscale(10);
        opacity: 0.75
        width: parent.width - xscale(20);
        height: _yscale(160)

        visible: false

        TitleText
        {
            id: title
            x: _xscale(10)
            y: _yscale(5)
            width: parent.width - currFeed.width - _xscale(20)
            height: _yscale(50)
            fontPixelSize: (_xscale(24) + _yscale(24)) / 2
            text:
            {
                if (!feedSource.feedList.get(feedSource.currentFeed))
                   return "";
                else if (feedSource.feedList.get(feedSource.currentFeed).title !== undefined)
                    return feedSource.feedList.get(feedSource.currentFeed).title
                else if (feedSource.feedList.get(feedSource.currentFeed).url !== undefined)
                    return feedSource.feedList.get(feedSource.currentFeed).url
                else
                    return ""
            }

            verticalAlignment: Text.AlignTop
        }

        InfoText
        {
            id: pos
            x: _xscale(50)
            y: _yscale(50)
            width: _xscale(400)
            height: _yscale(50)
            fontPixelSize: (_xscale(16) + _yscale(16)) / 2
            text:
            {
                if (getActivePlayer() === "VLC")
                    return "Position: " + Util.milliSecondsToString(vlcPlayer.getPosition()) + " / " + Util.milliSecondsToString(vlcPlayer.getDuration())
                else if (getActivePlayer() === "YOUTUBE")
                    return "Position: " + Util.milliSecondsToString(youtubePlayer.getPosition()) + " / " + Util.milliSecondsToString(youtubePlayer.getDuration())
                else
                    return "Position: " + "N/A"
            }
        }

        InfoText
        {
            id: timeLeft
            x: parent.width - width - _xscale(15); y: _yscale(50)
            width: _xscale(240)
            height: _yscale(50)
            fontPixelSize: (_xscale(16) + _yscale(16)) / 2
            text:
            {
                if (getActivePlayer() === "VLC")
                    return Util.milliSecondsToString(vlcPlayer.getDuration() - vlcPlayer.getPosition())
                else if (getActivePlayer() === "YOUTUBE")
                    return Util.milliSecondsToString(youtubePlayer.getDuration() - youtubePlayer.getPosition())
                else
                    "Remaining :" + "N/A"
            }

            horizontalAlignment: Text.AlignRight
        }

        InfoText
        {
            id: currFeed
            x: parent.width - width - _xscale(15)
            y: _yscale(0)
            width: _xscale(240)
            height: _yscale(50)
            fontPixelSize: (_xscale(16) + _yscale(16)) / 2
            text: feedSource.currentFeed + 1 + " of " + feedSource.feedCount + " (" + feedSource.feedName + ")"

            horizontalAlignment: Text.AlignRight
        }

        InfoText
        {
            id: currPlayer
            x: parent.width - width - _xscale(15)
            y: _yscale(24)
            width: _xscale(240)
            height: _yscale(50)
            fontPixelSize: (_xscale(16) + _yscale(16)) / 2
            text: getActivePlayer();

            horizontalAlignment: Text.AlignRight
        }

        Footer
        {
            id: footer
            x: root._xscale(5)
            y: parent.height - root._yscale(38)
            width: parent.width - root._xscale(10)
            height: root._yscale(32)

            redText: "Previous"
            greenText: "Next"
            yellowText:
            {
                "Show Web Pages";
            }
            blueText:
            {
                if (player === "RailCam")
                    "Show RailCam Info";
                else
                    "";
            }

            Tracer {}
       }


        RowLayout
        {
            id: toolbar
            opacity: .55
            spacing: _xscale(10)
            x: _xscale(10)
            y: _yscale(70)
            width: parent.width - _xscale(20)
            height: _yscale(50)
            anchors.bottomMargin: spacing
            anchors.leftMargin: spacing * _xscale(1.5)
            anchors.rightMargin: spacing * _xscale(1.5)
            Behavior on anchors.bottomMargin { PropertyAnimation { duration: 250} }
            Rectangle
            {
                height: _yscale(24)
                width: height
                radius: width * _xscale(0.25)
                color: 'black'
                border.width: _xscale(1)
                border.color: 'white'
                Image
                {
                    source: mythUtils.findThemeFile("images/play.png") //mediaplayer.playing ? mythUtils.findThemeFile("images/play.png") : mythUtils.findThemeFile("images/pause.png")
                    anchors.centerIn: parent
                }
            }
            Rectangle
            {
                Layout.fillWidth: true
                height: _yscale(10)
                color: 'transparent'
                border.width: _xscale(1)
                border.color: 'white'
                Rectangle
                {
                    width:
                    {
                        var position = 1;

                        if (getActivePlayer() === "VLC")
                            position = vlcPlayer.getPosition() / vlcPlayer.getDuration();
                        else if (getActivePlayer() === "YOUTUBE")
                            position = youtubePlayer.getPosition() / youtubePlayer.getDuration();

                        return (parent.width - anchors.leftMargin - anchors.rightMargin) * position;
                    }
                    color: 'blue'
                    anchors.margins: _xscale(2)
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                }
            }
        }
    }

    Timer
    {
        id: messageTimer
        interval: 6000; running: false; repeat: false
        onTriggered: messagePanel.visible = false;
    }

    BaseBackground
    {
        id: messagePanel
        x: _xscale(100); y: _yscale(120); width: _xscale(400); height: _yscale(110)
        visible: false

        InfoText
        {
            id: messageText
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
        }
    }

    function showMessage(message, timeOut)
    {
        if (!timeOut)
            timeOut = settings.osdTimeoutMedium;

        if (message !== "")
        {
            messageText.text = message;
            messagePanel.visible = true;
            messageTimer.interval = timeOut
            messageTimer.restart();
        }
        else
        {
            messageText.text = message;
            messagePanel.visible = false;
            messageTimer.stop();
        }
    }

    function getActivePlayer()
    {
        if (webPlayer.visible === true)
            return "BROWSER";
        else if (youtubePlayer.visible === true)
            return "YOUTUBE";
        else if (vlcPlayer.visible === true)
            return "VLC";
        else if (qtAVPlayer.visible === true)
            return "QTAV";
        else
            return "NONE";
    }

    function getActivePlayerItem()
    {
        if (webPlayer.visible === true)
            return webPlayer;
        else if (youtubePlayer.visible === true)
            return youtubePlayer;
        else if (vlcPlayer.visible === true)
            return vlcPlayer;
        else if (qtAVPlayer.visible === true)
            return qtAVPlayer;
        else
            return undefined;
    }

    function startPlayback()
    {
        if (feedSource.feedList === undefined ||
                feedSource.feedList.get(feedSource.currentFeed).player === undefined ||
                feedSource.feedList.get(feedSource.currentFeed).url === undefined)
            return;

        var newPlayer = feedSource.feedList.get(feedSource.currentFeed).player;
        switchPlayer(newPlayer);

        var newURL = feedSource.feedList.get(feedSource.currentFeed).url;
        switchURL(newURL);
    }

    function switchPlayer(newPlayer)
    {
        streamLinkProcess.stop();
        checkProcessTimer.running = false;
        streamLinkProcess.waitForFinished();

        youtubePlayer.stop();
        vlcPlayer.stop();
        qtAVPlayer.stop();
        webPlayer.url = "about:blank";

        // we always need to restart the StreamLink process even if it is already running
        if (newPlayer === "StreamLink")
        {
            youtubePlayer.visible = false;
            webPlayer.visible = false;
            vlcPlayer.visible = false;
            qtAVPlayer.visible = false;

            var url = feedSource.feedList.get(feedSource.currentFeed).url;

            var pluginPath = settings.sharePath.replace("file://", "") + "qml/Streamlink/plugins/"
            // also search for plugins in the streamlink directory in the same location as the webcams list file
            pluginPath += "," + Util.getPath(settings.webcamListFile.replace("file://", "")) + "/streamlink";

            var command = "streamlink"
            var parameters = ["--plugin-dirs", pluginPath, "--player-external-http", "--player-external-http-port", streamlinkPort, url, "best"]

            streamLinkProcess.start(command, parameters);

            checkProcessTimer.running = true;

            root.player = newPlayer;

            showMessage("Starting Streamer. Please Wait....", settings.osdTimeoutLong)
            return;
        }

        if (newPlayer === root.player)
            return;

        if (newPlayer === "VLC" || newPlayer === "Internal")
        {
            youtubePlayer.visible = false;
            webPlayer.visible = false;
            vlcPlayer.visible = true;
            qtAVPlayer.visible = false;
        }
        else if (newPlayer === "FFMPEG")
        {
            youtubePlayer.visible = false;
            webPlayer.visible = false;
            vlcPlayer.visible = false;
            qtAVPlayer.visible = true;
        }
        else if (newPlayer === "WebBrowser" || newPlayer === "RailCam")
        {
            youtubePlayer.visible = false;
            webPlayer.visible = true;
            vlcPlayer.visible = false;
            qtAVPlayer.visible = false;
        }
        else if (newPlayer === "YouTube")
        {
            // this uses the embedded YouTube player
            youtubePlayer.visible = true;
            webPlayer.visible = false;
            vlcPlayer.visible = false;
            qtAVPlayer.visible = false;
        }
        else if (newPlayer === "YouTubeTV")
        {
            // this uses the YouTube TV web player
            youtubePlayer.visible = false;
            webPlayer.visible = true;
            vlcPlayer.visible = false;
            qtAVPlayer.visible = false;
        }
        else
        {
            log.debug(Verbose.PLAYBACK, "MediaPlayer: switchPlayer - Got unknown player '" + newPlayer + "'");
            return;
        }

        root.player = newPlayer;
    }

    function switchURL(newURL)
    {
        log.debug(Verbose.PLAYBACK, "MediaPlayer: switchURL -  " + newURL);

        activeFeedChanged();
        showMessage("", 0);

        if (!feedSource.feedList.get(feedSource.currentFeed))
                title.text = "";
        else if (feedSource.feedList.get(feedSource.currentFeed).title !== undefined)
            title.text = feedSource.feedList.get(feedSource.currentFeed).title;
        else if (feedSource.feedList.get(feedSource.currentFeed).url !== undefined)
            title.text = feedSource.feedList.get(feedSource.currentFeed).url;
        else
            title.text = "";

        if (feedSource.feedName == "ZoneMinder Cameras")
            newURL += "&connkey=" + Util.randomIntFromRange(0, 999999);

        browser.visible = false;
        browser.url = "";

        if (root.player === "VLC" || root.player === "Internal")
        {
            vlcPlayer.source = newURL;
        }
        else if (root.player === "FFMPEG")
        {
            qtAVPlayer.source = newURL;
        }
        else if (root.player === "WebBrowser" || root.player === "RailCam")
        {
            webPlayer.profile = mythqmlWebProfile;
            webPlayer.url = newURL;
        }
        else if (root.player === "YouTubeTV")
        {
            webPlayer.profile = youtubeWebProfile;
            webPlayer.url = newURL;
        }
        else if (root.player === "YouTube")
        {
            var videoID = "''";
            var pos = newURL.indexOf("=");
            if (pos > 0)
                    videoID = "'" + newURL.slice(pos + 1, pos + 12) + "'";

            youtubePlayer.source = videoID;
        }
        else if (root.player === "StreamLink")
        {
            qtAVPlayer.source = newURL;
        }
        else
        {
            log.error(Verbose.PLAYBACK, "MediaPlayer: switchURL - Unknown player '" + root.player + "'");
            return;
        }
    }

    function play()
    {
        if (!_playbackStarted)
        {
            _playbackStarted = true;
            startPlayback();
        }
        else
        {
            if (getActivePlayer() === "VLC")
                vlcPlayer.play();
            else if (getActivePlayer() === "QTAV")
                qtAVPlayer.play();
            else if (getActivePlayer() === "YOUTUBE")
                youtubePlayer.play();
            else if (getActivePlayer() === "BROWSER")
            {
                // nothing to do
            }
        }
    }

    function stop()
    {
        streamLinkProcess.stop();
        checkProcessTimer.running = false;
        streamLinkProcess.waitForFinished();
        _playbackStarted = false;

        if (getActivePlayer() === "VLC")
        {
            vlcPlayer.stop();
            vlcPlayer.source = "";
        }
        else if (getActivePlayer() === "QTAV")
        {
            qtAVPlayer.stop();
            qtAVPlayer.source = "";
        }
        else if (getActivePlayer() === "YOUTUBE")
            youtubePlayer.stop();
        else if (getActivePlayer() === "BROWSER")
            webPlayer.url = "about:blank";
    }

    function togglePaused()
    {
        if (getActivePlayer() === "VLC")
            vlcPlayer.togglePaused();
        else if (getActivePlayer() === "QTAV")
            qtAVPlayer.togglePaused();
        else if (getActivePlayer() === "YOUTUBE")
            youtubePlayer.togglePaused();
    }

    function toggleMute()
    {
        root.muteAudio = !root.muteAudio;

        if (getActivePlayer() === "VLC")
        {
            vlcPlayer.setMute(root.muteAudio);
        }
        else if (getActivePlayer() === "QTAV")
        {
            qtAVPlayer.setMute(root.muteAudio);
        }
        else if (getActivePlayer() === "BROWSER")
        {
            webPlayer.audioMuted = root.muteAudio;
            webPlayer.triggerWebAction(WebEngineView.ToggleMediaMute);
        }
        else if (getActivePlayer() === "YOUTUBE")
        {
            youtubePlayer.setMute(root.muteAudio);
        }

        showMessage("Mute: " + (root.muteAudio ? "On" : "Off"), settings.osdTimeoutMedium);
    }

    function changeVolume(amount)
    {
        if (getActivePlayer() === "VLC")
            vlcPlayer.changeVolume(amount);
        else if (getActivePlayer() === "QTAV")
            qtAVPlayer.changeVolume(amount);
        else if (getActivePlayer() === "YOUTUBE")
            youtubePlayer.changeVolume(amount);
    }

    function getVolume()
    {
        if (getActivePlayer() === "VLC")
            return vlcPlayer.getVolume();
        else if (getActivePlayer() === "QTAV")
            return qtAVPlayer.getVolume();
        else if (getActivePlayer() === "YOUTUBE")
            return youtubePlayer.getVolume();

        return undefined
    }

    function setVolume(volume)
    {
        if (getActivePlayer() === "VLC")
            vlcPlayer.setVolume(volume);
        else if (getActivePlayer() === "QTAV")
            qtAVPlayer.setVolume(volume);
        else if (getActivePlayer() === "YOUTUBE")
            youtubePlayer.setVolume(volume);
    }

    function skipBack(time)
    {
        if (getActivePlayer() === "VLC")
            vlcPlayer.skipBack(time);
        else if (getActivePlayer() === "QTAV")
            qtAVPlayer.skipBack(time);
        else if (getActivePlayer() === "YOUTUBE")
            youtubePlayer.skipBack(time);
    }

    function skipForward(time)
    {
        if (getActivePlayer() === "VLC")
            vlcPlayer.skipForward(time);
        else if (getActivePlayer() === "QTAV")
            qtAVPlayer.skipForward(time);
        else if (getActivePlayer() === "YOUTUBE")
            youtubePlayer.skipForward(time);
    }

    function toggleInterlacer()
    {
        if (getActivePlayer() === "VLC")
            vlcPlayer.toggleInterlacer();
        else if (getActivePlayer() === "QTAV")
            qtAVPlayer.toggleInterlacer();
    }

    function showInfo(restart)
    {
        if (restart)
        {
            // restart the timer
            infoPanel.visible = true;
            infoTimer.restart();
        }
        else
        {
            if (infoPanel.visible)
                infoPanel.visible = false;
            else
            {
                infoPanel.visible = true;
                infoTimer.start();
            }
        }

        updateRailcamApproach();
    }

    function hideInfo()
    {
        infoPanel.visible = false;
        infoTimer.stop();
    }

    function nextFeed()
    {
        if (feedSource.feedName === "Advent Calendar")
            return;

        if (feedSource.currentFeed === feedSource.feedCount - 1)
        {
            feedSource.currentFeed = 0;
        }
        else
            feedSource.currentFeed++;

        startPlayback();

        showInfo(true);
    }

    function previousFeed()
    {
        if (feedSource.feedName === "Advent Calendar")
            return;

        if (feedSource.currentFeed === 0)
        {
            feedSource.currentFeed = feedSource.feedList.count - 1;
        }
        else
            feedSource.currentFeed--;

        startPlayback();

        showInfo(true);
    }

    function getLink(linktype)
    {
        var links = feedSource.feedList.get(feedSource.currentFeed).links.split("\n");

        for (var x = 0; x < links.length; x++)
        {
            if (links[x].startsWith(linktype))
            {
                return links[x].substring(linktype.length + 1, links[x].length);
            }
        }

        return undefined;
    }

    function getBrowserURL(o)
    {
        if (browserURLList.count === 0)
            return false;

        o.title = browserURLList.get(browserURLList.currentIndex).title;
        o.url = browserURLList.get(browserURLList.currentIndex).url;
        o.width = browserURLList.get(browserURLList.currentIndex).width;
        o.zoom = browserURLList.get(browserURLList.currentIndex).zoom;

        return true;
    }

    function getBrowserURLList()
    {
        return browserURLList;
    }

    function updateBrowserURLList()
    {
        browserURLList.clear();

        // add any RailCam Train Times
        var url = "https://railcam.uk/rcdata/RCData2_detail.php?r=S&hc={HEADCODE}&td={AREACODE}&vip=Y";

        var headCode = ""
        var areaCode = ""

        for (var x = 0; x < railcamModel.trainList.count; x++)
        {
            headCode = railcamModel.trainList.get(x).headcode;
            areaCode = railcamModel.trainList.get(x).buid.substring(0,2);

            if (headCode === "" || areaCode === "")
                continue;

            var actualURL = url.replace("{HEADCODE}", headCode).replace("{AREACODE}", areaCode);

             browserURLList.append({"title": "Train Times for " + headCode, "url": actualURL, "width" : 515, "zoom": 0.75});
        }

        // add YouTube chat
        url = getLink("youtube_chat");
        if (url !== undefined)
            browserURLList.append({"title": "YouTube Chat", "url": url, "width" : 350, "zoom": 1.0});

        // add RailCam chat
        url = getLink("railcam_chat");
        if (url !== undefined)
            browserURLList.append({"title": "RailCam Chat", "url": url, "width" : 400, "zoom": 1.0});

        // add website
        for (var y = 0; y < 10; y++)
        {
            url = getLink("website" + y);
            if (url !== undefined)
            {
                var list = url.split("|");
                if (list.length === 4)
                {
                    var title = list[0];
                    var width = parseInt(list[1]);
                    var zoom = parseFloat(list[2]);
                    var actualurl = list[3];
                    browserURLList.append({"title": title, "url": actualurl, "width" : width, "zoom": zoom});
                }
                else
                    browserURLList.append({"title": "Website", "url": url, "width" : 500, "zoom": 0.8});
            }
        }

        // if a RailCam feed add 'On The Camera Today/Tomorrow' webpages
        if (player === "RailCam")
        {
            browserURLList.append({"title": "RailCam - On the cameras today", "url": "http://news.railcam.uk/index.php/category/today/", "width" : 500, "zoom": 1.0});
            browserURLList.append({"title": "RailCam - On the cameras tomorrow", "url": "http://news.railcam.uk/index.php/category/tomorrow/", "width" : 500, "zoom": 1.0});
        }

        // TODO add other web urls here
    }

    function updateRailCamMiniDiagram(url)
    {
        railcamMiniDiagram.source = "";
        railcamMiniDiagram.source = url;
    }

    function updateRailcamApproach()
    {
        if (infoPanel.visible || player !== "RailCam")
        {
            railcamApproaching.visible = false;
            railcamMiniDiagram.visible = false;
        }
        else
        {
            railcamApproaching.hasData = (getLink("railcam_approach") !== undefined);
            railcamMiniDiagram.hasDiagram = (getLink("railcam_minidiagram") !== undefined);

            railcamApproaching.visible = showRailcamApproach;
            railcamMiniDiagram.visible = showRailcamDiagram;
        }
    }

    function nextURL()
    {
        browserURLList.currentIndex++

        if (browserURLList.currentIndex >= browserURLList.count)
            browserURLList.currentIndex = 0;
    }

    function previousURL()
    {
        browserURLList.currentIndex--;

        if (browserURLList.currentIndex < 0)
            browserURLList.currentIndex = browserURLList.count - 1;
    }
}

