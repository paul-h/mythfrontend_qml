import QtMultimedia 5.4

import QtQuick 2.5
import Base 1.0
import Dialogs 1.0
import Models 1.0
import SortFilterProxyModel 0.2

BaseScreen
{
    defaultFocusItem: calendarGrid

    property bool testMode: false

    Component.onCompleted:
    {
        showTitle(true, "Advent Calendar 2021");
        showTicker(false);
        setHelp("https://mythqml.net/help/advent_calendar.php#top");
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
        property bool checkForNew: true

        onLoaded:
        {
            if (checkForNew)
            {
                checkForNew = false;

                var index = dbUtils.getSetting("AdventIndex", settings.hostName, "");

                // check to see if we should switch to a new calendar
                var lastCheck = new Date(Date.parse(dbUtils.getSetting("AdventLastUpdate", settings.hostName, "2016-12-01T00:00:00.000")));
                var lastUpdate = calendarModel.calendarList.get(calendarModel.calendarList.count - 1).dateadded;

                if (lastCheck < lastUpdate)
                {
                    index = calendarModel.calendarList.count - 1;
                    dbUtils.setSetting("AdventLastUpdate", settings.hostName, lastUpdate);
                    dbUtils.setSetting("AdventIndex", settings.hostName, index);
                }

                if (index !== calendarModel.calendarIndex)
                    calendarModel.calendarIndex = index;
            }

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

    SortFilterProxyModel
    {
        id: calendarSortModel
        sourceModel: calendarModel.calendarList

        sorters:  StringSorter { roleName: "dateadded"; sortOrder: Qt.DescendingOrder }
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            // red
            if (calendarModel.model.get(calendarGrid.currentIndex).opened)
                closeWindow();
            else
                openWindow();
        }
        else if (event.key === Qt.Key_F2)
        {
            // green
            showSwitchAdventMenu();
        }
        else if (event.key === Qt.Key_Left && ((currentIndex % 6) === 0 && previousFocusItem))
        {
            escapeSound.play();
            previousFocusItem.focus = true;
        }
        else if (event.key === Qt.Key_F5)
        {
            testMode = !testMode;
            showNotification("Test Mode is " + (testMode ? "enabled" : "disabled"));
        }
        else if (event.key === Qt.Key_F6)
        {
            var player = calendarModel.model.get(calendarGrid.currentIndex).player;

            if (player === "VLC")
                calendarModel.model.get(calendarGrid.currentIndex).player = "YouTubeTV";
            else if (player === "YouTubeTV")
                calendarModel.model.get(calendarGrid.currentIndex).player = "YouTube";
            else if (player === "YouTube")
                calendarModel.model.get(calendarGrid.currentIndex).player = "VLC";

            showNotification("Player is now: " + calendarModel.model.get(calendarGrid.currentIndex).player);
        }
        else if (event.key === Qt.Key_M)
        {
            showMenu();
        }
        else
            event.accepted = false;
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
            Item
            {
                id: delegate
                property bool isOpen: opened
                property string iconURL: icon

                x: xscale(5)
                y: yscale(5)
                width: calendarGrid.cellWidth - 10; height: calendarGrid.cellHeight - 10

                Image
                {
                    id: image
                    anchors.fill: parent
                    opacity: 1.0
                    source: delegate.iconURL
                }
                Image
                {
                    id: calwindow
                    anchors.fill: parent

                    source: mythUtils.findThemeFile("images/advent_calendar/day" + day + ".png")
                    transform:
                    Rotation
                    {
                        id: winRot
                        origin.x: 0
                        origin.y: calwindow.height / 2
                        axis { x: 0; y: 1; z: 0 }
                        angle: delegate.isOpen ? -90 : 0
                        Behavior on angle
                        {
                            NumberAnimation
                            {
                                easing.type: Easing.InOutQuad
                                duration: 1500
                                onRunningChanged:
                                {
                                    if (!running && delegate.isOpen)
                                        playDialog.show(calendarGrid);

                                    if (running)
                                        delegate.z = 99;
                                    else
                                        delegate.z = 0;
                                }
                            }
                        }
                    }
                }
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
        for (var x = 0; x < calendarSortModel.count; x++)
        {
            var index = calendarModel.findIndexFromCalendarId(calendarSortModel.get(x).id);
            popupMenu.addMenuItem("0", calendarSortModel.get(x).title, index, (calendarSortModel.get(x).id === calendarModel.calendarList.get(calendarModel.calendarIndex).id ? true : false));
        }

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

        for (var x = 0; x < calendarSortModel.count; x++)
        {
            var index = calendarModel.findIndexFromCalendarId(calendarSortModel.get(x).id);
            popupMenu.addMenuItem("0", calendarSortModel.get(x).title, index, (calendarSortModel.get(x).id === calendarModel.calendarList.get(calendarModel.calendarIndex).id ? true : false));
        }

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
            openSound.play();

            if (!calendarModel.model.get(calendarGrid.currentIndex).opened)
            {
                calendarModel.model.get(calendarGrid.currentIndex).opened = true
                footer.redText = "Close Window";
            }
            else
                playDialog.show();
        }
    }

    function closeWindow()
    {
        closeSound.play();
        calendarModel.model.get(calendarGrid.currentIndex).opened = false;
        footer.redText = "Open Window";
    }
}
