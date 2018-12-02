import QtQuick 2.0
import QmlVlc 0.1
import QtWebEngine 1.3

Item
{
    id: root
    property string source: ""
    property bool loop: false
    property bool playbackStarted: false
    property bool muteAudio: false
    property int playerState: -1
    property int volume: 0
    property int position: 0
    property int duration: 0

    signal playbackEnded()
    signal showMessage(string message, int timeOut)

    property bool _playerLoaded: false

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
        enabled: visible
        backgroundColor: "black"
        url: if (visible) mythUtils.findThemeFile("HTML/YouTube.html"); else "";
        settings.pluginsEnabled : true

        onLoadingChanged:
        {
            if (loadRequest.status == WebEngineLoadRequest.LoadSucceededStatus && root.source != "")
            {
                _playerLoaded = true;
                runJavaScript("loadVideo(" + root.source + ")");
                statusUpdateTimer.start();
            }
        }

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
            browser.runJavaScript("getVolume();", function (result) { root.volume = result;});
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
            root.volume = Math.max(0, root.volume + amount);
        else
            root.volume = Math.min(100, root.volume + amount);

        browser.runJavaScript("changeVolume(" + root.volume + ");");

        showMessage("Volume: " + root.volume + "%", settings.osdTimeoutMedium);
    }

    function getMuted()
    {
        return root.muteAudio;
    }

    function setMute(mute)
    {
        if (!_playerLoaded)
            return;

        root.muteAudio = mute;

        browser.runJavaScript("setMute(" + mute + ");");
    }

    function toggleMute()
    {
        if (!_playerLoaded)
            return;

        root.muteAudio = !root.muteAudio;

        browser.runJavaScript("setMute(" + root.muteAudio + ");");
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

    function takeSnapshot(filename)
    {
        console.info("saving snapshot to: " + filename);
        browser.grabToImage(function(result)
                                 {
                                     result.saveToFile(filename);
                                 });
        showMessage("Snapshot Saved", settings.osdTimeoutMedium);
    }
}
