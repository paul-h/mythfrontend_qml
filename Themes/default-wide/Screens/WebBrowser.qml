import QtQuick 2.0
import QtQuick.Controls 1.4
import QtWebEngine 1.3
import Base 1.0

BaseScreen
{
    defaultFocusItem: browser
    property alias url: browser.url

    Component.onCompleted:
    {
        showTitle(true, "Web Browser");
        showTime(false);
        showTicker(false);
        showMouse(true);
    }

    Component.onDestruction: showMouse(false)

    Action
    {
        shortcut: "Escape"
        onTriggered: if (stack.depth > 1) {stack.pop(); escapeSound.play();} else Qt.quit();
    }

    WebEngineView
    {
        id: browser
        x: xscale(10); y: yscale(50); width: parent.width - xscale(20); height: parent.height - yscale(60)
        url: "http://www.bbc.co.uk"
        settings.pluginsEnabled : true
    }
}

