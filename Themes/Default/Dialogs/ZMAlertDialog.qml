import QtQuick 2.0
import Base 1.0
import QtGraphicalEffects 1.12
import QmlVlc 0.1
import "../../../Models"
import mythqml.net 1.0

BasePopup
{
    id: root

    property int alertedMonitorId: 2

    width: xscale(330)
    height: width / (16 / 9)

    Component.onCompleted: mediaPlayer.feed.switchToFeed("ZoneMinder Cameras", "", 0);

    function show(focusItem)
    {
        var index = -1;

        for (var x = 0; x < mediaPlayer.feed.feedCount; x++)
        {
            if (mediaPlayer.feed.feedList.get(x).id == alertedMonitorId)
            {
                index = x;
                break;
            }
        }

        if (index !== -1)
            mediaPlayer.goToFeed(index);

        _show(focusItem);
    }

    Connections
    {
        target: playerSources.zmCameraList
        function onMonitorStatus(monitorId, status)
        {
            if (mediaPlayer.feed.feedName === "ZoneMinder Cameras")
            {
                if (mediaPlayer.feed.feedList.get(mediaPlayer.feed.currentFeed).id === monitorId)
                {
                    if (status === "Alarm" || status === "Alert" || status === "Pre Alarm")
                        hideTimer.stop();
                    else
                        hideTimer.start();
                }
            }
        }
    }

    Timer
    {
        id: hideTimer
        interval: 5000; running: false; repeat: false
        onTriggered: hide();
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            mediaPlayer.previousFeed();
        }
        else if (event.key === Qt.Key_F2)
        {
            mediaPlayer.nextFeed();
        }
        else if (event.key === Qt.Key_I)
        {
            mediaPlayer.showInfo();
        }
        else if (event.key === Qt.Key_S)
        {
            takeSnapshot(root);
        }
        else
            event.accepted = false;
    }

    content: Item
    {
        anchors.fill: parent

        MediaPlayers
        {
            id: mediaPlayer
            anchors.fill: parent
        }
    }
}
