import QtQuick 2.0
import Base 1.0
import Dialogs 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: calendarGrid

    property bool testMode: false

    Component.onCompleted:
    {
        showTitle(true, "Advent Calendar 2019");

        var index = dbUtils.getSetting("Qml_adventIndex", settings.hostName, "");

        if (index !== "")
            calendarModel.calendarIndex = index;
    }

    Component.onDestruction:
    {
        for (var i = 0; i < calendarModel.model.count; i++)
        {
            var opened = calendarModel.model.get(i).opened ? "opened" : "closed";
            dbUtils.setSetting("Qml_advent" + calendarModel.calendarIndex + "Day" + i, settings.hostName, opened);
        }

        dbUtils.setSetting("Qml_adventIndex", settings.hostName, calendarModel.calendarIndex);
    }

    AdventCalendarModel
    {
        id: calendarModel
        onLoaded:
        {
            showTitle(true, calendarList.get(calendarModel.calendarIndex).title);

            for (var i = 0; i < model.count; i++)
            {
                var day = dbUtils.getSetting("Qml_advent" + calendarIndex + "Day" + i, settings.hostName);
                model.get(i).opened = (day === "opened");
            }
        }
    }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_F5)
        {
            testMode = !testMode;
            showNotification("Test Mode is " + (testMode ? "enabled" : "disabled"));
            event.accepted = true;
        }
    }

    GridView
    {
        id: calendarGrid
        x: xscale(50)
        y: yscale(50)
        width: xscale(1280) - xscale(96)
        height: yscale(720) - yscale(100)
        cellWidth: xscale(197)
        cellHeight: yscale(155)

        Component
        {
            id: calendarDelegate
            Image
            {
                id: wrapper
                x: xscale(5)
                y: yscale(5)
                opacity: 1.0
                width: calendarGrid.cellWidth - 10; height: calendarGrid.cellHeight - 10
                source: opened ? icon : mythUtils.findThemeFile("images/advent_calendar/day" + day + ".png")
             }
        }

        highlight: Rectangle { z: 99; color: "red"; opacity: 0.4; radius: 5 }
        model: calendarModel.model
        delegate: calendarDelegate
        focus: true

        Keys.onReturnPressed:
        {
            var date = new Date;
            var day = model.get(currentIndex).day;
            if (!testMode && date.getMonth() == 10 || (date.getMonth() == 11 && day > date.getDate()))
            {
                returnSound.play();
                notYetdialog.show();
                event.accepted = true;
            }
            else
            {
                returnSound.play();
                playDialog.show();
                event.accepted = true;
            }
        }

        Keys.onPressed:
        {
            if (event.key === Qt.Key_M)
            {
                popupMenu.clearMenuItems();

                popupMenu.addMenuItem("", "Switch Advent Calendar");
                for (var x = 0; x < calendarModel.calendarList.count; x++)
                    popupMenu.addMenuItem("0", calendarModel.calendarList.get(x).title, x);

                if (calendarModel.model.get(calendarGrid.currentIndex).opened)
                    popupMenu.addMenuItem("", "Close Window");
                else
                    popupMenu.addMenuItem("", "Open Window");

                popupMenu.addMenuItem("", "Close All Windows");

                popupMenu.show();
            }
            else
            {
                event.accepted = false;
            }
        }
    }

    PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "Advent Calendar Options"

        onItemSelected:
        {
            calendarGrid.focus = true;

            if (itemText == "Close Window")
            {
                calendarModel.model.get(calendarGrid.currentIndex).opened = false;
            }
            else if (itemText == "Open Window")
            {
                var date = new Date;
                var day = calendarModel.model.get(calendarGrid.currentIndex).day;
                if (!testMode && date.getMonth() == 10 || (date.getMonth() == 11 && day > date.getDate()))
                {
                    returnSound.play();
                    notYetdialog.show();
                }
                else
                {
                    calendarModel.model.get(calendarGrid.currentIndex).opened = true
                    returnSound.play();
                    playDialog.show();
                }
            }
            else if (itemText == "Close All Windows")
            {
                for (var i = 0; i < calendarModel.model.count; i++)
                {
                    calendarModel.model.get(i).opened = false;
                    dbUtils.setSetting("Qml_advent" + calendarModel.calendarIndex + "Day" + i, settings.hostName,  "closed");
                }
            }
            else if (itemData !== "")
            {
                calendarModel.calendarIndex = itemData;
                showTitle(true, calendarModel.calendarList.get(calendarModel.calendarIndex).title);
                //calendarModel.source = calendarModel.calendarList.get(calendarModel.calendarIndex).url
            }
        }

        onCancelled:
        {
            calendarGrid.focus = true;
        }
    }

    OkCancelDialog
    {
        id: notYetdialog

        title: "Hey cheeky!!"
        message: "It's too early to open this window!"
        rejectButtonText: ""

        width: xscale(600); height: yscale(300)

        onAccepted:  calendarGrid.focus = true
        onCancelled: calendarGrid.focus = true
    }

    AdventPlayDialog
    {
        id: playDialog

        title: if (calendarModel.model.get(calendarGrid.currentIndex)) "Day " + calendarModel.model.get(calendarGrid.currentIndex).day; else "";
        message: if (calendarModel.model.get(calendarGrid.currentIndex)) calendarModel.model.get(calendarGrid.currentIndex).title +  "\nDuration: " + calendarModel.model.get(calendarGrid.currentIndex).duration ; else "";
        image: if (calendarModel.model.get(calendarGrid.currentIndex)) calendarModel.model.get(calendarGrid.currentIndex).icon; else "";

        width: xscale(600); height: yscale(500)

        onAccepted:
        {
            calendarModel.model.get(calendarGrid.currentIndex).opened = true
            dbUtils.setSetting("Qml_advent" + calendarModel.calendarIndex + "Day" + calendarGrid.currentIndex, settings.hostName,  "opened");
            calendarGrid.focus = true;
            playerSources.adhocList = calendarGrid.model;
            stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{defaultFeedSource:  "Advent Calendar", defaultFilter:  "", defaultCurrentFeed: calendarGrid.currentIndex}});
        }
        onCancelled:
        {
            calendarGrid.focus = true;
        }
    }

    Snow {}
}
