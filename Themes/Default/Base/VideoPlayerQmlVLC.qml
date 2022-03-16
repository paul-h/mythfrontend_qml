import QtQuick 2.0
import QmlVlc 0.1
import mythqml.net 1.0

FocusScope
{
    id: root
    property alias source: mediaplayer.mrl
    property alias volume: mediaplayer.volume
    property bool loop: false
    property bool playbackStarted: false
    property bool muteAudio: false

    signal showMessage(string message, int timeOut)
    signal mediaStatusChanged(int mediaStatus)
    signal playbackStatusChanged(int playbackStatus)

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
                if (state === VlcPlayer.Playing)
                {
                    playbackStarted = true;
                }

                if (state == VlcPlayer.NothingSpecial)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQmlVLC: state: NothingSpecial");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Unknown);
                }
                else if (state === VlcPlayer.Opening)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQmlVLC: state: Opening");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Loading);
                }
                else if (state === VlcPlayer.Buffering)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQmlVLC: state: Buffering");
                }
                else if (state === VlcPlayer.Playing)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQmlVLC: state: Playing");
                    root.playbackStatusChanged(MediaPlayers.PlaybackStatus.Playing);
                    playbackStarted = true;
                }
                else if (state === VlcPlayer.Paused)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQmlVLC: state: Paused");
                    root.playbackStatusChanged(MediaPlayers.PlaybackStatus.Paused);
                }
                else if (state === VlcPlayer.Stopped)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQmlVLC: state: Stopped");
                    root.playbackStatusChanged(MediaPlayers.PlaybackStatus.Stopped);
                }
                else if (playbackStarted && position > 0 && state === VlcPlayer.Ended)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQmlVLC: status: Ended");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Ended);
                    playbackStarted = false;
                }
                else if (state === VlcPlayer.Error)
                {
                    log.debug(Verbose.PLAYBACK, "VideoPlayerQmlVLC: state: Error");
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Invalid);
                }
            }

            onMediaPlayerSeekableChanged: mediaplayer.seekable = seekable
            onPlayingChanged: muteTimer.start()

            onMediaPlayerBuffering:
            {
                if (percents < 100.0)
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Buffering);
                else
                    root.mediaStatusChanged(MediaPlayers.MediaStatus.Buffered);
            }
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
        if (mediaplayer.state === VlcPlayer.Paused || mediaplayer.state === VlcPlayer.Stopped)
            mediaplayer.play();
        else
            mediaplayer.pause();
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

    function setFillMode(mode)
    {
        if (mode === MediaPlayers.FillMode.Stretch)
        {
            videoSurface.fillMode = VlcVideoSurface.Stretch;
            showMessage("Fill Mode: Stretch", settings.osdTimeoutMedium);
        }
        else if (mode === MediaPlayers.FillMode.PreserveAspectFit)
        {
            videoSurface.fillMode = VlcVideoSurface.PreserveAspectFit;
            showMessage("Fill Mode: Fit", settings.osdTimeoutMedium);
        }
        else if (mode === MediaPlayers.FillMode.PreserveAspectCrop)
        {
            videoSurface.fillMode = VlcVideoSurface.PreserveAspectCrop;
            showMessage("Fill Mode: Crop", settings.osdTimeoutMedium);
        }
    }
}
