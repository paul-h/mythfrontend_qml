import QtQuick 2.9
import MDKPlayer 1.0


FocusScope
{
    id: root

    property alias source: mediaplayer.source
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

        color: "black"
        anchors.fill: parent

        MDKPlayer
        {
            id: mediaplayer
            property int currentDeinterlacer: 0
            property var deinterlacers: ["None", "Bob", "Yadif", "w3fdif"]

            anchors.fill: parent

            onCurrentDeinterlacerChanged:
            {
                var vfilter = "";

                switch (currentDeinterlacer)
                {
                    case 0:
                        vfilter = "";
                        break;
                    case 1:
                        vfilter = "bwdif";
                        break;
                    case 2:
                        vfilter = "yadif"
                        break;
                    case 3:
                        vfilter = "w3fdif"
                        break;
                    default:
                        vfilter =""
                        break;
                }

                setProperty("video.avfilter", vfilter);
            }

            onMediaStatusChanged:
            {
                if (mediaStatus & (MDKPlayer.MediaStatusEnd + MDKPlayer.MediaPrepared + MDKPlayer.MediaBuffered))
                    root.playbackEnded();
            }
        }
    }

    function getPlayerState()
    {
        return mediaplayer.playerState;
    }

    function isPlaying()
    {
        return mediaplayer.playerState == MDKPlayer.PlayerStatePlaying;
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
        if (mediaplayer.playerState === MDKPlayer.PlayerStatePaused) return true; else return false;
    }

    function togglePaused()
    {
        if (mediaplayer.playerState === MDKPlayer.PlayerStatePaused) mediaplayer.play(); else mediaplayer.pause();
    }

    function skipBack(time)
    {
        mediaplayer.seek(-time);
    }

    function skipForward(time)
    {
        mediaplayer.seek(time);
    }

    function changeVolume(amount)
    {
        amount = amount / 100;

        if (amount < 0)
            mediaplayer.volume = Math.max(0, mediaplayer.volume + amount);
        else
            mediaplayer.volume = Math.min(1.0, mediaplayer.volume + amount);

        showMessage("Volume: " + parseInt((mediaplayer.volume * 100)) + "%", settings.osdTimeoutMedium);
    }

    function getVolume()
    {
        return mediaplayer.volume * 100;
    }

    function setVolume(volume)
    {
        mediaplayer.volume = volume / 100;
    }

    function getMuted()
    {
        return root.muteAudio;
    }

    function setMute(mute)
    {
        mediaplayer.muted = mute;
    }

    function toggleMute()
    {
        mediaplayer.muted = !mediaplayer.muted;
    }

    function getPosition()
    {
        return mediaplayer.position;
    }

    function getDuration()
    {
        return mediaplayer.duration;
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
        if (mediaplayer.currentDeinterlacer >= mediaplayer.deinterlacers.length - 1)
            mediaplayer.currentDeinterlacer = 0;
        else
            mediaplayer.currentDeinterlacer++

        showMessage("Deinterlacer: " + mediaplayer.deinterlacers[mediaplayer.currentDeinterlacer], settings.osdTimeoutMedium);
    }
}
