import QtQuick

import Base 1.0
import mythqml.net 1.0

MainWindow
{
    id: launcherWindow

    mainMenu: "LauncherMenu.qml"
    helpURL: "https://mythqml.net/help/launcher.php";
    showWhatsNew: false
    exitOnEscape: false
    shutdownOnIdle: true
    showVideoBackground: false
    playStartupEffect: false
    showZMAlerts: false
    needPlayerSources: false

    property string showFrontend: ""

    idleTime: settings.launcherIdleTime

    Component.onCompleted:
    {
        delay(2000, checkAutoStart);
    }

    function checkAutoStart()
    {
        log.info(Verbose.GENERAL, "MainWindow: Checking to see if we need to auto start a frontend");

        var frontend = showFrontend === "" ? settings.autoStartFrontend : showFrontend;
        frontend = frontend.toLowerCase();

        if (frontend === "qml" || frontend === "qml_frontend")
        {
            var message = "Starting QML Frontend.\nPlease Wait...";
            var timeOut = settings.osdTimeoutMedium;
            showBusyDialog(message, timeOut);
            runCommand("mythfrontend_qml", []);
        }
        else if (frontend === "legacy")
        {
            var message = "Starting Old Frontend.\nPlease Wait...";
            var timeOut = settings.osdTimeoutMedium;
            showBusyDialog(message, timeOut);
            runCommand("mythfrontend", []);
        }
        else if (frontend === "kodi")
        {
            var message = "Starting KODI.\nPlease Wait...";
            var timeOut = settings.osdTimeoutMedium;
            showBusyDialog(message, timeOut);
            runCommand("kodi", []);
        }
        else if (frontend === "netflix")
        {
            var url = "https://www.netflix.com/browse";
            var zoom = 1.0;
            var fullscreen = true;

            stack.push(mythUtils.findThemeFile("Screens/WebBrowser.qml"), {url: url, fullscreen: fullscreen, zoomFactor: zoom});
        }
        else if (frontend === "pluto")
        {
            var url = "https://pluto.tv/live-tv/";
            var zoom = 1.0;
            var fullscreen = true;

            stack.push(mythUtils.findThemeFile("Screens/WebBrowser.qml"), {url: url, fullscreen: fullscreen, zoomFactor: zoom});
        }
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
}
