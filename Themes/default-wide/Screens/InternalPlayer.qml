import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.XmlListModel 2.0
import Base 1.0
import Dialogs 1.0
import "../../../Models"
import "../../../Util.js" as Util

BaseScreen
{
    id: root

    defaultFocusItem: mediaPlayer1

    property var feedList;
    property int currentFeed: 0
    property int layout: -1

    property bool _actionsEnabled: true

    signal feedChanged(int index)

    Component.onCompleted:
    {
        showTitle(true, "Media Player");
        showTime(false);
        showTicker(false);
        screenBackground.muteAudio(true);

        mediaPlayer1.feedList = feedList;
        mediaPlayer1.currentFeed = currentFeed;

        mediaPlayer2.feedList = feedList;
        mediaPlayer2.currentFeed = currentFeed + 1;

        mediaPlayer3.feedList = feedList;
        mediaPlayer3.currentFeed = currentFeed + 2;

        mediaPlayer4.feedList = feedList;
        mediaPlayer4.currentFeed = currentFeed + 3;

        setLayout(0);

        showInfo(true);
    }

    Component.onDestruction:
    {
        mediaPlayer1.stop();
        mediaPlayer2.stop();
        mediaPlayer3.stop();
        mediaPlayer4.stop();
        screenBackground.muteAudio(false);
    }

    Action
    {
        shortcut: "Escape"
        enabled: _actionsEnabled
        onTriggered: if (stack.depth > 1) {stack.pop(); escapeSound.play();} else Qt.quit();
    }

    Action
    {
        shortcut: "Down"
        enabled: _actionsEnabled
        onTriggered: nextPlayer();
    }

    Action
    {
        shortcut: "Up"
        enabled: _actionsEnabled
        onTriggered: previousPlayer();
    }

    Action
    {
        shortcut: "Left"
        enabled: _actionsEnabled
        onTriggered: previousPlayer();
    }

    Action
    {
        shortcut: "Right"
        enabled: _actionsEnabled
        onTriggered: nextPlayer();
    }

    Action
    {
        shortcut: "F1" // RED
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().previousFeed();
            showInfo(true);

            feedChanged(getActivePlayer().currentFeed);
        }
    }

    Action
    {
        shortcut: "F2" // GREEN
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().nextFeed();
            showInfo(true);

            feedChanged(getActivePlayer().currentFeed);
        }
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F3)
        {
            // YELLOW
            getActivePlayer().showRailCamDiagram();
        }
        else if (event.key === Qt.Key_F4)
        {
            // BLUE
            // TODO show web site?
        }
        else if (event.key === Qt.Key_F9)
        {
            getActivePlayer().toggleMute();
        }
        else if (event.key === Qt.Key_F)
        {
            if (layout === 0)
                return;

            if (mediaPlayer2.focus)
            {
                mediaPlayer1.feedList = mediaPlayer2.feedList;
                mediaPlayer1.currentFeed = mediaPlayer2.currentFeed;
            }
            else if (mediaPlayer3.focus)
            {
                mediaPlayer1.feedList = mediaPlayer3.feedList;
                mediaPlayer1.currentFeed = mediaPlayer3.currentFeed;
            }
            else if (mediaPlayer4.focus)
            {
                mediaPlayer1.feedList = mediaPlayer4.feedList;
                mediaPlayer1.currentFeed = mediaPlayer4.currentFeed;
            }

            mediaPlayer1.focus = true;
            mediaPlayer1.startPlayback();
            setLayout(0);

        }
        else if (event.key === Qt.Key_O)
        {
            getActivePlayer().stop();
        }
        else if (event.key === Qt.Key_P)
        {
            getActivePlayer().togglePaused();
            showInfo(true);
        }
        else if (event.key === Qt.Key_Less || event.key === Qt.Key_Comma)
        {
            getActivePlayer().skipBack(30000); // 30 seconds
            showInfo(true);
        }
        else if (event.key === Qt.Key_Greater || event.key === Qt.Key_Period)
        {
            getActivePlayer().skipForward(30000); // 30 seconds
            showInfo(true);
        }
        else if (event.key === Qt.Key_PageUp)
        {
            getActivePlayer().skipBack(600000); // 10 minutes
            showInfo(true);
        }
        else if (event.key === Qt.Key_PageDown)
        {
            getActivePlayer().skipForward(600000); // 10 minutes
            showInfo(true);
        }
        else if (event.key === Qt.Key_BracketLeft)
        {
            getActivePlayer().changeVolume(-1.0);
        }
        else if (event.key === Qt.Key_BracketRight)
        {
            getActivePlayer().changeVolume(1.0);
        }
        else if (event.key === Qt.Key_D)
        {
              getActivePlayer().toggleInterlacer();
        }
        else if (event.key === Qt.Key_S)
        {
            getActivePlayer().takeSnapshot();
        }
        else if (event.key === Qt.Key_I)
        {
            showInfo(false);
        }
        else if (event.key === Qt.Key_M)
        {
            popupMenu.clearMenuItems();

            popupMenu.addMenuItem("", "Switch Layout");
            popupMenu.addMenuItem("", "Player 1");

            popupMenu.addMenuItem("0", "Full Screen");
            popupMenu.addMenuItem("0", "Full screen with PIP");
            popupMenu.addMenuItem("0", "PBP 1/2 screen");
            popupMenu.addMenuItem("0", "PBP 3/4 screen with overlap");
            popupMenu.addMenuItem("0", "PBP 1 + 2");
            popupMenu.addMenuItem("0", "Quad Screen");

            for (var x = 0; x < mediaPlayer1.feedList.count; x++)
            {
                var path = "1"
                var title = mediaPlayer1.feedList.get(x).title;
                var data = "source=1\n" + x;
                popupMenu.addMenuItem(path, title, data);
            }

            if (root.layout > 0)
            {
                popupMenu.addMenuItem("", "Player 2");
                for (var x = 0; x < mediaPlayer2.feedList.count; x++)
                {
                    var path = "2"
                    var title = mediaPlayer2.feedList.get(x).title;
                    var data = "source=2\n" + x;
                    popupMenu.addMenuItem(path, title, data);
                }
            }

            if (root.layout > 3)
            {
                popupMenu.addMenuItem("", "Player 3");
                for (var x = 0; x < mediaPlayer3.feedList.count; x++)
                {
                    var path = "3"
                    var title = mediaPlayer3.feedList.get(x).title;
                    var data = "source=3\n" + x;
                    popupMenu.addMenuItem(path, title, data);
                }
            }

            if (root.layout > 4)
            {
                popupMenu.addMenuItem("", "Player 4");
                for (var x = 0; x < mediaPlayer4.feedList.count; x++)
                {
                    var path = "4"
                    var title = mediaPlayer4.feedList.get(x).title;
                    var data = "source=4\n" + x;
                    popupMenu.addMenuItem(path, title, data);
                }
            }

            _actionsEnabled = false;
            popupMenu.show();
       }
        else
        {
            event.accepted = false;
        }
    }

    MediaPlayer
    {
        id: mediaPlayer1
        visible: false
        enabled: visible

        onPlaybackEnded: if (layout === 0) { stop(); stack.pop(); }
    }

    MediaPlayer
    {
        id: mediaPlayer2
        visible: false
        enabled: visible
    }

    MediaPlayer
    {
        id: mediaPlayer3
        visible: false
        enabled: visible
    }

    MediaPlayer
    {
        id: mediaPlayer4
        visible: false
        enabled: visible
    }

    BaseBackground
    {
        id: infoPanel
        x: xscale(10); y: parent.height - yscale(50); width: parent.width - xscale(20); height: yscale(40)
        visible: false

        Image
        {
            x: xscale(30); y: yscale(5); width: xscale(32); height: yscale(32)
            source: mythUtils.findThemeFile("images/red_bullet.png")
        }

        InfoText
        {
            id: sort
            x: xscale(65); y: yscale(5); width: xscale(285); height: yscale(32)
            text: "Previous"
        }

        Image
        {
            x: xscale(350); y: yscale(5); width: xscale(32); height: yscale(32)
            source: mythUtils.findThemeFile("images/green_bullet.png")
        }

        InfoText
        {
            id: show
            x: xscale(385); y: yscale(5); width: xscale(285); height: yscale(32)
            text: "Next"
        }

        Image
        {
            x: xscale(670); y: yscale(5); width: xscale(32); height: yscale(32)
            source: mythUtils.findThemeFile("images/yellow_bullet.png")
        }

        InfoText
        {
            x: xscale(705); y: yscale(5); width: xscale(285); height: yscale(32)
            text: if (getActivePlayer().player === "RailCam") "Show Mini Diagram"; else "";
        }

        Image
        {
            x: xscale(990); y: yscale(5); width: xscale(32); height: yscale(32)
            source: mythUtils.findThemeFile("images/blue_bullet.png")
        }

        InfoText
        {
            x: xscale(1025); y: yscale(5); width: xscale(285); height: yscale(32)
            text: "Go To Website"
        }
    }

    PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "Media Player Options"

        onItemSelected:
        {
            mediaPlayer1.focus = true;
            _actionsEnabled = true;

            if (itemText == "Full Screen")
            {
                setLayout(0);
            }
            else if (itemText == "Full screen with PIP")
            {
                setLayout(1);
            }
            else if (itemText == "PBP 1/2 screen")
            {
                setLayout(2);
            }
            else if (itemText == "PBP 3/4 screen with overlap")
            {
                setLayout(3);
            }
            else if (itemText == "PBP 1 + 2")
            {
                setLayout(4);
            }
            else if (itemText == "Quad Screen")
            {
                setLayout(5);
            }
            else if (itemText == "Source 1 Toggle Mute")
                mediaPlayer1.toggleMute();
            else if (itemText == "Source 2 Toggle Mute")
                mediaPlayer2.toggleMute();
            else if (itemText == "Source 3 Toggle Mute")
                mediaPlayer3.toggleMute();
            else if (itemText == "Source 4 Toggle Mute")
                mediaPlayer4.toggleMute();
            else if (itemData.startsWith("source="))
            {
               var list = itemData.split("\n");
               console.info("found source=, list size: " + list.length);

               if (list.length == 2)
                {
                    if (list[0] == "source=1")
                    {
                        var feedIndex = list[1]
                        dbUtils.setSetting("Qml_player1Source", settings.hostName, feedIndex)
                        mediaPlayer1.currentFeed = feedIndex;
                        mediaPlayer1.startPlayback();
                    }
                    else if (list[0] == "source=2")
                    {
                        var feedIndex = list[1]
                        dbUtils.setSetting("Qml_player2Source", settings.hostName, feedIndex)
                        mediaPlayer2.currentFeed = feedIndex;
                        mediaPlayer2.startPlayback();                    }
                    else if (list[0] == "source=3")
                    {
                        var feedIndex = list[1]
                        dbUtils.setSetting("Qml_player3Source", settings.hostName, feedIndex)
                        mediaPlayer3.currentFeed = feedIndex;
                        mediaPlayer3.startPlayback();                    }
                    else if (list[0] == "source=4")
                    {
                        var feedIndex = list[1]
                        dbUtils.setSetting("Qml_player4Source", settings.hostName, feedIndex)
                        mediaPlayer4.currentFeed = feedIndex;
                        mediaPlayer4.startPlayback();                    }
                }
            }
        }

        onCancelled:
        {
            _actionsEnabled = true;
            mediaPlayer1.focus = true;
        }
    }

    function nextPlayer()
    {
        if (mediaPlayer1.focus && mediaPlayer2.visible)
            mediaPlayer2.focus = true;
        else if (mediaPlayer2.focus)
        {
            if (mediaPlayer3.visible)
                mediaPlayer3.focus = true;
            else
                mediaPlayer1.focus = true;
        }
        else if (mediaPlayer3.focus)
        {
            if (mediaPlayer4.visible)
                mediaPlayer4.focus = true;
            else
                mediaPlayer1.focus = true;
        }
        else if (mediaPlayer4.focus)
            mediaPlayer1.focus = true;
    }

    function previousPlayer()
    {
        if (mediaPlayer4.focus)
            mediaPlayer3.focus = true;
        else if (mediaPlayer3.focus)
            mediaPlayer2.focus = true;
        else if (mediaPlayer2.focus)
            mediaPlayer1.focus = true;
        else if (mediaPlayer1.focus)
        {
            if (mediaPlayer4.visible)
                mediaPlayer4.focus = true;
            else if (mediaPlayer3.visible)
                mediaPlayer3.focus = true;
            else if (mediaPlayer2.visible)
                mediaPlayer2.focus = true;
        }
    }

    function setLayout(newLayout)
    {
        if (root.layout === newLayout)
            return;

        root.layout = newLayout;

        if (root.layout === 0)
        {
            // full screen
            showVideo(false);

            mediaPlayer1.visible = true;
            mediaPlayer2.visible = false;
            mediaPlayer3.visible = false;
            mediaPlayer4.visible = false;

            mediaPlayer1.x = 0;
            mediaPlayer1.y = 0;
            mediaPlayer1.width = root.width;
            mediaPlayer1.height = root.height;
            mediaPlayer1.showBorder = false;

            mediaPlayer1.play();
            mediaPlayer2.stop();
            mediaPlayer3.stop();
            mediaPlayer4.stop();
        }
        else if (root.layout === 1)
        {
            // fullscreen with PIP
            showVideo(false);

            mediaPlayer1.visible = true;
            mediaPlayer2.visible = true;
            mediaPlayer3.visible = false;
            mediaPlayer4.visible = false;

            mediaPlayer1.x = 0;
            mediaPlayer1.y = 0;
            mediaPlayer1.width = root.width;
            mediaPlayer1.height = root.height;
            mediaPlayer1.showBorder = true;

            mediaPlayer2.x = root.width - xscale(50) - xscale(400);
            mediaPlayer2.y = yscale(50);
            mediaPlayer2.width = xscale(400);
            mediaPlayer2.height = yscale(225);

            mediaPlayer1.play();
            mediaPlayer2.play();
            mediaPlayer3.stop();
            mediaPlayer4.stop();
        }
        else if (root.layout === 2)
        {
            // PBP 1/2 screen
            showVideo(true);

            mediaPlayer1.visible = true;
            mediaPlayer2.visible = true;
            mediaPlayer3.visible = false;
            mediaPlayer4.visible = false;

            mediaPlayer1.x = 0;
            mediaPlayer1.y = yscale(250);
            mediaPlayer1.width = root.width / 2;
            mediaPlayer1.height = mediaPlayer1.width / 1.77777777;
            mediaPlayer1.showBorder = true;

            mediaPlayer2.x = root.width / 2;
            mediaPlayer2.y = yscale(250);
            mediaPlayer2.width = root.width / 2;
            mediaPlayer2.height = mediaPlayer2.width / 1.77777777;

            mediaPlayer1.play();
            mediaPlayer2.play();
            mediaPlayer3.stop();
            mediaPlayer4.stop();
        }
        else if (root.layout === 3)
        {
            // PBP 3/4 screen with overlap
            showVideo(true);

            mediaPlayer1.visible = true;
            mediaPlayer2.visible = true;
            mediaPlayer3.visible = false;
            mediaPlayer4.visible = false;

            mediaPlayer1.x = 0;
            mediaPlayer1.y = (root.height - (((root.width / 4) * 3) / 1.77777777)) / 2;
            mediaPlayer1.width = (root.width / 4) * 3;
            mediaPlayer1.height = ((root.width / 4) * 3) / 1.77777777;
            mediaPlayer1.showBorder = true;

            mediaPlayer2.x = root.width - xscale(400);
            mediaPlayer2.y = (root.height - 255) / 2;
            mediaPlayer2.width = xscale(400);
            mediaPlayer2.height = yscale(225);

            mediaPlayer1.play();
            mediaPlayer2.play();
            mediaPlayer3.stop();
            mediaPlayer4.stop();
        }
        else if (root.layout === 4)
        {
            // PBP 1 + 2
            showVideo(true);

            mediaPlayer1.visible = true;
            mediaPlayer2.visible = true;
            mediaPlayer3.visible = true;
            mediaPlayer4.visible = false;

            mediaPlayer1.x = 0;
            mediaPlayer1.y = (root.height - (((root.width / 4) * 3) / 1.77777777)) / 2;
            mediaPlayer1.width = (root.width / 4) * 3;
            mediaPlayer1.height = ((root.width / 4) * 3) / 1.77777777;
            mediaPlayer1.showBorder = true;

            mediaPlayer2.x = root.width - xscale(400);
            mediaPlayer2.y = yscale(90);
            mediaPlayer2.width = xscale(400);
            mediaPlayer2.height = yscale(225);

            mediaPlayer3.x = root.width - xscale(400);
            mediaPlayer3.y = yscale(400);
            mediaPlayer3.width = xscale(400);
            mediaPlayer3.height = yscale(225);

            mediaPlayer1.play();
            mediaPlayer2.play();
            mediaPlayer3.play();
            mediaPlayer4.stop();
        }
        else if (root.layout === 5)
        {
            // Quad Screen
            showVideo(false);

            mediaPlayer1.visible = true;
            mediaPlayer2.visible = true;
            mediaPlayer3.visible = true;
            mediaPlayer4.visible = true;

            mediaPlayer1.x = 0;
            mediaPlayer1.y = 0;
            mediaPlayer1.width = root.width / 2;
            mediaPlayer1.height = root.height / 2;
            mediaPlayer1.showBorder = true;

            mediaPlayer2.x = root.width / 2;
            mediaPlayer2.y = 0;
            mediaPlayer2.width = root.width / 2;
            mediaPlayer2.height = root.height / 2;

            mediaPlayer3.x = 0;
            mediaPlayer3.y = root.height / 2;
            mediaPlayer3.width = root.width / 2;
            mediaPlayer3.height = root.height / 2;

            mediaPlayer4.x = root.width / 2;
            mediaPlayer4.y = root.height / 2;
            mediaPlayer4.width = root.width / 2;
            mediaPlayer4.height = root.height / 2;;

            mediaPlayer1.play();
            mediaPlayer2.play();
            mediaPlayer3.play();
            mediaPlayer4.play();
        }

        mediaPlayer1.focus = true;
    }

    Timer
    {
        id: infoTimer
        interval: 6000; running: false; repeat: false
        onTriggered: infoPanel.visible = false;
    }

    function getActivePlayer()
    {
        if (mediaPlayer1.focus)
            return mediaPlayer1;
        else if (mediaPlayer2.focus)
            return mediaPlayer2;
        else if (mediaPlayer3.focus)
            return mediaPlayer3;
        else if (mediaPlayer4.focus)
            return mediaPlayer4;

        return mediaPlayer1;
    }

    function showInfo(restart)
    {
        if (restart)
        {
            // restart the timer
            infoPanel.visible = true;
            infoTimer.restart();
        }
        else
        {
            // toggle info panel
            if (infoPanel.visible)
                infoPanel.visible = false;
            else
            {
                infoPanel.visible = true;
                infoTimer.start();
            }
        }

        getActivePlayer().showInfo(restart);
    }
}
