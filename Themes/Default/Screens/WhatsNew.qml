import QtQuick
import QtQuick.Controls
import QtWebEngine

import Base 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: browser

    property bool autoShow: false
    property int currentPage: 0

    Component.onCompleted:
    {
        showTitle(true, "What's New");
        setHelp("https://mythqml.net/help/whatsnew.php#top");
        showTicker(false);

        var lastShown = parseInt(dbUtils.getSetting("LastWhatsNewShown", settings.hostName, "-1"));
        if (lastShown !== -1)
            autoShow ? currentPage = lastShown + 1 : currentPage = lastShown;
    }

    Action
    {
        id: escapeAction
        shortcut: "Escape"
        enabled: browser.focus
        onTriggered:
        {
            if (!isPanel)
            {
                if (stack.depth > 1)
                {
                    stack.pop();
                    escapeSound.play();
                }
            }
        }
    }

    Action
    {
        // red
        shortcut: "F1"
        enabled: browser.focus
        onTriggered:
        {
            if (currentPage > 0)
            {
                currentPage--;
                loadPage();
            }
        }
    }

    Action
    {
        // green
        shortcut: "F2"
        enabled: browser.focus
        onTriggered:
        {
            if (currentPage < whatsNewModel.count - 1)
            {
                currentPage++;
                loadPage();
            }
        }
    }

    Action
    {
        // yellow
        shortcut: "F3"
        enabled: browser.focus
        onTriggered: zoom(true);
    }

    Action
    {
        // blue
        shortcut: "F4"
        enabled: browser.focus
        onTriggered: zoom(false);
    }

    Action
    {
        shortcut: "+"
        onTriggered: zoom(true)
        enabled: browser.focus
    }

    Action
    {
        shortcut: "-"
        onTriggered: zoom(false)
        enabled: browser.focus
    }

    Action
    {
        shortcut: "S" // take snapshot of the screen
        enabled: browser.focus
        onTriggered: window.takeSnapshot();
    }

    Action
    {
        shortcut: "R" // for testing reset the last shown setting to -1
        enabled: browser.focus
        onTriggered: dbUtils.setSetting("LastWhatsNewShown", settings.hostName, -1);
    }

    Action
    {
        shortcut: "H" // show help screen
        enabled: browser.focus
        onTriggered: window.showHelp();
    }

    WhatsNewModel
    {
        id: whatsNewModel

        onLoaded: loadPage();
    }

    InfoText
    {
        id: posText
        x: xscale(900)
        y: yscale(0)
        width: xscale(120)
        text: currentPage + 1 + " of " + whatsNewModel.count
    }

    Rectangle
    {
        x: xscale(10)
        y: yscale(50)
        width: parent.width - xscale(20)
        height: parent.height - yscale(100)
        color: "white"
    }

    WebEngineView
    {
        id: browser
        x: xscale(10)
        y: yscale(50)
        width: parent.width - xscale(20)
        height: parent.height - yscale(100)
        zoomFactor: xscale(1.0)
        settings.pluginsEnabled: true
        settings.javascriptCanOpenWindows: true;
    }

    Footer
    {
        id: footer
        width: parent.width
        redText: "Previous News"
        greenText: "Next News"
        yellowText: "Zoom In"
        blueText: "Zoom Out"
    }

    function loadPage()
    {
        if (currentPage < 0 || currentPage >= whatsNewModel.count)
            return;

        browser.url = whatsNewModel.get(currentPage).url;

        if (currentPage > dbUtils.getSetting("LastWhatsNewShown", settings.hostName, "-1"))
            dbUtils.setSetting("LastWhatsNewShown", settings.hostName, currentPage);
    }

    function zoom(zoomIn)
    {
        if (zoomIn)
        {
            // a bug in Qt/Chromium means we have to set the zoomFactor twice for it to stick!
            browser.zoomFactor = Math.min(5,  browser.zoomFactor + 0.25);
            browser.zoomFactor = Math.min(5,  browser.zoomFactor + 0.25);
            showNotification("Zoom Factor: " + Math.round(browser.zoomFactor * 100) / 100);
        }
        else
        {
            // a bug in Qt/Chromium means we have to set the zoomFactor twice for it to stick!
            browser.zoomFactor = Math.max(0.25,  browser.zoomFactor - 0.25);
            browser.zoomFactor = Math.max(0.25,  browser.zoomFactor - 0.25);
            showNotification("Zoom Factor: " + Math.round(browser.zoomFactor * 100) / 100);
        }
    }
}
