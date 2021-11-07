import QtMultimedia 5.4

import QtQuick 2.5
import Base 1.0
import Dialogs 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: calendarGrid

    property bool testMode: false

    Component.onCompleted:
    {
        showTitle(true, "Advent Calendar 2020");
        showTicker(false);
        setHelp("https://mythqml.net/help/advent_calendar.php#top");

        var index = dbUtils.getSetting("AdventIndex", settings.hostName, "");

        if (index !== "")
            calendarModel.calendarIndex = index;
    }

    Component.onDestruction:
    {
        for (var i = 0; i < calendarModel.model.count; i++)
        {
            var opened = calendarModel.model.get(i).opened ? "opened" : "closed";
            dbUtils.setSetting("Advent" + calendarModel.calendarIndex + "Day" + i, settings.hostName, opened);
        }

        dbUtils.setSetting("AdventIndex", settings.hostName, calendarModel.calendarIndex);
    }

    SoundEffect
    {
         id: openSound
         source: mythUtils.findThemeFile("sounds/advent_open.wav")
         volume: soundEffectsVolume
    }

    SoundEffect
    {
         id: closeSound
         source: mythUtils.findThemeFile("sounds/advent_close.wav")
         volume: soundEffectsVolume
    }

    SoundEffect
    {
         id: notyetSound
         source: mythUtils.findThemeFile("sounds/downer.wav")
         volume: soundEffectsVolume
    }

    AdventCalendarModel
    {
        id: calendarModel
        onLoaded:
        {
            showTitle(true, calendarList.get(calendarModel.calendarIndex).title);

            var date = new Date;

            for (var i = 0; i < model.count; i++)
            {
                // if we are in November or December close all windows that should be closed
                if (date.getMonth() == 10 || (date.getMonth() == 11 && i > date.getDate()))
                {
                    model.get(i).opened = false;
                    dbUtils.setSetting("Advent" + calendarModel.calendarIndex + "Day" + i, settings.hostName,  "closed");
                }
                else
                {

                    var day = dbUtils.getSetting("Advent" + calendarIndex + "Day" + i, settings.hostName);
                    model.get(i).opened = (day === "opened");
                }
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
        x: xscale(20)
        y: yscale(50)
        width: parent.width - xscale(40)
        height: yscale(720) - yscale(100)
        cellWidth: (parent.width - xscale(40)) / 6
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
            openWindow();
        }

        Keys.onPressed:
        {
            event.accepted = true;

            if (event.key === Qt.Key_M)
            {
                showMenu();
            }
            else if (event.key === Qt.Key_F1)
            {
                // red
                if (calendarModel.model.get(calendarGrid.currentIndex).opened)
                    closeWindow();
                else
                    openWindow();
            }
            else if (event.key === Qt.Key_F2)
            {
                showSwitchAdventMenu();
            }
            else if (event.key === Qt.Key_Left && ((currentIndex % 6) === 0 && previousFocusItem))
            {
                event.accepted = true;
                escapeSound.play();
                previousFocusItem.focus = true;
            }
            else
            {
                event.accepted = false;
            }
        }

        onCurrentIndexChanged:
        {
            if (model.get(currentIndex).opened)
                footer.redText = "Close Window";
            else
                footer.redText = "Open Window";
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
                closeWindow();
            }
            else if (itemText == "Open Window")
            {
                openWindow();
            }
            else if (itemText == "Close All Windows")
            {
                for (var i = 0; i < calendarModel.model.count; i++)
                {
                    calendarModel.model.get(i).opened = false;
                    dbUtils.setSetting("Advent" + calendarModel.calendarIndex + "Day" + i, settings.hostName,  "closed");
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
            dbUtils.setSetting("Advent" + calendarModel.calendarIndex + "Day" + calendarGrid.currentIndex, settings.hostName,  "opened");
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

    Footer
    {
        id: footer
        redText: "Open Window"
        greenText: "Change Calendars"
        yellowText: ""
        blueText: ""
    }

    function showMenu()
    {
        popupMenu.message = "Advent Calendar Options";
        popupMenu.clearMenuItems();

        popupMenu.addMenuItem("", "Switch Advent Calendar");
        for (var x = 0; x < calendarModel.calendarList.count; x++)
            popupMenu.addMenuItem("0", calendarModel.calendarList.get(x).title, x, (x === calendarModel.calendarIndex ? true : false));

        if (calendarModel.model.get(calendarGrid.currentIndex).opened)
            popupMenu.addMenuItem("", "Close Window");
        else
            popupMenu.addMenuItem("", "Open Window");

        popupMenu.addMenuItem("", "Close All Windows");

        popupMenu.show();
    }

    function showSwitchAdventMenu()
    {
        popupMenu.message = "Switch Advent Calendar";
        popupMenu.clearMenuItems();

        for (var x = 0; x < calendarModel.calendarList.count; x++)
            popupMenu.addMenuItem("", calendarModel.calendarList.get(x).title, x, (x === calendarModel.calendarIndex ? true : false));

        popupMenu.show();
    }

    function openWindow()
    {
        var date = new Date;
        var day = calendarModel.model.get(calendarGrid.currentIndex).day;
        if (!testMode && date.getMonth() == 10 || (date.getMonth() == 11 && day > date.getDate()))
        {
            notyetSound.play();
            notYetdialog.show();
        }
        else
        {
            calendarModel.model.get(calendarGrid.currentIndex).opened = true
            footer.redText = "Close Window";
            openSound.play();
            playDialog.show();
        }
    }

    function closeWindow()
    {
        calendarModel.model.get(calendarGrid.currentIndex).opened = false;
        footer.redText = "Open Window";
    }
}
