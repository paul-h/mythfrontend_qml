import QtQuick 2.0
import QtQuick.Controls 1.4

Item
{
    id: screenBackground
    property alias title: screenTitle.text
    property alias showImage: background.visible
    property alias showSlideShow: slideShow.visible
    property alias showTitle: screenTitle.visible
    property alias showTime: time.visible
    property alias showVideo: videoPlayer.visible
    property alias showTicker: ticker.visible
    property alias showBusyIndicator: busyIndicator.running
    property bool  muteAudio: videoPlayer.getMute()
    property string helpURL: ""

    property bool  screenSaverMode: true

    onMuteAudioChanged: videoPlayer.setMute(muteAudio);

    function setTitle (show, newTitle)
    {
        screenTitle.visible = show;
        if (newTitle !== undefined)
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

    function setVideo(video)
    {
        videoPlayer.source = video;
    }

    function pauseVideo(pause)
    {
        if (videoPlayer.visible)
        {
            if (pause)
                videoPlayer.stop();
            else
                videoPlayer.play();
        }
    }

    function setSlideShow(path)
    {
        slideShow.folder = path;
    }

    function setHelpURL(url)
    {
        helpURL = url;
    }

    x: 0; y : 0; width: window.width; height: window.height

    // background image
    Image
    {
        id: background
        visible: !(videoPlayer.visible && !videoPlayer.playbackStarted)
        anchors.fill: parent
        source: mythUtils.findThemeFile(theme.backgroundImage)
    }

    // background slideshow
    SlideShow
    {
        id: slideShow
        anchors.fill: parent
        visible:  false
    }

    Snow
    {
        visible: (theme.backgroundSnow !== undefined && theme.backgroundSnow)
        enabled: visible
        imageSource: (theme.particleImage !== undefined ? mythUtils.findThemeFile(theme.particleImage) : mythUtils.findThemeFile("images/snowflake.png"))
    }

    // background video
    VideoPlayerQmlVLC
    {
        id: videoPlayer
        anchors.fill: parent
        visible: false

        Component.onCompleted:
        {
            setVolume(window.backgroundVideoVolume);

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

        onVisibleChanged: if (visible) play(); else stop()
    }

    // screen title
    TitleText
    {
        id: screenTitle
        text: title
        width: xscale(900)
        visible : true
        opacity: screenSaverMode ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: window._fadeTime } }
    }

    // time/date text
    DigitalClock
    {
        id: time
        x: xscale(750); y: yscale(0); width: xscale(500); height: yscale(50)
        format: "ddd MMM dd, HH:mm:ss"
        visible: true
        opacity: screenSaverMode ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: window._fadeTime } }
    }

    Scroller
    {
        id: ticker
        x: xscale(0); y: window.height - yscale(40); width: window.width; height: yscale(40)
        visible: false
        opacity: screenSaverMode ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: window._fadeTime } }
    }

    BusyIndicator
    {
        id: busyIndicator
        x: xscale(500); y: yscale(5); z:99
        running: false
        opacity: screenSaverMode ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: window._fadeTime } }
    }

    Component.onCompleted:
    {
        if (showVideo && theme.backgroundVideo != undefined && theme.backgroundVideo != "")
            videoPlayer.source = "file://" + settings.configPath + "Themes/Videos/" + theme.backgroundVideo;
    }
}
