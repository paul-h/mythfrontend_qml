import QtQuick 2.0
import Base 1.0
import "../../../Models"

BaseScreen
{
    defaultFocusItem: video1player
    property bool player1HasFocus: true

    Component.onCompleted:
    {
        showTitle(true, "LiveTV");
        showTime(true);
        showTicker(false);
    }

    Keys.onEscapePressed: { video1player.stop(); video2player.stop(); }

    Rectangle
    {
        id: player1Rect
        x: 0; y: yscale(50); width: xscale(640); height: yscale(357)
        color: "black"
        border.color: "white"
        border.width: xscale(4)

        VideoPlayerQmlVLC
        {
            id: video1player
            anchors.fill: parent
            anchors.margins: xscale(4)
            onFocusChanged: focusedPlayerChanged()
            visible: true
        }

        MouseArea
        {
            id: play1Area
            anchors.fill: parent
            onPressed: video1player.mute = !video1player.mute
        }

        KeyNavigation.up: video2player
        KeyNavigation.down: channelList
    }

    Rectangle
    {
        id: player2Rect
        x: xscale(640); y: yscale(50); width: xscale(640); height: yscale(357)
        color: "black"
        border.color: "white"
        border.width: xscale(4)

        VideoPlayerQmlVLC
        {
            id: video2player
            anchors.fill: parent
            anchors.margins: xscale(4)
            onFocusChanged: focusedPlayerChanged()
            visible: true
        }

        MouseArea
        {
            id: play2Area
            anchors.fill: parent
            onPressed: video2player.mute = !video2player.mute
        }

        KeyNavigation.up: video1player
        KeyNavigation.down: channelList
    }

    Component
    {
        id: listRow

        ListItem
        {
            Image
            {
               id: channelImage
               x: xscale(3); y: yscale(3); height: parent.height - yscale(6); width: height
               // FIXME: need to get the channel icon here
               source: mythUtils.findThemeFile("images/grid_noimage.png")
            }
            ListText
            {
                width:channelList.width; height: yscale(50)
                x: channelImage.width + xscale(10)
                text: name + " ~ " + type + " ~ " + lcn + " ~ " + url
            }
        }
    }

    VboxChannelsModel
    {
        id: vboxChannelsModel
        broadcaster: "freeview"
    }

    ListView
    {
        id: channelList
        x: xscale(50); y: yscale(440); width: xscale(1080); height: yscale(200)

        clip: true
        model: vboxChannelsModel
        delegate: listRow

        Keys.onPressed:
        {
            if (event.key === Qt.Key_PageDown)
            {
                currentIndex = currentIndex + 6 >= model.count ? model.count - 1 : currentIndex + 6;
                event.accepted = true;
            }
            else if (event.key === Qt.Key_PageUp)
            {
                currentIndex = currentIndex - 6 < 0 ? 0 : currentIndex - 6;
                event.accepted = true;
            }
            else if (event.key === Qt.Key_S)
            {
                if (vboxChannelsModel.broadcaster === "freeview")
                    vboxChannelsModel.broadcaster = "freesat";
                else
                    vboxChannelsModel.broadcaster = "freeview";
            }
        }

        Keys.onReturnPressed:
        {
            returnSound.play();
            if (player1HasFocus)
                video1player.source = encodeURI(model.get(currentIndex).url);
            else
                video2player.source = encodeURI(model.get(currentIndex).url);
        }

        KeyNavigation.left: video1player;
        KeyNavigation.right: video2player;
    }

    function focusedPlayerChanged()
    {
        if (video1player.focus)
        {
            player1HasFocus = true
            player1Rect.border.color = "red"
            player2Rect.border.color = "white"
        }
        else if (video2player.focus)
        {
            player1HasFocus = false
            player1Rect.border.color = "white"
            player2Rect.border.color = "red"
        }
    }
}

