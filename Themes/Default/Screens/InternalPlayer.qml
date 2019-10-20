import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.XmlListModel 2.0
import Base 1.0
import Dialogs 1.0
import Models 1.0
import "../../../Util.js" as Util

BaseScreen
{
    id: root

    defaultFocusItem: mediaPlayer1

    property var activePlayer: mediaPlayer1

    property int layout: 0

    property string defaultFeedSource: ""
    property string defaultFilter: "-1"
    property int    defaultCurrentFeed: -1

    property bool _actionsEnabled: true

    signal feedChanged(string filter, int index)

    Component.onCompleted:
    {
        showTitle(true, "Media Player");
        showTime(false);
        showTicker(false);
        muteAudio(true);

        mediaPlayer1.feed.switchToFeed(defaultFeedSource === "" ? "Live TV" : defaultFeedSource, defaultFilter, defaultCurrentFeed === -1 ? 0 : defaultCurrentFeed);

        if (defaultFeedSource === "" || defaultFeedSource === "Advent Calendar")
        {
            mediaPlayer2.feed.switchToFeed("Live TV" , -1, 1);
            mediaPlayer3.feed.switchToFeed("Live TV" , -1, 2);
            mediaPlayer4.feed.switchToFeed("Live TV" , -1, 3);
        }
        else
        {
            mediaPlayer2.feed.switchToFeed(defaultFeedSource, defaultFilter, defaultCurrentFeed === -1 ? 1 : defaultCurrentFeed + 1);
            mediaPlayer3.feed.switchToFeed(defaultFeedSource, defaultFilter, defaultCurrentFeed === -1 ? 2 : defaultCurrentFeed + 2);
            mediaPlayer4.feed.switchToFeed(defaultFeedSource, defaultFilter, defaultCurrentFeed === -1 ? 3 : defaultCurrentFeed + 3);
        }

        setLayout(layout);

        showInfo(true);
    }

    Component.onDestruction:
    {
        mediaPlayer1.stop();
        mediaPlayer2.stop();
        mediaPlayer3.stop();
        mediaPlayer4.stop();
    }

    Action
    {
        shortcut: "Escape"
        enabled: _actionsEnabled
        onTriggered:
        {
            if (stack.depth > 1)
            {
                mediaPlayer1.stop();
                mediaPlayer2.stop();
                mediaPlayer3.stop();
                mediaPlayer4.stop();
                stack.pop();
                escapeSound.play();
            }
        }
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

            feedChanged(getActivePlayer().feed.currentFilter, getActivePlayer().feed.currentFeed);
        }
    }

    Action
    {
        shortcut: "F2" // GREEN
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().nextFeed();

            feedChanged(getActivePlayer().feed.currentFilter, getActivePlayer().feed.currentFeed);
        }
    }

    Action
    {
        shortcut: "F3" // YELLOW
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().showRailCamDiagram();
        }
    }

    Action
    {
        shortcut: "F4" // BLUE
        enabled: _actionsEnabled
        onTriggered:
        {
            // TODO show web site?
        }
    }

    Action
    {
        shortcut: "F9" // toggle mute
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().toggleMute();
        }
    }

    Action
    {
        shortcut: "I" // Info
        enabled: _actionsEnabled
        onTriggered:
        {
            showInfo(false);
        }
    }

    Action
    {
        shortcut: "M" // Menu
        enabled: _actionsEnabled
        onTriggered:
        {
            popupMenu.message = "Media " + getActivePlayer().objectName + " Options";
            popupMenu.clearMenuItems();

            popupMenu.addMenuItem("", "Switch Layout");

            popupMenu.addMenuItem("0", "Full Screen");
            popupMenu.addMenuItem("0", "Full screen with PIP");
            popupMenu.addMenuItem("0", "PBP 1/2 screen");
            popupMenu.addMenuItem("0", "PBP 3/4 screen with overlap");
            popupMenu.addMenuItem("0", "PBP 1 + 2");
            popupMenu.addMenuItem("0", "Quad Screen");

            popupMenu.addMenuItem("", "Switch Source");
            popupMenu.addMenuItem("1", "Live TV");
            popupMenu.addMenuItem("1", "Recordings");
            popupMenu.addMenuItem("1", "Videos");
            popupMenu.addMenuItem("1", "Webcams");
            popupMenu.addMenuItem("1", "Web Videos");
            popupMenu.addMenuItem("1", "ZoneMinder Cameras");

            popupMenu.addMenuItem("", getActivePlayer().feed.feedName);
            playerSources.addFeedMenu(popupMenu, getActivePlayer().feed.feedName, "2", 1);

            popupMenu.addMenuItem("", "Toggle Mute");

            _actionsEnabled = false;
            popupMenu.show();
        }
    }

    Action
    {
        shortcut: "F" // Switch active player to fullscreen
        enabled: _actionsEnabled
        onTriggered:
        {
            if (layout === 0)
                return;

            if (mediaPlayer2.focus)
            {
                mediaPlayer1.feed.switchToFeed(mediaPlayer2.feed.feedName, mediaPlayer2.feed.currentFilter, mediaPlayer2.feed.currentFeed);
            }
            else if (mediaPlayer3.focus)
            {
                mediaPlayer1.feed.switchToFeed(mediaPlayer3.feed.feedName, mediaPlayer3.feed.currentFilter, mediaPlayer3.feed.currentFeed);;
            }
            else if (mediaPlayer4.focus)
            {
                mediaPlayer1.feed.switchToFeed(mediaPlayer4.feed.feedName, mediaPlayer4.feed.currentFilter, mediaPlayer4.feed.currentFeed);;
            }

            mediaPlayer1.focus = true;
            mediaPlayer1.startPlayback();
            mediaPlayer2.stop();
            mediaPlayer3.stop();
            mediaPlayer4.stop();

            setLayout(0);
        }
    }

    Action
    {
        shortcut: "O" // stop
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().stop();
        }
    }

    Action
    {
        shortcut: "P" // Play/Pause
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().togglePaused();
            showInfo(true);
        }
    }

    Action
    {
        shortcut: "[" // volume down
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().changeVolume(-1.0);
        }
    }

    Action
    {
        shortcut: "]" // volume up
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().changeVolume(1.0);
        }
    }

    Action
    {
        shortcut: "D" // switch deinterlacer
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().toggleInterlacer();
        }
    }

    Action
    {
        shortcut: "F11" // take snapshot of the active video player (possibly for a video thumbnail image)
        enabled: _actionsEnabled
        onTriggered:
        {
            var item = getActivePlayer().getActivePlayerItem();
            var url = getActivePlayer().feed.feedList.get(getActivePlayer().feed.currentFeed).url

            if (url.indexOf("file://") === 0)
            {
                // if we are playing a local file assume we want to create a video snapshot
                var filename = url.substring(7, url.length) + ".png";

                window.takeSnapshot(item, filename);

            }
            else
                window.takeSnapshot(item);

        }
    }

    Action
    {
        shortcut: "S" // take snapshot of the screen
        enabled: _actionsEnabled
        onTriggered:
        {
            window.takeSnapshot();
        }
    }

    Action
    {
        shortcut: "," // skip back 30 seconds
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().skipBack(30000);
            showInfo(true);
        }
    }

    Action
    {
        shortcut: "." // skip forward 30 seconds
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().skipForward(30000);
            showInfo(true);
        }
    }

    Action
    {
        shortcut: "<" // skip back 60 seconds
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().skipBack(60000);
            showInfo(true);
        }
    }

    Action
    {
        shortcut: ">" // skip forward 60 seconds
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().skipForward(60000);
            showInfo(true);
        }
    }

    Action
    {
        shortcut: "PgUp" // skip back 10 minutes
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().skipBack(600000);
            showInfo(true);
        }
    }

    Action
    {
        shortcut: "PgDown" // skip forward 10 minutess
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().skipForward(600000);
            showInfo(true);
        }
    }

    MediaPlayer
    {
        id: mediaPlayer1
        objectName: "Player 1"
        visible: false
        enabled: visible

        onFocusChanged: if (focus) activePlayer = mediaPlayer1
        onPlaybackEnded: if (layout === 0) { stop(); stack.pop(); }
    }

    MediaPlayer
    {
        id: mediaPlayer2
        objectName: "Player 2"
        visible: false
        enabled: visible

        onFocusChanged: if (focus) activePlayer = mediaPlayer2
    }

    MediaPlayer
    {
        id: mediaPlayer3
        objectName: "Player 3"
        visible: false
        enabled: visible

        onFocusChanged: if (focus) activePlayer = mediaPlayer3
    }

    MediaPlayer
    {
        id: mediaPlayer4
        objectName: "Player 4"
        visible: false
        enabled: visible

        onFocusChanged: if (focus) activePlayer = mediaPlayer4
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
            getActivePlayer().focus = true;
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
            else if (itemText == "Live TV")
            {
                getActivePlayer().feed.switchToFeed("Live TV", "-1", 0);
                getActivePlayer().startPlayback();
            }
            else if (itemText == "Recordings")
            {
                getActivePlayer().feed.switchToFeed("Recordings", "", 0);
                getActivePlayer().startPlayback();
            }
            else if (itemText == "Videos")
            {
                getActivePlayer().feed.switchToFeed("Videos", "", 0);
                getActivePlayer().startPlayback();
            }
            else if (itemText == "ZoneMinder Cameras")
            {
               getActivePlayer().feed.switchToFeed("ZoneMinder Cameras", "", 0);
                getActivePlayer().startPlayback();
            }
            else if (itemText == "Webcams")
            {
                getActivePlayer().feed.switchToFeed("Webcams", "", 0);
                getActivePlayer().startPlayback();
            }
            else if (itemText == "Web Videos")
            {
                getActivePlayer().feed.switchToFeed("Web Videos", "", 0);
                getActivePlayer().startPlayback();
            }
            else if (itemText == "Toggle Mute")
                getActivePlayer().toggleMute();
            else if (itemData.startsWith("player="))
            {
                var list = itemData.split("\n");
                var feedSource;
                var filter;
                var feedNo;

                if (list.length === 4)
                {
                    feedSource = list[1];
                    filter = list[2];
                    feedNo = list[3];
                    feedChanged(filter, feedNo);
                    getActivePlayer().feed.switchToFeed(feedSource, filter, feedNo);
                    getActivePlayer().startPlayback();
                }
            }
        }

        onCancelled:
        {
            _actionsEnabled = true;
            getActivePlayer().focus = true;
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
        if (activePlayer)
            return activePlayer;

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
