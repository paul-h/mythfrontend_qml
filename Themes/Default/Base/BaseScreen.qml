import QtQuick
import Base 1.0
import mythqml.net 1.0

Item
{
    property var    defaultFocusItem: undefined
    property var    previousFocusItem: undefined

    property bool reloadingTheme: false
    property bool closeOnEscape: true

    property bool   isPanel: (parent.objectName == "panelstack" || parent.objectName == "themedpanel")

    // private properties
    property double _wmult: width / 1280
    property double _hmult: height / 720

    property bool _showTitle: true
    property string _title: ""
    property bool _showTicker: false
    property bool _showTime: true
    property bool _showVideo: theme.backgroundVideo != undefined
    property bool _showImage: !showVideo
    property bool _muteAudio: false
    property string _helpURL: "https://mythqml.net/help/general.php#top"

    function _xscale(x)
    {
        return x * _wmult
    }

    function _yscale(y)
    {
        return y * _hmult
    }

    x: 0; y: 0; width: parent.width; height: parent.height

    // screen title
    TitleText
    {
        id: screenTitle
        x: 20
        width: parent.width - xscale(200)
        visible : true
    }

    Keys.onEscapePressed: event =>
    {
         if (!closeOnEscape)
            event.accepted = false;
        else
            event.accepted = handleEscape();
    }

    Keys.onLeftPressed: event =>
    {
        if (isPanel && previousFocusItem)
            previousFocusItem.focus = true
        else
            event.accepted = false;
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
        if (newTitle != null)
            objectName = newTitle;

        _showTitle = show;
        _title = newTitle != null ? newTitle : "";

        if (isPanel)
        {
            screenTitle.visible = show
            if (newTitle != null)
                screenTitle.text = newTitle;
        }
        else
            screenBackground.setTitle(show, newTitle);
    }

    function showTicker(show)
    {
        _showTicker = show;
        screenBackground.showTicker = show;
    }

    function showTime(show)
    {
        _showTime = show;
        screenBackground.showTime = show;
    }

    function showVideo(show)
    {
        _showVideo = show;
        screenBackground.showVideo = (show && theme.backgroundVideo != undefined);
    }

    function showImage(show)
    {
        _showImage = show;
        screenBackground.showImage = show;
    }

    function muteAudio(mute)
    {
        _muteAudio = mute;
        screenBackground.muteAudio = mute;
    }

    function pauseVideo(pause)
    {
        screenBackground.pauseVideo(pause);
    }

    function setHelp(url)
    {
        _helpURL = url;
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

    function handleResult(message)
    {
        log.debug(Verbose.NETWORK, "BaseScreen: handle search - " + message);
    }

    function restoreSettings()
    {
        screenBackground.showTitle = _showTitle;
        screenBackground.title = _title;

        screenBackground.showTicker = _showTicker;
        screenBackground.showTime = _showTime;
        screenBackground.showVideo = _showVideo;
        screenBackground.showImage = _showImage;
        screenBackground.muteAudio = _muteAudio;

        screenBackground.helpURL = _helpURL;
    }
}
