import QtQuick 2.0
import Base 1.0
import Models 1.0
import SqlQueryModel 1.0

BaseScreen
{
    defaultFocusItem: sourceList

    Component.onCompleted:
    {
        showTitle(true, "HDMI Sources Settings");
        setHelp("https://mythqml.net/help/settings_hdmisources.php#top");
        showTime(true);
        showTicker(false);
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            // RED - add
            dbUtils.addHDMISource(nameEdit.text, sourceParametersEdit.text)
            hdmiSourcesModel.reload();
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN - update
            dbUtils.updateHDMISource(hdmiSourcesModel.get(sourceList.currentIndex, "itemid"), nameEdit.text, sourceParametersEdit.text);
            hdmiSourcesModel.reload();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW - delete
            dbUtils.deleteHDMISource(hdmiSourcesModel.get(sourceList.currentIndex, "itemid"));
            hdmiSourcesModel.reload();
        }
        else if (event.key === Qt.Key_F4)
        {
            // BLUE - copy
        }
        else if (event.key === Qt.Key_H)
        {
            window.showHelp();
        }
        else
            event.accepted = false;
    }

    SqlQueryModel
    {
        id: hdmiSourcesModel

        sql: "SELECT itemid, name, parameters FROM hdmisources";

        database: "mythqml"

        onSqlChanged:
        {
            while (canFetchMore(index(-1, -1)))
                fetchMore(index(-1, -1));
        }
    }

    LabelText
    {
        x: xscale(20); y: yscale(50)
        text: "HDMI Sources:"
    }

    Component
    {
        id: listRow
        ListItem
        {
            ListText
            {
                x: xscale(5); y: 0
                text: name
            }
        }
    }

    Item
    {
        id: topGroup
        x: xscale(20); y: yscale(100); width: xscale(400); height: yscale(540)
        BaseBackground { anchors.fill: parent }
        ButtonList
        {
            id: sourceList;
            spacing: 3
            anchors.fill: parent;
            anchors.margins: xscale(10)
            model: hdmiSourcesModel
            delegate: listRow
            KeyNavigation.left: nameEdit
            KeyNavigation.right: nameEdit
            onCurrentIndexChanged:
            {
                nameEdit.text = hdmiSourcesModel.get(currentIndex, "name");
                sourceParametersEdit.text = hdmiSourcesModel.get(currentIndex, "parameters");
            }
        }
    }

    LabelText
    {
        x: xscale(460); y: yscale(50)
        text: "Name:"
    }

    BaseEdit
    {
        id: nameEdit
        x: xscale(460); y: yscale(100)
        width: xscale(500)
        height: yscale(50)
        text: settings.tivoIP
        KeyNavigation.up: saveButton
        KeyNavigation.down: sourceParametersEdit
        KeyNavigation.left: sourceList
        KeyNavigation.right: sourceList
    }

    LabelText
    {
        x: xscale(460); y: yscale(150)
        text: "Source Parameters:"
    }

    BaseMultilineEdit
    {
        id: sourceParametersEdit
        x: xscale(460); y: yscale(200)
        width: xscale(800)
        height: yscale(400)
        wrapMode: Text.NoWrap
        text: settings.tivoVideoSource
        KeyNavigation.up: nameEdit
        KeyNavigation.down: saveButton
        KeyNavigation.left: sourceList
        KeyNavigation.right: sourceList
    }

    BaseButton
    {
        id: saveButton;
        x: parent.width - width - xscale(50); y: yscale(615);
        text: "Save";
        KeyNavigation.up: sourceParametersEdit
        KeyNavigation.down: nameEdit
        onClicked: save()
    }

    Footer
    {
        id: footer
        redText: "Add"
        greenText: "Update"
        yellowText: "Delete"
        blueText: "Copy"
    }

    function save()
    {
        dbUtils.updateHDMISource(hdmiSourcesModel.get(sourceList.currentIndex, "itemid"), nameEdit.text, sourceParametersEdit.text);
        hdmiSourcesModel.reload();

        returnSound.play();
        stack.pop();
    }
}
