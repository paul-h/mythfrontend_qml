import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtAV 1.5
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

    signal playbackEnded()
    signal showMessage(string message, int timeOut)

    Rectangle
    {
        id: background

        color: "black"
        layer.enabled: false
        anchors.fill: parent

//        VideoFilter
//        {
//            id: vf
//            avfilter: "negate"
//        }

        Video
        {
            id: mediaplayer
            visible: (status === MediaPlayer.Buffered && playbackState === MediaPlayer.PlayingState);
            focus: true
            autoPlay: true
            backgroundColor: "black"
            anchors.fill: parent
            subtitle.engines: ["FFmpeg"]
            videoCodecPriority: ["CUDA", "FFmpeg", "VAAPI"]
            audioBackends: ["OpenAL", "Pulse", "Null"]
//            videoFilters: [vf]

            onStatusChanged:
            {
                if (status == MediaPlayer.NoMedia)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: no media");
                    showMessage("No Media", settings.osdTimeoutMedium);
                }
                else if (status === MediaPlayer.Loading)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: loading");
                }
                else if (status === MediaPlayer.Loaded)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: loaded");
                }
                else if (status === MediaPlayer.Buffering)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: buffering");
                    showMessage("Buffering", settings.osdTimeoutLong);
                }
                else if (status === MediaPlayer.Stalled)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: Stalled");
                }
                else if (status === MediaPlayer.Buffered)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: Buffered");
                    showMessage("", settings.osdTimeoutShort);
                }
                else if (status === MediaPlayer.EndOfMedia)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: EndOfMedia");
                    playbackEnded();
                }
                else if (status === MediaPlayer.InvalidMedia)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: InvalidMedia");
                }
                else if (status === MediaPlayer.UnknownStatus)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQtAV: status: UnknownStatus");
                }
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
        return mediaplayer.volume;
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
        //FIXME

        showMessage("Deinterlacer: N/A", settings.osdTimeoutMedium);
    }
}

