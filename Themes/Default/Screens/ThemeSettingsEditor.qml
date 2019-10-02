import QtQuick 2.0
import Base 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: themeSelector

    Component.onCompleted:
    {
        showTitle(true, "Theme Settings");
        showTime(false);
        showTicker(false);
    }

    LabelText
    {
        x: xscale(50); y: yscale(100)
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
            itemText: "MythCenter"
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
    }

    BaseSelector
    {
        id: themeSelector
        x: xscale(400); y: yscale(100)
        width: xscale(700)
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
        x: xscale(50); y: yscale(150)
        text: "Start Full screen:"
    }

    BaseCheckBox
    {
        id: startFullscreenCheck
        x: xscale(400); y: yscale(150)
        checked: settings.startFullscreen
        KeyNavigation.up: themeSelector
        KeyNavigation.down: saveButton
    }

    BaseButton
    {
        id: saveButton;
        x: xscale(900); y: yscale(630);
        text: "Save";
        KeyNavigation.up: startFullscreenCheck
        KeyNavigation.down: themeSelector
        onClicked:
        {
            dbUtils.setSetting("Qml_theme",           settings.hostName, themeModel.get(themeSelector.currentIndex).itemText);
            dbUtils.setSetting("Qml_startFullScreen", settings.hostName, startFullscreenCheck.checked);

            settings.themeName       = themeModel.get(themeSelector.currentIndex).itemText;
            settings.startFullscreen = startFullscreenCheck.checked;

            // update the theme path and reload the theme
            settings.qmlPath = settings.sharePath + "qml/Themes/" + settings.themeName + "/";

            window.theme = loadTheme();
            screenBackground.setVideo("file://" + settings.configPath + "Themes/Videos/" + theme.backgroundVideo);

            // force the stack to reload the main menu
            stack.clear();
            stack.initialItem = null
            stack.push({item: Qt.resolvedUrl("ThemedMenu.qml"), properties:{model: mainMenuLoader.item}});

            returnSound.play();
            stack.pop();
        }
    }
}
