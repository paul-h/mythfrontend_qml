import QtQuick 2.0
import QtQuick.Controls 1.4
import Base 1.0

BaseDialog
{
    id: busyDialog

    width: xscale(500)
    height: yscale(150)

    property alias message: message.text

    Keys.onPressed:
    {
        event.accepted = true;
    }

    content: Item
    {
        anchors.fill: parent

        LabelText
        {
            id: message
            text: "Please Wait...."
            x: 70; y: 40; width: parent.width - 50;
        }

        BusyIndicator
        {
            id: busy
            x: xscale(10); y: yscale(40);
            running: true
        }
    }
}
