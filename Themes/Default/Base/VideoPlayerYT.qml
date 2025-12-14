import QtQuick 2.0
import QmlVlc 0.1
import QtWebEngine 1.3

Item
{
    id: root
    property string source: ""
    property bool loop: false
    property bool playbackStarted: false

    property int playerState: -1

    property int position: 0
    property int duration: 0

    signal mediaStatusChanged(int mediaStatus)
    signal playbackStatusChanged(int playbackStatus)
    signal showMessage(string message, int timeOut)

    // private properties
    property bool _muteAudio: false
    property int _volume: 100
    property bool _playerLoaded: false

    onPlayerStateChanged:
    {
        if (playerState === -1) // unstarted
        {
            root.mediaStatusChanged(MediaPlayers.MediaStatus.Loading);
        }

        if (playerState === 0) // ended
        {
            root.mediaStatusChanged(MediaPlayers.MediaStatus.Ended);
            root.playbackStatusChanged(MediaPlayers.PlaybackStatus.Stopped); // ???
        }

        if (playerState === 1) // playing
        {
            playbackStarted = true;
            root.mediaStatusChanged(MediaPlayers.MediaStatus.Buffered);
            root.playbackStatusChanged(MediaPlayers.PlaybackStatus.Playing);
        }

        if (playerState === 2) // paused
        {
            root.playbackStatusChanged(MediaPlayers.PlaybackStatus.Paused);
        }

        if (playerState === 3) // buffering
        {
            root.mediaStatusChanged(MediaPlayers.MediaStatus.Buffering);
        }

        if (playerState === 5) // video cued
        {
            root.mediaStatusChanged(MediaPlayers.MediaStatus.Loaded);
        }
    }

    onSourceChanged:
    {
         if (_playerLoaded)
            browser.runJavaScript("loadVideo(" + source + ");");
    }

    WebEngineView
    {
        id: browser

        anchors.fill: parent
        visible: parent.visible
        focus: visible
        enabled: visible
        backgroundColor: "black"
        url: if (visible) "https://mythqml.net/yt_player/YouTube.html"; else "";
        settings.pluginsEnabled: true
//        settings.playbackRequiresUserGesture: false

        profile: playerSources.youtubeWEProfile

        onLoadingChanged:
        {
            if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus && root.source !== "")
            {
                _playerLoaded = true;
                runJavaScript("loadVideo(" + root.source + ")");
                browser.runJavaScript("changeVolume(" + root._volume + ");");
                browser.runJavaScript("setMute(" + root._muteAudio + ");");
                statusUpdateTimer.start();
                setSize(width, height);
            }
        }

        Component.onCompleted: settings.playbackRequiresUserGesture = false;
        onWidthChanged: setSize(width, height)
        onHeightChanged: setSize(width, height)
    }

    Timer
    {
        id: statusUpdateTimer
        interval: 1000; running: false; repeat: true
        onTriggered:
        {
            browser.runJavaScript("getPlayerState();", function (result) { root.playerState = result;});
            browser.runJavaScript("getPosition();", function (result) { root.position = result * 1000;});
            browser.runJavaScript("getDuration();", function (result) { root.duration = result * 1000;});
            browser.runJavaScript("getVolume();", function (result) { root._volume = result;});
        }
    }

    function setSize(width, height)
    {
        if (_playerLoaded)
            browser.runJavaScript("setSize(" + width + "," + height + ");");
    }

    function isPlaying()
    {
        return root.playerState === 1;
    }

    function play()
    {
        if (_playerLoaded && !isPlaying())
            browser.runJavaScript("playVideo();");
    }

    function stop()
    {
        if (_playerLoaded  && isPlaying())
            browser.runJavaScript("stopVideo();");
    }

    function pause()
    {
        if (_playerLoaded)
            browser.runJavaScript("pauseVideo();");
    }

    function getPaused()
    {
        return root.playerState === 2;
    }

    function togglePaused()
    {
        if (_playerLoaded)
            browser.runJavaScript("togglePaused();");
    }

    function skipBack(time)
    {
        if (_playerLoaded)
            browser.runJavaScript("skipBack(" + time + ");");
    }

    function skipForward(time)
    {
        if (_playerLoaded)
            browser.runJavaScript("skipForward(" + time + ");");
    }

    function changeVolume(amount)
    {
        if (!_playerLoaded)
            return;

        if (amount < 0)
            root._volume = Math.max(0, root._volume + amount);
        else
            root._volume = Math.min(100, root._volume + amount);

        if (_playerLoaded)
            browser.runJavaScript("changeVolume(" + root._volume + ");");

        showMessage("Volume: " + root._volume + "%", settings.osdTimeoutMedium);
    }

    function getVolume()
    {
        return root._volume;
    }

    function setVolume(volume)
    {
        root._volume = volume;

        if (_playerLoaded)
            browser.runJavaScript("changeVolume(" + root._volume + ");");
    }

    function getMute()
    {
        return root._muteAudio;
    }

    function setMute(mute)
    {
        if (!_playerLoaded)
            return;

        root._muteAudio = mute;

        browser.runJavaScript("setMute(" + mute + ");");
    }

    function toggleMute()
    {
        if (!_playerLoaded)
            return;

        root._muteAudio = !root._muteAudio;

        browser.runJavaScript("setMute(" + root._muteAudio + ");");
    }

    function getPosition()
    {
        return root.position;
    }

    function getDuration()
    {
        return root.duration;
    }

    function setLoopMode(doLoop)
    {
        if (_playerLoaded)
            browser.runJavaScript("setLoopMode(" + doLoop + ");");
    }

    function toggleInterlacer()
    {
        showMessage("Deinterlacers are not supported by this player", settings.osdTimeoutMedium);
    }

    function setFillMode(mode)
    {
        showMessage("FillMode is not supported by this player", settings.osdTimeoutMedium);
    }
}
