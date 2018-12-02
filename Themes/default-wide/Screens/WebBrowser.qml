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
        id: escapeAction
        shortcut: "Escape"
        enabled: browser.focus
        onTriggered:
        {
            if (browser.canGoBack)
                browser.goBack();
            else
                if (stack.depth > 1) {stack.pop(); escapeSound.play();} else Qt.quit();
        }
    }

    Action
    {
        shortcut: "F1"
        onTriggered: mythUtils.fakeKeyPress(browser, "F");
        enabled: browser.focus
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

    WebEngineView
    {
        id: browser
        x: root.fullscreen ? 0 : xscale(10);
        y: root.fullscreen ? 0 : yscale(50);
        width: root.fullscreen ? parent.width : parent.width - xscale(20);
        height: root.fullscreen ? parent.height : parent.height - yscale(60)

        settings.pluginsEnabled: true
        settings.javascriptCanOpenWindows: true;

        onNewViewRequested:
        {
            var website = request.requestedUrl.toString();
            var zoom = zoomFactor;
            stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: website, zoomFactor: zoom}});
        }
        onFullScreenRequested: request.accept();
        onNavigationRequested: request.action = WebEngineNavigationRequest.AcceptRequest;

        //onFocusChanged: { console.log("Browser focus: " + focus); showMouse(focus); }
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

