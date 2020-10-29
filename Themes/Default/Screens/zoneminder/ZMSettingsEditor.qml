import QtQuick 2.0
import Base 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: zmIPEdit

    Component.onCompleted:
    {
        showTitle(true, "ZoneMinder Settings");
        showTime(false);
        showTicker(false);
    }

    LabelText
    {
        x: xscale(50); y: yscale(100)
        text: "ZoneMinder Server IP:"
    }

    BaseEdit
    {
        id: zmIPEdit
        x: xscale(400); y: yscale(100)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.zmIP
        KeyNavigation.up: saveButton
        KeyNavigation.down: zmUserNameEdit
    }

    LabelText
    {
        x: xscale(50); y: yscale(150)
        text: "ZoneMinder User Name:"
    }

    BaseEdit
    {
        id: zmUserNameEdit
        x: xscale(400); y: yscale(150)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.zmUserName
        KeyNavigation.up: zmIPEdit;
        KeyNavigation.down: zmPasswordEdit;
    }

    LabelText
    {
        x: xscale(50); y: yscale(200)
        text: "ZoneMinder Password:"
    }

    BaseEdit
    {
        id: zmPasswordEdit
        x: xscale(400); y: yscale(200)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.zmPassword
        KeyNavigation.up: zmUserNameEdit;
        KeyNavigation.down: saveButton;
    }

    BaseButton
    {
        id: saveButton;
        x: parent.width - xscale(180); y: yscale(630);
        text: "Save";
        KeyNavigation.up: zmPasswordEdit
        KeyNavigation.down: zmIPEdit
        onClicked:
        {
            dbUtils.setSetting("ZmIP",         settings.hostName, zmIPEdit.text);
            dbUtils.setSetting("ZmUserName",   settings.hostName, zmUserNameEdit.text);
            dbUtils.setSetting("ZmPassword",   settings.hostName, zmPasswordEdit.text);

            settings.zmIP       = zmIPEdit.text;
            settings.zmUserName = zmUserNameEdit.text;
            settings.zmPassword = zmPasswordEdit.text;

            playerSources.zmSettingsChanged();

            returnSound.play();
            stack.pop();
        }
    }
}
