import QtQuick 2.0
import Base 1.0
import QtQuick.Controls 2.0

BaseDialog
{
    id: infoDialog

    property alias infoText: info.text
    property alias acceptButtonText: acceptButton.text

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_I || event.key === Qt.Key_Enter)
        {
            state = "";
            cancelled();
        }
        else if (event.key === Qt.Key_Down)
        {
            flickable.flick(0, -600);
        }
        else if (event.key === Qt.Key_Up)
        {
            flickable.flick(0, 600);
        }
        else if (event.key === Qt.Key_PageDown)
        {
            flickable.flick(0, -1000);
        }
        else if (event.key === Qt.Key_PageUp)
        {
            flickable.flick(0, 1000);
        }
    }

    content: Item
    {
        anchors.fill: parent
        Flickable
        {
            id: flickable
            anchors.fill: parent

            TextArea.flickable:
                TextArea
                {
                    id: info
                    font.family: theme.infoFontFamily
                    font.pixelSize: xscale(theme.infoFontPixelSize)
                    font.bold: theme.infoFontBold
                    color: theme.infoFontColor
                    clip: true
                    wrapMode: TextEdit.WordWrap
                    textFormat: TextEdit.RichText
                    readOnly: true
                }

            ScrollBar.vertical: ScrollBar { }
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

