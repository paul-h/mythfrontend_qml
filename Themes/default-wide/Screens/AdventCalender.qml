import QtQuick 2.0
import Base 1.0
import Dialogs 1.0

BaseScreen
{
    defaultFocusItem: calenderGrid

    Component.onCompleted:
    {
        console.log("init completed");
        showTitle(true, "Advent Calender 2017");

        for (var i = 0; i < calenderModel.count; i++)
        {
            var day = dbUtils.getSetting("Qml_adventDay" + i, settings.hostName);
            calenderGrid.model.get(i).opened = (day == "opened");
        }
    }

    Component.onDestruction:
    {
        for (var i = 0; i < calenderModel.count; i++)
        {
            var opened = calenderGrid.model.get(i).opened;
            dbUtils.setSetting("Qml_adventDay" + i, settings.hostName, opened ? "opened" : "closed");
        }
    }

    ListModel
    {
        id: calenderModel
        ListElement
        {
            day: "1"
            title: "Dave`s Model Railway Christmas Video"
            icon: "https://i.ytimg.com/vi/5xf55ayahlE/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=5xf55ayahlE"
            duration: "15:46"
            opened: false
        }
        ListElement
        {
            day: "2"
            title: "A Christmas Kiss - Daniel O'Donnell Feat. Mrs Merton"
            icon: "https://i.ytimg.com/vi/djJxHJBxlPc/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=djJxHJBxlPc"
            duration: "3:10"
            opened: false
        }
        ListElement
        {
            day: "3"
            title: "The Short Christmas Tree - The Good Life - BBC"
            icon: "https://i.ytimg.com/vi/RnH4st9So5E/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=RnH4st9So5E"
            duration: "3:01"
            opened: false
        }
        ListElement
        {
            day: "4"
            title: "Tom Chambers & Oti Mabuse Charleston to 'Santa Claus Is Comin' To Town' - Christmas Special: 2015"
            icon: "https://i.ytimg.com/vi/I1xauVkThQk/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=I1xauVkThQk"
            duration: "1:53"
            opened: false
        }
        ListElement
        {
            day: "5"
            title: "6 BEST CHRISTMAS LIGHT DISPLAYS EVER!!!"
            icon: "https://i.ytimg.com/vi/-VL9dQHMMfo/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=-VL9dQHMMfo"
            duration: "12:21"
            opened: false
        }
        ListElement
        {
            day: "6"
            title: "Merry Christmas Cute Video (Jingle Bells Song)"
            icon: "https://i.ytimg.com/vi/F6eM-9wYhQU/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=F6eM-9wYhQU"
            duration: "2:24"
            opened: false
        }
        ListElement
        {
            day: "7"
            title: "East Lancashire Railway Santa Specials"
            icon: "https://i.ytimg.com/vi/qkuqAqJLcrY/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=qkuqAqJLcrY"
            duration: "1:53"
            opened: false
        }
        ListElement
        {
            day: "8"
            title: "BBC1 Christmas Idents 1967 to 2015"
            icon: "https://i.ytimg.com/vi/X3wmpGOwzHE/hqdefault.jpg"
            video: "http://www.youtube.com/watch?v=X3wmpGOwzHE"
            duration: "20:54"
            opened: false
        }
        ListElement
        {
            day: "9"
            title: "Santa By Steam on the South Devon Railway, Buckfastleigh"
            icon: "https://i.ytimg.com/vi/8Afq9dK7CwM/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=8Afq9dK7CwM"
            duration: "1:27"
            opened: false
        }
        ListElement
        {
            day: "10"
            title: "2016 Claires Christmas Village"
            icon: "https://i.ytimg.com/vi/KvwmxC_zv4M/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=KvwmxC_zv4M"
            duration: "13:43"
            opened: false
        }
        ListElement
        {
            day: "11"
            title: "Very emotional Christmas advert 2015"
            icon: "https://i.ytimg.com/vi/FMZ3eYbLx7g/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=FMZ3eYbLx7g"
            duration: "3:38"
            opened: false
        }
        ListElement
        {
            day: "12"
            title: "Wizzard - I Wish It Could Be Christmas Everyday"
            icon: "https://i.ytimg.com/vi/bnczB6LXkqE/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=bnczB6LXkqE"
            duration: "4:54"
            opened: false
        }
        ListElement
        {
            day: "13"
            title: "John Lewis Adverts Christmas 2007-2015"
            icon: "https://i.ytimg.com/vi/VrvoJn1T_ok/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=VrvoJn1T_ok"
            duration: "14:17"
            opened: false
        }
        ListElement
        {
            day: "14"
            title: "2 Hrs of Christmas Classics with Christmas images"
            icon: "https://i.ytimg.com/vi/K-C0ADqtkjw/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=K-C0ADqtkjw"
            duration: "2:09:09"
            opened: false
        }
        ListElement
        {
            day: "15"
            title: "Mel & Kim - Rockin' Around The Christmas Tree"
            icon: "https://i.ytimg.com/vi/hdnaPAJgAQI/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=hdnaPAJgAQI"
            duration: "00:00"
            opened: false
        }
        ListElement
        {
            day: "16"
            title: "CP HOLIDAY CHRISTMAS TRAIN IN MONTREAL QUEBEC"
            icon: "https://i.ytimg.com/vi/lA3IQXkqexo/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=lA3IQXkqexo"
            duration: "10:06"
            opened: false
        }
        ListElement
        {
            day: "17"
            title: "Christmas adverts 80s uk"
            icon: "https://i.ytimg.com/vi/Nh9XX_9PPOI/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=Nh9XX_9PPOI"
            duration: "5:48"
            opened: false
        }
        ListElement
        {
            day: "18"
            title: "Helen Skelton Jives to 'All I Want For Christmas' - Strictly Come Dancing Christmas Special - BBC"
            icon: "https://i.ytimg.com/vi/cI6-SC6VdpA/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=cI6-SC6VdpA"
            duration: "1:47"
            opened: false
        }
        ListElement
        {
            day: "19"
            title: "Peter Kay's Car Share Christmas Special"
            icon: "https://i.ytimg.com/vi/38Ko4EPGdJY/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=38Ko4EPGdJY"
            duration: "6:06"
            opened: false
        }
        ListElement
        {
            day: "20"
            title: "2015 Santa Parade , Kings Park Fire Department"
            icon: "https://i.ytimg.com/vi/0JPT13OUVV8/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=0JPT13OUVV8"
            duration: "4:27"
            opened: false
        }
        ListElement
        {
            day: "21"
            title: "Christmas in London - Feel The Spirit - City of London - Christmas Lights"
            icon: "https://i.ytimg.com/vi/eM4PWCsJO1c/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=eM4PWCsJO1c"
            duration: "6:15"
            opened: false
        }
        ListElement
        {
            day: "22"
            title: "Mariah Carey - All I Want For Christmas Is You"
            icon: "https://i.ytimg.com/vi/yXQViqx6GMY/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=yXQViqx6GMY"
            duration: "3:55"
            opened: false
        }
        ListElement
        {
            day: "23"
            title: "BBC Video Tape Department - Entire 1979 Christmas Tape."
            icon: "https://i.ytimg.com/vi/jmVXtjqKkYY/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=jmVXtjqKkYY"
            duration: "56:18"
            opened: false
        }
        ListElement
        {
            day: "24"
            title: "2016 Nesconset,NY Fire Department Santa Claus Parade 17/12/16"
            icon: "https://i.ytimg.com/vi/SJLRWBKO9A8/hqdefault.jpg"
            video: "https://www.youtube.com/watch?v=SJLRWBKO9A8"
            duration: "9:06"
            opened: false
        }
    }

    GridView
    {
        id: calenderGrid
        x: xscale(50)
        y: yscale(50)
        width: xscale(1280) - xscale(96)
        height: yscale(720) - yscale(100)
        cellWidth: xscale(197)
        cellHeight: yscale(155)

        Component
        {
            id: calenderDelegate
            Image
            {
                id: wrapper
                //visible: opened
                x: xscale(5)
                y: yscale(5)
                opacity: 1.0
                width: calenderGrid.cellWidth - 10; height: calenderGrid.cellHeight - 10
                source: opened ? icon : mythUtils.findThemeFile("images/advent_calender/day" + day + ".png")
                //source: icon
            }
        }

        highlight: Rectangle { z: 99; color: "red"; opacity: 0.4; radius: 5 }
        model: calenderModel
        delegate: calenderDelegate
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

                if (calenderGrid.model.get(calenderGrid.currentIndex).opened)
                    popupMenu.addMenuItem("Close Window");
                else
                    popupMenu.addMenuItem("Open Window");

                popupMenu.addMenuItem("Close All Windows");

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
            calenderGrid.focus = true;

            if (itemText == "Close Window")
            {
                calenderGrid.model.get(calenderGrid.currentIndex).opened = false;
            }
            else if (itemText == "Open Window")
            {
                var date = new Date;
                var day = calenderGrid.model.get(calenderGrid.currentIndex).day;
                if (date.getMonth() == 10 || (date.getMonth() == 11 && day > date.getDate()))
                {
                    returnSound.play();
                    notYetdialog.show();
                }
                else
                {
                    calenderGrid.model.get(calenderGrid.currentIndex).opened = true
                    returnSound.play();
                    playDialog.show();
                }
            }
            else if (itemText == "Close All Windows")
            {
                for (var i = 0; i < calenderModel.count; i++)
                {
                    calenderGrid.model.get(i).opened = false;
                    dbUtils.setSetting("Qml_adventDay" + i, settings.hostName,  "closed");
                }
            }
        }

        onCancelled:
        {
            calenderGrid.focus = true;
        }
    }

    OkCancelDialog
    {
        id: notYetdialog

        title: "Hey cheeky!!"
        message: "It's too early to open this window!"
        rejectButtonText: ""

        width: xscale(600); height: yscale(300)

        onAccepted:  calenderGrid.focus = true
        onCancelled: calenderGrid.focus = true
    }

    AdventPlayDialog
    {
        id: playDialog

        title: "Day " + calenderGrid.model.get(calenderGrid.currentIndex).day
        message: calenderGrid.model.get(calenderGrid.currentIndex).title +  "\nDuration: " + calenderGrid.model.get(calenderGrid.currentIndex).duration
        image: calenderGrid.model.get(calenderGrid.currentIndex).icon

        width: xscale(600); height: yscale(500)

        onAccepted:
        {
            calenderGrid.model.get(calenderGrid.currentIndex).opened = true
            calenderGrid.focus = true;
            stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{source1: calenderGrid.model.get(calenderGrid.currentIndex).video, title1: calenderGrid.model.get(calenderGrid.currentIndex).title}});
        }
        onCancelled:
        {
            calenderGrid.focus = true;
        }
    }
}
