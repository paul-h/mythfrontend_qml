import QtQuick
import QtMultimedia

import mythqml.net 1.0

FocusScope
{
    id: root

    property alias source: mediaPlayer.source
    property alias position: mediaPlayer.position
    property alias duration: mediaPlayer.duration

    property bool playbackStarted: false
    property bool loop: false

    signal showMessage(string message, int timeOut)
    signal mediaStatusChanged(int mediaStatus)
    signal playbackStatusChanged(int playbackStatus)

    onLoopChanged:
    {
        if (loop)
            mediaPlayer.loops = MediaPlayer.Infinite;
        else
            mediaPlayer.loops = 1;
    }

    Rectangle
    {
        id: background

        color: "black"
        anchors.fill: parent

        MediaPlayer
        {
            id: mediaPlayer
            source: ""
            audioOutput: AudioOutput {}
            videoOutput: videoOutput

            onMediaStatusChanged:
            {
                if (mediaStatus == MediaPlayer.NoMedia)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQT: mediaStatus: No Media");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.NoMedia);
                }
                else if (mediaStatus == MediaPlayer.LoadingMedia)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQT: mediaStatus: Loading Media");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Loading);
                }
                else if (mediaStatus == MediaPlayer.LoadedMedia)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQT: mediaStatus: Loaded Media");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Loaded);
                }
                else if (mediaStatus == MediaPlayer.BufferingMedia)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQT: mediaStatus: Buffering Media");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Buffering);
                }
                else if (mediaStatus == MediaPlayer.StalledMedia)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQT: mediaStatus: Stalled Media");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Stalled);
                }
                else if (mediaStatus == MediaPlayer.BufferedMedia)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQT: mediaStatus: Buffered Media");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Buffered);
                }
                else if (mediaStatus == MediaPlayer.EndOfMedia)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQT: mediaStatus: Ended of Media");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Ended);
                }
                else if (mediaStatus == MediaPlayer.InvalidMedia)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQT: mediaStatus: Invalid Media");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Invalid);
                }
                else
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQT: mediaStatus: Unknown");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Unknown)
                }
            }

            onPlaybackStateChanged:
            {
                if (playbackState === MediaPlayer.PlayingState)
                    root.playbackStatusChanged(MediaPlayers.PlaybackStatus.Playing);
                else if (playbackState === MediaPlayer.PausedState)
                    root.playbackStatusChanged(MediaPlayers.PlaybackStatus.Paused);
                else if (playbackState === MediaPlayer.StoppedState)
                    root.playbackStatusChanged(MediaPlayers.PlaybackStatus.Stopped);
            }
        }

        VideoOutput
        {
            id: videoOutput
            anchors.fill: parent
        }
    }

    function getPlayerState()
    {
        return mediaPlayer.playbackState;
    }

    function isPlaying()
    {
        return mediaPlayer.playing;
    }

    function play()
    {
        mediaPlayer.play();
    }

    function stop()
    {
        mediaPlayer.stop();
    }

    function pause()
    {
        mediaPlayer.pause();
    }

    function getPaused()
    {
        if (mediaPlayer.playbackState === MediaPlayer.PausedState) return true; else return false;
    }

    function togglePaused()
    {
        if (mediaPlayer.playbackState === MediaPlayer.StoppedState || mediaPlayer.playerState === MediaPlayer.PausedState)
            mediaPlayer.play();
        else
            mediaPlayer.pause();
    }

    function skipBack(time)
    {
        mediaPlayer.position = mediaPlayer.Position - time;
    }

    function skipForward(time)
    {
        mediaPlayer.position = mediaPlayer.position + time;
    }

    function changeVolume(amount)
    {
        amount = amount / 100;

        if (amount < 0)
            mediaPlayer.audioOutput.volume = Math.max(0, mediaPlayer.audioOutput.volume + amount);
        else
            mediaPlayer.audioOutput.volume = Math.min(1.0, mediaPlayer.audioOutput.volume + amount);

        showMessage("Volume: " + parseInt((mediaPlayer.audioOutput.volume * 100)) + "%", settings.osdTimeoutMedium);
    }

    function getVolume()
    {
        return mediaPlayer.audioOutput.volume * 100;
    }

    function setVolume(volume)
    {
        mediaPlayer.audioOutput.volume = volume / 100;
    }

    function getMute()
    {
        return mediaPlayer.audioOutput.muted;
    }

    function setMute(mute)
    {
        mediaPlayer.audioOutput.muted = mute;
    }

    function toggleMute()
    {
        mediaPlayer.audioOutput.muted = !mediaPlayer.audioOutput.muted;
    }

    function setSubtitles(on)
    {
        if (on)
        {
            //FIXME should check we have subtitles and choose the correct track?
            mediaPlayer.activeSubtitleTrack = 0;
            showMessage("Subtitles: On", settings.osdTimeoutMedium);
        }
        else
        {
            mediaPlayer.activeSubtitleTrack = -1;
            showMessage("Subtitles: Off", settings.osdTimeoutMedium);
        }
    }

    function toggleSubtitles()
    {
        if (mediaPlayer.activeSubtitleTrack != -1)
            setSubtitles(false)
        else
            setSubtitles(true);
    }

    function getPosition()
    {
        return mediaPlayer.position;
    }

    function getDuration()
    {
        return mediaPlayer.duration;
    }

    function setLoopMode(doLoop)
    {
        if (doLoop)
            mediaplayer.loops = MediaPlayer.Infinite;
        else
            mediaplayer.loops = 1;
    }

    function toggleInterlacer()
    {
        showMessage("Deinterlacer is not supported by this player");
    }

    function setFillMode(mode)
    {
        if (mode === MediaPlayers.FillMode.Stretch)
        {
            mediaplayer.videoOutput.fillMode = VideoOutput.Stretch;
            showMessage("Fill Mode: Stretch", settings.osdTimeoutMedium);
        }
        else if (mode === MediaPlayers.FillMode.PreserveAspectFit)
        {
            mediaplayer.videoOutput.fillMode = VideoOutput.PreserveAspectFit;
            showMessage("Fill Mode: Fit", settings.osdTimeoutMedium);
        }
        else if (mode === MediaPlayers.FillMode.PreserveAspectCrop)
        {
            mediaplayer.videoOutput.fillMode = VideoOutput.PreserveAspectCrop;
            showMessage("Fill Mode: Crop", settings.osdTimeoutMedium);
        }
    }

    function startRecording(filename, format)
    {
        //mediaplayer.record(filename, format);
    }

    function stopRecording()
    {
        //mediaplayer.record(null, null);
    }

    function isRecording()
    {
        //return mediaplayer.isRecording();
    }
}
