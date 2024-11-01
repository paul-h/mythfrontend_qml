import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import Base 1.0

BaseScreen
{
    defaultFocusItem: urlEdit

    Component.onCompleted:
    {
        showTitle(true, "MDK Player Test");
        showTime(false);
        showTicker(false);
        muteAudio(true);
    }

    Component.onDestruction:
    {
        videoPlayer.stop();
    }

    Keys.onPressed: event =>
    {
        event.accepted = true;

        if (event.key === Qt.Key_P)
        {
            if (videoPlayer.isPlaying())
            {
                videoPlayer.pause();
            }
            else
            {
                videoPlayer.play();
            }
        }
        else if (event.key === Qt.Key_S)
        {
            videoPlayer.stop();
        }
        else if (event.key === Qt.Key_O)
        {
            videoPlayer.pause();
        }
        else if (event.key === Qt.Key_L)
        {
            videoPlayer.loop = !videoPlayer.loop;

            showNotification("Loop mode is: " + (videoPlayer.loop ? "On" : "Off"), settings.osdTimeoutMedium);
        }
        else if (event.key === Qt.Key_I)
        {
            showNotification("PlayerState is: " + videoPlayer.getPlayerState());
        }
        else if (event.key === Qt.Key_F9)
        {
            videoPlayer.toggleMute();
        }
        else if (event.key === Qt.Key_BracketLeft)
        {
            videoPlayer.changeVolume(-1);
        }
        else if (event.key === Qt.Key_BracketRight)
        {
            videoPlayer.changeVolume(1);
        }
        else if (event.key === Qt.Key_Less)
        {
            videoPlayer.skipBack(10 * 1000);
        }
        else if (event.key === Qt.Key_Greater)
        {
            videoPlayer.skipForward(30 * 1000);
        }
        else if (event.key === Qt.Key_PageUp)
        {
            videoPlayer.skipBack(10 * 60 * 1000);
        }
        else if (event.key === Qt.Key_PageDown)
        {
            videoPlayer.skipForward(10 * 60 * 1000);
        }
        else
            event.accepted = false;
    }

    LabelText
    {
        x: 50; y: 50
        text: "URL to play:"
    }

    BaseEdit
    {
        id: urlEdit
        x: xscale(200); y: yscale(50); width: parent.width - xscale(250)
        onEditingFinished: videoPlayer.source = text;

        KeyNavigation.up: videoPlayer;
        KeyNavigation.down: videoPlayer;
    }

    VideoPlayerMDK
    {
        id: videoPlayer

        x: xscale(50); width: parent.width - xscale(100);
        y: yscale(110); height: parent.height - yscale(140);

        KeyNavigation.up: urlEdit;
        KeyNavigation.down: urlEdit;

        onShowMessage: (message, timeOut) => window.showNotification(message, timeOut)

        onMediaStatusChanged: mediaStatus =>
        {
            if (mediaStatus === MediaPlayers.MediaStatus.Unknown)
                mediaStatusText.text = "Media Status: Unknown";
            else if (mediaStatus === MediaPlayers.MediaStatus.NoMedia)
                mediaStatusText.text = "Media Status: No Media";
            else if (mediaStatus === MediaPlayers.MediaStatus.Invalid)
                mediaStatusText.text = "Media Status: Invalid Media";
            else if (mediaStatus === MediaPlayers.MediaStatus.Loading)
                mediaStatusText.text = "Media Status: Loading Media";
            else if (mediaStatus === MediaPlayers.MediaStatus.Loaded)
                mediaStatusText.text = "Media Status: Loaded Media";
            else if (mediaStatus === MediaPlayers.MediaStatus.Buffering)
                mediaStatusText.text = "Media Status: Buffering Media";
            else if (mediaStatus === MediaPlayers.MediaStatus.Buffered)
                mediaStatusText.text = "Media Status: Buffered Media";
            else if (mediaStatus === MediaPlayers.MediaStatus.Ended)
                mediaStatusText.text = "Media Status: End Of Media";
            else if (mediaStatus === MediaPlayers.MediaStatus.Stalled)
                mediaStatusText.text = "Media Status: Stalled Media";
        }

        onPlaybackStatusChanged: playerStatus =>
        {
            if (playerStatus === MediaPlayers.PlaybackStatus.Stopped)
                playerStatusText.text = "Playback Status: Stopped";
            else if (playerStatus === MediaPlayers.PlaybackStatus.Paused)
                playerStatusText.text = "Playback Status: Paused";
            else if (playerStatus === MediaPlayers.PlaybackStatus.Playing)
                playerStatusText.text = "Playback Status: Playing";
        }

                onPositionChanged:
        {
            positionText.text = "Position " + position + "/" + duration;
        }

        InfoText
        {
            id: mediaStatusText
            x: 50
            y: 50
            width: 300
            text: ""
        }

        InfoText
        {
            id: playerStatusText
            x: 50
            y: 100
            width: 300
            text: ""
        }

        InfoText
        {
            id: positionText
            x: 50
            y: 150
            width: 300
            text: ""
        }
    }

    Rectangle
    {
        id: playerRect
        x: xscale(50); y: videoPlayer.y + videoPlayer.height; width: videoPlayer.width; height: yscale(4)
        color: videoPlayer.focus ? "green" : "white"
    }
}
