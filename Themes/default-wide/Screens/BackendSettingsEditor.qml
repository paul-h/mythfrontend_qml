import QtQuick 2.0
import Base 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: ipEdit

    Component.onCompleted:
    {
        showTitle(true, "Backend Settings");
        showTime(false);
        showTicker(false);
    }

    LabelText
    {
        x: xscale(50); y: yscale(100)
        text: "Master Backend IP:"
    }

    BaseEdit
    {
        id: ipEdit
        x: xscale(400); y: yscale(100)
        width: xscale(700)
        height: yscale(50)
        text: settings.masterIP
        KeyNavigation.up: saveButton
        KeyNavigation.down: portEdit
    }

    LabelText
    {
        x: xscale(50); y: yscale(150)
        text: "Master Backend Port:"
    }

    BaseEdit
    {
        id: portEdit
        x: xscale(400); y: yscale(150)
        width: xscale(700)
        height: yscale(50)
        text: settings.masterPort
        KeyNavigation.up: ipEdit
        KeyNavigation.down: pinEdit
    }

    //
    LabelText
    {
        x: xscale(50); y: yscale(200)
        text: "Security Pin:"
    }

    BaseEdit
    {
        id: pinEdit
        x: xscale(400); y: yscale(200)
        width: xscale(700)
        height: yscale(50)
        text: settings.securityPin
        KeyNavigation.up: portEdit
        KeyNavigation.down: saveButton
    }

    BaseButton
    {
        id: saveButton;
        x: xscale(900); y: yscale(630);
        text: "Save";
        KeyNavigation.up: pinEdit
        KeyNavigation.down: ipEdit
        onClicked:
        {
            dbUtils.setSetting("Qml_masterIP",    settings.hostName, ipEdit.text);
            dbUtils.setSetting("Qml_masterPort",  settings.hostName, portEdit.text);
            dbUtils.setSetting("Qml_securityPin", settings.hostName, pinEdit.text);

            settings.masterIP    = ipEdit.text;
            settings.masterPort  = parseInt(portEdit.text);
            settings.securityPin = pinEdit.text;

            returnSound.play();
            stack.pop();
        }
    }
}
