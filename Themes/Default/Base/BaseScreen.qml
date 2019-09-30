import QtQuick 2.0
import Base 1.0

Item
{
    property var    defaultFocusItem: undefined

    property bool   oldShowTitle: false
    property string oldTitle: ""

    property bool   oldShowTicker: false
    property bool   oldShowTime: false
    property bool   oldShowVideo: false
    property bool   oldShowImage: false
    property bool   oldMuteAudio: false

    x: 0; y: 0; width: parent.width; height: parent.height

    Keys.onEscapePressed:
    {
        if (stack.depth > 1)
        {
            escapeSound.play();
            stack.pop();
        }
        else
        {
            if (exitOnEscape)
            {
                escapeSound.play();
                quit();
            }
            else
                errorSound.play();
        }
    }

    function showTitle (show, newTitle)
    {
        screenBackground.setTitle(show, newTitle);
    }

    function showTicker(show)
    {
        screenBackground.showTicker = show;
    }

    function showTime(show)
    {
        screenBackground.showTime = show;
    }

    function showVideo(show)
    {
        screenBackground.showVideo = show;
    }

    function showImage(show)
    {
        screenBackground.showImage = show;
    }

    function muteAudio(mute)
    {
        screenBackground.muteAudio = mute;
    }

    function pauseVideo(pause)
    {
        screenBackground.pauseVideo(pause);
    }

    Component.onCompleted:
    {
        oldShowTitle = screenBackground.showTitle;
        oldTitle = screenBackground.title;

        oldShowTicker = screenBackground.showTicker;
        oldShowTime = screenBackground.showTime;
        oldShowVideo = screenBackground.showVideo;
        oldShowImage = screenBackground.showImage;
        oldMuteAudio = screenBackground.muteAudio;
    }

    Component.onDestruction:
    {
        screenBackground.showTitle = oldShowTitle;
        screenBackground.title = oldTitle;

        screenBackground.showTicker = oldShowTicker;
        screenBackground.showTime = oldShowTime;
        screenBackground.showVideo = oldShowVideo;
        screenBackground.showImage = oldShowImage;
        screenBackground.muteAudio = oldMuteAudio;
    }
}
