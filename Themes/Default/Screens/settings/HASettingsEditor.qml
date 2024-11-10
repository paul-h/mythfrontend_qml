import QtQuick 2.0
import Base 1.0
import Models 1.0
import Dialogs 1.0

BaseScreen
{
    defaultFocusItem: haUrlEdit

    Component.onCompleted:
    {
        showTitle(true, "Home Assistant Settings");
        setHelp("https://mythqml.net/help/settings_home_assistant.php#top");
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
        text: "HA URL:"
    }

    BaseEdit
    {
        id: haUrlEdit
        x: xscale(300); y: yscale(100)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.haURL
        KeyNavigation.up: saveButton;
        KeyNavigation.down: haAPITokenEdit;
    }

    LabelText
    {
        x: xscale(30); y: yscale(150)
        text: "API Token:"
    }

    BaseEdit
    {
        id: haAPITokenEdit
        x: xscale(300); y: yscale(150)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.haAPIToken
        KeyNavigation.up: haUrlEdit;
        KeyNavigation.down: haMenuFileEdit;
    }

    LabelText
    {
        x: xscale(30); y: yscale(200)
        text: "Menu File Location:"
    }

    BaseEdit
    {
        id: haMenuFileEdit
        x: xscale(300); y: yscale(200)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.haMenuFile
        KeyNavigation.up: haAPITokenEdit;
        KeyNavigation.down: saveButton;
        KeyNavigation.right: haMenuFileButton;
    }

    BaseButton
    {
        id: haMenuFileButton;
        x: parent.width - xscale(70)
        y: yscale(200);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: haAPITokenEdit
        KeyNavigation.left: haMenuFileEdit
        KeyNavigation.down: saveButton
        onClicked:
        {
            //TODO should show the current location in the dialog
            fileDialog.show();
        }
    }

    BaseButton
    {
        id: saveButton;
        x: parent.width - width - xscale(50); y: yscale(600);
        text: "Save";
        KeyNavigation.up: haMenuFileEdit
        KeyNavigation.down: haUrlEdit
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

    FileDirectoryDialog
    {
        id: fileDialog

        property bool searchWebsites: true
        title: "Choose a menu file"
        message: ""

        onAccepted:
        {
            haMenuFileButton.focus = true;
        }
        onCancelled:
        {
            haMenuFileButton.focus = true;
        }

        onItemSelected:
        {
            haMenuFileEdit.text = itemText;
            haMenuFileButton.focus = true;
        }
    }

    function save()
    {
        dbUtils.setSetting("HAURL",      settings.hostName, haUrlEdit.text);
        dbUtils.setSetting("HAAPIToken", settings.hostName, haAPITokenEdit.text);
        dbUtils.setSetting("HAMenuFile", settings.hostName, haMenuFileEdit.text);

        settings.haURL = haUrlEdit.text;
        settings.haAPIToken = haAPITokenEdit.text;
        settings.haMenuFile = haMenuFileEdit.text;

        returnSound.play();
        stack.pop();
    }
}
