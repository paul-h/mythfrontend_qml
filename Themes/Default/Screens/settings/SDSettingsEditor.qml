import QtQuick 2.0
import Base 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: sdUserNameEdit

    Component.onCompleted:
    {
        showTitle(true, "Schedules Direct Settings");
        setHelp("https://mythqml.net/help/settings_schedule_direct.php#top");
        showTime(true);
        showTicker(false);
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            // RED - cancel
            returnSound.play();
            stack.pop();
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN - save
            save();
        }
        else if (event.key === Qt.Key_F4)
        {
            // BLUE - help
            window.showHelp();
        }
        else
            event.accepted = false;
    }

    LabelText
    {
        x: xscale(30); y: yscale(100)
        text: "SD User Name:"
    }

    BaseEdit
    {
        id: sdUserNameEdit
        x: xscale(300); y: yscale(100)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.sdUserName
        KeyNavigation.up: saveButton;
        KeyNavigation.down: sdPasswordEdit;
    }

    LabelText
    {
        x: xscale(30); y: yscale(150)
        text: "SD Password:"
    }

    BaseEdit
    {
        id: sdPasswordEdit
        x: xscale(300); y: yscale(150)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.sdPassword
        KeyNavigation.up: sdUserNameEdit;
        KeyNavigation.down: saveButton;
    }

    BaseButton
    {
        id: saveButton;
        x: parent.width - width - xscale(50); y: yscale(600);
        text: "Save";
        KeyNavigation.up: sdPasswordEdit
        KeyNavigation.down: sdUserNameEdit
        onClicked: save()
    }

    Footer
    {
        id: footer
        redText: "Cancel"
        greenText: "Save"
        yellowText: ""
        blueText: "Help"
    }

    function save()
    {
        dbUtils.setSetting("SdUserName",   settings.hostName, sdUserNameEdit.text);
        dbUtils.setSetting("SdPassword",   settings.hostName, sdPasswordEdit.text);

        settings.sdUserName = sdUserNameEdit.text;
        settings.sdPassword = sdPasswordEdit.text;

        returnSound.play();
        stack.pop();
    }
}
