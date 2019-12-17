import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.XmlListModel 2.0
import QtWebEngine 1.3
import Base 1.0
import Dialogs 1.0
import Models 1.0
import "../../../Util.js" as Util

BaseScreen
{
    id: root

    defaultFocusItem: playerLayout.mediaPlayer1

    property alias layout: playerLayout.playerLayout

    property string defaultFeedSource: ""
    property string defaultFilter: "-1"
    property int    defaultCurrentFeed: -1

    property bool _actionsEnabled: true

    signal feedChanged(string feedSource, string filter, int index)

    Component.onCompleted:
    {
        showTitle(false, "Media Player");
        showTime(false);
        showTicker(false);
        muteAudio(true);

        playerLayout.mediaPlayer1.feed.switchToFeed(defaultFeedSource === "" ? "Live TV" : defaultFeedSource, defaultFilter, defaultCurrentFeed === -1 ? 0 : defaultCurrentFeed);

        if (defaultFeedSource === "" || defaultFeedSource === "Adhoc")
        {
            playerLayout.mediaPlayer2.feed.switchToFeed("Live TV" , -1, 1);
            playerLayout.mediaPlayer3.feed.switchToFeed("Live TV" , -1, 2);
            playerLayout.mediaPlayer4.feed.switchToFeed("Live TV" , -1, 3);
        }
        else
        {
            playerLayout.mediaPlayer2.feed.switchToFeed(defaultFeedSource, defaultFilter, defaultCurrentFeed === -1 ? 1 : defaultCurrentFeed + 1);
            playerLayout.mediaPlayer3.feed.switchToFeed(defaultFeedSource, defaultFilter, defaultCurrentFeed === -1 ? 2 : defaultCurrentFeed + 2);
            playerLayout.mediaPlayer4.feed.switchToFeed(defaultFeedSource, defaultFilter, defaultCurrentFeed === -1 ? 3 : defaultCurrentFeed + 3);
        }

        setLayout(layout);

        // FIXME why aren't the players starting on layout changes at first show?
        playerLayout.mediaPlayer1.startPlayback();

        if (layout >= 2)
            playerLayout.mediaPlayer2.startPlayback();

        if (layout >= 5)
            playerLayout.mediaPlayer3.startPlayback();

        if (layout === 6)
            playerLayout.mediaPlayer4.startPlayback();

        showInfo(true);
    }

    Component.onDestruction:
    {
        playerLayout.mediaPlayer1.stop();
        playerLayout.mediaPlayer2.stop();
        playerLayout.mediaPlayer3.stop();
        playerLayout.mediaPlayer4.stop();
    }

    Action
    {
        shortcut: "Escape"
        enabled: _actionsEnabled
        onTriggered:
        {
            if (stack.depth > 1)
            {
                playerLayout.mediaPlayer1.stop();
                playerLayout.mediaPlayer2.stop();
                playerLayout.mediaPlayer3.stop();
                playerLayout.mediaPlayer4.stop();
                stack.pop();
                escapeSound.play();
            }
        }
    }

    Action
    {
        shortcut: "Down"
        enabled: _actionsEnabled
        onTriggered: changeFocus("down");
    }

    Action
    {
        shortcut: "Up"
        enabled: _actionsEnabled
        onTriggered: changeFocus("up");
    }

    Action
    {
        shortcut: "Left"
        enabled: _actionsEnabled
        onTriggered: changeFocus("left");
    }

    Action
    {
        shortcut: "Right"
        enabled: _actionsEnabled
        onTriggered: changeFocus("right");
    }

    Action
    {
        shortcut: "F1" // RED
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().previousFeed();
            updateChat();
            feedChanged(getActivePlayer().feed.feedName, getActivePlayer().feed.currentFilter, getActivePlayer().feed.currentFeed);
        }
    }

    Action
    {
        shortcut: "F2" // GREEN
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().nextFeed();
            updateChat();
            updateRailCam();
            feedChanged(getActivePlayer().feed.feedName, getActivePlayer().feed.currentFilter, getActivePlayer().feed.currentFeed);
        }
    }

    Action
    {
        shortcut: "F3" // YELLOW
        enabled: _actionsEnabled
        onTriggered:
        {
            playerLayout.showChat = !playerLayout.showChat;
            updateChat();
            updateRailCam();
        }
    }

    Action
    {
        shortcut: "F4" // BLUE
        enabled: _actionsEnabled
        onTriggered:
        {
            playerLayout.showRailCam = !playerLayout.showRailCam

            if (playerLayout.showRailCam)
                playerLayout.railcamBrowser.url = getActivePlayer().getLink("railcam_minidiagram")
        }
    }

    Action
    {
        shortcut: "F5" // switch to next player layout
        enabled: _actionsEnabled
        onTriggered:
        {
            if (playerLayout.playerLayout < 6)
                playerLayout.playerLayout = playerLayout.playerLayout + 1;
            else
                playerLayout.playerLayout = 1
        }
    }

    Action
    {
        shortcut: "F6" // toggle show screen header
        enabled: _actionsEnabled
        onTriggered:
        {
            playerLayout.showHeader = !playerLayout.showHeader;
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
            if (playerLayout.activeItem.objectName === "Chat Browser")
            showChatMenu();
            else if (playerLayout.activeItem.objectName === "RailCam Browser")
                showRailCamMenu();
            else
                showPlayerMenu();
        }
    }

    Action
    {
        shortcut: "F" // Switch active player to fullscreen
        enabled: _actionsEnabled
        onTriggered:
        {
            if (layout === 1)
                return;

            if (playerLayout.mediaPlayer2.focus)
            {
                playerLayout.mediaPlayer1.feed.switchToFeed(playerLayout.mediaPlayer2.feed.feedName, playerLayout.mediaPlayer2.feed.currentFilter, playerLayout.mediaPlayer2.feed.currentFeed);
            }
            else if (playerLayout.mediaPlayer3.focus)
            {
                playerLayout.mediaPlayer1.feed.switchToFeed(playerLayout.mediaPlayer3.feed.feedName, playerLayout.mediaPlayer3.feed.currentFilter, playerLayout.mediaPlayer3.feed.currentFeed);;
            }
            else if (playerLayout.mediaPlayer4.focus)
            {
                playerLayout.mediaPlayer1.feed.switchToFeed(playerLayout.mediaPlayer4.feed.feedName, playerLayout.mediaPlayer4.feed.currentFilter, playerLayout.mediaPlayer4.feed.currentFeed);;
            }

            playerLayout.mediaPlayer1.focus = true;
            playerLayout.mediaPlayer1.startPlayback();
            playerLayout.mediaPlayer2.stop();
            playerLayout.mediaPlayer3.stop();
            playerLayout.mediaPlayer4.stop();

            setLayout(1);
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
        shortcut: "}" // volume down
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().changeVolume(-1.0);
        }
    }

    Action
    {
        shortcut: "{" // volume up
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

    Action
    {
        shortcut: "Return" // change chat?
        enabled: _actionsEnabled
        onTriggered:
        {
            if (playerLayout.showChat);
            {
                updateChat();
                updateRailCam();
            }
        }
    }

    PlayerLayout
    {
        id: playerLayout
        showChat: false
        showRailCam: false
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
            text:
            {
                if (getActivePlayer().player === "RailCam")
                    "RailCam Options";
                else if (getActivePlayer().player === "YouTube" || getActivePlayer().player === "YouTubeTV")
                    "YouTube Options";
                else "";
            }
        }

        Image
        {
            x: xscale(990); y: yscale(5); width: xscale(32); height: yscale(32)
            source: mythUtils.findThemeFile("images/blue_bullet.png")
        }

        InfoText
        {
            x: xscale(1025); y: yscale(5); width: xscale(285); height: yscale(32)
            text:
            {
                if (getActivePlayer().player === "RailCam")
                    "RailCam Diagrams";
                else
                    "";
            }
        }
    }

    PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "Media Player Options"

        onItemSelected:
        {
            playerLayout.activeItem.focus = true;

            _actionsEnabled = true;

            if (itemText == "Full Screen")
            {
                setLayout(1);
            }
            else if (itemText == "Full screen with PIP")
            {
                setLayout(2);
            }
            else if (itemText == "PBP 1/2 screen")
            {
                setLayout(3);
            }
            else if (itemText == "PBP 3/4 screen with overlap")
            {
                setLayout(4);
            }
            else if (itemText == "PBP 1 + 2")
            {
                setLayout(5);
            }
            else if (itemText == "Quad Screen")
            {
                setLayout(6);
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
            else if (itemText == "Report Broken WebCam")
            {
                var name = getActivePlayer().feed.feedList.get(getActivePlayer().feed.currentFeed).title
                var url = getActivePlayer().feed.feedList.get(getActivePlayer().feed.currentFeed).url

                Util.reportBroken("webcam", version, systemid, name, url);
                showNotification(name + "<br>Thank you for reporting this broken WebCam.<br>It will be fixed shortly", settings.osdTimeoutMedium);

            }
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
                    feedChanged(feedSource, filter, feedNo);
                    getActivePlayer().feed.switchToFeed(feedSource, filter, feedNo);
                    getActivePlayer().startPlayback();
                    updateChat();
                    updateRailCam();
                }
            }

            // chat options
            else if (itemText == "Hide Chat")
                playerLayout.showChat = false;
            else if (itemText == "Reload" && itemData == "Chat")
                playerLayout.chatBrowser.reload();
            else if (itemText == "Zoom In" && itemData == "Chat")
                { playerLayout.chatBrowser.zoomFactor += 0.1; playerLayout.chatBrowser.zoomFactor += 0.25 }
            else if (itemText == "Zoom Out" && itemData == "Chat")
                { playerLayout.chatBrowser.zoomFactor -= 0.1; playerLayout.chatBrowser.zoomFactor -= 0.25; }

            // railcam options
            else if (itemText == "Hide RailCam")
                playerLayout.showRailCam = false;
            else if (itemText == "Reload"  && itemData == "RailCam")
                playerLayout.railcamBrowser.reload();
            else if (itemText == "Zoom In" && itemData == "RailCam")
                { playerLayout.railcamBrowser.zoomFactor += 0.1; playerLayout.railcamBrowser.zoomFactor += 0.25; }
            else if (itemText == "Zoom Out" && itemData == "RailCam")
                { playerLayout.railcamBrowser.zoomFactor -= 0.1; playerLayout.railcamBrowser.zoomFactor -= 0.25; }


        }

        onCancelled:
        {
            _actionsEnabled = true;
            playerLayout.activeItem.focus = true;
        }
    }

    function changeFocus(direction)
    {
        var found = false;
        var i = playerLayout.activeItem;
        do
        {
            if (direction === "left")
                i = i.KeyNavigation.left;
            else if (direction === "right")
                i = i.KeyNavigation.right;
            else if (direction === "up")
                i = i.KeyNavigation.up;
            else if (direction === "down")
                i = i.KeyNavigation.down;

            if (i.visible && i !== playerLayout.activeItem)
            {
                i.focus = true;
                return;
            }
        } while (i !== undefined && i !== playerLayout.activeItem);
    }

    function updateChat()
    {
        if (playerLayout.showChat)
        {
            var chatURL = getActivePlayer().getLink("youtube_chat");
            var railcamURL = getActivePlayer().getLink("railcam_chat");

            if (chatURL !== undefined)
            {
                if (chatURL != playerLayout.chatBrowser.url)
                {
                    playerLayout.chatTitle.text = "YouTube Chat";
                    playerLayout.chatBrowser.url = chatURL;
                }
            }
            else if (railcamURL !== undefined)
            {
                if (railcamURL != playerLayout.chatBrowser.url)
                {
                    playerLayout.chatTitle.text = "RailCam Chat";
                    playerLayout.chatBrowser.url = railcamURL;
                }
            }
            else
            {
                playerLayout.chatTitle.text = "No Chat Available";
                playerLayout.chatBrowser.url = "about:blank";
            }
        }
    }

    function updateRailCam()
    {
        if (playerLayout.showRailCam)
        {
            var railcamURL = getActivePlayer().getLink("railcam_minidiagram");

            if (railcamURL !== undefined)
            {
                if (railcamURL != playerLayout.railcamBrowser.url)
                    playerLayout.railcamBrowser.url = railcamURL;
            }
            else
                playerLayout.railcamBrowser.url = "about:blank";
        }
    }

    function setLayout(newLayout)
    {
        root.layout = newLayout;
    }

    Timer
    {
        id: infoTimer
        interval: 6000; running: false; repeat: false
        onTriggered: infoPanel.visible = false;
    }

    function getActivePlayer()
    {
        if (playerLayout.activeItem.objectName.startsWith("Player"))
            return playerLayout.activeItem;

        return playerLayout.mediaPlayer1;
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

    function showPlayerMenu()
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

        if (getActivePlayer().feed.feedName === "Webcams")
            popupMenu.addMenuItem("", "Report Broken WebCam");

        _actionsEnabled = false;
        popupMenu.show();
    }

    function showChatMenu()
    {
        popupMenu.message = "Chat Options";
        popupMenu.clearMenuItems();

        popupMenu.addMenuItem("", "Hide Chat");
        popupMenu.addMenuItem("", "Reload", "Chat");
        popupMenu.addMenuItem("", "Zoom In", "Chat");
        popupMenu.addMenuItem("", "Zoom Out", "Chat");

        _actionsEnabled = false;
        popupMenu.show();
    }

    function showRailCamMenu()
    {
        popupMenu.message = "RailCam Options";
        popupMenu.clearMenuItems();

        popupMenu.addMenuItem("", "Hide RailCam");
        popupMenu.addMenuItem("", "Reload", "RailCam");
        popupMenu.addMenuItem("", "Zoom In", "RailCam");
        popupMenu.addMenuItem("", "Zoom Out", "RailCam");

        _actionsEnabled = false;
        popupMenu.show();
    }

}
