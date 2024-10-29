import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import Base 1.0
import VLCQt 1.1

BaseScreen
{
    defaultFocusItem: urlEdit

    Component.onCompleted:
    {
        showTitle(true, "VLC-Qt Player Test");
        showTime(false);
        showTicker(false);
        muteAudio(true);
    }

    Component.onDestruction:
    {
        videoPlayer.stop();
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

    VideoPlayerVLC
    {
        id: videoPlayer
        x: xscale(50); width: parent.width - xscale(100);
        y: yscale(110); height: parent.height - yscale(140);
        source: ""

        KeyNavigation.up: urlEdit;
        KeyNavigation.down: urlEdit;
    }

    Rectangle
    {
        id: playerRect
        x: xscale(50); y: videoPlayer.y + videoPlayer.height; width: videoPlayer.width; height: yscale(4)
        color: videoPlayer.focus ? "green" : "white"
    }
}
