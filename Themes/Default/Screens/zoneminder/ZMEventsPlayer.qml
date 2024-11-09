import QtQuick
import QtQuick.Controls

import Base 1.0
import Models 1.0
import Dialogs 1.0
import ZMEventsModel 1.0
import "../../../../Util.js" as Util

BaseScreen
{
    defaultFocusItem: footer

    property var eventList;
    property int currentEvent: 0

    signal feedChanged(int index)

    // private
    property int _frameNo: 1
    property bool _paused: false
    property int _playbackspeed: 1

    Component.onCompleted:
    {
        showTitle(true, "ZoneMinder Event Player");
        setHelp("https://mythqml.net/help/zm_eventsplayer.php#top");
        showTime(true);
        showTicker(false);

        updateEventDetails();

        eventList.dataChanged.connect(updateEventDetails);
     }

    Component.onDestruction:
    {
        eventList.dataChanged.disconnect(updateEventDetails);
    }

    onCurrentEventChanged:
    {
        updateEventDetails();
        frameImage.swapImage("http://" + settings.zmIP + "/zm/index.php?view=image&fid=" + _frameNo + "&eid=" + eventList.get(currentEvent).Id + "&show=capture&token=" + playerSources.zmToken);
        feedChanged(currentEvent);
    }

    Keys.onPressed: event =>
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1 || event.key === Qt.Key_Less)
        {
            // RED - Previous
            if (currentEvent > 0)
            {
                currentEvent--;
                _frameNo = 1;
            }
        }
        else if (event.key === Qt.Key_F2 || event.key === Qt.Key_Greater)
        {
            // GREEN - Next
            if (currentEvent < eventList.totalAvailable - 1)
            {
                currentEvent++;
                _frameNo = 1;
            }
        }
        else if (event.key === Qt.Key_F3 || event.key === Qt.Key_P)
        {
            // BLUE - Play/Pause
            if (_paused)
            {
                _paused = false;
                footer.yellowText = "Pause";
            }
            else
            {
                _paused = true;
                footer.yellowText = "Play";
            }
        }
        else if (event.key === Qt.Key_F4 || event.key === Qt.Key_D)
        {
            // YELLOW - Delete
            if (eventList.get(currentEvent).Archived === 1)
            {
                // don't allow archived events to be deleted
                errorSound.play();
                notAllowed.show();
                return;
            }

            eventList.deleteEvent(eventList.get(currentEvent).Id);
            updateEventDetails();

            _paused = false;
            _frameNo = 1;
            frameImage.swapImage("http://" + settings.zmIP + "/zm/index.php?view=image&fid=" + _frameNo + "&eid=" +eventList.get(currentEvent).Id + "&show=capture&token=" + playerSources.zmToken);
        }
        else if (event.key === Qt.Key_Left)
        {
            if (_frameNo > 1)
            {
                _frameNo--;
                frameImage.swapImage("http://" + settings.zmIP + "/zm/index.php?view=image&fid=" + _frameNo + "&eid=" +eventList.get(currentEvent).Id + "&show=capture&token=" + playerSources.zmToken);
            }
        }
        else if (event.key === Qt.Key_Right)
        {
            if (_frameNo < eventList.get(currentEvent).Frames)
            {
                _frameNo++;
                frameImage.swapImage("http://" + settings.zmIP + "/zm/index.php?view=image&fid=" + _frameNo + "&eid=" +eventList.get(currentEvent).Id + "&show=capture&token=" + playerSources.zmToken);
            }
        }
        else if (event.key === Qt.Key_PageDown)
        {
            if (_playbackspeed > 1)
                _playbackspeed--;

            showNotification("Playback Speed is now: " + _playbackspeed);
        }
        else if (event.key === Qt.Key_PageUp)
        {
            if (_playbackspeed < 50)
                _playbackspeed++;

            showNotification("Playback Speed is now: " + _playbackspeed);
        }
        else if (event.key === Qt.Key_M)
        {
            showMenu();
        }
        else
            event.accepted = false;
    }

    Timer
    {
        id: playbackTimer
        interval: 100; running: !_paused; repeat: true;
        onTriggered:
        {
            if (_frameNo < eventList.get(currentEvent).Frames)
            {
                _frameNo = Math.min(_frameNo + _playbackspeed, eventList.get(currentEvent).Frames);
                frameImage.swapImage("http://" + settings.zmIP + "/zm/index.php?view=image&fid=" + _frameNo + "&eid=" +eventList.get(currentEvent).Id + "&show=capture&token=" + playerSources.zmToken);
            }
            else
                _frameNo = 1;
        }
    }

    BaseBackground
    {
        x: xscale(40); y: yscale(60); width: xscale(1200); height: yscale(85)
    }

    LabelText { x: xscale(55); y: yscale(70); width: xscale(200); height: yscale(30); text: "Event:" }
    LabelText { x: xscale(55); y: yscale(100); width: xscale(250); height: yscale(30); text: "Frame:" }
    LabelText { x: xscale(700); y: yscale(70); width: xscale(200); height: yscale(30); text: "Camera:" }
    LabelText { x: xscale(700); y: yscale(100); width: xscale(250); height: yscale(30); text: "Date:" }

    InfoText
    {
        id: event
        x: xscale(150); y: yscale(70); width: xscale(330); height: yscale(30);
    }

    InfoText
    {
        id: frame
        x: xscale(150); y: yscale(100); width: xscale(330); height: yscale(30);
        text: _frameNo + " of " + eventList.get(currentEvent).Frames + " (" + eventList.get(currentEvent).Length + " seconds)"
    }

    InfoText
    {
        id: camera
        x: xscale(850); y: yscale(70); width: xscale(330); height: yscale(30)
    }

    InfoText
    {
        id: date
        x: xscale(850); y: yscale(100); width: xscale(330); height: yscale(30);
    }

    InfoText
    {
        id: playbackspeed
        x: frameImage.x + frameImage.width + xscale(10); y: yscale(650); width: xscale(100); height: yscale(30);
        text: _playbackspeed + "x"
    }

    Rectangle
    {
        x: xscale(300)
        y: yscale(170)
        width: xscale(600)
        height: yscale(450)
        color: "black"
    }

    FadeImage
    {
        id: frameImage
        x: xscale(300)
        y: yscale(160)
        width: xscale(666)
        height: yscale(500)
        doFade: false
        doScale: false
        source: "http://" + settings.zmIP + "/zm/index.php?view=image&fid=" + _frameNo + "&eid=" +eventList.get(currentEvent).Id + "&show=capture&token=" + playerSources.zmToken
    }

    Item
    {
        x: frameImage.x
        y: frameImage.y + frameImage.height + 3
        width: frameImage.width
        height: yscale(8)

        Rectangle
        {
            anchors.fill: parent
            color: "white"
        }

        Rectangle
        {
            x: 0; y: 0; height: parent.height;
            width: (parent.width / eventList.get(currentEvent).Frames) * _frameNo
            color: "red"
        }
    }

    Footer
    {
        id: footer
        width: parent.width
        redText: "Previous"
        greenText: "Next"
        yellowText: "Pause"
        blueText: "Delete"
    }

    PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "Event Options"

        onItemSelected: (itemText, itemData) =>
        {
            footer.focus = true;

            if (itemText == "Archive Event")
            {
                eventList.archiveEvent(eventList.get(currentEvent).Id);
            }
            else if (itemText == "Unarchive Event")
            {
                eventList.unarchiveEvent(eventList.get(currentEvent).Id);
            }
            else if (itemText == "Rename Event")
            {
                textEditDialog.show();
            }
        }

        onCancelled:
        {
            footer.focus = true;
        }
    }

    TextEditDialog
    {
        id: textEditDialog

        title: "Rename Event"
        message: "Enter the new event name."

        width: xscale(600); height: yscale(350)

        onResultText:
        {
            eventList.renameEvent(eventList.get(currentEvent).Id, text);

            footer.focus = true
        }
        onCancelled:
        {
            footer.focus = true
        }
    }

    OkCancelDialog
    {
        id: notAllowed

        title: "Can't Delete This Event"
        message: "This event is Archived and so can't be deleted until it is Unarchived"
        rejectButtonText: ""

        width: xscale(600); height: yscale(300)

        onAccepted:  footer.focus = true
        onCancelled: footer.focus = true
    }

    function showMenu()
    {
        popupMenu.message = "Event Options";
        popupMenu.clearMenuItems();

        if (eventList.get(currentEvent).Archived === 1)
            popupMenu.addMenuItem("", "Unarchive Event");
        else
            popupMenu.addMenuItem("", "Archive Event");

        popupMenu.addMenuItem("", "Rename Event");

        popupMenu.show();
    }

    function updateEventDetails()
    {
        event.text = eventList.get(currentEvent).Name + (eventList.get(currentEvent).Archived === 1 ? "*" : "") + " (" + (currentEvent + 1) + "/" + eventList.totalAvailable + ")";
        camera.text = playerSources.zmCameraList.lookupMonitorName(eventList.get(currentEvent).MonitorId);
        date.text = mythUtils.formatDateTime(eventList.get(currentEvent).StartTime);
    }
}
