import QtQuick 2.4
import QtMultimedia 5.4
import QtQuick.Controls 1.4
import QtQuick.XmlListModel 2.0
import QtWebSockets 1.0
import Process 1.0
import Base 1.0
import Screens 1.0
import "Models"

ApplicationWindow
{
    id: window
    visible: true
    visibility: settings.startFullscreen ? "FullScreen" : "Windowed"
    width: 1280
    height: 720

    property double wmult: width / 1280
    property double hmult: height / 720
    property alias theme: themeLoader.item

    // theme background video downloader
    Process
    {
        id: themeDLProcess
        onFinished:
        {
            if (exitStatus == Process.NormalExit)
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
            console.info("Received message: " + message)
        }
        onStatusChanged:
        {
            if (webSocket.status == WebSocket.Error)
            {
                console.info("Error: " + webSocket.errorString)
            }
            else if (webSocket.status == WebSocket.Connecting)
            {
                console.info("WebSocket: connecting");
            }
            else if (webSocket.status == WebSocket.Open)
            {
                console.info("WebSocket: Open");
                webSocket.sendTextMessage("WS_EVENT_ENABLE");
                webSocket.sendTextMessage("WS_EVENT_SET_FILTER LIVETV_CHAIN RECORDING_LIST_CHANGE UPDATE_FILE_SIZE SCHEDULE_CHANGE");
            }
            else if (webSocket.status == WebSocket.Closed)
            {
                console.info("Socket closed")
            }
        }

        active: true
    }

    // theme loader
    Loader
    {
        id: themeLoader
        source: settings.qmlPath + "Theme.qml"

        onLoaded:
        {
            if (theme.backgroundVideo != "")
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
        }
    }

    function showMouse(show)
    {
         if (show)
             mouseArea.cursorShape = Qt.Arrow
         else
             mouseArea.cursorShape = Qt.BlankCursor
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
    }
    SoundEffect
    {
         id: downSound
         source: mythUtils.findThemeFile("sounds/pock.wav");
    }
    SoundEffect
    {
         id: leftSound
         source: mythUtils.findThemeFile("sounds/pock.wav")
    }
    SoundEffect
    {
         id: rightSound
         source: mythUtils.findThemeFile("sounds/pock.wav")
    }
    SoundEffect
    {
         id: returnSound
         source: mythUtils.findThemeFile("sounds/poguck.wav")
    }
    SoundEffect
    {
         id: escapeSound
         source: mythUtils.findThemeFile("sounds/pock.wav")
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
        onTriggered: tickerProcess.start(settings.sharePath.replace("file://", "") + "/qml/Scripts/ticker-grabber.py", [settings.configPath + "/MythNews/ticker.xml"]);
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

    ScreenBackground
    {
        id: screenBackground
        showImage: true
        showVideo: false
        showTicker: true
        Component.onCompleted:
        {
            setTitle(true, "Main Menu");
            tickerProcess.start(settings.sharePath.replace("file://", "") + "/qml/Scripts/ticker-grabber.py", [settings.configPath + "/MythNews/ticker.xml"]);
        }
    }

    Loader
    {
        id: mainMenuLoader
        source: settings.menuPath + "MainMenu.qml"
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
                console.log("showTextBorder: " + settings.showTextBorder);
            }
            else if (event.key === Qt.Key_F10)
            {
                if (stack.depth > 1) {stack.pop(); escapeSound.play();} else Qt.quit();
            }
        }
    }

    MouseArea
    {
        id: mouseArea
        anchors.fill: parent
        enabled: false
        cursorShape: Qt.BlankCursor
    }
}
