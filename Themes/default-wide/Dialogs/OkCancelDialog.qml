import QtQuick 2.0
import Base 1.0

BaseDialog
{
    id: okDialog

    property alias acceptButtonText: acceptButton.text
    property alias rejectButtonText: rejectButton.text

    content: Item
    {
        anchors.fill: parent
    }

    buttons:
    [
        BaseButton
        {
            id: acceptButton
            text: "OK"
            focus: true
            visible: text != ""

            KeyNavigation.left: rejectButton;
            KeyNavigation.right: rejectButton;

            onClicked:
            {
                okDialog.state = "";
                okDialog.accepted();
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
                okDialog.state = "";
                okDialog.cancelled();
            }
        }
    ]
}

