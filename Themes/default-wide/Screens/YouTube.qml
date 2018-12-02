import QtQuick 2.0
import QtQuick.Controls 1.4
import QtWebEngine 1.3
import Base 1.0

BaseScreen
{
    id: root
    defaultFocusItem: browser
    property alias url: browser.url
    property bool fullscreen: true

    Component.onCompleted:
    {
        showTitle(false, "");
        showTime(false);
        showTicker(false);
        showMouse(true);
        pauseVideo(true);
        showVideo(false);
    }

    Component.onDestruction:
    {
        showMouse(false)
        pauseVideo(false);
    }

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
        url: "https://www.youtube.com/TV"
        settings.pluginsEnabled : true
    }
}

