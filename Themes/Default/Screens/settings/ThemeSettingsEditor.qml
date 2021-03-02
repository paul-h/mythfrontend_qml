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
        x: parent.width - width - xscale(50); y: yscale(630);
        text: "Save";
        KeyNavigation.up: startFullscreenCheck
        KeyNavigation.down: themeSelector
        onClicked:
        {
            dbUtils.setSetting("Theme",           settings.hostName, themeModel.get(themeSelector.currentIndex).itemText);
            dbUtils.setSetting("StartFullScreen", settings.hostName, startFullscreenCheck.checked);
            dbUtils.setSetting("MythQLayout",      settings.hostName, mythQLayoutCheck.checked);

            screenBackground.pauseVideo(true);

            // force a full restart of the app
            Qt.exit(1000);
        }
    }
}
