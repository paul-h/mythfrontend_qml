import QtQuick 2.0
import Base 1.0
import mythqml.net 1.0

Item
{
    property var    defaultFocusItem: undefined
    property var    previousFocusItem: undefined

    property bool   oldShowTitle: false
    property string oldTitle: ""

    property bool   oldShowTicker: false
    property bool   oldShowTime: false
    property bool   oldShowVideo: false
    property bool   oldShowImage: false
    property bool   oldMuteAudio: false

    property string oldHelpURL: ""

    property bool   isPanel: (parent.objectName == "panelstack" || parent.objectName == "themedpanel")

    // private properties
    property double _wmult: width / 1280
    property double _hmult: height / 720

    function _xscale(x)
    {
        return x * _wmult
    }

    function _yscale(y)
    {
        return y * _hmult
    }

    signal stateSaved()

    x: 0; y: 0; width: parent.width; height: parent.height

    // screen title
    TitleText
    {
        id: screenTitle
        x: 20
        width: parent.width - xscale(200)
        visible : true
    }

    Keys.onEscapePressed:
    {
        event.accepted = handleEscape();
    }

    Keys.onLeftPressed:
    {
        if (isPanel && previousFocusItem)
            previousFocusItem.focus = true
    }

    function handleEscape()
    {
        var res = true;

        if (!isPanel)
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
        else
        {
            themedPanel.handleEscape();
        }

        return res;
    }

    function showTitle(show, newTitle)
    {
        if (isPanel)
        {
            screenTitle.visible = show
            if (newTitle)
                screenTitle.text = newTitle;
        }
        else
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
        screenBackground.showVideo = show && theme.backgroundVideo != "";
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

    function setHelp(url)
    {
        screenBackground.helpURL = url;
    }

    function handleCommand(command)
    {
        log.debug(Verbose.GUI, "BaseScreen: handle command - " + command);
        return false;
    }

    function handleSearch(message)
    {
        log.debug(Verbose.GUI, "BaseScreen: handle search - " + message);
        return false;
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

        oldHelpURL = screenBackground.helpURL;

        stateSaved();
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

        screenBackground.helpURL = oldHelpURL;
    }
}
