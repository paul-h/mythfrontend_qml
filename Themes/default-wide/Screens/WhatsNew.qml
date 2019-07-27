import QtQuick 2.0
import QtQuick.Controls 1.5
import QtWebEngine 1.5
import Base 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: browser

    property int currentPage: 0

    Component.onCompleted:
    {
        showTitle(true, "What's New");
        showTicker(false);
    }

    Action
    {
        id: escapeAction
        shortcut: "Escape"
        enabled: browser.focus
        onTriggered:
        {
            escapeSound.play();
            stack.pop();
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
        onTriggered: zoom(false);
    }

    Action
    {
        // blue
        shortcut: "F4"
        enabled: browser.focus
        onTriggered: zoom(true);
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
        settings.pluginsEnabled: true
        settings.javascriptCanOpenWindows: true;
        url: mythUtils.findThemeFile("HTML/blank.html");
    }

    Footer
    {
        id: footer
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
    }

    function zoom(zoomIn)
    {
        if (zoomIn)
        {
            browser.zoomFactor = Math.min(5,  browser.zoomFactor + 0.25);
            showNotification("Zoom Factor: " + Math.round(browser.zoomFactor * 100) / 100);
        }
        else
        {
            browser.zoomFactor = Math.max(0.25,  browser.zoomFactor - 0.25);
            showNotification("Zoom Factor: " + Math.round(browser.zoomFactor * 100) / 100);
        }
    }
}
