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

    objectName: "internalplayer"

    defaultFocusItem: playerLayout.mediaPlayer1

    property alias layout: playerLayout.playerLayout
    property alias mediaPlayer1: playerLayout.mediaPlayer1

    property string defaultFeedSource: "Live TV"
    property string defaultFilter: ""
    property int    defaultCurrentFeed: 0

    property bool isFullScreen: width === window.width

    property bool _actionsEnabled: !window.showingZMAlerts && (playerLayout.browser.focus || playerLayout.mediaPlayer1.focus || playerLayout.mediaPlayer2.focus || playerLayout.mediaPlayer3.focus || playerLayout.mediaPlayer4.focus);

    signal feedChanged(string feedSource, string filter, int index)

    Component.onCompleted:
    {
        showTitle(false, "Media Player");
        setHelp("https://mythqml.net/help/internal_player.php#top");
        showTime(false);
        showTicker(false);
        muteAudio(true);

        radioPlayerDialog.suspendPlayback();

        playerLayout.mediaPlayer1.feed.feedModelLoaded.connect(feedSourceLoaded);
        playerLayout.mediaPlayer1.feed.switchToFeed(defaultFeedSource, defaultFilter, defaultCurrentFeed);

        setLayout(layout);

        // set the default volume
        var volume = dbUtils.getSetting("VideoPlayerVolume", settings.hostName, "100");

        // sanity check the volume
        if (volume < 0 || volume > 100)
            volume = 100;

        playerLayout.mediaPlayer1.setVolume(volume);
        playerLayout.mediaPlayer2.setVolume(volume);
        playerLayout.mediaPlayer3.setVolume(volume);
        playerLayout.mediaPlayer4.setVolume(volume);

        playerLayout.mediaPlayer1.browserURLListChanged.connect(updateBrowser());
        playerLayout.mediaPlayer2.browserURLListChanged.connect(updateBrowser());
        playerLayout.mediaPlayer3.browserURLListChanged.connect(updateBrowser());
        playerLayout.mediaPlayer4.browserURLListChanged.connect(updateBrowser());

        getActivePlayer().showInfo(true);
        getActivePlayer().updateRadioFeedList();
        updateRadioFeed();
    }

    Connections
    {
        target: radioPlayerDialog
        function onAccepted()
        {
            _actionsEnabled = true;
        }

        function onCancelled()
        {
            _actionsEnabled = true;
        }
    }

    Component.onDestruction:
    {
        playerLayout.mediaPlayer1.stop();
        playerLayout.mediaPlayer2.stop();
        playerLayout.mediaPlayer3.stop();
        playerLayout.mediaPlayer4.stop();

        radioPlayerDialog.resumePlayback();
    }

    Action
    {
        shortcut: "Escape"
        enabled: _actionsEnabled
        onTriggered:
        {
            if (getActivePlayer().showingFeedBrowser())
                getActivePlayer().hideFeedBrowser();
            else if (isPanel)
            {
                root.handleEscape();
            }
            else if (stack.depth > 1)
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
        enabled: _actionsEnabled  && (playerLayout.activeItem.objectName !== "Browser")
        onTriggered:
        {
            if (getActivePlayer().showingFeedBrowser())
                getActivePlayer().nextBrowserFeed();
            else
                changeFocus("down");
        }
    }

    Action
    {
        shortcut: "Up"
        enabled: _actionsEnabled && (playerLayout.activeItem.objectName !== "Browser")
        onTriggered:
        {
            if (getActivePlayer().showingFeedBrowser())
                getActivePlayer().previousBrowserFeed();
            else
                changeFocus("up");
        }
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
        onTriggered:
        {
            if (layout === 1)
            {
                if (isPanel)
                {
                    playerLayout.mediaPlayer1.focus = false;
                    playerLayout.mediaPlayer2.focus = false;
                    playerLayout.mediaPlayer3.focus = false;
                    playerLayout.mediaPlayer4.focus = false;
                    playerLayout.browser.focus = false;
                    root.previousFocusItem.focus = true;
                }
                else
                {
                    changeFocus("right");
                }
            }
            else
                changeFocus("right");
        }
    }

    Action
    {
        shortcut: "F1" // RED
        enabled: _actionsEnabled
        onTriggered:
        {
            if (playerLayout.activeItem.objectName === "Browser")
            {
                getActivePlayer().previousURL();
                updateBrowser();
            }
            else
            {
                getActivePlayer().previousFeed();
                getActivePlayer().updateBrowserURLList();
                getActivePlayer().updateRadioFeedList();
                updateBrowser();
                updateRadioFeed();
                feedChanged(getActivePlayer().feed.feedName, getActivePlayer().feed.currentFilter, getActivePlayer().feed.currentFeed);
            }
        }
    }

    Action
    {
        shortcut: "F2" // GREEN
        enabled: _actionsEnabled
        onTriggered:
        {
            if (playerLayout.activeItem.objectName === "Browser")
            {
                getActivePlayer().nextURL();
                updateBrowser();
            }
            else
            {
                getActivePlayer().nextFeed();
                getActivePlayer().updateBrowserURLList();
                getActivePlayer().updateRadioFeedList();
                updateBrowser();
                updateRadioFeed();
                feedChanged(getActivePlayer().feed.feedName, getActivePlayer().feed.currentFilter, getActivePlayer().feed.currentFeed);
            }
        }
    }

    Action
    {
        shortcut: "F3" // YELLOW
        enabled: _actionsEnabled
        onTriggered:
        {
            playerLayout.showBrowser = !playerLayout.showBrowser;
            getActivePlayer().updateBrowserURLList();
            updateBrowser();
        }
    }

    Action
    {
        shortcut: "F4" // BLUE
        enabled: _actionsEnabled
        onTriggered:
        {
            if (playerLayout.activeItem.objectName === "Browser")
            {
                mythUtils.sendKeyEvent(window, Qt.Key_Tab);
            }
            else if (getActivePlayer().showRailcamApproach && getActivePlayer().showRailcamDiagram)
            {
                getActivePlayer().showRailcamApproach = false;
                getActivePlayer().showRailcamDiagram = false;
            }
            else if (!getActivePlayer().showRailcamApproach && !getActivePlayer().showRailcamDiagram)
            {
                getActivePlayer().showRailcamApproach = true;
                getActivePlayer().showRailcamDiagram = false;
            }
            else if (getActivePlayer().showRailcamApproach && !getActivePlayer().showRailcamDiagram)
            {
                getActivePlayer().showRailcamApproach = false;
                getActivePlayer().showRailcamDiagram = true;
            }
            else if (!getActivePlayer().showRailcamApproach && getActivePlayer().showRailcamDiagram)
            {
                getActivePlayer().showRailcamApproach = true;
                getActivePlayer().showRailcamDiagram = true;
            }

            getActivePlayer().hideInfo();
            getActivePlayer().updateRailcamApproach();
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
        shortcut: "F6" // toggle online
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().toggleOnline();
        }
    }

    Action
    {
        shortcut: "F7" // toggle show screen header
        enabled: _actionsEnabled
        onTriggered:
        {
            playerLayout.showHeader = !playerLayout.showHeader;
        }
    }

    Action
    {
        shortcut: "F8" // show radio player dialog
        enabled: _actionsEnabled
        onTriggered:
        {
            _actionsEnabled = false;
            radioPlayerDialog.show();
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
            getActivePlayer().toggleInfo();
        }
    }

    Action
    {
        shortcut: "M" // Menu
        enabled: _actionsEnabled
        onTriggered:
        {
            if (playerLayout.activeItem.objectName === "Browser")
                showBrowserMenu();
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
            playerLayout.mediaPlayer1.play();
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
            getActivePlayer().showInfo(true);
        }
    }

    Action
    {
        shortcut: "[" // volume down
        enabled: _actionsEnabled
        onTriggered:
        {
            changeVolume(-1.0);
        }
    }

    Action
    {
        shortcut: "]" // volume up
        enabled: _actionsEnabled
        onTriggered:
        {
            changeVolume(1.0);
        }
    }

    Action
    {
        shortcut: "}" // volume down
        enabled: _actionsEnabled
        onTriggered:
        {
            changeVolume(-1.0);
        }
    }

    Action
    {
        shortcut: "{" // volume up
        enabled: _actionsEnabled
        onTriggered:
        {
            changeVolume(1.0);
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
        shortcut: "A" // switch fill mode
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().toggleFillMode();
        }
    }

    Action
    {
        shortcut: "F11" // take snapshot of the active video player (possibly for a video thumbnail image)
        enabled: _actionsEnabled
        onTriggered:
        {
            var item = getActivePlayer().videoPlayer;
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
            getActivePlayer().showInfo(true);
        }
    }

    Action
    {
        shortcut: "." // skip forward 30 seconds
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().skipForward(30000);
            getActivePlayer().showInfo(true);
        }
    }

    Action
    {
        shortcut: "<" // skip back 60 seconds
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().skipBack(60000);
            getActivePlayer().showInfo(true);
        }
    }

    Action
    {
        shortcut: ">" // skip forward 60 seconds
        enabled: _actionsEnabled
        onTriggered:
        {
            getActivePlayer().skipForward(60000);
            getActivePlayer().showInfo(true);
        }
    }

    Action
    {
        shortcut: "PgUp" // skip back 10 minutes
        enabled: _actionsEnabled && playerLayout.activeItem.objectName.startsWith("Player")
        onTriggered:
        {
            getActivePlayer().skipBack(600000);
            getActivePlayer().showInfo(true);
        }
    }

    Action
    {
        shortcut: "PgDown" // skip forward 10 minutess
        enabled: _actionsEnabled && playerLayout.activeItem.objectName.startsWith("Player")
        onTriggered:
        {
            getActivePlayer().skipForward(600000);
            getActivePlayer().showInfo(true);
        }
    }

    Action
    {
        shortcut: "Return" // change chat?
        enabled: _actionsEnabled
        onTriggered:
        {
            if (getActivePlayer().showingFeedBrowser())
            {
                getActivePlayer().selectFeedBrowser();
                feedChanged(getActivePlayer().feed.feedName, getActivePlayer().feed.currentFilter, getActivePlayer().feed.currentFeed);
            }
            else if (playerLayout.showChat)
            {
                updateBrowser();
            }
            else if (isPanel)
            {
                parent.toggleFullscreenPlayer();
            }
        }
    }

    Action
    {
        shortcut: "H" // help
        enabled: _actionsEnabled
        onTriggered:
        {
            window.showHelp();
        }
    }

    Action
    {
        shortcut: "R" // record
        enabled: _actionsEnabled
        onTriggered:
        {
            if (getActivePlayer().isRecording())
                getActivePlayer().stopRecording();
            else
                getActivePlayer().startRecording(settings.configPath + "recording.mkv", "");
        }
    }

    PlayerLayout
    {
        id: playerLayout
        showBrowser: false
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
            else if (itemText == "Tivo TV")
            {
                getActivePlayer().feed.switchToFeed("Tivo TV", ",,", 0);
                getActivePlayer().startPlayback();
            }
            else if (itemText == "IPTV")
            {
                getActivePlayer().feed.switchToFeed("IPTV", "-1", 0);
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
                var index = dbUtils.getSetting("WebcamListIndex", settings.hostName, "");
                var filter = index + ",," + "title";
                getActivePlayer().feed.switchToFeed("Webcams", filter, 0);
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
            else if (itemText == "Radio Player...")
            {
                _actionsEnabled = false;
                radioPlayerDialog.show();
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
                    getActivePlayer().play(true);
                    getActivePlayer().showInfo(true);
                    getActivePlayer().updateBrowserURLList();
                    getActivePlayer().updateRadioFeedList();
                    updateBrowser();
                    updateRadioFeed()
                }
            }

            // browser options
            else if (itemText == "Hide Browser")
                playerLayout.showBrowser = false;
            else if (itemText == "Reload")
                playerLayout.browser.reload();
            else if (itemText == "Zoom In")
                { playerLayout.browser.zoomFactor += 0.25;}
            else if (itemText == "Zoom Out")
                { playerLayout.browser.zoomFactor -= 0.25; }
            else if (itemData.startsWith("browser_index="))
            {
                var index = parseInt(itemData.replace("browser_index=", ""));

                if (index >= 0 && index < getActivePlayer().getBrowserURLList().count)
                {
                    getActivePlayer().getBrowserURLList().currentIndex = index;
                    updateBrowser();
                }
            }
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
        var prev_i = undefined;

        do
        {
            prev_i = i;

            if (direction === "left")
                i = i.KeyNavigation.left;
            else if (direction === "right")
                i = i.KeyNavigation.right;
            else if (direction === "up")
                i = i.KeyNavigation.up;
            else if (direction === "down")
                i = i.KeyNavigation.down;

            if (i !== undefined && i.visible && i !== playerLayout.activeItem)
            {
                i.focus = true;
                return;
            }
        } while (i !== undefined && i !== playerLayout.activeItem && prev_i !== i);
    }

    function updateBrowser()
    {
        var title;
        var url;
        var width;
        var zoom;
        var o = {title: "", url: "", width: "", zoom: ""};

        if (getActivePlayer().getBrowserURL(o))
        {
            if (playerLayout.browser.url == o.url)
                return;

            playerLayout.browserTitle.text = o.title;
            playerLayout.browser.url = o.url;
            playerLayout.browserWidth = xscale(o.width);
            playerLayout.browserZoom = xscale(o.zoom);
        }
        else
        {
            playerLayout.browserTitle.text = "No Web Pages Available";
            playerLayout.browser.url = "about:blank";
            playerLayout.browserWidth = xscale(350);
            playerLayout.browserZoom = xscale(1.0);
        }
    }

    function updateRadioFeed()
    {
        // copy the radio streams from the active player to the radio player
        radioPlayerDialog.switchStreamList("internal");
        radioPlayerDialog.clearStreams();

        for (var x = 0; x < (getActivePlayer().getRadioFeedList().count); x++)
        {
            var title = getActivePlayer().getRadioFeedList().get(x).title;
            var url = getActivePlayer().getRadioFeedList().get(x).url;
            var logo = getActivePlayer().getRadioFeedList().get(x).logo;

            radioPlayerDialog.addStream(title, url, logo)
        }

        if (radioPlayerDialog.radioPlayerEnabled)
            radioPlayerDialog.playFirst();
    }

    function setLayout(newLayout)
    {
        // restart player1
        playerLayout.mediaPlayer1.feed.switchToFeed(playerLayout.mediaPlayer1.feed.feedName, playerLayout.mediaPlayer1.feed.currentFilter, playerLayout.mediaPlayer1.feed.currentFeed);
        playerLayout.mediaPlayer1.play();

        if (newLayout == 2 || newLayout == 3 || newLayout == 4)
        {
            // we need 2 players for these layouts
            if (playerLayout.mediaPlayer2.feed.feedName === "" || playerLayout.mediaPlayer2.feed.currentFeed == -1)
            {
                playerLayout.mediaPlayer2.feed.switchToFeed(playerLayout.mediaPlayer1.feed.feedName, playerLayout.mediaPlayer1.feed.currentFilter, playerLayout.mediaPlayer1.feed.currentFeed + 1);
                playerLayout.mediaPlayer2.play();
            }
        }
        else if (newLayout == 5)
        {
            // we need 3 players for this layout
            if (playerLayout.mediaPlayer2.feed.feedName === "" || playerLayout.mediaPlayer2.feed.currentFeed == -1)
            {
                playerLayout.mediaPlayer2.feed.switchToFeed(playerLayout.mediaPlayer1.feed.feedName, playerLayout.mediaPlayer1.feed.currentFilter, playerLayout.mediaPlayer1.feed.currentFeed + 1);
                playerLayout.mediaPlayer2.play();
            }

            if (playerLayout.mediaPlayer3.feed.feedName === "" || playerLayout.mediaPlayer3.feed.currentFeed == -1)
            {
                playerLayout.mediaPlayer3.feed.switchToFeed(playerLayout.mediaPlayer2.feed.feedName, playerLayout.mediaPlayer2.feed.currentFilter, playerLayout.mediaPlayer2.feed.currentFeed + 1);
                playerLayout.mediaPlayer3.play();
            }
        }
        else if (newLayout == 6)
        {
            // we need 4 players for this layout
            if (playerLayout.mediaPlayer2.feed.feedName === "" || playerLayout.mediaPlayer2.feed.currentFeed == -1)
            {
                playerLayout.mediaPlayer2.feed.switchToFeed(playerLayout.mediaPlayer1.feed.feedName, playerLayout.mediaPlayer1.feed.currentFilter, playerLayout.mediaPlayer1.feed.currentFeed + 1);
                playerLayout.mediaPlayer2.play();
            }

            if (playerLayout.mediaPlayer3.feed.feedName === "" || playerLayout.mediaPlayer3.feed.currentFeed == -1)
            {
                playerLayout.mediaPlayer3.feed.switchToFeed(playerLayout.mediaPlayer2.feed.feedName, playerLayout.mediaPlayer2.feed.currentFilter, playerLayout.mediaPlayer2.feed.currentFeed + 1);
                playerLayout.mediaPlayer3.play();
            }

            if (playerLayout.mediaPlayer4.feed.feedName === "" || playerLayout.mediaPlayer4.feed.currentFeed == -1)
            {
                playerLayout.mediaPlayer4.feed.switchToFeed(playerLayout.mediaPlayer3.feed.feedName, playerLayout.mediaPlayer3.feed.currentFilter, playerLayout.mediaPlayer3.feed.currentFeed + 1);
                playerLayout.mediaPlayer4.play();
            }
        }

        root.layout = newLayout;
    }

    function getActivePlayer()
    {
        if (playerLayout.activeItem.objectName.startsWith("Player"))
            return playerLayout.activeItem;

        return playerLayout.mediaPlayer1;
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
        popupMenu.addMenuItem("1", "Tivo TV");
        popupMenu.addMenuItem("1", "IPTV");
        popupMenu.addMenuItem("1", "Recordings");
        popupMenu.addMenuItem("1", "Videos");
        popupMenu.addMenuItem("1", "Webcams");
        popupMenu.addMenuItem("1", "Web Videos");
        popupMenu.addMenuItem("1", "ZoneMinder Cameras");

        popupMenu.addMenuItem("", getActivePlayer().feed.feedName);
        playerSources.addFeedMenu(popupMenu, getActivePlayer().feed, "2", 1);

        popupMenu.addMenuItem("", "Toggle Mute");

        if (getActivePlayer().feed.feedName === "Webcams")
            popupMenu.addMenuItem("", "Report Broken WebCam");

        popupMenu.addMenuItem("", "Radio Player...");

        _actionsEnabled = false;
        popupMenu.show();
    }

    function showBrowserMenu()
    {
        getActivePlayer().updateBrowserURLList();
        var urlList = getActivePlayer().getBrowserURLList();

        popupMenu.message = "Browser Options";
        popupMenu.clearMenuItems();

        popupMenu.addMenuItem("", "Change Page");
        popupMenu.addMenuItem("", "Hide Browser");
        popupMenu.addMenuItem("", "Reload");
        popupMenu.addMenuItem("", "Zoom In");
        popupMenu.addMenuItem("", "Zoom Out");

        // Change Page Sub Menu
        for (var x = 0; x < urlList.count; x++)
        {
            popupMenu.addMenuItem("0", urlList.get(x).title, "browser_index=" + x);
        }

        _actionsEnabled = false;
        popupMenu.show();
    }

    function changeVolume(amount)
    {
        getActivePlayer().changeVolume(amount);
    }

    function feedSourceLoaded()
    {
        playerLayout.mediaPlayer1.play();
    }
}
