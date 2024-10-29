import QtQuick
import QtQuick.Controls
import QtWebEngine

import Base 1.0
import Dialogs 1.0

FocusScope
{
    id: root
    property alias url: browser.url
    property alias zoomFactor: browser.zoomFactor
    property alias backgroundColor: browser.backgroundColor
    property alias browser: browser

    property bool mouseMode: false

    property string mouseModeShortcut: "F1"
    property string tabShortcut: "F3"
    property string shiftTabShortcut: "F4"

    signal loaded()

    Action
    {
        shortcut: mouseModeShortcut
        onTriggered:
        {
            mouseMode = !mouseMode;

            if (mouseMode)
            {
                var pos = mythUtils.getMousePos();
                var p1 = browser.mapToGlobal(browser.x, browser.y);
                var p2 = browser.mapToGlobal(browser.x + browser.width, browser.y + browser.height);

                if (pos.x < p1.x || pos.y < p1.y | pos.x > p2.x | pos.y > p2.y)
                {
                    // move the mouse pointer to the center of the browser
                    var globalPos = browser.mapToGlobal(browser.x + (browser.width / 2), browser.y + (browser.height / 2));
                    mouseMoveTo(globalPos.x, globalPos.y);
                }
            }
        }
        enabled: focus && browser.focus
    }

    Action
    {
        shortcut: "+"
        onTriggered: zoom(true);
        enabled: focus && browser.focus
    }

    Action
    {
        shortcut: "-"
        onTriggered: zoom(false);
        enabled: focus && browser.focus
    }

    Action
    {
        shortcut: "S" // take snapshot of the screen
        onTriggered: window.takeSnapshot();
        enabled: focus && browser.focus
    }

    Action
    {
        shortcut: "Return"
        onTriggered: mouseLeftClick()
        enabled: focus && mouseMode
    }

    Action
    {
        shortcut: tabShortcut
        onTriggered: mythUtils.sendKeyEvent(window, Qt.Key_Tab);
        enabled: focus && mouseMode
    }

    Action
    {
        shortcut: shiftTabShortcut
        onTriggered: mythUtils.sendKeyEvent(window, Qt.Key_Tab, Qt.ShiftModifier);
        enabled: focus && mouseMode
    }

    Action
    {
        shortcut: "Up"
        onTriggered: mouseMove(0, -10)
        enabled: focus && mouseMode
    }

    Action
    {
        shortcut: "Down"
        onTriggered: mouseMove(0, 10)
        enabled: focus && mouseMode
    }

    Action
    {
        shortcut: "Left"
        onTriggered: mouseMove(-10, 0)
        enabled: focus && mouseMode
    }

    Action
    {
        shortcut: "Right"
        onTriggered: mouseMove(10, 0)
        enabled: focus && mouseMode
    }

    Rectangle
    {
        anchors.fill: parent
        color: "white"
    }

    WebEngineView
    {
        id: browser
        anchors.fill: parent
        focus: true
        settings.pluginsEnabled: true
        settings.javascriptEnabled: true
        settings.javascriptCanOpenWindows: true
        //settings.scrollAnimatorEnabled: true // Requires Qt6.8
        settings.allowRunningInsecureContent: true

        audioMuted: false;

        profile: playerSources.mythqmlWEProfile

        Component.onCompleted: settings.playbackRequiresUserGesture = false;

        onNewWindowRequested: request =>
        {
            var website = request.requestedUrl.toString();
            var zoom = zoomFactor;
            if (isPanel)
                panelStack.push(mythUtils.findThemeFile("Screens/WebBrowser.qml"), {url: website, zoomFactor: zoom});
            else
                stack.push(mythUtils.findThemeFile("Screens/WebBrowser.qml"), {url: website, zoomFactor: zoom});
        }
        onFullScreenRequested: request => request.accept();
        onNavigationRequested: request => request.accept();

        onLoadingChanged: loadingInfo =>
        {
            if (loadingInfo.status === WebEngineView.LoadSucceededStatus)
            {
                var feedurl = loadingInfo.url.toString();

                if (feedurl !== "")
                {
                    // start the windy.com radar animation
                    if (feedurl.includes("www.windy.com/-Weather-radar-radar"))
                    {
                        runJavaScript("document.getElementsByClassName(\"play-pause checkbox--off\")[0].click();");
                    }
                    else if (feedurl.includes("embed.windy.com/embed2.html"))
                    {
                        runJavaScript("document.getElementsByClassName(\"play-pause iconfont clickable off\")[0].click();");
                    }
                }

                loaded();
            }
        }
    }

    Image
    {
        id: mouseIcon
        x: _xscale(10); y: yscale(10); width: xscale(50); height: yscale(50)
        source: mythUtils.findThemeFile("images/mouse.png")
        visible: mouseMode
        SequentialAnimation
        {
            id: anim
            running: visible
            loops: Animation.Infinite

            PropertyAnimation
            {
                targets: [mouseIcon]
                property: "opacity"
                to: 1
                duration: 1000
            }
            PropertyAnimation
            {
                targets: [mouseIcon]
                property: "opacity"
                to: 0
                duration: 1000
            }
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
}

