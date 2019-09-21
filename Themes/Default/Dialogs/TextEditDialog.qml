import QtQuick 2.0
import Base 1.0

BaseDialog
{
    id: textEditDialog

    width: xscale(500)
    height: yscale(600)

    property alias text: textEdit.text

    signal resultText(string text)

    function show()
    {
        textEditDialog.state = "show";
    }

    content: Item
    {
        anchors.fill: parent

        BaseEdit
        {
            id: textEdit
            x: xscale(40); y: yscale(0); width: parent.width - xscale(80);
            text: "";
            focus: true;
            KeyNavigation.up: rejectButton;
            KeyNavigation.down: acceptButton;
            onEditingFinished:
            {
                textEditDialog.state = "";
                textEditDialog.resultText(textEdit.text);
            }
        }
    }

    buttons:
    [
        BaseButton
        {
            id: acceptButton
            text: "OK"
            visible: text != ""

            KeyNavigation.up: textEdit;
            KeyNavigation.down: textEdit;
            KeyNavigation.left: rejectButton;
            KeyNavigation.right: rejectButton;

            onClicked:
            {
                textEditDialog.state = "";
                textEditDialog.resultText(textEdit.text);
            }
        },

        BaseButton
        {
            id: rejectButton
            text: "Cancel"
            visible: text != ""

            KeyNavigation.up: textEdit;
            KeyNavigation.down: textEdit;
            KeyNavigation.left: acceptButton;
            KeyNavigation.right: acceptButton;

            onClicked:
            {
                textEditDialog.state = "";
                textEditDialog.cancelled();
            }
        }
    ]
}
