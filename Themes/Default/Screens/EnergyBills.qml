import QtQuick 2.7
import QtQuick.Controls 1.5
import QtWebEngine 1.5
import Base 1.0
import Models 1.0

import "../../../Util.js" as Util

BaseScreen
{
    defaultFocusItem: browser

    property int billIdx: 0
    property string activeFuel: "Gas"

    Component.onCompleted:
    {
        showTitle(true, "Fuel Bill Viewer (Gas)");
        showTime(true);
        showTicker(false);
        muteAudio(false);
    }

    FuelBillsModel
    {
        id: gasBills
        source: settings.energyDataDir + "/bills/Gas_Bills.xml"
        onLoaded:
        {
            showTitle (true, "Fuel Bill Viewer (" + gasBills.get(billIdx).name + ")");
            browser.url = gasBills.get(billIdx).url
        }
    }

    FuelBillsModel
    {
        id: electricBills
        source: settings.energyDataDir + "/bills/Electric_Bills.xml"
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
            if (billIdx === gasBills.count - 1)
            {
                errorSound.play();
                return;
            }
            else
            {
                returnSound.play();
                billIdx++;
            }

            if (activeFuel === "Gas")
            {
                showTitle (true, "Fuel Bill Viewer (" + gasBills.get(billIdx).name + ")");
                browser.url = gasBills.get(billIdx).url;
            }
            else
            {
                showTitle (true, "Fuel Bill Viewer (" + electricBills.get(billIdx).name + ")");
                browser.url = electricBills.get(billIdx).url;
            }
        }
    }

    Action
    {
        id: greenAction
        shortcut: "F2"
        enabled: browser.focus
        onTriggered:
        {
            if (billIdx === 0)
            {
                errorSound.play();
                return;
            }
            else
            {
                returnSound.play();
                billIdx--;
            }

            if (activeFuel === "Gas")
            {
                showTitle (true, "Fuel Bill Viewer (" + gasBills.get(billIdx).name + ")");
                browser.url = gasBills.get(billIdx).url;
            }
            else
            {
                showTitle (true, "Fuel Bill Viewer (" + electricBills.get(billIdx).name + ")");
                browser.url = electricBills.get(billIdx).url;
            }
        }
    }

    Action
    {
        id: yellowAction
        shortcut: "F3"
        enabled: browser.focus
        onTriggered:
        {
            if (activeFuel === "Electric")
                activeFuel = "Gas";
            else if (activeFuel === "Gas")
                activeFuel = "Electric";

            footer.yellowText = "Showing (" + activeFuel + ")";

            if (activeFuel === "Gas")
            {
                showTitle (true, "Fuel Bill Viewer (" + gasBills.get(billIdx).name + ")");
                browser.url = gasBills.get(billIdx).url;
            }
            else
            {
                showTitle (true, "Fuel Bill Viewer (" + electricBills.get(billIdx).name + ")");
                browser.url = electricBills.get(billIdx).url;
            }
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

    WebEngineView
    {
        id: browser
        x:  xscale(10);
        y:  yscale(50);
        width: parent.width - xscale(20);
        height: parent.height - yscale(100)

        settings.pluginsEnabled: true
        settings.javascriptEnabled: true
        settings.javascriptCanOpenWindows: true
    }

    Footer
    {
        id: footer
        redText: "Previous Bill"
        greenText: "Next Bill"
        yellowText: "Fuel (Gas)"
        blueText: ""
    }
}
