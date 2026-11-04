import QtQuick 2.0
import Base 1.0

BaseDialog
{
    id: playDialog

    property alias image: icon.source
    property int   bookmark: 0

    signal play
    signal playFrom

    content: Item
    {
        anchors.fill: parent
        Image
        {
            id: icon
            x: xscale(150); y: 0
            width: parent.width - xscale(300); height: yscale(200)
        }
    }

    buttons:
    [
        BaseButton
        {
            id: acceptButton
            text: "Play"
            focus: bookmark === 0
            visible: text != ""

            KeyNavigation.left: rejectButton;
            KeyNavigation.right: bookmark ? bookmarkButton : rejectButton;

            onClicked:
            {
                playDialog.state = "";
                playDialog.play();
            }
        },

        BaseButton
        {
            id: bookmarkButton
            width: xscale(300)
            text: "Play From Bookmark"
            focus: bookmark !== 0
            visible: bookmark != 0

            KeyNavigation.left: acceptButton;
            KeyNavigation.right: rejectButton;

            onClicked:
            {
                playDialog.state = "";
                playDialog.playFrom();
            }
        },

        BaseButton
        {
            id: rejectButton
            text: "Cancel"
            visible: text != ""

            KeyNavigation.left: bookmark ? bookmarkButton : acceptButton;
            KeyNavigation.right: acceptButton;

            onClicked:
            {
                playDialog.state = "";
                playDialog.cancelled();
            }
        }
    ]

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_P)
        {
            playDialog.state = "";
            playDialog.accepted();
        }
        else
        {
            // eat all key presses except these
            if (event.key === Qt.Key_Up || event.key === Qt.Key_Down || event.key === Qt.Key_Enter)
                event.accepted = false
        }
    }
}

