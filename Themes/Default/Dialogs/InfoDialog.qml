import QtQuick 2.0
import Base 1.0

BaseDialog
{
    id: infoDialog

    property alias infoText: info.text
    property alias acceptButtonText: acceptButton.text


    content: Item
    {
        anchors.fill: parent

        InfoText
        {
            id: info
            anchors.fill: parent
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignTop
            multiline: true
            text: ""
        }
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
                infoDialog.hide();
                infoDialog.accepted();
            }
        }
    ]
}

