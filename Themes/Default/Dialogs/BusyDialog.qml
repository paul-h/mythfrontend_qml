import QtQuick
import QtQuick.Controls

import Base 1.0

BaseDialog
{
    id: busyDialog

    property int timeOut: -1

    x: (window.width - width) / 2
    y: (window.height - height) / 2
    width: xscale(500)
    height: yscale(150)

    property alias message: message.text

    onTimeOutChanged: timeoutTimer.running = (timeOut > 0 ? true : false)

    Timer
    {
        id: timeoutTimer

        interval: timeOut; running: false; repeat: false
        onTriggered: hide();
    }

    Keys.onPressed: event =>
    {
        event.accepted = true;
    }

    content: Item
    {
        anchors.fill: parent

        LabelText
        {
            id: message
            x: busy.width + xscale(15)
            y: yscale(5)
            width: parent.width - x - xscale(5)
            height: parent.height - yscale(10)
            text: "Please Wait...."
        }

        BusyIndicator
        {
            id: busy
            x: xscale(10); y: yscale(40);
            running: true
        }
    }
}
