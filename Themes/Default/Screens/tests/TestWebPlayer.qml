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
        showTitle(true, "Web Player Test");
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
        else if (event.key === Qt.Key_C)
        {
            videoPlayer.toggleSubtitles();
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
        onEditingFinished: videoPlayer.url = text;

        KeyNavigation.up: videoPlayer;
        KeyNavigation.down: videoPlayer;
    }

    VideoPlayerWeb
    {
        id: videoPlayer

        x: xscale(50); width: parent.width - xscale(100);
        y: yscale(110); height: parent.height - yscale(140);

        KeyNavigation.up: urlEdit;
        KeyNavigation.down: urlEdit;

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
