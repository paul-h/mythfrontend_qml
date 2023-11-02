import QtQuick 2.0
import QtQuick.Controls 1.5
import QtWebEngine 1.5
import Base 1.0
import Dialogs 1.0

BaseScreen
{
    id: root
    defaultFocusItem: browser
    property alias url: browser.url
    property alias zoomFactor: browser.zoomFactor
    property bool fullscreen: false

    Component.onCompleted:
    {
        showTitle(!fullscreen, "Web Browser");
        setHelp("https://mythqml.net/help/web_browser.php#top");
        showTime(false);
        showTicker(false);
        pauseVideo(fullscreen);
        muteAudio(fullscreen);
        radioPlayerDialog.suspendPlayback();
    }

    Component.onDestruction:
    {
        pauseVideo(false);
        radioPlayerDialog.resumePlayback();
    }

    onFullscreenChanged: { showVideo(!fullscreen);  pauseVideo(fullscreen); }

    Action
    {
        id: escapeAction
        shortcut: "Escape"
        enabled: browser.focus
        onTriggered:
        {
            if (browser.canGoBack)
                browser.goBack();
            else
            {
                if (!isPanel)
                {
                    if (stack.depth > 1)
                    {
                        stack.pop();
                        escapeSound.play();
                    }
                }
                else
                {
                    handleEscape();
                }
            }
        }
    }

    Action
    {
        shortcut: "F8"
        onTriggered: toggleFullscreen()
        enabled: browser.focus
    }

    Action
    {
        shortcut: "+"
        onTriggered: zoom(true);
        enabled: browser.focus
    }

    Action
    {
        shortcut: "-"
        onTriggered: zoom(false);
        enabled: browser.focus
    }

    Action
    {
        shortcut: "M"
        onTriggered: popupMenu.show();
        enabled: browser.focus
    }

    Action
    {
        shortcut: "S" // take snapshot of the screen
        onTriggered: window.takeSnapshot();
        enabled: browser.focus
    }

    Rectangle
    {
        x: root.fullscreen ? 0 : xscale(10);
        y: root.fullscreen ? 0 : yscale(50);
        width: root.fullscreen ? parent.width : parent.width - xscale(20);
        height: root.fullscreen ? parent.height : parent.height - yscale(60)
        color: "white"
    }

    WebEngineView
    {
        id: browser
        x: root.fullscreen ? 0 : xscale(10);
        y: root.fullscreen ? 0 : yscale(50);
        width: root.fullscreen ? parent.width : parent.width - xscale(20);
        height: root.fullscreen ? parent.height : parent.height - yscale(60)

        settings.pluginsEnabled: true
        settings.javascriptEnabled: true
        settings.javascriptCanOpenWindows: true
        audioMuted: false;

        Component.onCompleted: settings.playbackRequiresUserGesture = false;

        onNewViewRequested:
        {
            var website = request.requestedUrl.toString();
            var zoom = zoomFactor;
            if (isPanel)
                panelStack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: website, zoomFactor: zoom}});
            else
                stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: website, zoomFactor: zoom}});
        }
        onFullScreenRequested: request.accept();
        onNavigationRequested: request.action = WebEngineNavigationRequest.AcceptRequest;
    }

     PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "Browser Options"
        width: xscale(400); height: yscale(600)

        onItemSelected:
        {
            if (itemData === "enterurl")
            {
                textEditDialog.show()
                return;
            }
            else if (itemData === "zoomin")
                zoom(true);
            else if (itemData === "zoomout")
                zoom(false);
            else if (itemData === "fullscreen")
                toggleFullscreen();

            browser.focus = true;
        }
        onCancelled:
        {
            browser.focus = true;
        }

        Component.onCompleted:
        {
            addMenuItem("", "Enter URL", "enterurl");
            addMenuItem("", "Zoom In", "zoomin");
            addMenuItem("", "Zoom Out", "zoomout");
            addMenuItem("", "Toggle Full Screen", "fullscreen");
        }
    }

    TextEditDialog
    {
        id: textEditDialog

        title: "Enter URL"
        message: "Enter URL you want to show."

        width: xscale(600); height: yscale(350)

        onResultText:
        {
            if (text.startsWith("http://") || text.startsWith("https://"))
                browser.url = text
            else
                browser.url = "http://" + text

            browser.focus = true
        }
        onCancelled:
        {
            browser.focus = true
        }
    }

    function zoom(zoomIn)
    {
        if (zoomIn)
        {
            browser.zoomFactor = Math.min(5,  browser.zoomFactor + 0.25)
        }
        else
        {
            browser.zoomFactor = Math.max(0.25,  browser.zoomFactor - 0.25)
        }
    }

    function toggleFullscreen()
    {
        root.fullscreen = !root.fullscreen;
        root.showTitle(!root.fullscreen, "Web Browser");
    }
}

