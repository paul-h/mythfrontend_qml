import QtQuick
import QtQuick.Controls
import Base 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: themeSelector

    Component.onCompleted:
    {
        showTitle(true, "Theme Settings");
        setHelp("https://mythqml.net/help/settings_themes.php#top");
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
        text: "Theme:"
    }

    ListModel
    {
        id: themeModel

        ListElement
        {
            itemText: "3DVillageAUTUMN"
        }
        ListElement
        {
            itemText: "3DVillageHALLOWEEN"
        }
        ListElement
        {
            itemText: "3DVillageXMAS"
        }
        ListElement
        {
            itemText: "MythCenter"
        }
        ListElement
        {
            itemText: "MythCenterNG"
        }
        ListElement
        {
            itemText: "MythCenterAUTUMN"
        }
        ListElement
        {
            itemText: "MythCenterEASTER"
        }
        ListElement
        {
            itemText: "MythCenterFIREPLACE"
        }
        ListElement
        {
            itemText: "MythCenterFIREWORKS"
        }
        ListElement
        {
            itemText: "MythCenterHALLOWEEN"
        }
        ListElement
        {
            itemText: "MythCenterXMAS"
        }
        ListElement
        {
            itemText: "SlideShowAUTUMN"
        }
        ListElement
        {
            itemText: "SlideShowFIREWORKS"
        }
        ListElement
        {
            itemText: "SlideShowHALLOWEEN"
        }
        ListElement
        {
            itemText: "SlideShowXMAS"
        }
    }

    BaseSelector
    {
        id: themeSelector
        x: xscale(400); y: yscale(100)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        showBackground: true
        pageCount: 5
        model: themeModel

        KeyNavigation.up: saveButton
        KeyNavigation.down: startFullscreenCheck

        Component.onCompleted: selectItem(settings.themeName)
    }

    LabelText
    {
        x: xscale(30); y: yscale(150)
        text: "Start Full screen:"
    }

    BaseCheckBox
    {
        id: startFullscreenCheck
        x: xscale(400); y: yscale(150)
        checked: settings.startFullscreen
        KeyNavigation.up: themeSelector
        KeyNavigation.down: mythQLayoutCheck
    }

    LabelText
    {
        x: xscale(30); y: yscale(200)
        text: "Use MythQ Menu Layout:"
    }

    BaseCheckBox
    {
        id: mythQLayoutCheck
        x: xscale(400); y: yscale(200)
        checked: settings.mythQLayout
        KeyNavigation.up: startFullscreenCheck
        KeyNavigation.down: saveButton
    }

    BaseButton
    {
        id: saveButton;
        x: parent.width - width - xscale(50); y: yscale(600);
        text: "Save";
        KeyNavigation.up: startFullscreenCheck
        KeyNavigation.down: themeSelector
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
        dbUtils.setSetting("Theme",           settings.hostName, themeModel.get(themeSelector.currentIndex).itemText);
        dbUtils.setSetting("StartFullScreen", settings.hostName, startFullscreenCheck.checked);
        dbUtils.setSetting("MythQLayout",      settings.hostName, mythQLayoutCheck.checked);

        settings.themeName       = themeModel.get(themeSelector.currentIndex).itemText;
        settings.startFullscreen = startFullscreenCheck.checked;
        settings.mythQLayout = mythQLayoutCheck.checked;

        // update the theme path and reload the theme
        settings.qmlPath = settings.sharePath + "qml/Themes/" + settings.themeName + "/";
        loadTheme();

        // since we can't control when a screen will get detroyed set a flag telling each screen not to restore any showing flags
        for (var x = stack.depth - 1; x >= 0 ; x--)
        {
            var screen = stack.get(x, StackView.DontLoad);

            if (screen)
                screen.reloadingTheme = true;
        }

        // force the stack to reload the main menu
        stack.clear();
        stack.createInitialItem();

        returnSound.play();
    }
}
