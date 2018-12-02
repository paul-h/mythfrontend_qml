import QtQuick 2.0
import QtQuick.Controls 1.4
import QtWebEngine 1.5
import Base 1.0
import Process 1.0
import QtAV 1.5

BaseScreen
{
    id: root
    defaultFocusItem: playerVLC
    property string command
    property var    parameters
    property string port
    property string log
    property bool   useQtAV: false

    Component.onCompleted:
    {
        showTitle(false, "");
        showTime(false);
        showTicker(false);
        pauseVideo(true);
        showVideo(false);

        while (stack.busy) {};

        streamLinkProcess.start(command, parameters);
    }

    Component.onDestruction:
    {
        pauseVideo(false);
    }

    Keys.onEscapePressed:
    {
        playerVLC.stop();
        playerQtAV.stop();
        streamLinkProcess.kill();
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_M)
        {

        }
        else if (event.key === Qt.Key_F1)
        {
            // RED
            useQtAV = !useQtAV;
            startPlayer();
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW
        }
        else if (event.key === Qt.Key_F4)
        {
            //BLUE
        }
        else
        {
            event.accepted = false;
        }
    }

    Process
    {
        id: streamLinkProcess
        onFinished:
        {
            if (exitStatus == Process.NormalExit)
            {
                //stack.pop();
            }
        }
    }

    Timer
    {
        id: checkProcessTimer
        interval: 1000; running: true; repeat: true
        onTriggered:
        {
            log = streamLinkProcess.readAll();

            if (log.includes("No playable streams found on this URL"))
                stack.pop();
            else if (log.includes("Starting server, access with one of:"))
            {
                startPlayer();
            }
        }
    }

    VideoPlayerQmlVLC
    {
        id: playerVLC

        visible: true;
        anchors.fill: parent

        onPlaybackEnded:
        {
            //stop();
            //stack.pop();
        }
    }

    VideoPlayerQtAV
    {
        id: playerQtAV

        visible: false;
        anchors.fill: parent
        fillMode: VideoOutput.Stretch

        onPlaybackEnded:
        {
            //stop();
            //stack.pop();
        }
    }

    function startPlayer()
    {
        if (root.useQtAV)
        {
            playerVLC.stop();
            playerVLC.visible = false

            playerQtAV.visible = true;
            playerQtAV.source = "http://127.0.1.1:" + port + "/";
            playerQtAV.play();
        }
        else
        {
            playerQtAV.stop();
            playerQtAV.visible = false

            playerVLC.visible = true;
            playerVLC.source = "http://127.0.1.1:" + port + "/";
            playerVLC.play();
        }
    }
}

