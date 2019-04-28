import QtQuick 2.0
import QtQuick.Controls 1.4
import QtWebEngine 1.3
import Base 1.0

BaseScreen
{
    id: root
    defaultFocusItem: browser
    property string url: ""

    // one of VLC, BROWSER, YOUTUBE
    property string type: "VLC"
    onTypeChanged: switchType(type)
    onUrlChanged: switchURL(url)

    Component.onDestruction: showMouse(false)

    Action
    {
        shortcut: "Escape"
        onTriggered: if (stack.depth > 1) {stack.pop(); escapeSound.play();} else Qt.quit();
    }

    WebEngineView
    {
        id: browser
        x: 0
        y: 0
        width: parent.width
        height: parent.height
        visible: false;
        url: "https://www.youtube.com/TV"
        settings.pluginsEnabled : true
    }

    VideoPlayerQmlVLC
    {
        id: vlcPlayer

        visible: false;

        onPlaybackEnded:
        {
            stop();
            stack.pop();
        }
    }

    function switchType(newType)
    {
        if (newType === root.type)
            return;

        if (newType === "VLC")
        {
            browser.visible = false;
            vlcPlayer.visible = true;
            showMouse(false);
        }
        else if (newType === "BROWSER")
        {
            browser.visible = true;
            vlcPlayer.visible = false;
            showMouse(true);
        }
        else if (newType === "YOUTUBE")
        {
            browser.visible = true;
            vlcPlayer.visible = false;
            showMouse(true);
        }
        else
        {
            console.log("Got unknown player type '" + newType + "' in MediaPlayer!");
            return;
        }

        type = newType;
    }

    function switchURL(newURL)
    {
        if (roor.type === "VLC")
        {
            vlcPlayer.source = newURL;
        }
        else if (newType === "BROWSER")
        {
            browser.url = newURL;
        }
        else if (newType === "YOUTUBE")
        {
            browser.url = newURL;
        }
        else
        {
            console.log("Unknown player type '" + root.type + "' in MediaPlayer!");
            return;
        }
    }
}

