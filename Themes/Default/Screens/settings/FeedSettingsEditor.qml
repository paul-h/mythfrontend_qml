import QtQuick 2.0
import Base 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: videoPathEdit

    Component.onCompleted:
    {
        showTitle(true, "Feed Source Settings");
        setHelp("https://mythqml.net/help/settings_feedsources.php");
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
        text: "Video Path:"
    }

    BaseEdit
    {
        id: videoPathEdit
        x: xscale(300); y: yscale(100)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.videoPath
        KeyNavigation.up: saveButton
        KeyNavigation.right: videoPathButton
        KeyNavigation.down: picturePathEdit
    }

    BaseButton
    {
        id: videoPathButton;
        x: parent.width - xscale(70); y: yscale(100);
        width: yscale(50); height: yscale(50)
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
        x: xscale(30); y: yscale(150)
        text: "Picture Path:"
    }

    BaseEdit
    {
        id: picturePathEdit
        x: xscale(300); y: yscale(150)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.picturePath
        KeyNavigation.up: videoPathEdit
        KeyNavigation.right: picturePathButton
        KeyNavigation.down: sdChannelsEdit
    }

    BaseButton
    {
        id: picturePathButton;
        x: parent.width - xscale(70); y: yscale(150);
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
        x: xscale(30); y: yscale(200)
        text: "SD Channels File:"
    }

    BaseEdit
    {
        id: sdChannelsEdit
        x: xscale(300); y: yscale(200)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.sdChannels
        KeyNavigation.up: picturePathEdit
        KeyNavigation.right: sdChannelsButton
        KeyNavigation.down: vboxFreeviewIPEdit
    }

    BaseButton
    {
        id: sdChannelsButton;
        x: parent.width - xscale(70); y: yscale(200);
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
        x: xscale(30); y: yscale(250)
        text: "VBox Freeview IP:"
    }

    BaseEdit
    {
        id: vboxFreeviewIPEdit
        x: xscale(300); y: yscale(250)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.vboxFreeviewIP
        KeyNavigation.up: sdChannelsEdit
        KeyNavigation.down: vboxFreesatIPEdit
    }

    LabelText
    {
        x: xscale(30); y: yscale(300)
        text: "VBox Freesat IP:"
    }

    BaseEdit
    {
        id: vboxFreesatIPEdit
        x: xscale(300); y: yscale(300)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.vboxFreesatIP
        KeyNavigation.up: vboxFreeviewIPEdit
        KeyNavigation.down: hdmiEncoderEdit
    }

    LabelText
    {
        x: xscale(30); y: yscale(350)
        text: "HDMI Encoder:"
    }

    BaseEdit
    {
        id: hdmiEncoderEdit
        x: xscale(300); y: yscale(350)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.hdmiEncoder
        KeyNavigation.up: vboxFreesatIPEdit
        KeyNavigation.down: webcamListFileEdit
    }

    LabelText
    {
        x: xscale(30); y: yscale(400)
        text: "Webcam List File:"
    }

    BaseEdit
    {
        id: webcamListFileEdit
        x: xscale(300); y: yscale(400)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.webcamListFile
        KeyNavigation.up: hdmiEncoderEdit
        KeyNavigation.right: webcamListFileButton
        KeyNavigation.down: webvideoListFileEdit
    }

    BaseButton
    {
        id: webcamListFileButton;
        x: parent.width - xscale(70); y: yscale(400);
        width: xscale(50); height: yscale(50)
        text: "X";
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
        x: xscale(30); y: yscale(450)
        text: "Webvideo List File:"
    }

    BaseEdit
    {
        id: webvideoListFileEdit
        x: xscale(300); y: yscale(450)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.webvideoListFile
        KeyNavigation.up: webcamListFileEdit
        KeyNavigation.right: webvideoListFileButton
        KeyNavigation.down: youtubeSubListFileEdit
    }

    BaseButton
    {
        id: webvideoListFileButton;
        x: parent.width - xscale(70); y: yscale(450);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: webcamListFileButton
        KeyNavigation.left: webvideoListFileEdit
        KeyNavigation.down: youtubeSubListFileButton
        onClicked:
        {
            // TODO show directory finder popup
        }
    }

    LabelText
    {
        x: xscale(30); y: yscale(500)
        text: "YouTube Subscripitions List:"
    }

    BaseEdit
    {
        id: youtubeSubListFileEdit
        x: xscale(300); y: yscale(500)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.youtubeSubListFile
        KeyNavigation.up: webvideoListFileEdit
        KeyNavigation.right: youtubeSubListFileButton
        KeyNavigation.down: youtubeAPIKeyEdit
    }

    BaseButton
    {
        id: youtubeSubListFileButton;
        x: parent.width - xscale(70); y: yscale(500);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: webvideoListFileButton
        KeyNavigation.left: youtubeSubListFileEdit
        KeyNavigation.down: youtubeAPIKeyButton
        onClicked:
        {
            // TODO show directory finder popup
        }
    }

    LabelText
    {
        x: xscale(30); y: yscale(550)
        text: "YouTube API Key:"
    }

    BaseEdit
    {
        id: youtubeAPIKeyEdit
        x: xscale(300); y: yscale(550)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: settings.youtubeAPIKey
        KeyNavigation.up: youtubeSubListFileEdit
        KeyNavigation.right: youtubeAPIKeyButton
        KeyNavigation.down: saveButton
    }

    BaseButton
    {
        id: youtubeAPIKeyButton;
        x: parent.width - xscale(70); y: yscale(550);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: youtubeSubListFileButton
        KeyNavigation.left: youtubeAPIKeyEdit
        KeyNavigation.down: saveButton
        onClicked:
        {
            // TODO Youtube API sign up page in web browser
        }
    }

    BaseButton
    {
        id: saveButton;
        x: parent.width - width - xscale(50); y: yscale(620);
        text: "Save";
        KeyNavigation.up: youtubeAPIKeyEdit
        KeyNavigation.down: videoPathEdit
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
        dbUtils.setSetting("VideoPath",          settings.hostName, videoPathEdit.text);
        dbUtils.setSetting("PicturePath",        settings.hostName, picturePathEdit.text);
        dbUtils.setSetting("SdChannels",         settings.hostName, sdChannelsEdit.text);
        dbUtils.setSetting("VboxFreeviewIP",     settings.hostName, vboxFreeviewIPEdit.text);
        dbUtils.setSetting("VboxFreesatIP",      settings.hostName, vboxFreesatIPEdit.text);
        dbUtils.setSetting("HdmiEncoder",        settings.hostName, hdmiEncoderEdit.text);
        dbUtils.setSetting("WebcamListFile",     settings.hostName, webcamListFileEdit.text);
        dbUtils.setSetting("WebvideoListFile",   settings.hostName, webvideoListFileEdit.text);
        dbUtils.setSetting("YoutubeSubListFile", settings.hostName, youtubeSubListFileEdit.text);
        dbUtils.setSetting("YoutubeAPIKey",      settings.hostName, youtubeAPIKeyEdit.text);

        settings.videoPath          = videoPathEdit.text;
        settings.picturePath        = picturePathEdit.text;
        settings.sdChannels         = sdChannelsEdit.text;
        settings.vboxFreeviewIP     = vboxFreeviewIPEdit.text;
        settings.vboxFreesatIP      = vboxFreesatIPEdit.text;
        settings.hdmiEncoder        = hdmiEncoderEdit.text;
        settings.webcamListFile     = webcamListFileEdit.text;
        settings.webvideoListFile   = webvideoListFileEdit.text;
        settings.youtubeSubListFile = youtubeSubListFileEdit.text;
        settings.youtubeAPIKey      = youtubeAPIKeyEdit.text;

        returnSound.play();
        stack.pop();
    }
}
