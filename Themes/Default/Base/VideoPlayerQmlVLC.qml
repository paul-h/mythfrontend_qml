import QtQuick 2.0
import QmlVlc 0.1

FocusScope
{
    id: root
    property alias source: mediaplayer.mrl
    property alias volume: mediaplayer.volume
    property bool loop: false
    property bool playbackStarted: false
    property bool muteAudio: false

    signal stateChanged(int state)
    signal playbackEnded()
    signal showMessage(string message, int timeOut)

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
                {
                    playbackStarted = true;
                }

                root.stateChanged(state);
            }

            onMediaPlayerSeekableChanged: mediaplayer.seekable = seekable
            onPlayingChanged: muteTimer.start()
        }

        Timer
        {
            id: muteTimer
            interval: 500; running: false; repeat: true
            onTriggered:
            {
                // keep checking the mute status until we get the result we want
                if (mediaplayer.audio.mute != -1)
                {
                    if (mediaplayer.audio.mute != root.muteAudio)
                        mediaplayer.audio.mute = root.muteAudio;
                    else
                        running = false;
                }
            }
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
        }
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

    function skipBack(time)
    {
        if (mediaplayer.seekable) mediaplayer.time = mediaplayer.time - time;
    }

    function skipForward(time)
    {
        if (mediaplayer.seekable) mediaplayer.time = mediaplayer.time + time;
    }

    function changeVolume(amount)
    {
        if (amount < 0)
            mediaplayer.volume = Math.max(0, mediaplayer.volume + amount);
        else
            mediaplayer.volume = Math.min(100, mediaplayer.volume + amount);

        showMessage("Volume: " + mediaplayer.volume + "%", settings.osdTimeoutMedium);
    }

    function getVolume()
    {
        return mediaplayer.volume;
    }

    function setVolume(volume)
    {
        mediaplayer.volume = volume;
    }

    function getMuted()
    {
        return root.muteAudio;
    }

    function setMute(mute)
    {
        root.muteAudio = mute;

        if (mute !== mediaplayer.audio.mute)
            mediaplayer.audio.mute = mute;
    }

    function toggleMute()
    {
        root.muteAudio = !root.muteAudio;

        mediaplayer.audio.mute = root.muteAudio;
    }

    function getPosition()
    {
        return mediaplayer.time;
    }

    function getDuration()
    {
        return Math.max(mediaplayer.length, mediaplayer.time);
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

        showMessage("Deinterlacer: " + videoSurface.deinterlacers[videoSurface.currentDeinterlacer], settings.osdTimeoutMedium);
    }
}
