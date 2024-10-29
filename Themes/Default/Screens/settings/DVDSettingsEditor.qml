import QtQuick
import Base 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: dvdCommandEdit

    Component.onCompleted:
    {
        showTitle(true, "DVD Settings");
        setHelp("https://mythqml.net/help/settings_dvd.php#top");
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
        text: "Command:"
    }

    BaseEdit
    {
        id: dvdCommandEdit
        x: xscale(300); y: yscale(100)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.dvdCommand
        KeyNavigation.up: saveButton;
        KeyNavigation.down: dvdParametersEdit;
    }

    LabelText
    {
        x: xscale(30); y: yscale(150)
        text: "Parameters:"
    }

    BaseEdit
    {
        id: dvdParametersEdit
        x: xscale(300); y: yscale(150)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.dvdParameters
        KeyNavigation.up: dvdCommandEdit;
        KeyNavigation.down: saveButton;
    }

    BaseButton
    {
        id: saveButton;
        x: parent.width - width - xscale(50); y: yscale(600);
        text: "Save";
        KeyNavigation.up: dvdParametersEdit
        KeyNavigation.down: dvdCommandEdit
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
        dbUtils.setSetting("DvdCommand",    settings.hostName, dvdCommandEdit.text);
        dbUtils.setSetting("DvdParameters", settings.hostName, dvdParametersEdit.text);

        settings.dvdCommand = dvdCommandEdit.text;
        settings.dvdParameters = dvdParametersEdit.text;

        returnSound.play();
        stack.pop();
    }
}
