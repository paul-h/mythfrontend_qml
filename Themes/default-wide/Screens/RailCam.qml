import QtQuick 2.0
import QtQuick.Controls 1.4
import QtWebEngine 1.5
import Base 1.0

BaseScreen
{
    id: root
    defaultFocusItem: videoPlayer
    property alias videoUrl: videoPlayer.url
    property alias website: browser.url
    property bool fullscreen: true
    property alias zoomFactor: browser.zoomFactor

    Component.onCompleted:
    {
        showTitle(false, "");
        showTime(false);
        showTicker(false);
        showMouse(true);

        browser.backgroundColor = "transparent";
    }

    Component.onDestruction: showMouse(false)

    Action
    {
        shortcut: "Escape"
        onTriggered: if (stack.depth > 1) {stack.pop(); escapeSound.play();} else Qt.quit();
    }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_M)
        {
            browser.visible = !browser.visible
            videoPlayer.focus = true
        }
        else if (event.key === Qt.Key_F1)
        {
            // RED
            browser.visible = !browser.visible
            videoPlayer.focus = true
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW
        }
        else if (event.key === Qt.Key_F4)
        {
            //BLUE
        }
    }

    WebEngineView
    {
        id: videoPlayer
        x: 0
        y: 0
        width: parent.width
        height: parent.height
        url: ""
        settings.pluginsEnabled: true
    }

    WebEngineView
    {
        id: browser
        x: 0
        y: 0
        width: 10;
        height: 10;

        visible: false
        enabled: visible

        settings.pluginsEnabled: true

        onLoadingChanged:
        {
            if (loadRequest.status == WebEngineLoadRequest.LoadSucceededStatus)
            {
                x = (parent.width - contentsSize.width) / 2;
                y = parent.height - contentsSize.height - yscale(20);
                width = contentsSize.width;
                height = contentsSize.height;
            }
        }
    }
}

