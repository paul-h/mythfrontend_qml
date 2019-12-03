import QtQuick 2.0
import Base 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: videoPathEdit

    Component.onCompleted:
    {
        showTitle(true, "Feed Source Settings");
        showTime(false);
        showTicker(false);
    }

    LabelText
    {
        x: xscale(50); y: yscale(100)
        text: "Video Path:"
    }

    BaseEdit
    {
        id: videoPathEdit
        x: xscale(400); y: yscale(100)
        width: xscale(700)
        height: yscale(50)
        text: settings.videoPath
        KeyNavigation.up: saveButton
        KeyNavigation.right: videoPathButton
        KeyNavigation.down: picturePathEdit
    }

    BaseButton
    {
        id: videoPathButton;
        x: xscale(1120); y: yscale(100);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: saveButton
        KeyNavigation.left: videoPathEdit
        KeyNavigation.down: picturePathEdit
        onClicked:
        {
            // TODO show directory finder popup
        }
    }

    //
    LabelText
    {
        x: xscale(50); y: yscale(150)
        text: "Picture Path:"
    }

    BaseEdit
    {
        id: picturePathEdit
        x: xscale(400); y: yscale(150)
        width: xscale(700)
        height: yscale(50)
        text: settings.picturePath
        KeyNavigation.up: videoPathEdit
        KeyNavigation.right: picturePathButton
        KeyNavigation.down: sdChannelsEdit
    }

    BaseButton
    {
        id: picturePathButton;
        x: xscale(1120); y: yscale(150);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: videoPathEdit
        KeyNavigation.left: picturePathEdit
        KeyNavigation.down: sdChannelsEdit
        onClicked:
        {
            // TODO show directory finder popup
        }
    }

    LabelText
    {
        x: xscale(50); y: yscale(200)
        text: "SD Channels File:"
    }

    BaseEdit
    {
        id: sdChannelsEdit
        x: xscale(400); y: yscale(200)
        width: xscale(700)
        height: yscale(50)
        text: settings.sdChannels
        KeyNavigation.up: picturePathEdit
        KeyNavigation.right: sdChannelsButton
        KeyNavigation.down: vboxFreeviewIPEdit
    }

    BaseButton
    {
        id: sdChannelsButton;
        x: xscale(1120); y: yscale(200);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: picturePathEdit
        KeyNavigation.left: sdChannelsEdit
        KeyNavigation.down: vboxFreeviewIPEdit
        onClicked:
        {
            // TODO show directory finder popup
        }
    }

    LabelText
    {
        x: xscale(50); y: yscale(250)
        text: "VBox Freeview IP:"
    }

    BaseEdit
    {
        id: vboxFreeviewIPEdit
        x: xscale(400); y: yscale(250)
        width: xscale(700)
        height: yscale(50)
        text: settings.vboxFreeviewIP
        KeyNavigation.up: sdChannelsEdit
        KeyNavigation.down: vboxFreesatIPEdit
    }

    LabelText
    {
        x: xscale(50); y: yscale(300)
        text: "VBox Freesat IP:"
    }

    BaseEdit
    {
        id: vboxFreesatIPEdit
        x: xscale(400); y: yscale(300)
        width: xscale(700)
        height: yscale(50)
        text: settings.vboxFreesatIP
        KeyNavigation.up: vboxFreeviewIPEdit
        KeyNavigation.down: hdmiEncoderEdit
    }

    LabelText
    {
        x: xscale(50); y: yscale(350)
        text: "HDMI Encoder:"
    }

    BaseEdit
    {
        id: hdmiEncoderEdit
        x: xscale(400); y: yscale(350)
        width: xscale(700)
        height: yscale(50)
        text: settings.hdmiEncoder
        KeyNavigation.up: vboxFreesatIPEdit
        KeyNavigation.down: webcamListFileEdit
    }

    LabelText
    {
        x: xscale(50); y: yscale(400)
        text: "Webcam List File:"
    }

    BaseEdit
    {
        id: webcamListFileEdit
        x: xscale(400); y: yscale(400)
        width: xscale(700)
        height: yscale(50)
        text: settings.webcamListFile
        KeyNavigation.up: hdmiEncoderEdit
        KeyNavigation.right: webcamListFileButton
        KeyNavigation.down: webvideoListFileEdit
    }

    BaseButton
    {
        id: webcamListFileButton;
        x: xscale(1120); y: yscale(400);
        width: xscale(50); height: yscale(50)
        text: "";
        KeyNavigation.up: hdmiEncoderEdit
        KeyNavigation.left: webcamListFileEdit
        KeyNavigation.down: webvideoListFileButton
        onClicked:
        {
            // TODO show directory finder popup
        }
    }

    LabelText
    {
        x: xscale(50); y: yscale(450)
        text: "Webvideo List File:"
    }

    BaseEdit
    {
        id: webvideoListFileEdit
        x: xscale(400); y: yscale(450)
        width: xscale(700)
        height: yscale(50)
        text: settings.webvideoListFile
        KeyNavigation.up: webcamListFileEdit
        KeyNavigation.right: webvideoListFileButton
        KeyNavigation.down: saveButton
    }

    BaseButton
    {
        id: webvideoListFileButton;
        x: xscale(1120); y: yscale(450);
        width: xscale(50); height: yscale(50)
        text: "";
        KeyNavigation.up: webcamListFileButton
        KeyNavigation.left: webvideoListFileEdit
        KeyNavigation.down: saveButton
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
        KeyNavigation.up: webvideoListFileEdit
        KeyNavigation.down: videoPathEdit
        onClicked:
        {
            dbUtils.setSetting("VideoPath",        settings.hostName, videoPathEdit.text);
            dbUtils.setSetting("PicturePath",      settings.hostName, picturePathEdit.text);
            dbUtils.setSetting("SdChannels",       settings.hostName, sdChannelsEdit.text);
            dbUtils.setSetting("VboxFreeviewIP",   settings.hostName, vboxFreeviewIPEdit.text);
            dbUtils.setSetting("VboxFreesatIP",    settings.hostName, vboxFreesatIPEdit.text);
            dbUtils.setSetting("HdmiEncoder",      settings.hostName, hdmiEncoderEdit.text);
            dbUtils.setSetting("WebcamListFile",   settings.hostName, webcamListFileEdit.text);
            dbUtils.setSetting("WebvideoListFile", settings.hostName, webvideoListFileEdit.text);

            settings.videoPath        = videoPathEdit.text;
            settings.picturePath      = picturePathEdit.text;
            settings.sdChannels       = sdChannelsEdit.text;
            settings.vboxFreeviewIP   = vboxFreeviewIPEdit.text;
            settings.vboxFreesatIP    = vboxFreesatIPEdit.text;
            settings.hdmiEncoder      = hdmiEncoderEdit.text;
            settings.webcamListFile   = webcamListFileEdit.text;
            settings.webvideoListFile = webvideoListFileEdit.text;

            returnSound.play();
            stack.pop();
        }
    }
}
