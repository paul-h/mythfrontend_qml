import QtQuick
import Base 1.0
import Dialogs 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: fireTVPlayer

    Component.onCompleted:
    {
        showTitle(true, "Test Tivo and FireTV Players");
        showTime(true);
        showTicker(false);
        muteAudio(true);
    }

    Component.onDestruction:
    {
        fireTVPlayer.stop();
        //tivoPlayer.stop();
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            console.log("F1 pressed");
            fireTVPlayer.source = "file:///home/paul/.mythqml/firetv_pipe";
            fireTVPlayer.play();
        }
        else if (event.key === Qt.Key_F2)
        {
            fireTVPlayer.stop();
        }
        else if (event.key === Qt.Key_F3)
        {
            fireTVPlayer.pause();

        }
        else if (event.key === Qt.Key_F4)
        {
        }
        else
            event.accepted = true;
    }

    VideoPlayerFireTV
    {
        id: fireTVPlayer
        x: xscale(100)
        y: yscale(100)
        width: xscale(500)
        height: width / (16 / 9)
    }

//    VideoPlayerTivo
//    {
//        id: tivoPlayer
//        x: xscale(700)
//        y: yscale(100)
//        width: xscale(500)
//        height: width / (16 / 9)
//    }
}
