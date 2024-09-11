import QtQuick 2.0
import Base 1.0
import Models 1.0
import Dialogs 1.0

BaseScreen
{
    defaultFocusItem: energyDataDirEdit

    Component.onCompleted:
    {
        showTitle(true, "Data Sources Settings");
        setHelp("https://mythqml.net/help/settings_data_sources.php#top");
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
        text: "Energy Data Directory:"
    }

    BaseEdit
    {
        id: energyDataDirEdit
        x: xscale(300); y: yscale(100)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.energyDataDir
        KeyNavigation.up: saveButton
        KeyNavigation.down: bankingDataDirEdit
        KeyNavigation.right: energyDataDirButton
    }

    BaseButton
    {
        id: energyDataDirButton;
        x: parent.width - xscale(70)
        y: yscale(100);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: saveButton
        KeyNavigation.left: energyDataDirEdit
        KeyNavigation.down: bankingDataDirButton
        onClicked:
        {
            fileDialog.focusedButton = energyDataDirButton;
            fileDialog.show();
        }
    }

    LabelText
    {
        x: xscale(30); y: yscale(150)
        text: "Banking Data Directory:"
    }

    BaseEdit
    {
        id: bankingDataDirEdit
        x: xscale(300); y: yscale(150)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.bankingDataDir
        KeyNavigation.up: energyDataDirEdit
        KeyNavigation.down: saveButton
        KeyNavigation.right: bankingDataDirButton
    }

    BaseButton
    {
        id: bankingDataDirButton;
        x: parent.width - xscale(70)
        y: yscale(150);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: energyDataDirButton
        KeyNavigation.left: bankingDataDirEdit
        KeyNavigation.down: saveButton
        onClicked:
        {
            fileDialog.focusedButton = bankingDataDirButton;
            fileDialog.show();
        }
    }

    BaseButton
    {
        id: saveButton;
        x: parent.width - width - xscale(50); y: yscale(600);
        text: "Save";
        KeyNavigation.up: bankingDataDirEdit
        KeyNavigation.down: energyDataDirEdit
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
        property var focusedButton: undefined

        title: "Choose a directory"
        message: ""

        onAccepted:
        {
            focusedButton.focus = true;
        }
        onCancelled:
        {
            focusedButton.focus = true;
        }

        onItemSelected:
        {
            if (focusedButton === energyDataDirButton)
                energyDataDirEdit.text = itemText;
            else
                bankingDataDirEdit.text = itemText;

            focusedButton.focus = true;
        }
    }

    function save()
    {
        dbUtils.setSetting("EnergyDataDir",   settings.hostName, energyDataDirEdit.text);
        dbUtils.setSetting("BankingDataDir",  settings.hostName, bankingDataDirEdit.text);

        settings.energyDataDir = energyDataDirEdit.text;
        settings.bankingDataDir = bankingDataDirEdit.text;

        returnSound.play();
        stack.pop();
    }
}
