import QtQuick 2.0
import Base 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: tivoIPEdit

    Component.onCompleted:
    {
        showTitle(true, "Tivo Settings");
        setHelp("https://mythqml.net/help/settings_tivo.php#top");
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
        text: "Tivo IP:"
    }

    BaseEdit
    {
        id: tivoIPEdit
        x: xscale(300); y: yscale(100)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.tivoIP
        KeyNavigation.up: saveButton
        KeyNavigation.down: tivoPortEdit
    }

    LabelText
    {
        x: xscale(30); y: yscale(150)
        text: "Tivo Port:"
    }

    BaseEdit
    {
        id: tivoPortEdit
        x: xscale(300); y: yscale(150)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.tivoControlPort
        KeyNavigation.up: tivoIPEdit;
        KeyNavigation.down: tivoVideoURLEdit;
    }

    LabelText
    {
        x: xscale(30); y: yscale(200)
        text: "Tivo Video URL:"
    }

    BaseEdit
    {
        id: tivoVideoURLEdit
        x: xscale(300); y: yscale(200)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.tivoVideoURL
        KeyNavigation.up: tivoPortEdit;
        KeyNavigation.down: saveButton;
    }

    BaseButton
    {
        id: saveButton;
        x: parent.width - width - xscale(50); y: yscale(600);
        text: "Save";
        KeyNavigation.up: tivoVideoURLEdit
        KeyNavigation.down: tivoIPEdit
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
        dbUtils.setSetting("TivoIP",          settings.hostName, tivoIPEdit.text);
        dbUtils.setSetting("TivoControlPort", settings.hostName, tivoPortEdit.text);
        dbUtils.setSetting("TivoVideoURL",    settings.hostName, tivoVideoURLEdit.text);

        settings.tivoIP       = tivoIPEdit.text;
        settings.tivoPort     = tivoPortEdit.text;
        settings.tivoVideoURL = tivoVideoURLEdit.text;

        //playerSources.zmSettingsChanged();

        returnSound.play();
        stack.pop();
    }
}
