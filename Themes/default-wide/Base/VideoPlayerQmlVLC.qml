import QtQuick 2.0
import QtQuick.Layouts 1.0
import QmlVlc 0.1

import "../../../Util.js" as Util


FocusScope
{
    id: root
    property alias playlist: mediaplayer.playlist
    property alias source: mediaplayer.mrl
    property alias volume: mediaplayer.volume
    property bool loop: false
    property bool playbackStarted: false
    signal playbackEnded()

    property string title: ""
    property string subtitle: ""

    Rectangle
    {
        id: background
        property alias source: mediaplayer.mrl

        color: "black"

        anchors.fill: parent

        VlcPlayer
        {
            id: mediaplayer

            property bool seekable: true

            onStateChanged:
            {
                if (playbackStarted && position > 0 && state === VlcPlayer.Ended)
                {
                    playbackStarted = false;
                    root.playbackEnded();
                }

                if (state === VlcPlayer.Playing)
                    playbackStarted = true;
            }

            onMediaPlayerSeekableChanged: mediaplayer.seekable = seekable

            audio.mute: false
        }

        VlcVideoSurface
        {
             id: videoSurface

             property int currentDeinterlacer: 0
             property var deinterlacers: ["None", "Blend", "Bob", "Discard", "Linear", "Mean", "X", "Yadif", "Yadif (2x)", "Phosphor", "IVTC"]

             source: mediaplayer;
             anchors.fill: parent;
             fillMode: VlcVideoSurface.Stretch;
             focus: true

             Keys.onReturnPressed: root.togglePaused();
             Keys.onLeftPressed: if (mediaplayer.seekable) mediaplayer.time = mediaplayer.time - 30000;
             Keys.onRightPressed: if (mediaplayer.seekable) mediaplayer.time = mediaplayer.time + 30000;
             Keys.onPressed:
             {
                 event.accepted = true;

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
                     togglePaused();
                 else if (event.key === Qt.Key_S)
                 {
                     if (mediaplayer.mrl.indexOf("file://") == 0)
                        takeSnapshot(mediaplayer.mrl.substring(7, mediaplayer.mrl.length) + ".png");
                     else
                        takeSnapshot(settings.configPath + "snapshot.png");
                 }
                 else if (event.key === Qt.Key_BracketLeft)
                     changeVolume(-1.0);
                 else if (event.key === Qt.Key_BracketRight)
                     changeVolume(1.0);
                 else if (event.key === Qt.Key_F11)
                     toggleMute();
                 else if (event.key === Qt.Key_D)
                     toggleInterlacer();
                 else if (event.key === Qt.Key_PageUp && mediaplayer.seekable)
                     mediaplayer.time = mediaplayer.time - 600000;
                 else if (event.key === Qt.Key_PageDown && mediaplayer.seekable)
                     mediaplayer.time = mediaplayer.time + 600000;
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
                text: "Position: " + Util.milliSecondsToString(mediaplayer.time) + " / " + Util.milliSecondsToString(mediaplayer.length)
            }

            InfoText
            {
                id: timeLeft
                x: parent.width - width - xscale(15); y: yscale(45)
                text: "Remaining :" + Util.milliSecondsToString(mediaplayer.length - mediaplayer.time)
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
                        width: (parent.width - anchors.leftMargin - anchors.rightMargin) * mediaplayer.position
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
        return mediaplayer.state === VlcPlayer.Playing;
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
        if (mediaplayer.state === VlcPlayer.Paused) return true; else return false;
    }

    function togglePaused()
    {
        if (mediaplayer.state === VlcPlayer.Paused) mediaplayer.play(); else mediaplayer.pause();
    }

    function changeVolume(amount)
    {
        if (amount < 0)
            mediaplayer.volume = Math.max(0, mediaplayer.volume + amount);
        else
            mediaplayer.volume = Math.min(100, mediaplayer.volume + amount);

        showMessage("Volume: " + mediaplayer.volume + "%");
    }

    function getMuted()
    {
        return mediaplayer.audio.mute;
    }

    function setMute(mute)
    {
        if (mute != mediaplayer.audio.mute)
            mediaplayer.audio.mute = mute;

        //showMessage("Mute: " + (mute ? "On" : "Off"));
    }

    function toggleMute()
    {
        mediaplayer.audio.mute = !mediaplayer.audio.mute;
        //showMessage("Mute: " + (mediaplayer.audio.mute ? "On" : "Off"));
    }

    function setLoopMode(doLoop)
    {
        if (doLoop)
            mediaplayer.playlist.mode = VlcPlaylist.Loop;
        else
            mediaplayer.playlist.mode = VlcPlaylist.Single;
    }

    function toggleInterlacer()
    {
        videoSurface.currentDeinterlacer++

        if (videoSurface.currentDeinterlacer >= videoSurface.deinterlacers.length)
            videoSurface.currentDeinterlacer = 0;

        if (videoSurface.currentDeinterlacer > 0)
            mediaplayer.video.deinterlace.enable(videoSurface.deinterlacers[videoSurface.currentDeinterlacer])
        else
            mediaplayer.video.deinterlace.disable()

        showMessage("Deinterlacer: " + videoSurface.deinterlacers[videoSurface.currentDeinterlacer]);
    }

    function takeSnapshot(filename)
    {
        console.info("saving snapshot to: " + filename);
        videoSurface.grabToImage(function(result)
                                 {
                                     result.saveToFile(filename);
                                 });
        showMessage("Snapshot Saved");
    }
}
