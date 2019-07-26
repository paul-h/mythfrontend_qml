import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0
import QtWebEngine 1.3
import Base 1.0
import Process 1.0
import QtAV 1.5
import SortFilterProxyModel 0.2

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

    property bool _playbackStarted: false

    signal playbackEnded()

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
        border.width: root.showBorder ? xscale(5) : 0
        border.color: root.focus ? "green" : "white"
    }

    WebEngineView
    {
        id: webPlayer
        visible: false
        enabled: visible
        anchors.fill: parent
        anchors.margins: playerRect.border.width
        url: ""
        settings.pluginsEnabled: true
        settings.javascriptEnabled: true
//        settings.playbackRequiresUserGesture: false
        audioMuted: false;

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
        id: railcamBrowser
        x: 0
        y: 0
        width: 10;
        height: 10;

        zoomFactor: parent.width / xscale(1280)
        visible: false
        enabled: visible

        settings.pluginsEnabled: true

        onLoadingChanged:
        {
            if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus)
            {
                x = (parent.width - contentsSize.width) / 2;
                y = parent.height - contentsSize.height - yscale(20);
                width = contentsSize.width;
                height = contentsSize.height;
            }
        }
    }

    VideoPlayerYT
    {
        id: youtubePlayer
        visible: false
        enabled: visible
        anchors.fill: parent
        anchors.margins: xscale(5)

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
        anchors.margins: xscale(5)

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
        anchors.margins: xscale(5)

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

    Timer
    {
        id: infoTimer
        interval: 6000; running: false; repeat: false
        onTriggered: infoPanel.visible = false;
    }

    BaseBackground
    {
        id: infoPanel
        x: xscale(10); y: parent.height - yscale(170); width: parent.width - xscale(20); height: yscale(110)
        visible: false

        TitleText
        {
            id: title
            x: xscale(10); y: yscale(5); width: parent.width - xscale(20)
            text:
            {
                if (feedSource.feedList.get(feedSource.currentFeed).title !== "")
                    return feedSource.feedList.get(feedSource.currentFeed).title
                else
                    return feedSource.feedList.get(feedSource.currentFeed).url
            }

            verticalAlignment: Text.AlignTop
        }

        InfoText
        {
            id: pos
            x: xscale(50); y: yscale(45)
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
            x: parent.width - width - xscale(15); y: yscale(45)
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
            x: parent.width - width - xscale(15); y: yscale(0)
            width: xscale(380)
            text: feedSource.currentFeed + 1 + " of " + feedSource.feedCount + " (" + feedSource.feedName + ")"

            horizontalAlignment: Text.AlignRight
        }

        InfoText
        {
            id: currPlayer
            x: parent.width - width - xscale(15); y: yscale(24)
            width: xscale(380)
            text: getActivePlayer();

            horizontalAlignment: Text.AlignRight
        }


        RowLayout
        {
            id: toolbar
            opacity: .55
            spacing: xscale(10)
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: spacing
            anchors.leftMargin: spacing * xscale(1.5)
            anchors.rightMargin: spacing * xscale(1.5)
            Behavior on anchors.bottomMargin { PropertyAnimation { duration: 250} }
            Rectangle
            {
                height: yscale(24)
                width: height
                radius: width * xscale(0.25)
                color: 'black'
                border.width: xscale(1)
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
                height: yscale(10)
                color: 'transparent'
                border.width: xscale(1)
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
                    anchors.margins: xscale(2)
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
        x: xscale(100); y: yscale(120); width: xscale(400); height: yscale(110)
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

    function startPlayback()
    {
        if (feedSource.feedList === undefined)
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
        webPlayer.url = mythUtils.findThemeFile("HTML/blank.html");;

        // we always need to restart the StreamLink process even if it is already running
        if (newPlayer === "StreamLink")
        {
            youtubePlayer.visible = false;
            webPlayer.visible = false;
            vlcPlayer.visible = false;
            qtAVPlayer.visible = false;

            var url = feedSource.feedList.get(feedSource.currentFeed).url;
            var command = "streamlink"
            var parameters = ["--player-external-http", "--player-external-http-port", streamlinkPort, url, "best"]

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
            console.log("Got unknown player '" + newPlayer + "' in MediaPlayer!");
            return;
        }

        root.player = newPlayer;
    }

    function switchURL(newURL)
    {
        if (feedSource.feedName == "ZoneMinder Cameras")
            newURL += "&connkey=" + Util.randomIntFromRange(0, 999999);

        railcamBrowser.visible = false;
        railcamBrowser.url = "";

        if (root.player === "VLC" || root.player === "Internal")
        {
            vlcPlayer.source = newURL;
        }
        else if (root.player === "FFMPEG")
        {
            qtAVPlayer.source = newURL;
        }
        else if (root.player === "WebBrowser" || root.player === "RailCam" || root.player === "YouTubeTV")
        {
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
            console.log("Unknown player '" + root.player + "' in MediaPlayer!");
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
            webPlayer.url = "";
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

    function takeSnapshot()
    {
        var filename;
        var index = 0;
        var padding = "";

        if (feedSource.feedList.get(feedSource.currentFeed).url.indexOf("file://") === 0)
            filename = feedSource.feedList.get(feedSource.currentFeed).url.substring(7, feedSource.feedList.get(feedSource.currentFeed).url.length);
        else
            filename = settings.configPath + "snapshot";

        if (mythUtils.fileExists(filename + ".png"))
        {
            do
            {
                index += 1;

                if (index < 10)
                    padding = "00";
                else if (index < 100)
                    padding = "0";

            }  while (mythUtils.fileExists(filename + padding + index + ".png"));

            filename = filename + padding + index + ".png";
        }
        else
           filename = filename + ".png";



        if (getActivePlayer() === "VLC")
            vlcPlayer.takeSnapshot(filename)
        else if (getActivePlayer() === "YOUTUBE")
            youtubePlayer.takeSnapshot(filename)
        else if (getActivePlayer() === "QTAV")
            qtAVPlayer.takeSnapshot(filename)
        else
            console.log("Media Player '" + root.player + "' does not support taking snapshots");
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
    }

    function showRailCamDiagram()
    {
        if (feedSource.feedList.get(feedSource.currentFeed).player === "RailCam")
        {
            if (railcamBrowser.visible)
            {
                railcamBrowser.url = "";
                railcamBrowser.visible = false;
            }
            else
            {
                railcamBrowser.zoomFactor = xscale(feedSource.feedList.get(feedSource.currentFeed).zoom)
                railcamBrowser.url = feedSource.feedList.get(feedSource.currentFeed).website;
                railcamBrowser.visible = true;
            }
        }
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
}

