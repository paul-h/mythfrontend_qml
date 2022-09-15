import QtQuick 2.10
import MDKPlayer 1.0
import mythqml.net 1.0
import Telnet 1.0

FocusScope
{
    id: root

    property string ip: settings.tivoIP
    property int port:  settings.tivoControlPort

    property int channel: -1

    property alias source: mediaplayer.source
    property alias volume: mediaplayer.volume
    property bool loop: false
    property bool playbackStarted: false
    property bool muteAudio: false

    signal showMessage(string message, int timeOut)
    signal mediaStatusChanged(int mediaStatus)
    signal playbackStatusChanged(int playbackStatus)

    Component.onCompleted: telnet.connectToTelnet(ip + ":" + port);

    ListModel
    {
        id: remoteCodes

        ListElement { key: Qt.Key_Up;           remote: "UP"}
        ListElement { key: Qt.Key_Down;         remote: "DOWN"}
        ListElement { key: Qt.Key_Right;        remote: "RIGHT"}
        ListElement { key: Qt.Key_Left;         remote: "LEFT"}
        ListElement { key: Qt.Key_Enter;        remote: "SELECT"}
        ListElement { key: Qt.Key_T;            remote: "TIVO"}
        ListElement { key: Qt.Key_L;            remote: "LIVETV"}
        ListElement { key: Qt.Key_F5;           remote: "THUMBSUP"}
        ListElement { key: Qt.Key_F6;           remote: "THUMBSDOWN"}
        ListElement { key: Qt.Key_R;            remote: "RECORD"}
        ListElement { key: Qt.Key_0;            remote: "NUM0"}
        ListElement { key: Qt.Key_1;            remote: "NUM1"}
        ListElement { key: Qt.Key_2;            remote: "NUM2"}
        ListElement { key: Qt.Key_3;            remote: "NUM3"}
        ListElement { key: Qt.Key_4;            remote: "NUM4"}
        ListElement { key: Qt.Key_5;            remote: "NUM5"}
        ListElement { key: Qt.Key_6;            remote: "NUM6"}
        ListElement { key: Qt.Key_7;            remote: "NUM7"}
        ListElement { key: Qt.Key_8;            remote: "NUM8"}
        ListElement { key: Qt.Key_9;            remote: "NUM9"}
        ListElement { key: Qt.Key_Return;       remote: "ENTER"}
        ListElement { key: Qt.Key_C;            remote: "CLEAR"}
        ListElement { key: Qt.Key_P;            remote: "PLAY"}
        ListElement { key: Qt.Key_Space;        remote: "PAUSE"}
        ListElement { key: Qt.Key_S;            remote: "STOP"}
        ListElement { key: Qt.Key_Minus;        remote: "SLOW"}
        ListElement { key: Qt.Key_X;            remote: "STANDBY"}
        ListElement { key: Qt.Key_N;            remote: "NOWSHOWING"}
        ListElement { key: Qt.Key_A;            remote: "ADVANCE"}
        ListElement { key: Qt.Key_E;            remote: "REPLAY"}
        ListElement { key: Qt.Key_G;            remote: "GUIDE"}
        ListElement { key: Qt.Key_F1;           remote: "ACTION_A"}
        ListElement { key: Qt.Key_F2;           remote: "ACTION_B"}
        ListElement { key: Qt.Key_F3;           remote: "ACTION_C"}
        ListElement { key: Qt.Key_F4;           remote: "ACTION_D"}
        ListElement { key: Qt.Key_I;            remote: "INFO"}
        ListElement { key: Qt.Key_F4;           remote: "WINDOW"}
        ListElement { key: Qt.Key_Question;     remote: "SEARCH"}
        ListElement { key: Qt.Key_B;            remote: "BACK"}
        ListElement { key: Qt.Key_PageUp;       remote: "CHANNELUP"}
        ListElement { key: Qt.Key_PageDown;     remote: "CHANNELDOWN"}
        ListElement { key: Qt.Key_BracketLeft;  remote: "REVERSE"}
        ListElement { key: Qt.Key_BracketRight; remote: "FORWARD"}
    }

    Keys.onPressed:
    {
        for (var x = 0; x < remoteCodes.count; x++)
        {
            if (event.key === remoteCodes.get(x).key)
            {
                telnet.telnetSend("IRCODE " + remoteCodes.get(x).remote);
                event.accepted = true;
                return;
            }
        }

        if (event.key === Qt.Key_Escape)
        {
            KeyNavigation.up.forceActiveFocus();
            event.accepted = true;
            return;
        }

        event.accepted = false;
    }

    // for channel change on TiVo
    Telnet
    {
        id: telnet


        onDataChanged:
        {
            var list = data.split(" ");
            if (list.length === 3)
                root.channel = parseInt(list[1]);
        }
    }

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

            source: settings.tivoVideoURL

            anchors.fill: parent

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

    function changeChannel(chanNo)
    {
        var sNum = chanNo.toString();
        for (var x = 0; x < sNum.length; x++)
        {
            telnet.telnetSend("IRCODE NUM" + sNum.charAt(x));
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
}
