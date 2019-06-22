import QtQuick 2.0
import Base 1.0
import Dialogs 1.0
import Models 1.0
import "../../../Util.js" as Util

BaseScreen
{
    defaultFocusItem: monitorList

    Component.onCompleted:
    {
        showTitle(true, "ZoneMinder Console");
        showTime(true);
        showTicker(false);

        updateStats();
    }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_F1)
        {
            // RED - Edit Camera
            var monitorID = monitorList.model.get(monitorList.currentIndex).id;
            var cameraFunction = monitorList.model.get(monitorList.currentIndex).monfunction;
            var cameraEnabled = monitorList.model.get(monitorList.currentIndex).monenabled;

            editMonitor.title = "Change Monitor Function";
            editMonitor.message = "Edit function for monitor<br><font color=\"yellow\" >" + monitorList.model.get(monitorList.currentIndex).name + "</font>";
            editMonitor.monitorID = monitorID;
            editMonitor.cameraFunction = cameraFunction;
            editMonitor.cameraEnabled = cameraEnabled;
            editMonitor.show();
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN - Restart ZoneMinder
            zmRestart();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW - Stop ZoneMinder
            if (zmDaemonCheckModel.running)
                zmStop();
            else
                zmStart();

            zmDaemonCheckModel.reload();
        }
        else if (event.key === Qt.Key_F4)
        {
            // BLUE - refresh
            playerSources.zmCameraList.reload();
            zmLoadModel.reload();
        }
    }

    Timer
    {
        id: tickerUpdateTimer
        interval: 10000; running: true; repeat: true
        onTriggered:
        {
            playerSources.zmCameraList.reload();
            zmLoadModel.reload();
            zmDaemonCheckModel.reload();

            updateStats();
        }
    }

    ZMLoadModel
    {
        id: zmLoadModel
        onLoaded: load.info = "<font color=\"white\" >" + zmLoadModel.load1 + ", " + zmLoadModel.load5 + ", " + zmLoadModel.load15 + "</font></p>"
    }

    ZMDaemonCheckModel
    {
        id: zmDaemonCheckModel
        onLoaded:
        {
            if (zmDaemonCheckModel.running)
            {
                status.text = "Running";
                status.fontColor = "green";
            }
            else
            {
                status.text = "Stopped";
                status.fontColor = "red";
            }
         }
    }

    BaseBackground
    {
        x: xscale(40); y: yscale(95); width: xscale(1200); height: yscale(100)
    }

    // running status
    LabelText { x: xscale(440); y: yscale(95); width: xscale(400); height: yscale(40); fontColor: "yellow"; horizontalAlignment: Text.AlignHCenter;  text: "ZoneMinder Server Status" }
    InfoText { id: status; x: xscale(440); y: yscale(120); width: xscale(400); height: yscale(40); horizontalAlignment: Text.AlignHCenter; text: "?"}

    // load
    RichText { id: load;  x: xscale(60); y: yscale(155); width: xscale(400); height: yscale(40); label: "<p style=\"font-size: 20px; color: #ff00ff\"><b>Load: </b></font>"; info: "<font color=\"white\" >?, ?, ?</font></p>" }

    // total no. of events
    RichText { id: totalEvents;  x: xscale(440); y: yscale(155); width: xscale(400); height: yscale(40); horizontalAlignment: Text.AlignHCenter; label: "<p style=\"font-size: 20px; color: #ff00ff\"><b>Events: </b></font>"; info: "<font color=\"white\" >?</font></p>" }

    // disk usage
    RichText { id: diskused; x: xscale(920); y: yscale(155); width: xscale(300); height: yscale(40); horizontalAlignment: Text.AlignRight ;label: "<p style=\"font-size: 20px; color: #ff00ff\"><b>Disk Used: </b></font>"; info: "<font color=\"white\" >" + "?" + "</font></p>" }

    BaseBackground
    {
        x: xscale(40); y: yscale(250); width: xscale(1200); height: yscale(400)
    }

    LabelText { x: xscale(55); y: yscale(220); width: xscale(130); height: yscale(30); text: "Camera" }
    LabelText { x: xscale(265); y: yscale(220); width: xscale(130); height: yscale(30); text: "Function" }
    LabelText { x: xscale(410); y: yscale(220); width: xscale(130); height: yscale(30); text: "Source" }
    LabelText { x: xscale(930); y: yscale(220); width: xscale(130); height: yscale(30); horizontalAlignment: Text.AlignRight; text: "Events" }
    LabelText { x: xscale(1090); y: yscale(220); width: xscale(130); height: yscale(30); horizontalAlignment: Text.AlignRight; text: "Used" }

    Component
    {
        id: listRow

        ListItem
        {
            ListText
            {
                x: xscale(5)
                width: xscale(210); height: yscale(50)
                text: name
            }
            BaseCheckBox
            {
                x: xscale(220); y: yscale(15)
                width: xscale(20); height: yscale(20)
                checked: monenabled
            }
            ListText
            {
                x: xscale(245)
                width: xscale(170); height: yscale(50)
                text: monfunction
            }
            ListText
            {
                x: xscale(360)
                width: xscale(560); height: yscale(50)
                text: if (host !== "") host; else device + " (" + channel + ")";
            }
            ListText
            {
                x: xscale(920)
                width: xscale(90); height: yscale(50)
                text: totalevents
                horizontalAlignment: Text.AlignRight
            }
            ListText
            {
                x: xscale(1025)
                width: xscale(150); height: yscale(50)
                text: if (totalevents > 0) Util.formatFileSize(totaleventsdiskspace, false); else "0B"
                horizontalAlignment: Text.AlignRight
            }
        }
    }

    ButtonList
    {
        id: monitorList
        x: xscale(50); y: yscale(270); width: xscale(1180); height: yscale(380)

        model: playerSources.zmCameraList
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
        greenText: "Restart ZoneMinder"
        yellowText: zmDaemonCheckModel.running ? "Stop Zoneminder" : "Start Zoneminder"
        blueText: "Refresh"
    }

    function updateStats()
    {
        var used = 0;
        var events = 0
        for (var x = 0; x < playerSources.zmCameraList.count; x++)
        {
            if (playerSources.zmCameraList.get(x).totalevents > 0)
            {
                used += playerSources.zmCameraList.get(x).totaleventsdiskspace;
                events += playerSources.zmCameraList.get(x).totalevents;
            }
        }

        diskused.info = "<font color=\"white\" >" + Util.formatFileSize(used, false) + "</font></p>"
        totalEvents.info = "<font color=\"white\" >" + events + "</font></p>"
    }

    function zmStop()
    {
        var http = new XMLHttpRequest();
        var url = "http://" + settings.zmIP + "/zm/api/states/change/stop.json";
        var params = playerSources.zmAuth;

        http.open("POST", url, true);
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

        http.onreadystatechange = function()
        {
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    console.log("ZoneMinder has been stopped OK")
                }
                else
                {
                    console.log("error zmStop: " + http.status)
                }
            }
        }
        http.send(params);
    }

    function zmStart()
    {
        var http = new XMLHttpRequest();
        var url = "http://" + settings.zmIP + "/zm/api/states/change/start.json?";
        var params = playerSources.zmAuth;

        http.open("POST", url, true);
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

        http.onreadystatechange = function()
        {
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    console.log("ZoneMinder has been started OK")
                }
                else
                {
                    console.log("error zmStart: " + http.status)
                }
            }
        }
        http.send(params);
    }

    function zmRestart()
    {
        var http = new XMLHttpRequest();
        var url = "http://" + settings.zmIP + "/zm/api/states/change/restart.json?";
        var params = playerSources.zmAuth;

        http.open("POST", url, true);
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

        http.onreadystatechange = function()
        {
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    console.log("ZoneMinder has been restarted OK")
                }
                else
                {
                    console.log("error zmRestart: " + http.status)
                }
            }
        }
        http.send(params);
    }

    function zmChangeMonitorState(monitorID, _function, enabled)
    {
        var http = new XMLHttpRequest();
        var url = "http://" + settings.zmIP + "/zm/api/monitors/" + monitorID + ".json";
        var params =  "Monitor[Function]=" + _function + "&Monitor[Enabled]=" + (enabled ? "1" : "0") + "&" + playerSources.zmAuth;

        http.open("POST", url, true);
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

        http.onreadystatechange = function()
        {
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    console.log("ZoneMinder function of monitor " + monitorID + " has been changed to '" + _function + "', enabled: " + (enabled ? "true" : "false"))
                }
                else
                {
                    console.log("error zmChangeMonitorState: " + http.status);
                    console.log(http.responseText);
                }
            }
        }
        http.send(params);
    }

    BaseDialog
    {
        id: editMonitor

        property int monitorID: -1
        property string cameraFunction: "None"
        property bool cameraEnabled: false

        onCameraFunctionChanged: functionSelector.selectItem(cameraFunction);
        onCameraEnabledChanged: enabledCheck.checked = cameraEnabled;

        ListModel
        {
            id: functionModel

            ListElement
            {
                itemText: "None"
            }
            ListElement
            {
                itemText: "Monitor"
            }
            ListElement
            {
                itemText: "Modect"
            }
            ListElement
            {
                itemText: "Record"
            }
            ListElement
            {
                itemText: "Mocord"
            }
            ListElement
            {
                itemText: "Nodect"
            }
        }

        content: Item
        {
            anchors.fill: parent

            BaseSelector
            {
                id: functionSelector
                x: xscale(120); y: 0; width: xscale(250)
                showBackground: false
                pageCount: 1
                model: functionModel

                KeyNavigation.up: rejectButton;
                KeyNavigation.down: enabledCheck;
            }

            BaseCheckBox
            {
                id: enabledCheck
                x: xscale(150); y: yscale(70)
                checked: false
                KeyNavigation.up: functionSelector;
                KeyNavigation.down: acceptButton;
            }

            LabelText
            {
                x: xscale(200);
                y: yscale(70);
                width: xscale(400);
                height: yscale(40);
                text: "Enabled"
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
                    editMonitor.state = "";
                    editMonitor.accepted();

                    zmChangeMonitorState(editMonitor.monitorID, functionSelector.model.get(functionSelector.currentIndex).itemText, enabledCheck.checked);
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
                    editMonitor.state = "";
                    editMonitor.cancelled();
                }
            }
        ]

        onAccepted: monitorList.focus = true
        onCancelled: monitorList.focus = true;
    }
}
