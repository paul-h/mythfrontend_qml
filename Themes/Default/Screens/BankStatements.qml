import QtQuick
import QtQuick.Controls
import QtWebEngine

import Base 1.0
import Models 1.0
import Dialogs 1.0
import Qt.labs.folderlistmodel 2.15

import "../../../Util.js" as Util

BaseScreen
{
    id: root

    defaultFocusItem: browser

    property int statementIdx: 0

    Component.onCompleted:
    {
        showTitle(true, "Bank Statements Viewer");
        showTime(true);
        showTicker(false);
        muteAudio(false);
    }

    Connections
    {
        target: browser
        ignoreUnknownSignals: true

        function onMouseModeChanged()
        {
            footer.blueText = (browser.mouseMode ? "Mouse Mode (On)" : "Mouse Mode (Off)");
        }
    }

    FolderListModel
    {
        id: folderModel
        folder: settings.bankingDataDir
        nameFilters: ["*.pdf"]
        showDirsFirst: true
        caseSensitive: false
        sortReversed: true
        showOnlyReadable: true
        onStatusChanged:
        {
            if (folderModel.status == FolderListModel.Ready)
            {
                showTitle (true, "Bank Statements Viewer (" + extractDate(folderModel.get(statementIdx, "fileBaseName")) + ")");
                browser.url = folderModel.get(statementIdx, "fileUrl");
            }
        }
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
            else
            {
                handleEscape();
            }
        }
    }

    Action
    {
        id: redAction
        shortcut: "F1"
        enabled: browser.focus
        onTriggered: previousStatement()
    }

    Action
    {
        id: greenAction
        shortcut: "F2"
        enabled: browser.focus
        onTriggered: nextStatement()
    }

    Action
    {
        shortcut: "M"
        onTriggered: popupMenu.show();
        enabled: browser.focus
    }

    BaseWebBrowser
    {
        id: browser
        x:  xscale(10);
        y:  yscale(50);
        width: parent.width - xscale(20);
        height: parent.height - yscale(100)
        mouseModeShortcut: "F4"
        tabShortcut: "F5"
        shiftTabShortcut: "F6"
    }

    Footer
    {
        id: footer
        redText: "Previous Statement"
        greenText: "Next Statement"
        yellowText: ""
        blueText: "Mouse Mode (Off)"
    }

    PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "Bank Statementss Options"
        width: xscale(400); height: yscale(600)

        onItemSelected: (itemText, itemData) =>
        {
            if (itemData === "previous")
                previousStatement();
            else if (itemData === "next")
                nextStatement();
            else if (itemData === "zoomin")
                zoomIn();
            else if (itemData === "zoomout")
                zoomOut();
            else if (itemData === "mousemode")
                browser.mouseMode = !browser.mouseMode;

            browser.focus = true;
        }
        onCancelled:
        {
            browser.focus = true;
        }

        Component.onCompleted:
        {
            addMenuItem("", "Previous Statement", "previous");
            addMenuItem("", "Next Statement", "next");
            //addMenuItem("", "Zoom In", "zoomin");
            //addMenuItem("", "Zoom Out", "zoomout");
            addMenuItem("", "Toggle Mouse Mode", "mousemode");
        }
    }

    function previousStatement()
    {
        if (statementIdx === folderModel.count - 1)
        {
            errorSound.play();
            return;
        }
        else
        {
            returnSound.play();
            statementIdx++;
        }

        showTitle (true, "Bank Statements Viewer (" + extractDate(folderModel.get(statementIdx, "fileBaseName")) + ")");
        browser.url = folderModel.get(statementIdx, "fileUrl");
    }

    function nextStatement()
    {
        if (statementIdx === 0)
        {
            errorSound.play();
            return;
        }
        else
        {
            returnSound.play();
            statementIdx--;
        }

        showTitle (true, "Bank Statements Viewer (" + extractDate(folderModel.get(statementIdx, "fileBaseName")) + ")");
        browser.url = browser.url = folderModel.get(statementIdx, "fileUrl");
    }

    function zoomIn()
    {
        var x = xscale(1205);
        var y = yscale(557);
        var pos = root.mapToGlobal(x, y);
        mythUtils.mouseMove(pos.x, pos.y);
        mythUtils.mouseLeftClick(window, x, y);
    }

    function zoomOut()
    {
        var x = xscale(1206);
        var y = yscale(604);
        var pos = root.mapToGlobal(x, y);
        mythUtils.mouseMove(pos.x, pos.y);
        mythUtils.mouseLeftClick(window, x, y);
    }

    function extractDate(basename)
    {
        var day = basename.substr(6, 2);
        var month = basename.substr(4, 2);
        var year = basename.substr(0, 4);
        var date = new Date(year, month - 1, day);

        return date.toLocaleString(Qt.locale(), "dd MMMM yyyy")
    }
}
