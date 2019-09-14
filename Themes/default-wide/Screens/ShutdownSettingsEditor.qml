import QtQuick 2.0
import Base 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: frontendIdleTimeEdit

    Component.onCompleted:
    {
        showTitle(true, "Shutdown Settings");
        showTime(false);
        showTicker(false);
    }

    LabelText
    {
        x: xscale(50); y: yscale(100)
        width: xscale(340)
        text: "Frontend Idle Time (minutes):"
    }

    BaseEdit
    {
        id: frontendIdleTimeEdit
        x: xscale(400); y: yscale(100)
        width: xscale(700)
        height: yscale(50)
        text: settings.frontendIdleTime
        KeyNavigation.up: saveButton
        KeyNavigation.down: launcherIdleTimeEdit
    }

    LabelText
    {
        x: xscale(50); y: yscale(150)
        width: xscale(340)
        text: "Launcher Idle Time (minutes):"
    }

    BaseEdit
    {
        id: launcherIdleTimeEdit
        x: xscale(400); y: yscale(150)
        width: xscale(700)
        height: yscale(50)
        text: settings.launcherIdleTime
        KeyNavigation.up: frontendIdleTimeEdit
        KeyNavigation.down: rebootCmdEdit
    }

    LabelText
    {
        x: xscale(50); y: yscale(200)
        width: xscale(340)
        text: "Reboot Command:"
    }

    BaseEdit
    {
        id: rebootCmdEdit
        x: xscale(400); y: yscale(200)
        width: xscale(700)
        height: yscale(50)
        text: settings.rebootCommand
        KeyNavigation.up: launcherIdleTimeEdit
        KeyNavigation.down: shutdownCmdEdit
    }

    LabelText
    {
        x: xscale(50); y: yscale(250)
        width: xscale(340)
        text: "Shutdown Command:"
    }

    BaseEdit
    {
        id: shutdownCmdEdit
        x: xscale(400); y: yscale(250)
        width: xscale(700)
        height: yscale(50)
        text: settings.shutdownCommand
        KeyNavigation.up: rebootCmdEdit
        KeyNavigation.down: saveButton
    }

    BaseButton
    {
        id: saveButton;
        x: xscale(900); y: yscale(630);
        text: "Save";
        KeyNavigation.up: shutdownCmdEdit
        KeyNavigation.down: frontendIdleTimeEdit
        onClicked:
        {
            dbUtils.setSetting("Qml_frontendIdleTime", settings.hostName, frontendIdleTimeEdit.text);
            dbUtils.setSetting("Qml_launcherIdleTime", settings.hostName, launcherIdleTimeEdit.text);
            dbUtils.setSetting("Qml_rebootCommand",   settings.hostName, rebootCmdEdit.text);
            dbUtils.setSetting("Qml_shutdownCommand", settings.hostName, shutdownCmdEdit.text);

            settings.frontendIdleTime = frontendIdleTimeEdit.text;
            settings.launcherIdleTime = launcherIdleTimeEdit.text;
            settings.rebootCommand   = rebootCmdEdit.text;
            settings.shutdownCommand = shutdownCmdEdit.text;

            // guess which idleTime we need to use
            window.idleTime = (window.shutdownOnIdle ? settings.launcherIdleTime : settings.frontendIdleTime);

            returnSound.play();
            stack.pop();
        }
    }
}
