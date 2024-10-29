import QtQuick
import QtQuick.Controls
import QtWebEngine

import Base 1.0
import Models 1.0
import Dialogs 1.0

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

    Connections
    {
        target: browser
        ignoreUnknownSignals: true

        function onMouseModeChanged()
        {
            footer.blueText = (browser.mouseMode ? "Mouse Mode (On)" : "Mouse Mode (Off)");
        }
    }

    FuelBillsModel
    {
        id: gasBills
        source: settings.energyDataDir + "/bills/Gas_Bills.xml"
        onLoaded:
        {
            showTitle (true, "Fuel Bill Viewer (" + gasBills.get(billIdx).name + ")");
            browser.url = settings.energyDataDir + "/bills/" + gasBills.get(billIdx).url
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
        onTriggered: previousBill()
    }

    Action
    {
        id: greenAction
        shortcut: "F2"
        enabled: browser.focus
        onTriggered: nextBill()
    }

    Action
    {
        id: yellowAction
        shortcut: "F3"
        enabled: browser.focus
        onTriggered: changeFuel()
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
        redText: "Previous Bill"
        greenText: "Next Bill"
        yellowText: "Fuel (Gas)"
        blueText: "Mouse Mode (Off)"
    }

    PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "Energy Bills Options"
        width: xscale(400); height: yscale(600)

        onItemSelected:
        {
            if (itemData === "previous")
                previousBill();
            else if (itemData === "next")
                nextBill();
            else if (itemData === "fuel")
                changeFuel();
            else if (itemData === "zoomin")
                zoomIn();
            else if (itemData === "zoomout")
                zoomOut;
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
            addMenuItem("", "Previous Bill", "previous");
            addMenuItem("", "Next Bill", "next");
            addMenuItem("", "Change Fuel", "fuel");
            //addMenuItem("", "Zoom In", "zoomin");
            //addMenuItem("", "Zoom Out", "zoomout");
            addMenuItem("", "Toggle Mouse Mode", "mousemode");
        }
    }

    function previousBill()
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
            browser.url = settings.energyDataDir + "/bills/" + gasBills.get(billIdx).url;
        }
        else
        {
            showTitle (true, "Fuel Bill Viewer (" + electricBills.get(billIdx).name + ")");
            browser.url = settings.energyDataDir + "/bills/" + electricBills.get(billIdx).url;
        }
    }

    function nextBill()
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
            browser.url = settings.energyDataDir + "/bills/" + gasBills.get(billIdx).url;
        }
        else
        {
            showTitle (true, "Fuel Bill Viewer (" + electricBills.get(billIdx).name + ")");
            browser.url = settings.energyDataDir + "/bills/" + electricBills.get(billIdx).url;
        }
    }

    function changeFuel()
    {
        if (activeFuel === "Electric")
            activeFuel = "Gas";
        else if (activeFuel === "Gas")
            activeFuel = "Electric";

        footer.yellowText = "Showing (" + activeFuel + ")";

        if (activeFuel === "Gas")
        {
            showTitle (true, "Fuel Bill Viewer (" + gasBills.get(billIdx).name + ")");
            browser.url = settings.energyDataDir + "/bills/" + gasBills.get(billIdx).url;
        }
        else
        {
            showTitle (true, "Fuel Bill Viewer (" + electricBills.get(billIdx).name + ")");
            browser.url = settings.energyDataDir + "/bills/" + electricBills.get(billIdx).url;
        }
    }

    function zoomIn()
    {
        var x = xscale(1205);
        var y = yscale(557);
        var pos = root.mapToGlobal(1205, 557);
        mythUtils.mouseMove(xscale(pos.x), yscale(pos.y));
        mythUtils.mouseLeftClick(window, x, y);
    }

    function zoomOut()
    {
        var x = xscale(1205);
        var y = yscale(604);
        var pos = root.mapToGlobal(x, y);
        mythUtils.mouseMove(pos.x, pos.y);
        mythUtils.mouseLeftClick(window, x, y);
    }
}
