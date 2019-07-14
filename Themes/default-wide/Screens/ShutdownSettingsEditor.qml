import QtQuick 2.0
import Base 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: idleTimeEdit

    Component.onCompleted:
    {
        showTitle(true, "Shutdown Settings");
        showTime(false);
        showTicker(false);
    }

    LabelText
    {
        x: xscale(50); y: yscale(100)
        text: "Idle Time (seconds):"
    }

    BaseEdit
    {
        id: idleTimeEdit
        x: xscale(400); y: yscale(100)
        width: xscale(700)
        height: yscale(50)
        text: settings.idleTime
        KeyNavigation.up: saveButton
        KeyNavigation.down: rebootCmdEdit
    }

    LabelText
    {
        x: xscale(50); y: yscale(150)
        text: "Reboot Command:"
    }

    BaseEdit
    {
        id: rebootCmdEdit
        x: xscale(400); y: yscale(150)
        width: xscale(700)
        height: yscale(50)
        text: settings.rebootCommand
        KeyNavigation.up: idleTimeEdit;
        KeyNavigation.down: shutdownCmdEdit;
    }

    LabelText
    {
        x: xscale(50); y: yscale(200)
        text: "Shutdown Command:"
    }

    BaseEdit
    {
        id: shutdownCmdEdit
        x: xscale(400); y: yscale(200)
        width: xscale(700)
        height: yscale(50)
        text: settings.shutdownCommand
        KeyNavigation.up: rebootCmdEdit;
        KeyNavigation.down: saveButton;
    }

    BaseButton
    {
        id: saveButton;
        x: xscale(900); y: yscale(630);
        text: "Save";
        KeyNavigation.up: shutdownCmdEdit
        KeyNavigation.down: idleTimeEdit
        onClicked:
        {
            dbUtils.setSetting("Qml_idleTime",        settings.hostName, idleTimeEdit.text);
            dbUtils.setSetting("Qml_rebootCommand",   settings.hostName, rebootCmdEdit.text);
            dbUtils.setSetting("Qml_shutdownCommand", settings.hostName, shutdownCmdEdit.text);

            settings.idleTime        = idleTimeEdit.text;
            settings.rebootCommand   = rebootCmdEdit.text;
            settings.shutdownCommand = shutdownCmdEdit.text;

            returnSound.play();
            stack.pop();
        }
    }
}
