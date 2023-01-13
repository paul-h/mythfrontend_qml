import QtQuick 2.0
import Base 1.0
import Dialogs 1.0
import QtGraphicalEffects 1.12
import QmlVlc 0.1
import "../../../Models"
import mythqml.net 1.0

BasePopup
{
    id: root

    property int alertedMonitorId: -1
    property bool autoHide: false

    width: xscale(330)
    height: width / (16 / 9)

    Component.onCompleted: mediaPlayer.feed.switchToFeed("ZoneMinder Cameras", "", 0);

    function show(focusItem)
    {
        if (alertedMonitorId === -1)
            alertedMonitorId = playerSources.zmCameraList.model.get(0).id;

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
            if (autoHide && mediaPlayer.feed.feedName === "ZoneMinder Cameras")
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

    Connections
    {
        target: popupMenu
        function onItemSelected(itemText, itemData)
        {
            mediaPlayer.focus = true;

            if (itemText == "Next Camera")
            {
                mediaPlayer.nextFeed();
            }
            else if (itemText == "Previous Camera")
            {
                mediaPlayer.previousFeed();
            }
            else if (itemText == "Enable Alerts")
            {
                playerSources.zmCameraList.showAlertDialog = true;
                notificationText.text = 'ZoneMinder alerts are <font color=' + (playerSources.zmCameraList.showAlertDialog ? '"green"><b>enabled' : '"red"><b>disabled') + '</font></b>';
                notificationPanel.visible = true;
                notificationTimer.start();
            }
            else if (itemText == "Disable Alerts")
            {
                playerSources.zmCameraList.showAlertDialog = false;
                notificationText.text = 'ZoneMinder alerts are <font color=' + (playerSources.zmCameraList.showAlertDialog ? '"green"><b>enabled' : '"red"><b>disabled') + '</font></b>';
                notificationPanel.visible = true;
                notificationTimer.start();
            }
            else if (itemText == "Close")
            {
                hide();
            }

        }
    }

    Timer
    {
        id: hideTimer
        interval: 5000; running: root.autoHide; repeat: false
        onTriggered: { popupMenu.hide(); hide(); }
    }

    Timer
    {
        id: notificationTimer
        interval: 6000; running: false; repeat: false
        onTriggered: notificationPanel.visible = false;
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
        else if (event.key === Qt.Key_F3)
        {
            playerSources.zmCameraList.showAlertDialog = !playerSources.zmCameraList.showAlertDialog;
            notificationText.text = 'ZoneMinder alerts are <font color=' + (playerSources.zmCameraList.showAlertDialog ? '"green"><b>enabled' : '"red"><b>disabled') + '</font></b>';
            notificationPanel.visible = true;
            notificationTimer.start();
        }
        else if (event.key === Qt.Key_I)
        {
            mediaPlayer.showInfo();
        }
        else if (event.key === Qt.Key_S)
        {
            takeSnapshot(root);
        }
        else if (event.key === Qt.Key_M)
        {
            popupMenu.title = "Menu";
            popupMenu.message = "ZoneMinder Alert Options";

            popupMenu.clearMenuItems();

            popupMenu.addMenuItem("", "Previous Camera");
            popupMenu.addMenuItem("", "Next Camera");

            if (playerSources.zmCameraList.showAlertDialog)
                popupMenu.addMenuItem("", "Disable Alerts");
            else
                popupMenu.addMenuItem("", "Enable Alerts");

            popupMenu.addMenuItem("", "Close");

            popupMenu.show();
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

        BaseBackground
        {
            id: notificationPanel
            x: xscale(10); y: yscale(10); width: parent.width - xscale(20); height: parent.height - yscale(20)
            visible: false

            InfoText
            {
                id: notificationText
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                multiline: true
                textFormat: TextEdit.RichText
                fontPixelSize: xscale(30)
                fontColor: "white"
            }
        }
    }
}
