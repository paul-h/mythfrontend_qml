import QtQuick 2.7
import QtQuick.Controls 1.5
import QtWebEngine 1.5
import Base 1.0
import Models 1.0
import Qt.labs.folderlistmodel 2.15

import "../../../Util.js" as Util

BaseScreen
{
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
        folder: settings.bankingDataDir.replace("file://", "")
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
        onTriggered:
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
    }

    Action
    {
        id: greenAction
        shortcut: "F2"
        enabled: browser.focus
        onTriggered:
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
            browser.url = browser.url = folderModel.get(statementIdx, "fileUrl");;
        }
    }

    Action
    {
        id: yellowAction
        shortcut: "F3"
        enabled: browser.focus
        onTriggered:
        {
            mythUtils.sendKeyEvent(window, Qt.Key_Return);
        }
    }

    Action
    {
        id: blueAction
        shortcut: "F5"
        enabled: browser.focus
        onTriggered:
        {
            mythUtils.sendKeyEvent(window, Qt.Key_Tab);
        }
    }

    Action
    {
        shortcut: ","
        enabled: browser.focus
        onTriggered:
        {
            mythUtils.sendKeyEvent(window, Qt.Key_Minus);
        }
    }

    Action
    {
        shortcut: "."
        enabled: browser.focus
        onTriggered:
        {
            mythUtils.sendKeyEvent(window, Qt.Key_Equal);
        }
    }

    Action
    {
        shortcut: "<"
        enabled: browser.focus
        onTriggered:
        {
            mythUtils.sendKeyEvent(window, Qt.Key_Minus);
        }
    }

    Action
    {
        shortcut: ">"
        enabled: browser.focus
        onTriggered:
        {
            mythUtils.sendKeyEvent(window, Qt.Key_Equal);
        }
    }

    BaseWebBrowser
    {
        id: browser
        x:  xscale(10);
        y:  yscale(50);
        width: parent.width - xscale(20);
        height: parent.height - yscale(100)
        mouseModeShortcut: "F4"
    }

    Footer
    {
        id: footer
        redText: "Previous Statement"
        greenText: "Next Statement"
        yellowText: ""
        blueText: "Mouse Mode (Off)"
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
