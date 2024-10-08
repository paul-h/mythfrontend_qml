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
import com.blackgrain.qml.quickdownload 1.0
import "../../../Util.js" as Util

Window
{
    id: window
    visible: true
    visibility: settings.startFullscreen ? "FullScreen" : "Windowed"
    x: 0
    y: 0
    width: 1280
    height: 720

    property string mainMenu: "MainMenu.qml"
    property alias helpURL: screenBackground.helpURL
    property bool showWhatsNew: true
    property bool exitOnEscape: true
    property bool shutdownOnIdle: false
    property bool showVideoBackground: true
    property bool playStartupEffect: true
    property bool showZMAlerts: true
    property bool showingZMAlerts: (zmAlertDialog.state === "show")
    property bool needPlayerSources: true

    property int idleTime: settings.frontendIdleTime

    property double wmult: width / 1280
    property double hmult: height / 720
    property var theme: Theme {}
    property int soundEffectsVolume: 100
    property int backgroundVideoVolume: 100
    property int radioPlayerVolume: 100

    property var playerSources: undefined

    property int _fadeTime: 4000

    property bool _savedShowImage: false
    property bool _savedShowTime: false
    property bool _savedShowTicker: false
    property bool _savedShowVideo: false
    property bool _savedShowSlideShow: false;

    property alias stack: stack

    Component.onCompleted:
    {
        eventListener.listenTo(window)

        soundEffectsVolume = dbUtils.getSetting("SoundEffectsVolume", settings.hostName, "100");
        backgroundVideoVolume = dbUtils.getSetting("BackgroundVideoVolume", settings.hostName, "100");
        radioPlayerVolume = dbUtils.getSetting("RadioPlayerVolume", settings.hostName, "100");

        if (needPlayerSources)
            loadPlayerSources();
    }

    Connections
    {
        target: eventListener
        function onKeyPressed() { idleTimer.restart(); }
        function onMouseMoved()
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

    Download
    {
        id: themeDownloader

        overwrite: true
        followRedirects: true
        onRedirected: log.info(Verbose.NETWORK, "ThemeDownloader: got redirected: "+ url + "->" + redirectUrl)

        onError:
        {
            log.error(Verbose.GENERAL, "ThemeDownloader: download failed. URL was: " + url + ", Error was: "+ errorString);
            showNotification("Downloading of the background video failed.<br>Error was: "+ errorString, settings.osdTimeoutMedium);
        }

        onFinished:
        {
            if (theme.backgroundVideo !== undefined)
            {
                showNotification("Downloading of the background video completed OK", settings.osdTimeoutShort);
                screenBackground.showVideo = true;
                screenBackground.setVideo("file://" + settings.configPath + "Themes/Videos/" + theme.backgroundVideo.filename);
                screenBackground.showImage = false;
            }
            else if (theme.backgroundSlideShow !== undefined)
            {
                var source = destination.toString().replace("file://", ""); // the file we just downloaded
                var dest = settings.configPath.replace("file://", "") + "Themes/Pictures/" + settings.themeName + "/";

                showNotification("Downloading of the background slideshow completed OK<br>Extracting images - Please Wait...", settings.osdTimeoutLong);
                unTarProcess.start("tar", ['--overwrite', '-x', '-C', dest, '-f', source]);
            }
        }

        onUpdate:
        {
            var received = kiloBytesReceived / 1024;
            var total = kiloBytesTotal / 1024;

            if (theme.backgroundVideo !== undefined)
            {
                if (total > 0)
                    showNotification("Downloading the background video.<br>Received " + received.toFixed(1) + "Mb of " + total.toFixed(1) + "Mb<br>Please Wait....", settings.osdTimeoutLong);
                else
                    showNotification("Downloading the background video.<br>Received " + received.toFixed(1) + "Mb<br>Please Wait....", settings.osdTimeoutLong);
            }
            else if (theme.backgroundSlideShow !== undefined)
            {
                if (total > 0)
                    showNotification("Downloading the background slideshow.<br>Received " + received.toFixed(1) + "Mb of " + total.toFixed(1) + "Mb<br>Please Wait....", settings.osdTimeoutLong);
                else
                    showNotification("Downloading the background slideshow.<br>Received " + received.toFixed(1) + "Mb<br>Please Wait....", settings.osdTimeoutLong);
            }
        }
    }

    Process
    {
        id: unTarProcess
        onFinished:
        {
            if (exitStatus === Process.NormalExit && unTarProcess.exitCode() === 0)
            {
                showNotification("Extracting slideshow images completed OK", settings.osdTimeoutShort);
                screenBackground.showVideo = false;
                screenBackground.setSlideShow(settings.configPath + "Themes/Pictures/" + settings.themeName);
                screenBackground.showImage = false;
                screenBackground.showSlideShow = true;

                dbUtils.setSetting(settings.themeName + "Version", settings.hostName, theme.backgroundSlideShow.version);

                if (radioPlayerDialog.themePlayerEnabled)
                {
                    radioPlayerDialog.playStream(dbUtils.getSetting(settings.themeName + "RadioStream", settings.hostName, ""));
                    showNotification("Playing audio stream.<br>" + radioPlayerDialog.streamList.get(radioPlayerDialog.streamList.currentItem).title);
                }
            }
            else
            {
                var source = settings.configPath + "Themes/Pictures/" + settings.themeName + "/" + theme.backgroundSlideShow.filename;
                var dest = settings.configPath + "Themes/Pictures/" + settings.themeName + "/"

                mythUtils.removeFile(source);

                showNotification("Extracting of the background slideshow images failed!");
                log.error(Verbose.GUI, "MainWindow: Error - failed to extract background slideshow images from: " + source);
                log.error(Verbose.GUI, "MainWindow: Error - exit code was: " + unTarProcess.exitCode());
            }
        }
    }

    WebSocket
    {
        id: webSocket
        url: "ws://" + settings.masterIP + ":" + settings.websocketPort
        onTextMessageReceived:
        {
            log.debug(Verbose.WEBSOCKET, "WebSocket: Received message - " + message)
        }
        onStatusChanged:
        {
            if (webSocket.status == WebSocket.Error)
            {
                log.error(Verbose.WEBSOCKET, "WebSocket: Error - " + webSocket.errorString + " (" + url + ")");

                // the old server used a different port lets try that
                if (settings.masterPort === settings.websocketPort)
                {
                    settings.websocketPort = settings.websocketPort + 5;
                    log.error(Verbose.WEBSOCKET, "WebSocket: trying old websocket port (" + settings.websocketPort + ")");
                }
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
         volume: soundEffectsVolume / 100
    }
    SoundEffect
    {
         id: downSound
         source: mythUtils.findThemeFile("sounds/pock.wav")
         volume: soundEffectsVolume / 100
    }
    SoundEffect
    {
         id: leftSound
         source: mythUtils.findThemeFile("sounds/pock.wav")
         volume: soundEffectsVolume / 100
    }
    SoundEffect
    {
         id: rightSound
         source: mythUtils.findThemeFile("sounds/pock.wav")
         volume: soundEffectsVolume / 100
    }
    SoundEffect
    {
         id: returnSound
         source: mythUtils.findThemeFile("sounds/poguck.wav")
         volume: soundEffectsVolume / 100
    }
    SoundEffect
    {
         id: escapeSound
         source: mythUtils.findThemeFile("sounds/pock.wav")
         volume: soundEffectsVolume / 100
    }
    SoundEffect
    {
         id: messageSound
         source: mythUtils.findThemeFile("sounds/message.wav")
         volume: 1.0 //soundEffectsVolume / 100
    }
    SoundEffect
    {
         id: errorSound
         source: mythUtils.findThemeFile("sounds/downer.wav")
         volume: soundEffectsVolume / 100
    }

    SoundEffect
    {
         id: startupSound
         source: mythUtils.findThemeFile("sounds/welcome.wav")
         volume: soundEffectsVolume / 100
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
        interval: 2000; running: true; repeat: false
        onTriggered:
        {
            // wiggle the mouse to force it to timeout and auto hide itself
            var pos =  mythUtils.getMousePos();
            mythUtils.mouseMove(pos.x + 1, pos.y + 1);

            screenBackground.screenSaverMode = false
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
            showSlideShow: false
            showTicker: true
            Component.onCompleted:
            {
                tickerProcess.start(settings.sharePath.replace("file://", "") + "/qml/Scripts/ticker-grabber.py", [settings.configPath + "ticker.xml"]);
                loadTheme();
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
                createInitialItem();
            }

            onCurrentItemChanged:
            {
                if (currentItem)
                {
                    currentItem.defaultFocusItem.focus = true;

                    if (typeof currentItem.restoreSettings === "function")
                        currentItem.restoreSettings();
                }
            }

            Keys.onPressed:
            {
                if (event.key === Qt.Key_F1)
                {
                    // red
                    screenBackground.screenSaverMode = !screenBackground.screenSaverMode;
                }
                else if (event.key === Qt.Key_F2)
                {
                    // green
                    if (radioPlayerDialog.isPlaying())
                    {
                        radioPlayerDialog.toggleMute();
                        showNotification("Radio Player Mute: " + (radioPlayerDialog.muteAudio ? "On" : "Off"));
                    }
                    else
                    {
                        screenBackground.muteAudio = !screenBackground.muteAudio;
                        showNotification("Background Video Mute: " + (screenBackground.muteAudio ? "On" : "Off"));
                    }
                }
                else if (event.key === Qt.Key_F3)
                {
                    // yellow
                    radioPlayerDialog.show();
                }
                else if (event.key === Qt.Key_F || event.key === Qt.Key_W)
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
                else if (event.key === Qt.Key_H)
                {
                    showHelp();
                }
                else if (event.key === Qt.Key_Z)
                {
                    zmAlertDialog.autoHide = false;
                    zmAlertDialog.show();
                }
            }

            Behavior on opacity { NumberAnimation { duration: _fadeTime } }

            function createInitialItem()
            {
                if (settings.mythQLayout)
                    stack.push(createThemedPanel());
                else
                    stack.push(createThemedMenu());
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
                    var object = component.createObject(stack, {model: mainMenuLoader.item});
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
            x: parent.width - width - xscale(100); y: yscale(120); width: xscale(400); height: yscale(110)
            visible: false

            InfoText
            {
                id: notificationText
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                multiline: true
                textFormat: TextEdit.RichText
            }
        }

        BusyDialog
        {
            id: busyDialog
        }
    }

    function showBusyDialog(message, timeoutTime)
    {
        busyDialog.message = message;
        busyDialog.timeOut = timeoutTime;
        busyDialog.show();
    }

    function hideBusyDialog()
    {
        busyDialog.hide();
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

    function mouseMove(x, y)
    {
        var pos = mythUtils.getMousePos();
        var new_x = pos.x + x;
        var new_y = pos.y + y;
        mythUtils.mouseMove(new_x, new_y);
    }

    function mouseMoveTo(x, y)
    {
        mythUtils.mouseMove(x, y);
    }

    function mouseLeftClick()
    {
        var pos = mythUtils.getMousePos();
        var localPos = root.mapFromGlobal(pos.x, pos.y)
        mythUtils.mouseLeftClick(window, localPos.x, localPos.y);
    }

    Timer
    {
        id: notificationTimer
        interval: 6000; running: false; repeat: false
        onTriggered: notificationPanel.visible = false;
    }

    function loadPlayerSources()
    {
        log.info(Verbose.INFO, "loading playerSources from: " + settings.sharePath + "qml/Models/PlayerSourcesModel.qml");

        var component = Qt.createComponent(settings.sharePath + "qml/Models/PlayerSourcesModel.qml");

        while (component.status != Component.Ready && component.status != Component.Error)
        {
            log.debug(Verbose.GUI, "waiting for component to load! Status: " + component.status);
        }

        if (component.status == Component.Ready)
        {
            playerSources = component.createObject(window);

            if (playerSources == null)
            {
                // Error Handling
                log.error(Verbose.GUI, "Error creating playerSources");
                return null
            }

            return playerSources;
        }
        else if (component.status == Component.Error)
        {
            // Error Handling
            log.error(Verbose.GUI, "Error loading component: " + component.errorString());
        }

        return null;
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
            theme = component.createObject(window);

            if (theme == null)
            {
                // Error Handling
                log.error(Verbose.GUI, "Error creating theme");
                return null
            }

            // find any theme sound effects
            upSound.source = mythUtils.findThemeFile("sounds/pock.wav");
            downSound.source = mythUtils.findThemeFile("sounds/pock.wav");
            leftSound.source = mythUtils.findThemeFile("sounds/pock.wav");
            rightSound.source = mythUtils.findThemeFile("sounds/pock.wav");
            returnSound.source = mythUtils.findThemeFile("sounds/poguck.wav");
            escapeSound.source = mythUtils.findThemeFile("sounds/pock.wav");
            messageSound.source = mythUtils.findThemeFile("sounds/message.wav");
            errorSound.source = mythUtils.findThemeFile("sounds/downer.wav");
            startupSound.source = mythUtils.findThemeFile("sounds/welcome.wav");

            if (playStartupEffect)
                startupSound.play();

            var dest;

            if (theme.backgroundVideo != undefined)
            {
                dest = settings.configPath + "Themes/Videos/" + theme.backgroundVideo.filename;

                if (!mythUtils.fileExists(dest))
                {
                    mythUtils.mkPath(settings.configPath + "Themes/Videos");

                    screenBackground.showVideo = false;
                    screenBackground.showImage = true;
                    screenBackground.showSlideShow = false;
                    screenBackground.setVideo("");

                    log.info(Verbose.GUI, "MainWindow: Downloading theme background video to - " + dest);

                    // start the download
                    themeDownloader.destination = dest;
                    themeDownloader.start(theme.backgroundVideo);
                }
                else
                {
                    log.info(Verbose.GUI, "MainWindow: starting background video");
                    screenBackground.showVideo = showVideoBackground;

                    if (showVideoBackground)
                        screenBackground.setVideo("file://" + settings.configPath + "Themes/Videos/" + theme.backgroundVideo.filename);
                    else
                        screenBackground.setVideo("");

                    screenBackground.showImage = !showVideoBackground;
                    screenBackground.showSlideShow = false;
                }
            }
            else if (theme.backgroundSlideShow != undefined)
            {
                dest = settings.configPath + "Themes/Pictures/" + settings.themeName + "/" + theme.backgroundSlideShow.filename;

                // check for new slideshow version
                var installedVersion = dbUtils.getSetting(settings.themeName + "Version", settings.hostName, "1.0");

                if (theme.backgroundSlideShow.version > installedVersion)
                {
                    okCancelDialog.title = "New version of theme slideshow available";
                    okCancelDialog.message = '<font  color="yellow"><b>Theme Name: </font></b>' + settings.themeName +
                            '<br><font color="yellow"><b>Installed Version: </font></b>' + installedVersion +
                            '<br><font  color="yellow"><b>New Version: </font></b>' + theme.backgroundSlideShow.version +
                            '<br><br>Please wait while it is downloaded and installed.';
                    okCancelDialog.show(stack.currentItem.defaultFocusItem);

                    // remove the old slideshow archive, pictures and music tracks
                    mythUtils.clearDir(settings.configPath + "Themes/Pictures/" + settings.themeName);
                }

                if (!mythUtils.fileExists(dest))
                {
                    mythUtils.mkPath(settings.configPath + "Themes/Pictures/" + settings.themeName);

                    screenBackground.showVideo = false;
                    screenBackground.showImage = true;
                    screenBackground.showSlideShow = false;

                    log.info(Verbose.GUI, "MainWindow: Downloading theme background slideshow to - " + dest);

                    themeDownloader.destination = dest;
                    themeDownloader.start(theme.backgroundSlideShow);
                }
                else
                {
                    log.info(Verbose.GUI, "MainWindow: starting background slideshow");
                    screenBackground.setSlideShow(settings.configPath + "Themes/Pictures/" + settings.themeName);
                    screenBackground.showVideo = false;
                    screenBackground.showImage = !showVideoBackground;
                    screenBackground.showSlideShow = showVideoBackground;
                    screenBackground.setVideo("");
                }
            }
            else
            {
                screenBackground.showVideo = false;
                screenBackground.showImage = true;
                screenBackground.showSlideShow = false;
                screenBackground.setVideo("");
            }

            // load any radio streams defined by the theme
            if (theme.radioStreams && theme.radioStreams.count > 0)
            {
                radioPlayerDialog.clearStreams();

                for (var x = 0; x < theme.radioStreams.count; x++)
                {
                    var title = theme.radioStreams.get(x).title;
                    var url  = theme.radioStreams.get(x).url;
                    var logo  = theme.radioStreams.get(x).logo;

                    if (!url.startsWith("http://") && !url.startsWith("https://") && !url.startsWith("file://"))
                        url = "file://" + settings.configPath + "Themes/Pictures/" + settings.themeName + "/" + url;

                    if (!logo.startsWith("http://") && !logo.startsWith("https://") && !logo.startsWith("file://"))
                        logo = "file://" + settings.configPath + "Themes/Pictures/" + settings.themeName + "/" + logo;

                    radioPlayerDialog.addStream(title, url, logo);
                }

                if (radioPlayerDialog.themePlayerEnabled)
                {
                    radioPlayerDialog.playStream(dbUtils.getSetting(settings.themeName + "RadioStream", settings.hostName, ""));
                    showNotification("Playing audio stream.<br>" + radioPlayerDialog.streamList.get(radioPlayerDialog.streamList.currentItem).title);
                }
            }
            else
            {
                radioPlayerDialog.clearStreams();
                radioPlayerDialog.stop();
            }

            return theme;
        }
        else if (component.status == Component.Error)
        {
            // Error Handling
            log.error(Verbose.GUI, "Error loading component:" + component.errorString());
        }

        return null;
    }

    function showHelp()
    {
        showWebpage(screenBackground.helpURL, xscale(1.3), true);
    }

    function showWebpage(url, zoom, fullscreen)
    {
        if (url == "" || url == undefined)
        {
            showNotification("ERROR: Cannot show the webpage - given an invalid URL");
            return;
        }

        if (!url.startsWith("http://") && !url.startsWith("https://") && !url.startsWith("file://"))
            url = "http://" + url;

        stack.push({item: mythUtils.findThemeFile("Screens/WebBrowser.qml"), properties:{url: url, zoomFactor: zoom, fullscreen: fullscreen}});
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

        property bool doSleep: true

        onFinished:
        {
            log.debug(Verbose.PROCESS, "External Process is finished");
            if (doSleep)
            {
                busyDialog.hide();
                wake();
            }
            else
                doSleep = true;
        }

        onStateChanged:
        {
            if (state === Process.Running)
            {
                log.debug(Verbose.PROCESS, "External Process is running");

                if (doSleep)
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

            // if the user added a jumpto commandline parameter try to jump to it
            if (jumpto !== "")
                handleJumpTo(jumpto);
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
            stack.push({item: mythUtils.findThemeFile("Screens/WhatsNew.qml"), properties:{autoShow: true}});
        }
    }

    RadioPlayerDialog
    {
        id: radioPlayerDialog
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
            else if (itemData === "suspend")
            {
                suspend();
            }
            else if (itemData === "exit")
            {
                quit();
            }
            else if (itemData === "volume")
            {
                volumeDialog.oldEffectsVolume = window.soundEffectsVolume;
                volumeDialog.oldBackgroundVideoVolume = window.backgroundVideoVolume;
                volumeDialog.oldRadioPlayerVolume = window.radioPlayerVolume;

                var index = window.soundEffectsVolume;
                effectsSelector.selectItem(volumeModel.get(index).itemText);

                index = window.backgroundVideoVolume;
                backgroundSelector.selectItem(volumeModel.get(index).itemText);

                index = window.radioPlayerVolume;
                radioSelector.selectItem(volumeModel.get(index).itemText);

                volumeDialog.show(_activeFocusItem);
                return;
            }
            else if (itemData === "radioplayer")
            {
                radioPlayerDialog.show();
            }
            else if (itemData === "zoneminder")
            {
                zmAlertDialog.autoHide = false;
                zmAlertDialog.show();
            }
            else if (itemData === "showhelp")
            {
                showHelp();
            }
        }
    }

    OkCancelDialog
    {
        id: versionDialog

        title: appName
        message: '<font  color="yellow"><b>Version: </font></b>' + version  + " (" + branch + ")" +
                 '<br><font color="yellow"><b>Date: </font></b>' + buildtime +
                 '<br><font  color="yellow"><b>OS Version: </font></b>' + osversion +
                 '<br><font  color="yellow"><b>Qt Version: </font></b>' + qtversion +
                 '<br><br>(c) Paul Harrison 2019-2024'

        rejectButtonText: ""
        acceptButtonText: "Close"

        width: xscale(600); height: yscale(300)
    }

    OkCancelDialog
    {
        id: okCancelDialog

        title: appName

        rejectButtonText: ""
        acceptButtonText: "OK"

        width: xscale(600); height: yscale(300)
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
        height: yscale(485)

        property int oldEffectsVolume: -1
        property int oldBackgroundVideoVolume: -1
        property int oldRadioPlayerVolume: -1

        onAccepted:
        {
            window.soundEffectsVolume = volumeModel.get(effectsSelector.currentIndex).volume;
            window.backgroundVideoVolume = volumeModel.get(backgroundSelector.currentIndex).volume;
            window.radioPlayerVolume = volumeModel.get(radioSelector.currentIndex).volume;

            dbUtils.setSetting("SoundEffectsVolume", settings.hostName, window.soundEffectsVolume);
            dbUtils.setSetting("BackgroundVideoVolume", settings.hostName, window.backgroundVideoVolume);
            dbUtils.setSetting("RadioPlayerVolume", settings.hostName, window.radioPlayerVolume);
        }

        onCancelled:
        {
            window.soundEffectsVolume = oldEffectsVolume;
            window.backgroundVideoVolume = oldBackgroundVideoVolume;
            window.radioPlayerVolume = oldRadioPlayerVolume;
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
                        window.soundEffectsVolume = volumeModel.get(effectsSelector.currentIndex).volume;
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
                KeyNavigation.down: radioSelector;

                onItemSelected:
                {
                    if (volumeDialog.oldBackgroundVideoVolume !== -1)
                    {
                        window.backgroundVideoVolume = volumeModel.get(backgroundSelector.currentIndex).volume;
                    }
                }
            }

            LabelText
            {
                text: "Radio Player"
                x: xscale(10); y: yscale(120); width: xscale(250);
            }

            BaseSelector
            {
                id: radioSelector
                x: xscale(260); y: yscale(120);
                model: volumeModel
                KeyNavigation.up: backgroundSelector;
                KeyNavigation.down: acceptButton;

                onItemSelected:
                {
                    if (volumeDialog.oldRadioPlayerVolume !== -1)
                    {
                        radioPlayerVolume = volumeModel.get(radioSelector.currentIndex).volume;
                        radioPlayerDialog.volume = volumeModel.get(radioSelector.currentIndex).volume;
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
                KeyNavigation.up: radioSelector;
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
                KeyNavigation.up: radioSelector;
                KeyNavigation.down: effectsSelector;

                onClicked:
                {
                    volumeDialog.state = "";
                    volumeDialog.cancelled();
                }
            }
        ]
    }

    ZMAlertDialog
    {
        id: zmAlertDialog

        property var lastAlert: Date.now()

        x: window.width
        y: yscale(50)
        actualX: parent.width - width - xscale(25)
        actualY: yscale(50)
        hiddenX: window.width
        hiddenY: yscale(50)
    }

    function showZMAlert(monitorId)
    {
        if (!window.showZMAlerts)
            return;

        // are we already showing the alert dialog for this monitor
        if (zmAlertDialog.alertedMonitorId === monitorId && zmAlertDialog.state === "show")
            return;

        // if we are already showing the alert dialog just switch to the new alarmed monitor
        if (zmAlertDialog.state === "show")
        {
            zmAlertDialog.alertedMonitorId = monitorId;
            zmAlertDialog.show();
            return;
        }

        // we need to show the alert dialog
        var now = Date.now();

        if (now - zmAlertDialog.lastAlert > 60 * 1000)
        {
            messageSound.play()
            zmAlertDialog.autoHide = true;
            zmAlertDialog.alertedMonitorId = monitorId;
            zmAlertDialog.lastAlert = Date.now();
            zmAlertDialog.show();
        }
    }

    function sleep()
    {
        log.info(Verbose.GENERAL, "Going to sleep....zzzzz");

        _savedShowImage = screenBackground.showImage;
        _savedShowTime = screenBackground.showTime;
        _savedShowTicker = screenBackground.showTicker;
        _savedShowVideo = screenBackground.showVideo;
        _savedShowSlideShow = screenBackground.showSlideShow;

        screenBackground.showImage = true;
        screenBackground.showTime = false;
        screenBackground.showTicker =false;
        screenBackground.pauseVideo(true);
        screenBackground.showVideo = false;
        screenBackground.showSlideShow = false;

        radioPlayerDialog.suspendPlayback();

        idleTimer.stop();
        tickerUpdateTimer.stop();
    }

    function wake()
    {
        log.info(Verbose.GENERAL, "Waking up.... \\0/");
        screenBackground.showImage =_savedShowImage;
        screenBackground.showTime = _savedShowTime;
        screenBackground.showTicker = _savedShowTicker;
        screenBackground.showVideo= _savedShowVideo;
        screenBackground.pauseVideo(false);
        screenBackground.showSlideShow = _savedShowSlideShow;

        radioPlayerDialog.resumePlayback();

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

    function suspend()
    {
        if (settings.suspendCommand != "")
        {
            log.info(Verbose.GENERAL, "Suspending!!!!")
            externalProcess.doSleep = false;
            externalProcess.start(settings.suspendCommand);
        }
    }

    function sendCommandToHelper(command)
    {
        if (helperWebSocket.active)
            helperWebSocket.sendTextMessage(command);
    }

    function isHelperAvailable()
    {
        return helperWebSocket.active && helperWebSocket.status === WebSocket.Open;
    }

    JumpModel {id: jumpModel}

    function handleJumpTo(message)
    {
        var jumpTo = message.jumpTo.toLowerCase();
        log.debug(Verbose.GENERAL, "Looking for jumpPoint: " + jumpTo);

        for (var x = 0; x < jumpModel.count; x++)
        {
            var jumpPoints = jumpModel.get(x).jumpText.split("|");

            for (var y = 0; y < jumpPoints.length; y++)
            {
                if (jumpTo === jumpPoints[y].toLowerCase())
                {

                    log.debug(Verbose.GENERAL, "handleJumpTo: jump point was found");

                    // jump back to the main menu
                    while (stack.depth > 1)
                    {
                        stack.pop(null, StackView.Immediate);
                    }

                    // perform the jump
                    if (jumpModel.get(x).loaderSource === "ThemedMenu.qml")
                    {
                        menuLoader.source = settings.menuPath + jumpModel.get(x).menuSource;
                        stack.push({item: mythUtils.findThemeFile("Screens/ThemedMenu.qml"), properties:{model: menuLoader.item}});
                    }
                    else if (jumpModel.get(x).loaderSource === "WebBrowser.qml")
                    {
                        var url = jumpModel.get(x).url
                        var zoom = xscale(jumpModel.get(x).zoom)
                        var fullscreen = jumpModel.get(x).fullscreen
                        stack.push({item: mythUtils.findThemeFile("Screens/WebBrowser.qml"), properties:{url: url, fullscreen: fullscreen, zoomFactor: zoom}});
                    }
                    else if (jumpModel.get(x).loaderSource === "InternalPlayer.qml")
                    {
                        var layout = jumpModel.get(x).layout
                        var feedSource = jumpModel.get(x).feedSource
                        stack.push({item: mythUtils.findThemeFile("Screens/InternalPlayer.qml"), properties:{layout: layout, defaultFeedSource: feedSource, defaultCurrentFeed: 0}});
                    }
                    else if (jumpModel.get(x).loaderSource === "External Program")
                    {
                        var dialogMessage = jumpModel.get(x).menutext + " will start shortly.\nPlease Wait.....";
                        var timeOut = 10000;
                        showBusyDialog(dialogMessage, timeOut);
                        var command = jumpModel.get(x).exec
                        externalProcess.start(command, []);
                    }
                    else
                    {
                        stack.push({item: mythUtils.findThemeFile("Screens/" + jumpModel.get(x).loaderSource)})
                    }

                    return;
                }
            }
        }

        // if we get here we didn't find the jump point
        log.debug(Verbose.GENERAL, "handleJumpTo: jump point was not found");
    }

    function handleKeypress(messageJson)
    {
        var key = messageJson.key.toLowerCase();
        log.debug(Verbose.GENERAL, "Looking for keypress: " + key);

        if (key === "back" || key === "escape")
            mythUtils.sendKeyEvent(window, Qt.Key_Escape);
        else if (key === "up")
            mythUtils.sendKeyEvent(window, Qt.Key_Up);
        else if (key === "down")
            mythUtils.sendKeyEvent(window, Qt.Key_Down);
        else if (key === "left")
            mythUtils.sendKeyEvent(window, Qt.Key_Left);
        else if (key === "right")
            mythUtils.sendKeyEvent(window, Qt.Key_Right);
        else if (key === "page up")
            mythUtils.sendKeyEvent(window, Qt.Key_PageUp);
        else if (key === "page down")
            mythUtils.sendKeyEvent(window, Qt.Key_PageDown);
        else if (key === "red")
            mythUtils.sendKeyEvent(window, Qt.Key_F1);
        else if (key === "green")
            mythUtils.sendKeyEvent(window, Qt.Key_F2);
        else if (key === "yellow")
            mythUtils.sendKeyEvent(window, Qt.Key_F3);
        else if (key === "blue")
            mythUtils.sendKeyEvent(window, Qt.Key_F4);
        else if (key ==="ok" || key === "select" || key === "return")
            mythUtils.sendKeyEvent(window, Qt.Key_Return);


    }

    function handleSearch(messageJson)
    {
        log.debug(Verbose.GENERAL, "handleSearch: " + messageJson);

        for (var x = stack.depth - 1; x >= 0 ; x--)
        {
            var screen = stack.get(x, StackView.DontLoad);

            if (screen)
            {
                if (screen.handleSearch(messageJson))
                    break;
            }
        }
    }

    function handleCommand(messageJson)
    {
        log.debug(Verbose.GENERAL, "handleCommand: " + messageJson);

        for (var x = stack.depth - 1; x >= 0 ; x--)
        {
            var screen = stack.get(x, StackView.DontLoad);

            if (screen)
            {
                if (screen.handleCommand(messageJson))
                    break;
            }
        }
    }

    function handleResult(messageJson)
    {
        log.debug(Verbose.GENERAL, "handleResult: " + messageJson);

        for (var x = stack.depth - 1; x >= 0 ; x--)
        {
            var screen = stack.get(x, StackView.DontLoad);

            if (screen)
            {
                if (screen.handleResult(messageJson))
                    break;
            }
        }
    }
}
