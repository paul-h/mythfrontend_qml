import QtQuick 2.0
import Base 1.0
import Dialogs 1.0

BaseScreen
{
    defaultFocusItem: calendarGrid

    Component.onCompleted:
    {
        console.log("init completed");
        showTitle(true, "Advent Calendar 2018");

        for (var i = 0; i < calendarModel.count; i++)
        {
            var day = dbUtils.getSetting("Qml_adventDay" + i, settings.hostName);
            calendarGrid.model.get(i).opened = (day == "opened");
        }
    }

    Component.onDestruction:
    {
        for (var i = 0; i < calendarModel.count; i++)
        {
            var opened = calendarGrid.model.get(i).opened;
            dbUtils.setSetting("Qml_adventDay" + i, settings.hostName, opened ? "opened" : "closed");
        }
    }

    ListModel
    {
        id: calendarModel
        ListElement
        {
            day: "1"
            title: "Christmas Trains Galore!"
            icon: "https://i.ytimg.com/vi/TjEbRcojUyA/hqdefault.jpg"
            url: "https://www.youtube.com/watch?v=TjEbRcojUyA"
            player: "Internal"
            duration: "25:05"
            opened: false
        }
        ListElement
        {
            day: "2"
            title: "Winter Wonderland On Ice FULL SHOW 2017 SeaWorld Orlando Christmas Ice Skating Show"
            icon: "https://i.ytimg.com/vi/UFmcZXwRa_g/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=UFmcZXwRa_g"
            player: "YouTube"
            duration: "26:44"
            opened: false
        }
        ListElement
        {
            day: "3"
            title: "The Christmas Shoes"
            icon: "https://i.ytimg.com/vi/MpkI7GW2V34/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=MpkI7GW2V34"
            player: "YouTubeTV"
            duration: "5:11"
            opened: false
        }
        ListElement
        {
            day: "4"
            title: "Top 10 Most Heartwarming Christmas Commercials Ever Made"
            icon: "https://i.ytimg.com/vi/QcqMxBKN4Os/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=QcqMxBKN4Os"
            player: "YouTube"
            duration: "17:31"
            opened: false
        }
        ListElement
        {
            day: "5"
            title: "Million Dollar Homes Decorated with Christmas Lights in Montreal, QC, Canada!"
            icon: "https://i.ytimg.com/vi/1yeH5hbP4TI/hqdefault.jpg"
            url: "https://www.youtube.com/watch?v=1yeH5hbP4TI"
            player: "Internal"
            duration: "4:55"
            opened: false
        }
        ListElement
        {
            day: "6"
            title: "Happy New Year 2018 ! Best Christmas Show Dance Jingle Bells"
            icon: "https://i.ytimg.com/vi/QReh4CJ1wHo/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=QReh4CJ1wHo"
            player: "YouTubeTV"
            duration: "10:34"
            opened: false
        }
        ListElement
        {
            day: "7"
            title: "Top 10 Most Funniest Christmas Die Laughing Commercials Ever"
            icon: "https://i.ytimg.com/vi/6mThgQ813zY/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=6mThgQ813zY"
            player: "YouTube"
            duration: "13:08"
            opened: false
        }
        ListElement
        {
            day: "8"
            title: "It'll Be Alright on the Night 3 (ITV, 25th December 1981)"
            icon: "https://i.ytimg.com/vi/HYyCSuNnxp0/hqdefault.jpg"
            url: "https://www.youtube.com/watch?v=HYyCSuNnxp0"
            player: "Internal"
            duration: "1:01:15"
            opened: false
        }
        ListElement
        {
            day: "9"
            title: "The Tractors Santa Claus Is Coming (In a boogie-woogie choo-choo train)"
            icon: "https://i.ytimg.com/vi/iYO8mrsgw9g/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=iYO8mrsgw9g"
            player: "YouTubeTV"
            duration: "3:54"
            opened: false
        }
        ListElement
        {
            day: "10"
            title: "Christmas cats compilation"
            icon: "https://i.ytimg.com/vi/L1x0lrutyZA/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=L1x0lrutyZA"
            player: "YouTube"
            duration: "5:43"
            opened: false
        }
        ListElement
        {
            day: "11"
            title: "Merry Christmas Everyone (Collectable Version (DVD) - Re-mastered audio 2004)"
            icon: "https://i.ytimg.com/vi/ZeyHl1tQeaQ/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=ZeyHl1tQeaQ"
            player: "YouTubeTV"
            duration: "4:35"
            opened: false
        }
        ListElement
        {
            day: "12"
            title: "Santa And The Christmas Train"
            icon: "https://i.ytimg.com/vi/M97RF9QYEPE/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=M97RF9QYEPE"
            player: "YouTube"
            duration: "8:09"
            opened: false
        }
        ListElement
        {
            day: "13"
            title: "Santa's Got a Hot Rod"
            icon: "https://i.ytimg.com/vi/HpXTUD57njs/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=HpXTUD57njs"
            player: "YouTube"
            duration: "4:10"
            opened: false
        }
        ListElement
        {
            day: "14"
            title: "Christmas Lights Train Ride"
            icon: "https://i.ytimg.com/vi/IKj9C3vICXM/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=IKj9C3vICXM"
            player: "YouTube"
            duration: "9:17"
            opened: false
        }
        ListElement
        {
            day: "15"
            title: "The Dean Martin Christmas Show (December 21, 1967)"
            icon: "https://i.ytimg.com/vi/Bf_hHU1Yu7o/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=Bf_hHU1Yu7o"
            player: "YouTube"
            duration: "51:28"
            opened: false
        }
        ListElement
        {
            day: "16"
            title: "Mickey's Once Upon A Christmastime Parade at Very Merry Christmas Party - with Princesses, Frozen"
            icon: "https://i.ytimg.com/vi/hSB7-vcKZMA/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=hSB7-vcKZMA"
            player: "YouTube"
            duration: "15:41"
            opened: false
        }
        ListElement
        {
            day: "17"
            title: "O Come All Ye Faithful - Epic Flash Mob Carol #LIGHTtheWORLD | The Five Strings"
            icon: "https://i.ytimg.com/vi/XI2c9yptr4U/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=XI2c9yptr4U"
            player: "YouTube"
            duration: "4:43"
            opened: false
        }
        ListElement
        {
            day: "18"
            title: "The Strictly Cast dance to a medley of 'Auld Lang Syne' and ‘Underneath the Tree’ - Strictly 2016"
            icon: "https://i.ytimg.com/vi/u4fwcR2HJJ0/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=u4fwcR2HJJ0"
            player: "YouTube"
            duration: "2:59"
            opened: false
        }
        ListElement
        {
            day: "19"
            title: "Christmas Animation - The Snowman"
            icon: "https://i.ytimg.com/vi/sOyJ3FExfSE/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=sOyJ3FExfSE"
            player: "YouTubeTV"
            duration: "2:04"
            opened: false
        }
        ListElement
        {
            day: "20"
            title: "Christmas Steam on the Romney, Hythe & Dymchurch Railway (December 1990)"
            icon: "https://i.ytimg.com/vi/9P4Ucvyv96Q/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=9P4Ucvyv96Q"
            player: "YouTube"
            duration: "28:13"
            opened: false
        }
        ListElement
        {
            day: "21"
            title: "LONDON WALK | Oxford Street Christmas Lights and Xmas Window Displays"
            icon: "https://i.ytimg.com/vi/oWfX1PjIEPQ/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=oWfX1PjIEPQ"
            player: "YouTube"
            duration: "21:16"
            opened: false
        }
        ListElement
        {
            day: "22"
            title: "Eric Clapton - White Christmas (Performance Video)"
            icon: "https://i.ytimg.com/vi/QFNEQ9ybrGI/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=QFNEQ9ybrGI"
            player: "YouTubeTV"
            duration: "3:01"
            opened: false
        }
        ListElement
        {
            day: "23"
            title: "The Little Drummer Boy - Božič s Prifarci"
            icon: "https://i.ytimg.com/vi/LDyZToH2k3s/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=LDyZToH2k3s"
            player: "YouTube"
            duration: "9:06"
            opened: false
        }
        ListElement
        {
            day: "24"
            title: "The Andy Williams Christmas Show (1966)"
            icon: "https://i.ytimg.com/vi/pFb2qZfmh4M/hqdefault.jpg"
            url: "https://www.youtube.com/TV#/watch/video/control?v=pFb2qZfmh4M"
            player: "YouTubeTV"
            duration: "43:43"
            opened: false
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
                //visible: opened
                x: xscale(5)
                y: yscale(5)
                opacity: 1.0
                width: calendarGrid.cellWidth - 10; height: calendarGrid.cellHeight - 10
                source: opened ? icon : mythUtils.findThemeFile("images/advent_calendar/day" + day + ".png")
                //source: icon
            }
        }

        highlight: Rectangle { z: 99; color: "red"; opacity: 0.4; radius: 5 }
        model: calendarModel
        delegate: calendarDelegate
        focus: true

        Keys.onReturnPressed:
        {
            var date = new Date;
            var day = model.get(currentIndex).day;
            if (date.getMonth() == 10 || (date.getMonth() == 11 && day > date.getDate()))
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

                if (calendarGrid.model.get(calendarGrid.currentIndex).opened)
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
                calendarGrid.model.get(calendarGrid.currentIndex).opened = false;
            }
            else if (itemText == "Open Window")
            {
                var date = new Date;
                var day = calendarGrid.model.get(calendarGrid.currentIndex).day;
                if (date.getMonth() == 10 || (date.getMonth() == 11 && day > date.getDate()))
                {
                    returnSound.play();
                    notYetdialog.show();
                }
                else
                {
                    calendarGrid.model.get(calendarGrid.currentIndex).opened = true
                    returnSound.play();
                    playDialog.show();
                }
            }
            else if (itemText == "Close All Windows")
            {
                for (var i = 0; i < calendarModel.count; i++)
                {
                    calendarGrid.model.get(i).opened = false;
                    dbUtils.setSetting("Qml_adventDay" + i, settings.hostName,  "closed");
                }
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

        title: "Day " + calendarGrid.model.get(calendarGrid.currentIndex).day
        message: calendarGrid.model.get(calendarGrid.currentIndex).title +  "\nDuration: " + calendarGrid.model.get(calendarGrid.currentIndex).duration
        image: calendarGrid.model.get(calendarGrid.currentIndex).icon

        width: xscale(600); height: yscale(500)

        onAccepted:
        {
            calendarGrid.model.get(calendarGrid.currentIndex).opened = true
            calendarGrid.focus = true;
            stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{feedList:  calendarGrid.model, currentFeed: calendarGrid.currentIndex}});
        }
        onCancelled:
        {
            calendarGrid.focus = true;
        }
    }
}
