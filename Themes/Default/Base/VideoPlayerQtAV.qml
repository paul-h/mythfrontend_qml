import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtAV 1.7
import mythqml.net 1.0

import "../../../Util.js" as Util


FocusScope
{
    id: root
    //property alias playlist: mediaplayer.playlist
    property alias source: mediaplayer.source
    property alias volume: mediaplayer.volume
    property alias fillMode: mediaplayer.fillMode

    property bool loop: false
    property bool playbackStarted: false

    signal showMessage(string message, int timeOut)
    signal mediaStatusChanged(int mediaStatus)
    signal playbackStatusChanged(int playbackStatus)

    Rectangle
    {
        id: background

        color: "black"
        layer.enabled: false
        anchors.fill: parent

        VideoFilter
        {
            id: vf
            enabled: currentDeinterlacer > 0
            avfilter: ""

            property int currentDeinterlacer: 0
            property var deinterlacers: ["None", "Bob", "Yadif", "w3fdif"]

            onCurrentDeinterlacerChanged:
            {
                switch (currentDeinterlacer)
                {
                    case 0:
                        avfilter = "";
                        break;
                    case 1:
                        avfilter = "bwdif";
                        break;
                    case 2:
                        avfilter = "yadif"
                        break;
                    case 3:
                        avfilter = "w3fdif"
                        break;
                    default:
                        avfilter =""
                        break;
                }
            }
        }

        Video
        {
            id: mediaplayer
            visible: (status === MediaPlayer.Buffered && (playbackState === MediaPlayer.PlayingState || playbackState === MediaPlayer.PausedState));
            focus: true
            autoPlay: true
            backgroundColor: "black"
            anchors.fill: parent
            subtitle.engines: ["FFmpeg"]
            videoCodecPriority: ["FFmpeg", "VAAPI", "CUDA"]
            audioBackends: ["OpenAL", "Pulse", "Null"]
            videoFilters: [vf]

            onStatusChanged:
            {
                if (status == MediaPlayer.NoMedia)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: no media");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.NoMedia);
                }
                else if (status === MediaPlayer.Loading)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: loading");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Loading);
                }
                else if (status === MediaPlayer.Loaded)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: loaded");
                }
                else if (playbackState === MediaPlayer.PlayingState && status === MediaPlayer.Buffering)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: buffering");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Buffering);
                }
                else if (status === MediaPlayer.Stalled)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: Stalled");
                }
                else if (status === MediaPlayer.Buffered)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: Buffered");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Buffered)
                }
                else if (status === MediaPlayer.EndOfMedia)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: EndOfMedia");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Ended);
                }
                else if (status === MediaPlayer.InvalidMedia)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: InvalidMedia");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Invalid);
                }
                else if (status === MediaPlayer.UnknownStatus)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: UnknownStatus");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Unknown);
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
        if (mediaplayer.playbackState === MediaPlayer.StoppedState)
            mediaplayer.play();
        else if (mediaplayer.playbackState === MediaPlayer.PlayingState)
            mediaplayer.pause();
        else
            mediaplayer.play();
    }

    function skipBack(time)
    {
        mediaplayer.seek(mediaplayer.position - time);
    }

    function skipForward(time)
    {
        mediaplayer.seek(mediaplayer.position + time);
    }

    function changeVolume(amount)
    {
        amount = amount / 100

        if (amount < 0)
            mediaplayer.volume = Math.max(0.0, mediaplayer.volume + amount);
        else
            mediaplayer.volume = Math.min(1.0, mediaplayer.volume + amount);

        showMessage("Volume: " + Math.round(mediaplayer.volume * 100) + "%", settings.osdTimeoutMedium);
    }

    function getVolume()
    {
        return parseInt(mediaplayer.volume * 100);
    }

    function setVolume(volume)
    {
        mediaplayer.volume = volume / 100;
    }

    function getMuted()
    {
        return mediaplayer.muted;
    }

    function setMute(mute)
    {
        if (mute !== mediaplayer.muted)
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
        //FIXME
    }

    function toggleInterlacer()
    {
        if (vf.currentDeinterlacer >= vf.deinterlacers.length - 1)
            vf.currentDeinterlacer = 0;
        else
            vf.currentDeinterlacer++

        showMessage("Deinterlacer: " + vf.deinterlacers[vf.currentDeinterlacer], settings.osdTimeoutMedium);
    }

    function setFillMode(mode)
    {
        if (mode === MediaPlayers.FillMode.Stretch)
        {
            mediaplayer.fillMode = VideoOutput.Stretch;
            showMessage("Fill Mode: Stretch", settings.osdTimeoutMedium);
        }
        else if (mode === MediaPlayers.FillMode.PreserveAspectFit)
        {
            mediaplayer.fillMode = VideoOutput.PreserveAspectFit;
            showMessage("Fill Mode: Fit", settings.osdTimeoutMedium);
        }
        else if (mode === MediaPlayers.FillMode.PreserveAspectCrop)
        {
            mediaplayer.fillMode = VideoOutput.PreserveAspectCrop;
            showMessage("Fill Mode: Crop", settings.osdTimeoutMedium);
        }
    }
}

