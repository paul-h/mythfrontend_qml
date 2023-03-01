import QtQuick 2.10
import MDKPlayer 1.0
import mythqml.net 1.0

FocusScope
{
    id: root

    property alias source: mediaplayer.source
    property bool loop: false
    property bool playbackStarted: false

    signal showMessage(string message, int timeOut)
    signal mediaStatusChanged(int mediaStatus)
    signal playbackStatusChanged(int playbackStatus)

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
                if (mediaStatus == (MDKPlayer.MediaStatusEnd + MDKPlayer.MediaPrepared + MDKPlayer.MediaBuffered))
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerMDK: mediaStatus: Ended");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Ended);
                }
                else if (mediaStatus & MDKPlayer.MediaStatusInvalid)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerMDK: mediaStatus: Invalid");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Invalid);
                }
                else if (mediaStatus & MDKPlayer.MediaStatusUnloaded)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerMDK: mediaStatus: Unloaded");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Unknown);
                }
                else if (mediaStatus == (MDKPlayer.MediaStatusLoaded + MDKPlayer.MediaStatusPrepared + MDKPlayer.MediaStatusBuffered))
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerMDK: mediaStatus: Loaded | Prepared | Buffered");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Buffered);
                }
                else if (mediaStatus & MDKPlayer.MediaStatusLoading)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerMDK: mediaStatus: Loaded");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Loading)
                }
                else if (mediaStatus & MDKPlayer.MediaStatusBuffering)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerMDK: mediaStatus: Buffering");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Buffering)
                }
                else
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerMDK: mediaStatus: Unknown");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Unknown)
                }
            }

            onPlayerStateChanged:
            {
                if (playerState === MDKPlayer.PlayerStatePlaying)
                    root.playbackStatusChanged(MediaPlayers.PlaybackStatus.Playing);
                else if (playerState === MDKPlayer.PlayerStatePaused)
                    root.playbackStatusChanged(MediaPlayers.PlaybackStatus.Paused);
                else if (playerState === MDKPlayer.PlayerStateStopped)
                    root.playbackStatusChanged(MediaPlayers.PlaybackStatus.Stopped);
            }
        }
    }

    LabelText
    {
        anchors.fill: parent
        visible: !mediaplayer.isAvailable
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "The MDK player is not available.\nPlease install the MDK library. See help for instructions."
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
        if (mediaplayer.playerState === MDKPlayer.PlayerStateStopped || mediaplayer.playerState === MDKPlayer.PlayerStatePaused)
            mediaplayer.play();
        else
            mediaplayer.pause();
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

    function getMute()
    {
        return mediaplayer.muted;
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

    function setFillMode(mode)
    {
        mediaplayer.setFillMode(mode);

        if (mode === VideoPlayerMDK.FillMode.Stretch)
            showMessage("Fill Mode: Stretch", settings.osdTimeoutMedium);
        else if (mode === VideoPlayerMDK.FillMode.PreserveAspectFit)
            showMessage("Fill Mode: Fit", settings.osdTimeoutMedium);
        else if (mode === VideoPlayerMDK.FillMode.PreserveAspectCrop)
            showMessage("Fill Mode: Crop", settings.osdTimeoutMedium);
    }

    function startRecording(filename, format)
    {
        mediaplayer.record(filename, format);
    }

    function stopRecording()
    {
        mediaplayer.record(null, null);
    }

    function isRecording()
    {
        return mediaplayer.isRecording();
    }
}
