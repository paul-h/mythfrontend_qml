import QtQuick 2.0
import QtQuick.Controls 1.4

Item
{
    id: screenBackground
    property alias title: screenTitle.text
    property alias showImage: background.visible
    property alias showTitle: screenTitle.visible
    property alias showTime: time.visible
    property alias showVideo: videoPlayer.visible
    property alias showTicker: ticker.visible
    property alias showBusyIndicator: busyIndicator.running

    function setTitle (show, newTitle)
    {
        screenTitle.visible = show;
        screenTitle.text = newTitle;
    }

    function setTicker(show, newText)
    {
        ticker.visible = show;
        ticker.text = newText;
    }

    function addTickerItem(id, item)
    {
        ticker.model.append({"id": id, "text": item})
    }

    function clearTickerItems()
    {
        ticker.model.clear();
    }

    function muteAudio(mute)
    {
        videoPlayer.setMute(mute);
    }

    function setVideo(video)
    {
        videoPlayer.source = video;
    }

    function pauseVideo(pause)
    {
        if (videoPlayer.visible)
        {
            if (pause)
                videoPlayer.pause();
            else
                videoPlayer.play();
        }
    }

    x: 0; y : 0; width: window.width; height: window.height

    // background video
    VideoPlayerQmlVLC
    {
        id: videoPlayer
        anchors.fill: parent
        visible: false
        loop: true;

        Component.onCompleted:
        {
            if (showVideo)
            {
                setLoopMode(true);
            }
        }

        Component.onDestruction:
        {
            if (showVideo)
            {
                stop();
            }
        }
    }

    // background image
    Image
    {
        id: background
        visible: true
        anchors.fill: parent
        source: mythUtils.findThemeFile(theme.backgroundImage)
    }

    // screen title
    TitleText
    {
        id: screenTitle
        text: title
        width: 900
        visible : true
    }

    // time/date text
    DigitalClock
    {
        id: time
        x: xscale(750); y: yscale(0); width: xscale(500); height: yscale(50)
        format: "ddd MMM dd, HH:mm:ss"
        visible: true
    }

    Scroller
    {
        id: ticker
        x: xscale(0); y: window.height - yscale(40); width: window.width; height: yscale(40)
        visible: false
    }

    BusyIndicator
    {
        id: busyIndicator
        x: xscale(500); y: yscale(5); z:99
        running: false
    }

    Component.onCompleted:
    {
        if (showVideo)
            videoPlayer.source = "file://" + mythUtils.findThemeFile(theme.backgroundVideo);
    }
}
