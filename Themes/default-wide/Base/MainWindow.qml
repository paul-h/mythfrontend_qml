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

    property alias playerSources: playerSourcesLoader.item;

    Component.onCompleted:
    {
        eventListener.listenTo(window)

        soundEffectsVolume = dbUtils.getSetting("Qml_soundEffectsVolume", settings.hostName, "1.0");
        backgroundVideoVolume = dbUtils.getSetting("Qml_backgroundVideoVolume", settings.hostName, "1.0");
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

    // theme background video downloader
    Process
    {
        id: themeDLProcess
        onFinished:
        {
            if (exitStatus === Process.NormalExit)
            {
                screenBackground.showVideo = true;
                screenBackground.setVideo("file://" + theme.backgroundVideo);
                screenBackground.showImage = false;
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

    // feeds loader
    Loader
    {
        id: playerSourcesLoader
        source: settings.sharePath + "qml/Models/PlayerSourcesModel.qml"
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
            preventStealing: true
            propagateComposedEvents: true

            onShowMouseChanged: if (showMouse) cursorShape = Qt.ArrowCursor; else cursorShape = Qt.BlankCursor;
            onAutoHideChanged: mouseTimer.stop();

            onClicked: mouse.accepted = false;
            onPressed: mouse.accepted = false;
            onReleased: mouse.accepted = false;
            onDoubleClicked: mouse.accepted = false;
            onPressAndHold: mouse.accepted = false
        }

        StackView
        {
            id: stack
            width: parent.width; height: parent.height
            initialItem: ThemedMenu {model: mainMenuLoader.item}
            focus: true

            onCurrentItemChanged:
            {
                if (currentItem)
                {
                    currentItem.defaultFocusItem.focus = true
                }
            }

            Keys.onPressed:
            {
                if (event.key === Qt.Key_F)
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

            if (theme.backgroundVideo !== "")
            {
                if (theme.needsDownload && !mythUtils.fileExists(theme.backgroundVideo))
                {
                    screenBackground.showVideo = false;
                    screenBackground.showImage = true;
                    themeDLProcess.start(theme.downloadCommand, theme.downloadOptions);
                }
                else
                {
                    screenBackground.showVideo = true;
                    screenBackground.showImage = false;
                }
            }
            else
            {
                screenBackground.showVideo = false;
                screenBackground.showImage = true;
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
        interval: 3000; running: false; repeat: true
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
            filename = settings.configPath + "snapshots/snapshot";

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

    function checkWhatsNew()
    {
        var lastShownIndex = parseInt(dbUtils.getSetting("Qml_lastWhatsNewShown", settings.hostName, -1)) + 1;

        if (lastShownIndex < whatsNewModel.count)
        {
            messageSound.play();
            stack.push({item: mythUtils.findThemeFile("Screens/WhatsNew.qml"), properties:{currentPage:  lastShownIndex}});
        }
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
