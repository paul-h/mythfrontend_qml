import QtQuick 2.0
import Base 1.0
import "../../../Models"

BaseScreen
{
    defaultFocusItem: statusList

    Component.onCompleted:
    {
        showTitle(true, "ZoneMinder Console");
        showTime(false);
        showTicker(false);
    }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_F1)
        {
        }
        else if (event.key === Qt.Key_F2)
        {
        }
        else if (event.key === Qt.Key_F3)
        {
        }
        else if (event.key === Qt.Key_F4)
        {
        }
        else if (event.key === Qt.Key_F5)
        {
        }
    }

    BaseBackground
    {
        x: xscale(40); y: yscale(95); width: xscale(1200); height: yscale(100)
    }

    DigitalClock
    {
        x: xscale(60); y: yscale(100); width: xscale(300); height: yscale(80)
        format: "ddd MMM dd"
        visible: true
    }

    DigitalClock
    {
        x: xscale(920); y: yscale(100); width: xscale(300); height: yscale(40)
        format: "HH:mm:ss"
        visible: true
    }

    // running status
    LabelText { x: xscale(440); y: yscale(110); width: xscale(400); height: yscale(40);horizontalAlignment: Text.AlignHCenter;  text: "Status" }
    LabelText { id: status; x: xscale(440); y: yscale(130); width: xscale(400); height: yscale(40); horizontalAlignment: Text.AlignHCenter; text: "Running" }

    // load
    LabelText { id: load; x: xscale(60); y: yscale(155); width: xscale(300); height: yscale(40); text: "Load: 100%" }

    // disk usage
    LabelText { id: disk; x: xscale(920); y: yscale(155); width: xscale(300); height: yscale(40); horizontalAlignment: Text.AlignRight; text: "Disk: 100%" }

    BaseBackground
    {
        x: xscale(40); y: yscale(250); width: xscale(1200); height: yscale(400)
    }

    LabelText { x: xscale(70); y: yscale(220); width: xscale(130); height: yscale(30); text: "Camera" }
    LabelText { x: xscale(390); y: yscale(220); width: xscale(130); height: yscale(30); text: "Function" }
    LabelText { x: xscale(710); y: yscale(220); width: xscale(130); height: yscale(30); text: "Source" }
    LabelText { x: xscale(1110); y: yscale(220); width: xscale(130); height: yscale(30); horizontalAlignment: Text.AlignRight; text: "Events" }

    LabelText { x: xscale(340); y: yscale(650); width: xscale(600); height: yscale(40); horizontalAlignment: Text.AlignHCenter; text: "[R] = Running [S] = Stopped" }

    Component
    {
        id: listRow

        ListItem
        {
            Image
            {
               id: channelImage
               x: 3; y:3; height: parent.height - 6; width: height
               source: if (icon)
                            icon
                        else
                            "images/grid_noimage.png"
            }
            ListText
            {
                width: statusList.width; height: 50
                x: channelImage.width + 5
                text: name + " ~ " + callsign + " ~ " + channo + " ~ " + xmltvid
            }
        }
    }

    ButtonList
    {
        id: statusList
        x: xscale(60); y: yscale(270); width: xscale(1180); height: yscale(380)

        focus: true
        clip: true
        model: SDChannelsModel {}
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
        }

        Keys.onReturnPressed:
        {
            returnSound.play();
        }

        KeyNavigation.left: dbChannelList;
        KeyNavigation.right: dbChannelList;
    }

}
