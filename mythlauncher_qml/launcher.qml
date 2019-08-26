import QtQuick 2.4
import Base 1.0

MainWindow
{
    id: window

    mainMenu: "LauncherMenu.qml"

    Component.onCompleted:
    {
        delay(1000, checkAutoStart);
    }

    function checkAutoStart()
    {
        console.log("Checking to see if we need to auto start a frontend");

        if (settings.autoStartFrontend === "QML_Frontend")
        {
            var message = "Starting QML Frontend.\nPlease Wait...";
            var timeOut = settings.osdTimeoutMedium;
            showBusyDialog(message, timeOut);
            runCommand("mythfrontend_qml", []);
        }
        else if (settings.autoStartFrontend === "Legacy_Frontend")
        {
            var message = "Starting Old Frontend.\nPlease Wait...";
            var timeOut = settings.osdTimeoutMedium;
            showBusyDialog(message, timeOut);
            runCommand("mythfrontend", []);
        }
        else if (settings.autoStartFrontend === "KODI")
        {
            var message = "Starting KODI.\nPlease Wait...";
            var timeOut = settings.osdTimeoutMedium;
            showBusyDialog(message, timeOut);
            runCommand("kodi", []);
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