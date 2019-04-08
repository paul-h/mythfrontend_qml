import QtQuick 2.0
import Base 1.0
import "../../../Models"

BaseScreen
{
    defaultFocusItem: masterBEEdit

    Component.onCompleted:
    {
        showTitle(true, "General Settings");
        showTime(false);
        showTicker(false);
    }

    LabelText
    {
        x: xscale(50); y: yscale(100)
        text: "Master Backend IP:"
    }

    BaseEdit
    {
        id: masterBEEdit
        x: xscale(400); y: yscale(100)
        width: xscale(700)
        height: yscale(50)
        text: settings.masterBackend
        KeyNavigation.up: saveButton
        KeyNavigation.down: videoPathEdit
    }

    LabelText
    {
        x: xscale(50); y: yscale(150)
        text: "Video Path:"
    }

    BaseEdit
    {
        id: videoPathEdit
        x: xscale(400); y: yscale(150)
        width: xscale(700)
        height: yscale(50)
        text: settings.videoPath
        KeyNavigation.up: masterBEEdit;
        KeyNavigation.right: videoPathButton
        KeyNavigation.down: picturePathEdit;
    }

    BaseButton
    {
        id: videoPathButton;
        x: xscale(1120); y: yscale(150);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: masterBEEdit
        KeyNavigation.left: videoPathEdit
        KeyNavigation.down: picturePathEdit;
        onClicked:
        {
            // TODO show directory finder popup
        }
    }

    //
    LabelText
    {
        x: xscale(50); y: yscale(200)
        text: "Picture Path:"
    }

    BaseEdit
    {
        id: picturePathEdit
        x: xscale(400); y: yscale(200)
        width: xscale(700)
        height: yscale(50)
        text: settings.picturePath
        KeyNavigation.up: videoPathEdit;
        KeyNavigation.right: picturePathButton
        KeyNavigation.down: sdChannelsEdit;
    }

    BaseButton
    {
        id: picturePathButton;
        x: xscale(1120); y: yscale(200);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: videoPathEdit
        KeyNavigation.left: picturePathEdit
        KeyNavigation.down: sdChannelsEdit;
        onClicked:
        {
            // TODO show directory finder popup
        }
    }

    LabelText
    {
        x: xscale(50); y: yscale(250)
        text: "SD Channels File:"
    }

    BaseEdit
    {
        id: sdChannelsEdit
        x: xscale(400); y: yscale(250)
        width: xscale(700)
        height: yscale(50)
        text: settings.sdChannels
        KeyNavigation.up: picturePathEdit;
        KeyNavigation.right: sdChannelsButton
        KeyNavigation.down: vboxFreeviewIPEdit;
    }

    BaseButton
    {
        id: sdChannelsButton;
        x: xscale(1120); y: yscale(250);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: picturePathEdit
        KeyNavigation.left: sdChannelsEdit
        KeyNavigation.down: vboxFreeviewIPEdit;
        onClicked:
        {
            // TODO show directory finder popup
        }
    }

    LabelText
    {
        x: xscale(50); y: yscale(300)
        text: "VBox Freeview IP:"
    }

    BaseEdit
    {
        id: vboxFreeviewIPEdit
        x: xscale(400); y: yscale(300)
        width: xscale(700)
        height: yscale(50)
        text: settings.vboxFreeviewIP
        KeyNavigation.up: sdChannelsEdit;
        KeyNavigation.down: vboxFreesatIPEdit;
    }

    LabelText
    {
        x: xscale(50); y: yscale(350)
        text: "VBox Freesat IP:"
    }

    BaseEdit
    {
        id: vboxFreesatIPEdit
        x: xscale(400); y: yscale(350)
        width: xscale(700)
        height: yscale(50)
        text: settings.vboxFreesatIP
        KeyNavigation.up: vboxFreeviewIPEdit;
        KeyNavigation.down: hdmiEncoderEdit;
    }

    LabelText
    {
        x: xscale(50); y: yscale(400)
        text: "HDMI Encoder:"
    }

    BaseEdit
    {
        id: hdmiEncoderEdit
        x: xscale(400); y: yscale(400)
        width: xscale(700)
        height: yscale(50)
        text: settings.hdmiEncoder
        KeyNavigation.up: vboxFreesatIPEdit;
        KeyNavigation.down: themeSelector;
    }

    LabelText
    {
        x: xscale(50); y: yscale(450)
        text: "Theme:"
    }

        ListModel
    {
        id: themeModel

        ListElement
        {
            itemText: "MythCenter-wide"
        }
        ListElement
        {
            itemText: "MythCenterAUTUMN-wide"
        }
        ListElement
        {
            itemText: "MythCenterEASTER-wide"
        }
        ListElement
        {
            itemText: "MythCenterFIREWORKS-wide"
        }
        ListElement
        {
            itemText: "MythCenterHALLOWEEN-wide"
        }
        ListElement
        {
            itemText: "MythCenterXMAS-wide"
        }
    }

    BaseSelector
    {
        id: themeSelector
        x: xscale(400); y: yscale(450)
        width: xscale(700)
        height: yscale(50)
        showBackground: true
        pageCount: 5
        model: themeModel

        KeyNavigation.up: hdmiEncoderEdit;
        KeyNavigation.down: startFullscreenCheck;

        Component.onCompleted: selectItem(settings.themeName)
    }

    LabelText
    {
        x: xscale(50); y: yscale(500)
        text: "Start Full screen:"
    }

    BaseCheckBox
    {
        id: startFullscreenCheck
        x: xscale(400); y: yscale(500)
        checked: settings.startFullscreen
        KeyNavigation.up: themeSelector;
        KeyNavigation.down: webcamPathEdit;
    }

    //
    LabelText
    {
        x: xscale(50); y: yscale(550)
        text: "Webcam Path:"
    }

    BaseEdit
    {
        id: webcamPathEdit
        x: xscale(400); y: yscale(550)
        width: xscale(700)
        height: yscale(50)
        text: settings.webcamPath
        KeyNavigation.up: startFullscreenCheck;
        KeyNavigation.right: webcamPathButton
        KeyNavigation.down: saveButton;
    }

    BaseButton
    {
        id: webcamPathButton;
        x: xscale(1120); y: yscale(550);
        width: xscale(50); height: yscale(50)
        text: "";
        KeyNavigation.up: startFullscreenCheck
        KeyNavigation.left: webcamPathEdit
        KeyNavigation.down: saveButton;
        onClicked:
        {
            // TODO show directory finder popup
        }
    }

    BaseButton
    {
        id: saveButton;
        x: xscale(900); y: yscale(630);
        text: "Save";
        KeyNavigation.up: webcamPathEdit
        KeyNavigation.down: masterBEEdit
        onClicked:
        {
            console.log("save button pressed");
            dbUtils.setSetting("Qml_masterBackend",   settings.hostName, masterBEEdit.text);
            dbUtils.setSetting("Qml_videoPath    ",   settings.hostName, videoPathEdit.text);
            dbUtils.setSetting("Qml_picturePath",     settings.hostName, picturePathEdit.text);
            dbUtils.setSetting("Qml_sdChannels",      settings.hostName, sdChannelsEdit.text);
            dbUtils.setSetting("Qml_vboxFreeviewIP",  settings.hostName, vboxFreeviewIPEdit.text);
            dbUtils.setSetting("Qml_vboxFreesatIP",   settings.hostName, vboxFreesatIPEdit.text);
            dbUtils.setSetting("Qml_hdmiEncoder",     settings.hostName, hdmiEncoderEdit.text);
            dbUtils.setSetting("Qml_theme",           settings.hostName, themeModel.get(themeSelector.currentIndex).itemText);
            dbUtils.setSetting("Qml_startFullScreen", settings.hostName, startFullscreenCheck.checked);
            dbUtils.setSetting("Qml_webcamPath",      settings.hostName, webcamPathEdit.text);

            settings.masterBackend   = masterBEEdit.text;
            settings.videoPath       = videoPathEdit.text;
            settings.picturePath     = picturePathEdit.text;
            settings.sdChannels      = sdChannelsEdit.text;
            settings.vboxFreeviewIP  = vboxFreeviewIPEdit.text;
            settings.vboxFreesatIP   = vboxFreesatIPEdit.text;
            settings.hdmiEncoder     = hdmiEncoderEdit.text;
            settings.themeName       = themeModel.get(themeSelector.currentIndex).itemText;
            settings.startFullscreen = startFullscreenCheck.checked;
            settings.webcamPath      = webcamPathEdit.text;

            // update the theme path and reload the theme
            settings.qmlPath = settings.sharePath + "qml/Themes/" + settings.themeName + "/";
            themeLoader.source = settings.qmlPath + "Theme.qml";
            screenBackground.setVideo("file://" + theme.backgroundVideo);

            returnSound.play();
            stack.pop();
        }
    }
}
