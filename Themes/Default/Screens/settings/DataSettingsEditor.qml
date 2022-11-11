import QtQuick 2.0
import Base 1.0
import Models 1.0

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
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.energyDataDirectory
        KeyNavigation.up: saveButton
        KeyNavigation.down: saveButton
    }

    BaseButton
    {
        id: saveButton;
        x: parent.width - width - xscale(50); y: yscale(600);
        text: "Save";
        KeyNavigation.up: energyDataDirEdit
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

    function save()
    {
        dbUtils.setSetting("EnergyDataDir",   settings.hostName, energyDataDirEdit.text);

        settings.energyDataDir = energyDataDirEdit.text;

        returnSound.play();
        stack.pop();
    }
}
