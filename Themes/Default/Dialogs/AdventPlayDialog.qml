import QtQuick 2.0
import Base 1.0

BaseDialog
{
    id: playDialog

    property alias image: icon.source

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
            focus: true
            visible: text != ""

            KeyNavigation.left: rejectButton;
            KeyNavigation.right: rejectButton;

            onClicked:
            {
                playDialog.state = "";
                playDialog.accepted();
            }
        },

        BaseButton
        {
            id: rejectButton
            text: "Cancel"
            visible: text != ""

            KeyNavigation.left: acceptButton;
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

