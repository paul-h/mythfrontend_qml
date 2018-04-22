import QtQuick 2.0
import VLCQt 1.2

import "../../../Util.js" as Util


FocusScope
{
    id: root
    property alias source: mediaplayer.url
    //property alias muted: mediaplayer.muted
    property alias volume: mediaplayer.volume
    property alias audioTrack: mediaplayer.audioTrack
    property bool loop: false

    anchors.fill: parent

    Rectangle
    {
        id: background
        property alias source: mediaplayer.url

        color: "black"

        anchors.fill: parent

        VlcVideoPlayer
        {
            id: mediaplayer
            focus: true
            //autoPlay: true
            anchors.fill: parent
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
                    togglePaused();
                else if (event.key === Qt.Key_BracketLeft)
                    changeVolume(-0.01);
                else if (event.key === Qt.Key_BracketRight)
                    changeVolume(0.01);
                else if (event.key === Qt.Key_M)
                    toggleMute();
                else
                    event.accepted = false;
            }

            onStateChanged:
            {
                console.log("videoplayer onStateChanged called " + state);
                if (loop && state === 6)
                {
                    console.log("videoplayer restarting playback");
                    stop();
                    play();
                }
            }
        }

        Rectangle
        {
            id: infoPanel
            x: 10; y: parent.height - 80; width: parent.width - 20; height: 70
            visible: false
            color: "black"
            opacity: 0.4
            radius: 5
            border.color: "green"
            border.width: 3

            Text
            {
                x: 10; y: 5
                id: pos
                text: "Position: " + Util.milliSecondsToString(mediaplayer.position) + " / " + Util.milliSecondsToString(mediaplayer.duration)
                color: "white"
            }

            Text
            {
                x: 10; y: 20
                id: timeLeft
                text: "Remaining :" + Util.milliSecondsToString(mediaplayer.duration - mediaplayer.position)
                color: "white"
            }
            Text
            {
                x: 10; y: 35
                id: vol
                text:
                {
                    var volPercent = mediaplayer.volume * 100;
                    "Volume: " + Math.round(volPercent) + "%"
                }
                color: "white"
            }

            Text
            {
                x: 10; y: 5
                id: artist
                text: if (mediaplayer.metaData.albumArtist)
                          "Artist: " + mediaplayer.metaData.albumArtist;
                      else
                          "Artist: Unknown";
                color: "white"
            }
            Text
            {
                x: 10; y: 20
                id: title
                text: if (mediaplayer.metaData.title)
                "Title: " + mediaplayer.metaData.title;
                else
                    "Title: Unknown";
                color: "white"
            }

        }

        MouseArea
        {
            id: playArea
            anchors.fill: parent
            onPressed: mediaplayer.play();
        }

    }

    function play()
    {
        mediaplayer.play();
    }

    function stop()
    {
        mediaplayer.stop();
    }

    function togglePaused()
    {
        if (mediaplayer.playbackState === MediaPlayer.PausedState) mediaplayer.play(); else mediaplayer.pause();
    }

    function changeVolume(amount)
    {
        if (amount < 0)
            mediaplayer.volume = Math.max(0.0, mediaplayer.volume + amount);
        else
            mediaplayer.volume = Math.min(1.0, mediaplayer.volume + amount);
    }

    function toggleMute()
    {
        mediaplayer.muted = !mediaplayer.muted;
        console.log("muted is now: " + mediaplayer.muted)
    }
}
