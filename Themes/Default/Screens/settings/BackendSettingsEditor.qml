import QtQuick 2.0
import Base 1.0
import Models 1.0
import Dialogs 1.0

BaseScreen
{
    defaultFocusItem: ipEdit

    Component.onCompleted:
    {
        showTitle(true, "MythTV Settings");
        showTime(true);
        showTicker(false);
        setHelp("https://mythqml.net/help/settings_mythbackend.php");
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

    // MythTV Backend Settings
    LabelText
    {
        x: xscale(30); y: yscale(100)
        text: "MythTV Master Backend IP:"
    }

    BaseEdit
    {
        id: ipEdit
        x: xscale(300); y: yscale(100)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.masterIP
        KeyNavigation.up: saveButton
        KeyNavigation.down: portEdit
    }

    LabelText
    {
        x: xscale(30); y: yscale(150)
        text: "MythTV Master Backend Port:"
    }

    BaseEdit
    {
        id: portEdit
        x: xscale(300); y: yscale(150)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.masterPort
        KeyNavigation.up: ipEdit
        KeyNavigation.down: pinEdit
    }

    //
    LabelText
    {
        x: xscale(30); y: yscale(200)
        text: "MythTV Security Pin:"
    }

    BaseEdit
    {
        id: pinEdit
        x: xscale(300); y: yscale(200)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.securityPin
        KeyNavigation.up: portEdit
        KeyNavigation.down: mysqlIPEdit
    }

    // Mysql Database Settings
    LabelText
    {
        x: xscale(30); y: yscale(270)
        text: "Mysql Database IP:"
    }

    BaseEdit
    {
        id: mysqlIPEdit
        x: xscale(300); y: yscale(270)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.mysqlIP
        KeyNavigation.up: pinEdit
        KeyNavigation.down: mysqlPortEdit
    }

    LabelText
    {
        x: xscale(30); y: yscale(320)
        text: "Mysql Port:"
    }

    BaseEdit
    {
        id: mysqlPortEdit
        x: xscale(300); y: yscale(320)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.mysqlPort
        KeyNavigation.up: mysqlIPEdit
        KeyNavigation.down: mysqlUserEdit
    }

    LabelText
    {
        x: xscale(30); y: yscale(370)
        text: "Mysql User Name:"
    }

    BaseEdit
    {
        id: mysqlUserEdit
        x: xscale(300); y: yscale(370)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.mysqlUser
        KeyNavigation.up: mysqlPortEdit
        KeyNavigation.down: mysqlPasswordEdit
    }

    LabelText
    {
        x: xscale(30); y: yscale(420)
        text: "Mysql Password:"
    }

    BaseEdit
    {
        id: mysqlPasswordEdit
        x: xscale(300); y: yscale(420)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.mysqlPassword
        KeyNavigation.up: mysqlUserEdit
        KeyNavigation.down: mysqlDBNameEdit
    }

    LabelText
    {
        x: xscale(30); y: yscale(470)
        text: "Mysql Database Name:"
    }

    BaseEdit
    {
        id: mysqlDBNameEdit
        x: xscale(300); y: yscale(470)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: settings.mysqlDBName
        KeyNavigation.up: mysqlPasswordEdit
        KeyNavigation.down: saveButton
    }

    BaseButton
    {
        id: saveButton;
        x: parent.width - width - xscale(50); y: yscale(600);
        text: "Save";
        KeyNavigation.up: mysqlDBNameEdit
        KeyNavigation.down: ipEdit
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

    OkCancelDialog
    {
        id: okDialog

        title: "Backend Settings"
        message: "NOTE: you will have to restart " + appName + " for the settings to take effect"
        rejectButtonText: ""
        acceptButtonText: "OK"

        width: xscale(600); height: yscale(300)

        onAccepted:
        {
            returnSound.play();
            stack.pop();

        }
        onCancelled:
        {
            returnSound.play();
            stack.pop();
        }
    }

    function save()
    {
        // master backend settings
        dbUtils.setSetting("MasterIP",    settings.hostName, ipEdit.text);
        dbUtils.setSetting("MasterPort",  settings.hostName, portEdit.text);
        dbUtils.setSetting("SecurityPin", settings.hostName, pinEdit.text);

        settings.masterIP    = ipEdit.text;
        settings.masterPort  = parseInt(portEdit.text);
        settings.securityPin = pinEdit.text;

        // mysql database settings
        dbUtils.setSetting("MysqlIP", settings.hostName, mysqlIPEdit.text);
        dbUtils.setSetting("MysqlPort", settings.hostName,mysqlPortEdit.text);
        dbUtils.setSetting("MysqlUser", settings.hostName, mysqlUserEdit.text);
        dbUtils.setSetting("MysqlPassword", settings.hostName, mysqlPasswordEdit.text);
        dbUtils.setSetting("MysqlDBName", settings.hostName, mysqlDBNameEdit.text);

        settings.MysqlIP       = mysqlIPEdit.text;
        settings.MysqlPort     = mysqlPortEdit.text;
        settings.MysqlUser     = mysqlUserEdit.text;
        settings.MysqlPassword = mysqlPasswordEdit.text;
        settings.MysqlDBName   = mysqlDBNameEdit.text;

        okDialog.show();
    }
}
