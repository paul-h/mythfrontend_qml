import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtAV 1.5

import "../../../Util.js" as Util


FocusScope
{
    id: root
    //property alias playlist: mediaplayer.playlist
    property alias source: mediaplayer.source
    property alias volume: mediaplayer.volume
    property bool loop: false
    property bool playbackStarted: false
    signal playbackEnded()

    property string title: ""
    property string subtitle: ""

    property bool fullscreen: false

    property int _oldX
    property int _oldY
    property int _oldWidth
    property int _oldHeight

    Rectangle
    {
        id: background
        property alias source: mediaplayer.source

        color: "black"

        anchors.fill: parent

//        VideoFilter
//        {
//            id: vf
//            avfilter: "negate"
//        }

        Video
        {
            id: mediaplayer
            focus: true
            autoPlay: true
            anchors.fill: parent
            subtitle.engines: ["FFmpeg"]
            videoCodecPriority: ["CUDA", "FFmpeg"]
            audioBackends: ["OpenAL", "Pulse", "Null"]
//            videoFilters: [vf]
            Keys.onReturnPressed: root.togglePaused();
            Keys.onLeftPressed: seek(position - 30000);
            Keys.onRightPressed: seek(position + 30000);
            Keys.onPressed:
            {
                if (event.key === Qt.Key_I)
                {
                    if (infoPanel.visible)
                        infoPanel.visible = false;
                    else
                        infoPanel.visible = true;
                }
                else if (event.key === Qt.Key_O)
                    stop();
                else if (event.key === Qt.Key_P)
                    root.togglePaused();
                else if (event.key === Qt.Key_BracketLeft)
                    changeVolume(-0.01);
                else if (event.key === Qt.Key_BracketRight)
                    changeVolume(0.01);
                else if (event.key === Qt.Key_M)
                    toggleMute();
                else if (event.key === Qt.Key_W)
                    toggleFullscreen();
                else if (event.key === Qt.Key_H)
                    console.log("supportedAudioBackends: " + supportedAudioBackends);
                else
                    event.accepted = false;
            }
        }

        BaseBackground
        {
            id: infoPanel
            x: xscale(10); y: parent.height - yscale(120); width: parent.width - xscale(20); height: yscale(110)
            visible: false

            TitleText
            {
                id: title
                x: xscale(10); y: yscale(5); width: parent.width - xscale(20)
                text:
                {
                    if (root.title != "")
                        return root.title
                    else
                        return root.source
                }

                verticalAlignment: Text.AlignTop
            }

            InfoText
            {
                id: pos
                x: xscale(50); y: yscale(45)
                text: "Position: " + Util.milliSecondsToString(mediaplayer.position) + " / " + Util.milliSecondsToString(mediaplayer.duration)
            }

            InfoText
            {
                id: timeLeft
                x: parent.width - width - xscale(15); y: yscale(45)
                text: "Remaining :" + Util.milliSecondsToString(mediaplayer.duration - mediaplayer.position)
                horizontalAlignment: Text.AlignRight
            }

            RowLayout
            {
                id: toolbar
                opacity: .55
                spacing: xscale(10)
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: spacing
                anchors.leftMargin: spacing * xscale(1.5)
                anchors.rightMargin: spacing * xscale(1.5)
                Behavior on anchors.bottomMargin { PropertyAnimation { duration: 250} }
                Rectangle
                {
                    height: yscale(24)
                    width: height
                    radius: width * xscale(0.25)
                    color: 'black'
                    border.width: xscale(1)
                    border.color: 'white'
                    Image
                    {
                        source: mediaplayer.playing ? mythUtils.findThemeFile("images/play.png") : mythUtils.findThemeFile("images/pause.png")
                        anchors.centerIn: parent
                    }
                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked: mediaplayer.togglePause()
                    }
                }
                Rectangle
                {
                    Layout.fillWidth: true
                    height: yscale(10)
                    color: 'transparent'
                    border.width: xscale(1)
                    border.color: 'white'
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle
                    {
                        width: (parent.width - anchors.leftMargin - anchors.rightMargin) *  (mediaplayer.position / mediaplayer.duration)
                        color: 'blue'
                        anchors.margins: xscale(2)
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                    }
                }
            }
        }

        BaseBackground
        {
            id: messagePanel
            x: xscale(100); y: yscale(120); width: xscale(400); height: yscale(110)
            visible: false

            InfoText
            {
                id: messageText
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
            }
        }
        MouseArea
        {
            id: playArea
            anchors.fill: parent
            onPressed: mediaplayer.play();
        }

    }

    Timer
    {
        id: messageTimer
        interval: 3000; running: false; repeat: false
        onTriggered: messagePanel.visible = false;
    }

    function showMessage(message)
    {
        messageText.text = message;
        messagePanel.visible = true;
        messageTimer.restart();
    }

    function isPlaying()
    {
        return mediaplayer.playbackState === MediaPlayer.PlayingState;
    }

    function play()
    {
        mediaplayer.play();
    }

    function stop()
    {
        mediaplayer.stop();
    }

    function pause()
    {
        mediaplayer.pause();
    }

    function getPaused()
    {
        if (mediaplayer.state === MediaPlayer.PausedState) return true; else return false;
    }

    function togglePaused()
    {
        console.info("MediaPlayer.state: " + mediaplayer.state);
        if (mediaplayer.playbackState === MediaPlayer.StoppedState)
            mediaplayer.play();
        else if (mediaplayer.playbackState === MediaPlayer.PlayingState)
            mediaplayer.pause();
        else
            mediaplayer.play();
    }

    function changeVolume(amount)
    {
        if (amount < 0)
            mediaplayer.volume = Math.max(0.0, mediaplayer.volume + amount);
        else
            mediaplayer.volume = Math.min(1.0, mediaplayer.volume + amount);

        showMessage("Volume: " + Math.round(mediaplayer.volume * 100) + "%");
    }

    function getMuted()
    {
        return mediaplayer.audio.mute;
    }

    function setMute(mute)
    {
        if (mute != mediaplayer.mediaplayer.muted)
            mediaplayer.muted = mute;
    }

    function toggleMute()
    {
        mediaplayer.muted = !mediaplayer.muted;
    }

    function setLoopMode(doLoop)
    {
        //FIXME
    }

    function toggleInterlacer()
    {
        //FIXME

        showMessage("Deinterlacer: N/A");
    }

    function takeSnapshot(filename)
    {
        //FIXME
        console.info("saving snapshot to: " + filename);
        showMessage("Saving snapshots not currently available in this player");
    }

    function toggleFullscreen()
    {
        if (root.fullscreen)
        {
            root.fullscreen = false;
            root.x = root._oldX;
            root.y = root._oldY;
            root.width = root._oldWidth;
            root.height = root._oldHeight;
        }
        else
        {
            root.fullscreen = true;
            root._oldX = root.x;
            root._oldY = root.y;
            root._oldWidth = root.width;
            root._oldHeight = root.height;

            root.x = 0;
            root.y = 0;
            root.width = window.width;
            root.height = window.height;

            mediaplayer.focus = true;
        }
    }
}

