import QtQuick 2.4
import QtQuick.Window 2.2
import QtMultimedia 5.4
import QtQuick.Controls 1.4
import QtQuick.XmlListModel 2.0
import QtWebSockets 1.0
import Process 1.0
import Base 1.0
import Dialogs 1.0
import Screens 1.0
import Models 1.0
import mythqml.net 1.0

Window
{
    id: window
    visible: true
    visibility: settings.startFullscreen ? "FullScreen" : "Windowed"
    width: 1280
    height: 720

    property string mainMenu: "MainMenu.qml"
    property bool showWhatsNew: true
    property bool exitOnEscape: true
    property bool shutdownOnIdle: false

    property int idleTime: settings.frontendIdleTime

    property double wmult: width / 1280
    property double hmult: height / 720
    property var theme: loadTheme()
    property double soundEffectsVolume: 1.0
    property double backgroundVideoVolume: 1.0

    property alias playerSources: playerSourcesModel

    Component.onCompleted:
    {
        eventListener.listenTo(window)

        soundEffectsVolume = dbUtils.getSetting("SoundEffectsVolume", settings.hostName, "1.0");
        backgroundVideoVolume = dbUtils.getSetting("BackgroundVideoVolume", settings.hostName, "1.0");
    }

    Connections
    {
        target: eventListener
        onKeyPressed: idleTimer.restart();
        onMouseMoved:
        {
            if (mouseArea.showMouse)
            {
                if (mouseArea.autoHide)
                    mouseTimer.restart();

                if (mouseArea.cursorShape === Qt.BlankCursor)
                    mouseArea.cursorShape = Qt.ArrowCursor;

                 mouseArea.oldX = mouseArea.mouseX;
                 mouseArea.oldY =mouseArea.mouseY;
            }
        }
    }

    PlayerSourcesModel
    {
        id: playerSourcesModel
    }

    // theme background video downloader
    Process
    {
        id: themeDLProcess
        onFinished:
        {
            var source;
            var dest;

            if (theme.backgroundVideo)
            {
                source = "https://mythqml.net/downloads/themes/" + settings.themeName + "/" + theme.backgroundVideo;
                dest = settings.configPath + "Themes/Videos/" + theme.backgroundVideo;

                if (exitStatus === Process.NormalExit && themeDLProcess.exitCode() === 0)
                {
                    showNotification("");
                    screenBackground.showVideo = true;
                    screenBackground.setVideo("file://" + settings.configPath + "Themes/Videos/" + theme.backgroundVideo);
                    screenBackground.showImage = false;
                }
                else
                {
                    mythUtils.removeFile(dest);
                    showNotification("Downloading of the background video failed!");
                    log.error(Verbose.GUI, "MainWindow: Error - failed to download background video from: " + source);
                    log.error(Verbose.GUI, "MainWindow: Error - exit code was: " + themeDLProcess.exitCode());
                }
            }
            else
            {
                source = settings.configPath + "Themes/Pictures/" + settings.themeName + "/" + theme.backgroundSlideShow;
                dest = settings.configPath + "Themes/Pictures/" + settings.themeName + "/";

                if (exitStatus === Process.NormalExit && themeDLProcess.exitCode() === 0)
                {
                    // extract the slideshow pictures from the compressed tar.gz file
                    unTarProcess.start("tar", ['--overwrite', '-x', '-C', dest, '-f', source]);
                }
                else
                {
                    source = "https://mythqml.net/downloads/themes/" + settings.themeName + "/" + theme.backgroundSlideShow;
                    mythUtils.removeFile(dest);
                    showNotification("Downloading of the background slideshow failed!");
                    log.error(Verbose.GUI, "MainWindow: Error - failed to download background slideshow from: " + source);
                    log.error(Verbose.GUI, "MainWindow: Error - exit code was: " + themeDLProcess.exitCode());
                }
            }
        }
    }

    Process
    {
        id: unTarProcess
        onFinished:
        {
            if (exitStatus === Process.NormalExit && themeDLProcess.exitCode() === 0)
            {
                showNotification("");
                screenBackground.showVideo = false;
                screenBackground.setSlideShow(settings.configPath + "Themes/Pictures/" + settings.themeName);
                screenBackground.showImage = false;
                screenBackground.showSlideShow = true;
            }
            else
            {
                var source = "https://mythqml.net/downloads/themes/" + settings.themeName + "/" + theme.backgroundSlideShow;
                var dest = settings.configPath + "Themes/Pictures/" + settings.themeName + "/" + theme.backgroundSlideShow;
                mythUtils.removeFile(dest);
                showNotification("Downloading of the background video failed!");
                log.error(Verbose.GUI, "MainWindow: Error - failed to download background video from: " + source);
                log.error(Verbose.GUI, "MainWindow: Error - exit code was: " + themeDLProcess.exitCode());
            }
        }
    }

    WebSocket
    {
        id: webSocket
        url: settings.webSocketUrl
        onTextMessageReceived:
        {
            log.debug(Verbose.WEBSOCKET, "WebSocket: Received message - " + message)
        }
        onStatusChanged:
        {
            if (webSocket.status == WebSocket.Error)
            {
                log.error(Verbose.WEBSOCKET, "WebSocket: Error - " + webSocket.errorString)
            }
            else if (webSocket.status == WebSocket.Connecting)
            {
                log.debug(Verbose.WEBSOCKET, "WebSocket: connecting");
            }
            else if (webSocket.status == WebSocket.Open)
            {
                log.debug(Verbose.WEBSOCKET, "WebSocket: Open");
                webSocket.sendTextMessage("WS_EVENT_ENABLE");
                webSocket.sendTextMessage("WS_EVENT_SET_FILTER LIVETV_CHAIN RECORDING_LIST_CHANGE UPDATE_FILE_SIZE SCHEDULE_CHANGE");
            }
            else if (webSocket.status == WebSocket.Closed)
            {
                log.debug(Verbose.WEBSOCKET, "WebSocket: closed")
            }
        }

        active: true
    }

    function xscale(x)
    {
        return x * wmult;
    }

    function yscale(y)
    {
        return y * hmult;
    }

    // Sound effects
    SoundEffect
    {
         id: upSound
         source: mythUtils.findThemeFile("sounds/pock.wav");
         volume: soundEffectsVolume
    }
    SoundEffect
    {
         id: downSound
         source: mythUtils.findThemeFile("sounds/pock.wav")
         volume: soundEffectsVolume
    }
    SoundEffect
    {
         id: leftSound
         source: mythUtils.findThemeFile("sounds/pock.wav")
         volume: soundEffectsVolume
    }
    SoundEffect
    {
         id: rightSound
         source: mythUtils.findThemeFile("sounds/pock.wav")
         volume: soundEffectsVolume
    }
    SoundEffect
    {
         id: returnSound
         source: mythUtils.findThemeFile("sounds/poguck.wav")
         volume: soundEffectsVolume
    }
    SoundEffect
    {
         id: escapeSound
         source: mythUtils.findThemeFile("sounds/pock.wav")
         volume: soundEffectsVolume
    }
    SoundEffect
    {
         id: messageSound
         source: mythUtils.findThemeFile("sounds/message.wav")
         volume: 1.0 //soundEffectsVolume
    }
    SoundEffect
    {
         id: errorSound
         source: mythUtils.findThemeFile("sounds/downer.wav")
         volume: soundEffectsVolume
    }

    // ticker items grabber process
    Process
    {
        id: tickerProcess
        onFinished:
        {
            if (exitStatus == Process.NormalExit)
                tickerModel.reload()
        }
    }

    Timer
    {
        id: tickerUpdateTimer
        interval: 600000; running: true; repeat: true
        onTriggered: tickerProcess.start(settings.sharePath.replace("file://", "") + "/qml/Scripts/ticker-grabber.py", [settings.configPath + "ticker.xml"]);
    }

    Timer
    {
        id: mouseMoveTimer
        interval: 1000; running: true; repeat: false
        onTriggered:
        {
            // wiggle the mouse to force it to timeout and auto hide itself
            var pos =  mythUtils.getMousePos();
            mythUtils.moveMouse(pos.x + 1, pos.y + 1);
        }
    }

    Timer
    {
        id: idleTimer
        interval: (idleTime * 60) * 1000; running: (idleTime > 0 ? true : false); repeat: true
        onTriggered:
        {
            stop();
            stack.push({item: mythUtils.findThemeFile("Screens/IdleScreen.qml")});
        }
    }

    TickerModel
    {
        id: tickerModel

        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                screenBackground.clearTickerItems();

                for (var x = 0; x < count; x++)
                {
                    var text = "<b>" + get(x).category + ":</b> " + get(x).text;
                    screenBackground.addTickerItem(get(x).id, text);
                }
            }
        }
    }

    Loader
    {
        id: mainMenuLoader
        source: settings.menuPath + mainMenu
    }

    Item
    {
        id: root
        anchors.fill: parent


        ScreenBackground
        {
            id: screenBackground
            showImage: true
            showVideo: false
            showTicker: true
            Component.onCompleted:
            {
                tickerProcess.start(settings.sharePath.replace("file://", "") + "/qml/Scripts/ticker-grabber.py", [settings.configPath + "ticker.xml"]);
            }
        }

        MouseArea
        {
            id: mouseArea

            property bool showMouse: true;
            property bool autoHide: true;

            property int oldX: 0
            property int oldY: 0

            anchors.fill: parent
            enabled: true;
            cursorShape: Qt.BlankCursor

            preventStealing: true
            propagateComposedEvents: true

            onShowMouseChanged: if (showMouse) cursorShape = Qt.ArrowCursor; else cursorShape = Qt.BlankCursor;
            onAutoHideChanged: mouseTimer.stop();

            onClicked: mouse.accepted = false;
            onPressed: mouse.accepted = false;
            onReleased: mouse.accepted = false;
            onDoubleClicked: mouse.accepted = false;
            onPressAndHold: mouse.accepted = false;
        }

        StackView
        {
            id: stack
            width: parent.width; height: parent.height
            focus: true
            opacity: screenBackground.screenSaverMode ? 0 : 1

            Component.onCompleted:
            {
                if (settings.mythQLayout)
                    stack.push(createThemedPanel());
                else
                    stack.push(createThemedMenu());
            }

            onCurrentItemChanged:
            {
                if (currentItem)
                {
                    currentItem.defaultFocusItem.focus = true;
                }
            }

            Keys.onPressed:
            {
                if (event.key === Qt.Key_F1)
                {
                    screenBackground.screenSaverMode = !screenBackground.screenSaverMode;
                }
                else if (event.key === Qt.Key_F2)
                {
                    screenBackground.muteAudio = !screenBackground.muteAudio;
                }
                else if (event.key === Qt.Key_F || event.key === Qt.Key_F8)
                {
                    if (visibility == 5)
                        visibility = 2
                    else
                        visibility = 5
                }
                else if (event.key === Qt.Key_F12)
                {
                    settings.showTextBorder = ! settings.showTextBorder;
                }
                else if (event.key === Qt.Key_S)
                {
                    takeSnapshot();
                }
                else if (event.key === Qt.Key_F10)
                {
                    if (stack.depth > 1) {stack.pop(); escapeSound.play();} else quit();
                }
            }

            function createThemedMenu()
            {
                var component = Qt.createComponent(mythUtils.findThemeFile("Screens/ThemedMenu.qml"));

                if (component.status === Component.Error)
                {
                    log.error(Verbose.GUI, "createThemedMenu: componant creation failed with error: " + component.errorString());
                    Qt.quit();
                }

                if (component.status === Component.Ready)
                {
                    var object =component.createObject(window, {model: mainMenuLoader.item});
                    return object;
                }
                else
                {
                    log.error(Verbose.GUI, "createThemedMenu: component not ready");
                    Qt.quit();
                }
            }

            function createThemedPanel()
            {
                var component = Qt.createComponent(mythUtils.findThemeFile("Screens/ThemedPanel.qml"));

                if (component.status === Component.Error)
                {
                    log.error(Verbose.GUI, "createThemedPanel: componant creation failed with error: " + component.errorString());
                    Qt.quit();
                }


                if (component.status === Component.Ready)
                {
                    var object = component.createObject(stack, {});
                    return object;
                }
                else
                {
                    log.error(Verbose.GUI, "createThemedPanel: component not ready");
                    Qt.quit();
                }
            }
        }

        BaseBackground
        {
            id: notificationPanel
            x: xscale(800); y: yscale(100); width: xscale(400); height: yscale(110)
            visible: false

            InfoText
            {
                id: notificationText
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                multiline: true
            }
        }

        BusyDialog
        {
            id: busyDialog
        }
    }

     function loadTheme()
    {
        log.info(Verbose.GUI, "loading theme from: " + settings.qmlPath + "Theme.qml");

        var component = Qt.createComponent(settings.qmlPath + "Theme.qml");

        while (component.status != Component.Ready && component.status != Component.Error)
        {
            log.debug(Verbose.GUI, "waiting for component to load! Status: " + component.status);
        }

        if (component.status == Component.Ready)
        {
            var theme = component.createObject(window);

            if (theme == null)
            {
                // Error Handling
                log.error(Verbose.GUI, "Error creating theme");
                return null
            }

            if (theme.backgroundVideo === undefined || theme.backgroundVideo != "")
            {
                if (!mythUtils.fileExists(settings.configPath + "Themes/Videos/" + theme.backgroundVideo))
                {
                    var source = "https://mythqml.net/downloads/themes/" + settings.themeName +"/" + theme.backgroundVideo;
                    var dest = settings.configPath + "Themes/Videos/" + theme.backgroundVideo;
                    screenBackground.showVideo = false;
                    screenBackground.showImage = true;
                    screenBackground.showSlideShow = false;

                    log.info(Verbose.GUI, "MainWindow: Downloading theme background video from - " + source);
                    log.info(Verbose.GUI, "to - " + dest);

                    showNotification("Downloading the background video.<br>Please Wait....", settings.osdTimeoutLong);

                    themeDLProcess.start("wget", ['-O', dest, source]);
                }
                else
                {
                    screenBackground.showVideo = true;
                    screenBackground.showImage = false;
                    screenBackground.showSlideShow = false;
                }
            }
            else if (theme.backgroundSlideShow != "")
            {
                if (!mythUtils.fileExists(settings.configPath + "Themes/Pictures/" + settings.themeName + "/" +theme.backgroundSlideShow))
                {
                    var source = "https://mythqml.net/downloads/themes/" + settings.themeName + "/" + theme.backgroundSlideShow;
                    var dest = settings.configPath + "Themes/Pictures/" + settings.themeName + "/" + theme.backgroundSlideShow;

                    mythUtils.mkPath(settings.configPath + "Themes/Pictures/" + settings.themeName);

                    screenBackground.showVideo = false;
                    screenBackground.showImage = true;
                    screenBackground.showSlideShow = false;

                    log.info(Verbose.GUI, "MainWindow: Downloading theme background slideshow from - " + source);
                    log.info(Verbose.GUI, "to - " + dest);

                    showNotification("Downloading the background slideshow.<br>Please Wait....", 1000 * 60 * 60);

                    themeDLProcess.start("wget", ['-O', dest, source]);
                }
                else
                {
                    screenBackground.setSlideShow(settings.configPath + "Themes/Pictures/" + settings.themeName);
                    screenBackground.showVideo = false;
                    screenBackground.showImage = false;
                    screenBackground.showSlideShow = true;
                }
            }
            else
            {
                screenBackground.showVideo = false;
                screenBackground.showImage = true;
                screenBackground.showSlideShow = false;
            }

            return theme
        }
        else if (component.status == Component.Error)
        {
            // Error Handling
            log.error(Verbose.GUI, "Error loading component:", component.errorString());
        }

        return null;
    }

    function showBusyDialog(message, timeoutTime)
    {
        busyDialog.message = message;
        busyDialog.timeOut = timeoutTime;
        busyDialog.show();
    }

    Timer
    {
        id: mouseTimer
        interval: 3000; running: true; repeat: true
        onTriggered:
        {
            if (mouseArea.mouseX === mouseArea.oldX || mouseArea.mouseY === mouseArea.oldY)
            {
                stop();
                mouseArea.cursorShape = Qt.BlankCursor;
            }
        }
    }

    function showMouse(show)
    {
        mouseArea.showMouse = show;
    }

    Timer
    {
        id: notificationTimer
        interval: 6000; running: false; repeat: false
        onTriggered: notificationPanel.visible = false;
    }

    function showNotification(message, timeOut)
    {
        if (!timeOut)
            timeOut = settings.osdTimeoutMedium;

        if (message !== "")
        {
            notificationText.text = message;
            notificationPanel.visible = true;
            notificationTimer.interval = timeOut
            notificationTimer.restart();
        }
        else
        {
            notificationText.text = message;
            notificationPanel.visible = false;
            notificationTimer.stop();
        }
    }

    function takeSnapshot(item, filename)
    {
        if (item === undefined)
            item = root;

        if (filename === undefined)
        {
            filename = settings.configPath + "Snapshots/snapshot";

            var index = 0;
            var padding = "";

            if (mythUtils.fileExists(filename + ".png"))
            {
                do
                {
                    index += 1;

                    if (index < 10)
                        padding = "00";
                    else if (index < 100)
                        padding = "0";

                }  while (mythUtils.fileExists(filename + padding + index + ".png"));

                filename = filename + padding + index + ".png";
            }
            else
                filename = filename + ".png";
        }

        log.info(Verbose.FILE, "saving snapshot to: " + filename);
        item.grabToImage(function(result)
                         {
                              result.saveToFile(filename);
                              showNotification("Snapshot Saved", settings.osdTimeoutMedium);
                         });
    }

    function runCommand(command, parameters)
    {
        externalProcess.start(command, parameters);
    }

    Process
    {
        id: externalProcess
        onFinished:
        {
            log.debug(Verbose.PROCESS, "External Process is finished");
            wake();
        }

        onStateChanged:
        {
            if (state === Process.Running)
            {
                log.debug(Verbose.PROCESS, "External Process is running");
                sleep();
            }
        }
    }

    Timer
    {
        id: whatsNewTimer
        interval: 1000; running: window.showWhatsNew; repeat: false
        onTriggered:
        {
            whatsNewTimer.stop();
            checkWhatsNew();
        }
    }

    WhatsNewModel
    {
        id: whatsNewModel
    }

    Timer
    {
        id: delayTimer
    }

    function delay(delayTime, cb)
    {
        delayTimer.interval = delayTime;
        delayTimer.repeat = false;
        delayTimer.triggered.connect(cb);
        delayTimer.start();
    }

    function checkWhatsNew()
    {
        var lastShownIndex = parseInt(dbUtils.getSetting("LastWhatsNewShown", settings.hostName, -1));

        if (lastShownIndex === -1)
        {
            // must be first run?
        }
        else if (lastShownIndex + 1 < whatsNewModel.count)
        {
            messageSound.play();
            stack.push({item: mythUtils.findThemeFile("Screens/WhatsNew.qml"), properties:{currentPage:  lastShownIndex + 1}});
        }
    }

    PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "Menu Options"

        onItemSelected:
        {
            if (itemData === "version")
            {
                versionDialog.show(_activeFocusItem);
                return;
            }
            else if (itemData === "reboot")
            {
                reboot();
            }
            else if (itemData === "shutdown")
            {
                shutdown();
            }
            else if (itemData === "exit")
            {
                quit();
            }
            else if (itemData === "volume")
            {
                volumeDialog.oldEffectsVolume = window.soundEffectsVolume;
                volumeDialog.oldBackgroundVideoVolume = window.backgroundVideoVolume;

                var index = window.soundEffectsVolume * 100.0;
                effectsSelector.selectItem(volumeModel.get(index).itemText);

                index = window.backgroundVideoVolume * 100.0;
                backgroundSelector.selectItem(volumeModel.get(index).itemText);

                volumeDialog.show(_activeFocusItem);
                return;
            }
        }
    }

    OkCancelDialog
    {
        id: versionDialog

        title: appName
        message: '<font  color="yellow"><b>Version: </font></b>' + version  + " (" + branch + ")" +
                 '<br><font color="yellow"><b>Date: </font></b>' + buildtime +
                 '<br><font  color="yellow"><b>Qt Version: </font></b>' + qtversion +
                 '<br><br>(c) Paul Harrison 2019-2020'

        rejectButtonText: ""
        acceptButtonText: "OK"

        width: xscale(600); height: yscale(300)

        //onAccepted: if (_activeFocusItem) _activeFocusItem.focus = true;
        //onCancelled: if (_activeFocusItem) _activeFocusItemlistView.focus = true;
    }

    ListModel
    {
        id: volumeModel

        Component.onCompleted:
        {
            append({ "volume": 0, "itemText": "Muted"});

            for (var x = 1; x <= 100; x++)
            {
                append({ "volume": x, "itemText": x + "%"});
            }
        }
    }

    BaseDialog
    {
        id: volumeDialog
        title: "Volume"
        message: "Set sound effects and background video volume"
        width: xscale(500)
        height: yscale(400)

        property double oldEffectsVolume: -1
        property double oldBackgroundVideoVolume: -1

        onAccepted:
        {
            window.soundEffectsVolume = volumeModel.get(effectsSelector.currentIndex).volume / 100;
            window.backgroundVideoVolume = volumeModel.get(backgroundSelector.currentIndex).volume / 100;

            dbUtils.setSetting("SoundEffectsVolume", settings.hostName, window.soundEffectsVolume);
            dbUtils.setSetting("BackgroundVideoVolume", settings.hostName, window.backgroundVideoVolume);
        }

        onCancelled:
        {
            window.soundEffectsVolume = oldEffectsVolume;
            window.backgroundVideoVolume = oldBackgroundVideoVolume;
        }

        content: Item
        {
            anchors.fill: parent

            LabelText
            {
                text: "Sound Effects"
                x: xscale(10); y: 0; width: xscale(250);
            }

            BaseSelector
            {
                id: effectsSelector
                x: xscale(260); y: yscale(0);
                model: volumeModel
                focus: true;
                KeyNavigation.up: rejectButton;
                KeyNavigation.down: backgroundSelector;

                onItemSelected:
                {
                    if (volumeDialog.oldEffectsVolume !== -1)
                    {
                        window.soundEffectsVolume = volumeModel.get(effectsSelector.currentIndex).volume / 100;
                        returnSound.play();
                    }
                }
            }
            LabelText
            {
                text: "Background Video"
                x: xscale(10); y: yscale(60); width: xscale(250);
            }

            BaseSelector
            {
                id: backgroundSelector
                x: xscale(260); y: yscale(60);
                model: volumeModel
                KeyNavigation.up: effectsSelector;
                KeyNavigation.down: acceptButton;

                onItemSelected:
                {
                    if (volumeDialog.oldBackgroundVideoVolume !== -1)
                    {
                         window.backgroundVideoVolume = volumeModel.get(backgroundSelector.currentIndex).volume / 100;
                    }

                }
            }
        }

        buttons:
        [
            BaseButton
            {
                id: acceptButton
                text: "OK"
                visible: text != ""

                KeyNavigation.left: rejectButton;
                KeyNavigation.right: rejectButton;
                KeyNavigation.up: backgroundSelector;
                KeyNavigation.down: effectsSelector;
                onClicked:
                {
                    volumeDialog.state = "";
                    volumeDialog.accepted();
                }
            },

            BaseButton
            {
                id: rejectButton
                text: "Cancel"
                visible: text != ""

                KeyNavigation.left: acceptButton;
                KeyNavigation.right: acceptButton;
                KeyNavigation.up: backgroundSelector;
                KeyNavigation.down: effectsSelector;

                onClicked:
                {
                    volumeDialog.state = "";
                    volumeDialog.cancelled();
                }
            }
        ]
    }

    function sleep()
    {
        log.info(Verbose.GENERAL, "Going to sleep....zzzzz");
        screenBackground.showImage = true;
        screenBackground.showTime = false;
        screenBackground.showTicker =false;
        screenBackground.pauseVideo(true);
        screenBackground.showVideo = false;
        //window.active = false;
        idleTimer.stop();
        tickerUpdateTimer.stop();
    }

    function wake()
    {
        log.info(Verbose.GENERAL, "Waking up.... \\0/");
        screenBackground.showImage =false;
        screenBackground.showTime = true;
        screenBackground.showTicker = true;
        screenBackground.showVideo= true;
        screenBackground.pauseVideo(false);
        //window.active = false;
        idleTimer.start();
        tickerUpdateTimer.start();
    }

    function quit()
    {
        screenBackground.pauseVideo(true);
        Qt.quit();
    }

    function shutdown()
    {
        if (settings.shutdownCommand != "")
        {
            log.info(Verbose.GENERAL, "Shutting Down!!!!")
            busyDialog.message = "Shutting Down...";
            busyDialog.timeOut = 10000;
            busyDialog.show();
            externalProcess.start(settings.shutdownCommand);
        }
    }

    function reboot()
    {
        if (settings.rebootCommand != "")
        {
            log.info(Verbose.GENERAL, "Rebooting!!!!")
            busyDialog.message = "Rebooting. Please Wait...";
            busyDialog.timeOut = 10000;
            busyDialog.show();
            externalProcess.start(settings.rebootCommand);
        }
    }
}
