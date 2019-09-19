import QtQuick 2.0
import Base 1.0
import Models 1.0
import ZMEventsModel 1.0
import "../../../Util.js" as Util
import mythqml.net 1.0

BaseScreen
{
    defaultFocusItem: eventsList

    Component.onCompleted:
    {
        showTitle(true, "ZoneMinder Events");
        showTime(true);
        showTicker(false)
    }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_F1 || event.key === Qt.Key_D)
        {
            // RED - delete
            if (zmEventsModel.totalAvailable > 0)
                zmEventsModel.deleteEvent(zmEventsModel.get(eventsList.currentIndex).Id);
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN
            zmEventsModel.descending = ! zmEventsModel.descending;

            if (zmEventsModel.descending)
                footer.greenText = "Sort (Newest First)"
            else
                footer.greenText = "Sort (Oldest First)"

            zmEventsModel.reload();
        }
        else if (event.key === Qt.Key_F3 || event.key === Qt.Key_P)
        {
            // YELLOW - play event
            if (zmEventsModel.totalAvailable > 0)
                playEvent();
        }
        else if (event.key === Qt.Key_F4)
        {
            // BLUE - refresh
            zmEventsModel.reload();
        }
    }

    ZMEventsModel
    {
        id: zmEventsModel
        auth: playerSources.zmAuth

        onTotalAvailableChanged:
        {
            if (eventsList.currentIndex === -1)
            {
                eventsList.positionViewAtIndex(0, ListView.Beginning);
                eventsList.currentIndex = 0;
            }
        }

        onLoaded:
        {
            if (dateModel.count === 0)
                updateDateModel();

            if (cameraModel.count === 0)
                updateCameraModel();
        }

        function deleteEvent(eventID)
        {
            // do this first so the GUI updates properly
            remove(findEventIndex(eventID));

            var http = new XMLHttpRequest();
            var url = "http://" + settings.zmIP + "/zm/api/events/" + eventID + ".json";
            var params = playerSources.zmAuth;

            http.open("DELETE", url, true);
            http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

            http.onreadystatechange = function()
            {
                if (http.readyState == 4)
                {
                    if (http.status == 200)
                    {
                        log.info(Verbose.GENERAL, "ZMEventsView: Event Deleted OK - " + eventID)

                        // update the monitorsModel so the event counts are updated
                        playerSources.zmCameraList.reload();
                    }
                    else
                    {
                        log.error(Verbose.GENERAL, "ZMEventsView: Failed to delete event. Got status - " + http.status)
                    }
                }
            }
            http.send(params);
        }

        function findEventIndex(eventID)
        {
            for (var x = 0; x < totalAvailable; x++)
            {
                if (get(x).Id === eventID)
                    return x;
            }

            log.error(Verbose.GENERAL, "ZMEventsView: ZMEventsModel - failed to find eventID: " + eventID);
            return -1;
        }
    }

    BaseBackground
    {
        x: xscale(40); y: yscale(60); width: xscale(1200); height: yscale(100)
    }

    LabelText { x: xscale(55); y: yscale(70); width: xscale(200); height: yscale(30); text: "Select Camera" }
    LabelText { x: xscale(700); y: yscale(70); width: xscale(250); height: yscale(30); text: "Select Date" }

    InfoText
    {
        id: position;
        x: xscale(1090); y: yscale(120); width: xscale(130); height: yscale(30);
        horizontalAlignment: Text.AlignRight;
        text: zmEventsModel.totalAvailable >  0 ? (eventsList.currentIndex + 1) + " of " + zmEventsModel.totalAvailable : "";
    }

    ListModel
    {
        id: cameraModel
    }

    BaseSelector
    {
        id: cameraSelector
        x: xscale(55); y: yscale(110); width: xscale(350)
        showBackground: false
        pageCount: 5
        model: cameraModel

        KeyNavigation.up: eventsList;
        KeyNavigation.down: dateSelector;

        onItemSelected:
        {
            zmEventsModel.monitorID = model.get(index).monitorID;
            zmEventsModel.reload();
            eventsList.positionViewAtIndex(0, ListView.Beginning);
            eventsList.currentIndex = 0;
        }
    }

    ListModel
    {
        id: dateModel
    }

    BaseSelector
    {
        id: dateSelector

        property bool updatingModel: false

        x: xscale(700); y: yscale(110); width: xscale(350)
        showBackground: false
        pageCount: 5
        model: dateModel

        KeyNavigation.up: cameraSelector;
        KeyNavigation.down: eventsList;

        onItemSelected:
        {
            if (!updatingModel)
            {
                zmEventsModel.date = model.get(index).date;
                zmEventsModel.reload();
                eventsList.positionViewAtIndex(0, ListView.Beginning);
                eventsList.currentIndex = 0;
            }
        }
    }

    Component
    {
        id: listRow

        ListItem
        {
            Image
            {
                source: if (Id !== undefined) "http://" + settings.zmIP + "/zm/index.php?view=image&fid=10&eid=" + Id + "&" + playerSources.zmAuth; else ""; //+ "&show=analyse&";
                x: xscale(3)
                y: yscale(3)
                width: xscale(44)
                height: yscale(44)
                asynchronous: true
            }

            ListText
            {
                x: xscale(55)
                width: xscale(250); height: yscale(50)
                text: if (Name !== undefined) Name ; else "";
            }
            ListText
            {
                x: xscale(260)
                width: xscale(190); height: yscale(50)
                text: if (MonitorId !== undefined) playerSources.zmCameraList.lookupMonitorName(MonitorId); else "";
            }
            ListText
            {
                x: xscale(460)
                width: xscale(600); height: yscale(50)
                text: Frames + " frames (" + Length + " seconds)"
            }
            ListText
            {
                x: xscale(770)
                width: xscale(400); height: yscale(50)
                text: if (StartTime !== undefined) mythUtils.formatDateTime(StartTime); else "";
                horizontalAlignment: Text.AlignRight
            }
        }
    }

    BaseBackground
    {
        x: xscale(40); y: yscale(180); width: xscale(1200); height: yscale(470)
    }

    ButtonList
    {
        id: eventsList
        x: xscale(50); y: yscale(190); width: xscale(1180); height: yscale(450)
        focus: true
        clip: true
        model: zmEventsModel
        delegate: listRow

        Keys.onReturnPressed:
        {
            if (zmEventsModel.totalAvailable > 0)
                playEvent();

            event.accepted = true;
        }

        KeyNavigation.left: cameraSelector;
        KeyNavigation.right: dateSelector;
    }

    InfoText
    {
        id: noEvents
        x: xscale(50); y: yscale(190); width: xscale(1180); height: yscale(450)
        fontPixelSize: xscale(30)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        visible: (zmEventsModel.totalAvailable === 0)
        text: "No events found"
    }

    Footer
    {
        id: footer
        redText: "Delete Event"
        greenText: "Sort (Oldest First)"
        yellowText: "Play Event"
        blueText: "Refresh"
    }

    function playEvent()
    {
        returnSound.play();
        var item = stack.push({item: Qt.resolvedUrl("ZMEventsPlayer.qml"), properties:{eventList:  eventsList.model, currentEvent: eventsList.currentIndex}});
        item.feedChanged.connect(feedChanged);
    }

    function feedChanged(index)
    {
        eventsList.currentIndex = index;
    }

    function updateDateModel()
    {
        dateSelector.updatingModel = true;
        dateModel.clear();
        dateModel.append({ "date": new Date(0), "itemText": "All Dates" });

        for (var x = 0; x < zmEventsModel.dateList.length; x++)
        {
            dateModel.append({ "date": zmEventsModel.dateList[x], "itemText": mythUtils.formatDate(zmEventsModel.dateList[x])});
        }
        dateSelector.updatingModel = false;
    }

    function updateCameraModel()
    {
        cameraModel.clear();
        cameraModel.append({ "monitorID": -1, "itemText": "All Cameras" });

        for (var x = 0; x < playerSources.zmCameraList.count; x++)
        {
            if (playerSources.zmCameraList.get(x).totalevents > 0)
                cameraModel.append({ "monitorID": playerSources.zmCameraList.get(x).id, "itemText": playerSources.zmCameraList.get(x).name});
        }
    }
}
