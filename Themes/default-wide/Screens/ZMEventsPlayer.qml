import QtQuick 2.0
import QtQuick.Controls 1.4
import Base 1.0
import Models 1.0
import ZMEventsModel 1.0
import "../../../Util.js" as Util

BaseScreen
{
    defaultFocusItem: footer

    property var eventList;
    property int currentEvent: 0

    signal feedChanged(int index)

    // private
    property int _frameNo: 1
    property bool _paused: false

    Component.onCompleted:
    {
        showTitle(true, "ZoneMinder Event Player");
        showTime(true);
        showTicker(false);

        updateEventDetails();
     }

    onCurrentEventChanged:
    {
        updateEventDetails();
        frameImage.swapImage("http://" + settings.zmIP + "/zm/index.php?view=image&fid=" + _frameNo + "&eid=" + eventList.get(currentEvent).Id + "&show=capture");
        feedChanged(currentEvent);
    }

    Action
    {
        shortcut: "Escape"
        onTriggered: if (stack.depth > 1) {stack.pop(); escapeSound.play();} else Qt.quit();
    }

    Keys.onPressed:
    {
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
                footer.redText = "Pause";
            }
            else
            {
                _paused = true;
                footer.redText = "Play";
            }
        }
        else if (event.key === Qt.Key_F4 || event.key === Qt.Key_D)
        {
            // YELLOW - Delete
            var eventNo = currentEvent;

            eventList.deleteEvent(eventList.get(eventNo).Id);
            updateEventDetails();

            _paused = false;
            _frameNo = 1;
            frameImage.swapImage("http://" + settings.zmIP + "/zm/index.php?view=image&fid=" + _frameNo + "&eid=" +eventList.get(currentEvent).Id + "&show=capture");

        }
        else if (event.key === Qt.Key_Left)
        {
            if (_frameNo > 1)
            {
                _frameNo--;
                frameImage.swapImage("http://" + settings.zmIP + "/zm/index.php?view=image&fid=" + _frameNo + "&eid=" +eventList.get(currentEvent).Id + "&show=capture");
            }
        }
        else if (event.key === Qt.Key_Right)
        {
            if (_frameNo < eventList.get(currentEvent).Frames)
            {
                _frameNo++;
                frameImage.swapImage("http://" + settings.zmIP + "/zm/index.php?view=image&fid=" + _frameNo + "&eid=" +eventList.get(currentEvent).Id + "&show=capture");
            }
        }
    }

    Timer
    {
        id: playbackTimer
        interval: 100; running: !_paused; repeat: true;
        onTriggered:
        {
            if (_frameNo < eventList.get(currentEvent).Frames)
            {
                _frameNo++;
                frameImage.swapImage("http://" + settings.zmIP + "/zm/index.php?view=image&fid=" + _frameNo + "&eid=" +eventList.get(currentEvent).Id + "&show=capture");
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
        y: xscale(160)
        width: xscale(666)
        height: yscale(500)
        doFade: false
        doScale: false
        source: "http://" + settings.zmIP + "/zm/index.php?view=image&fid=" + _frameNo + "&eid=" +eventList.get(currentEvent).Id + "&show=capture"
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
        redText: "Previous"
        greenText: "Next"
        yellowText: "Pause"
        blueText: "Delete"
    }

    function updateEventDetails()
    {
        event.text = eventList.get(currentEvent).Name + " (" + (currentEvent + 1) + "/" + eventList.totalAvailable + ")";
        camera.text = playerSources.zmCameraList.lookupMonitorName(eventList.get(currentEvent).MonitorId);
        date.text = mythUtils.formatDateTime(eventList.get(currentEvent).StartTime);
    }
}
