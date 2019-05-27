import QtQuick 2.0
import Base 1.0
import Models 1.0
import "../../../Util.js" as Util

BaseScreen
{
    defaultFocusItem: statusList

    Component.onCompleted:
    {
        showTitle(true, "ZoneMinder Console");
        showTime(true);
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
    }

    ZMLoginModel
    {
        id: zmLogin
        Component.onCompleted: getLogin()

        onLoaded:
        {
            var auth = get(0).credentials;
            console.log("ZMLoginModel loaded: " + auth);
            zmMonitorsModel.auth = auth;
            statusList.model = zmMonitorsModel;
        }
    }

    ZMMonitorsModel
    {
        id: zmMonitorsModel
    }

    BaseBackground
    {
        x: xscale(40); y: yscale(95); width: xscale(1200); height: yscale(100)
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

    LabelText { x: xscale(55); y: yscale(220); width: xscale(130); height: yscale(30); text: "Camera" }
    LabelText { x: xscale(310); y: yscale(220); width: xscale(130); height: yscale(30); text: "Function" }
    LabelText { x: xscale(510); y: yscale(220); width: xscale(130); height: yscale(30); text: "Source" }
    LabelText { x: xscale(1090); y: yscale(220); width: xscale(130); height: yscale(30); horizontalAlignment: Text.AlignRight; text: "Events" }

    LabelText { x: xscale(340); y: yscale(650); width: xscale(600); height: yscale(40); horizontalAlignment: Text.AlignHCenter; text: "[R] = Running [S] = Stopped" }

    Component
    {
        id: listRow

        ListItem
        {
            ListText
            {
                x: 5
                width: xscale(250); height: yscale(50)
                text: name
            }
            ListText
            {
                x: xscale(260)
                width: xscale(190); height: yscale(50)
                text: monfunction
            }
            ListText
            {
                x: xscale(460)
                width: xscale(600); height: yscale(50)
                text: if (host !== "") host; else device + " (" + channel + ")";
            }
            ListText
            {
                x: xscale(1070)
                width: xscale(100); height: yscale(50)
                text: totalevents
                horizontalAlignment: Text.AlignRight
            }
        }
    }

    ButtonList
    {
        id: statusList
        x: xscale(50); y: yscale(270); width: xscale(1180); height: yscale(380)

        focus: true
        clip: true
        delegate: listRow

        Keys.onReturnPressed:
        {
            returnSound.play();
        }
    }

    Footer
    {
        id: footer
        redText: "Edit Camera"
        greenText: "Stop Camera"
        yellowText: "Stop Zoneminder"
        blueText: "Refresh"
    }
}
