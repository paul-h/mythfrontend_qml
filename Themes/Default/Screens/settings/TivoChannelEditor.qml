import QtQuick

import Base 1.0
import Dialogs 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: chanNoEdit

    property int channelIndex: -1
    property var channelList: undefined

    Component.onCompleted:
    {
        setHelp("https://mythqml.net/help/settings_tivo_channel_editor.php#top");
        showTime(true);
        showTicker(false);

        channelChanged();
    }

    Keys.onPressed: event =>
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
        else if (event.key === Qt.Key_F3)
        {
            listModel.clear();

            for (var x = 0; x < virginChannels.model.count; x++)
            {
                var chan = virginChannels.model.get(x);
                listModel.append({"item": chan.channelNumber + "~" + chan.title + "~" + chan.id});
            }

            searchDialog.model = listModel;
            searchDialog.field = "Channel Number";
            searchDialog.show();
        }
        else if (event.key === Qt.Key_F4)
        {
            // BLUE - help
            window.showHelp();
        }
        else if (event.key === Qt.Key_F5)
        {
            if (channelIndex > 0)
                channelIndex--;
            else
                channelIndex = channelList.count - 1;

            channelChanged();
        }
        else if (event.key === Qt.Key_F6)
        {
            if (channelIndex < channelList.count - 1)
                channelIndex++;
            else
                channelIndex = 0;

            channelChanged();
        }

        else
            event.accepted = false;
    }

    JSONListModel
    {
        id: virginChannels
        //source: "https://prod.oesp.virginmedia.com/oesp/v4/GB/eng/web/channels"
        source: "https://spark-prod-gb.gnp.cloud.virgintvgo.virginmedia.com/eng/web/linear-service/v2/channels?cityId=40967&language=en&productClass=Orion-DASH&platform=web"
        query: "$.channels[*]"
    }

    SDChannelsModel
    {
        id: sdChannelsModel
    }

    ListModel
    {
        id: listModel
    }

    LabelText
    {
        x: xscale(30); y: yscale(100)
        text: "Channel No:"
    }

    BaseEdit
    {
        id: chanNoEdit
        x: xscale(300); y: yscale(100)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: ""
        KeyNavigation.up: saveButton
        KeyNavigation.down: nameEdit
        KeyNavigation.right: chanNoButton;
    }

    BaseButton
    {
        id: chanNoButton;
        x: parent.width - xscale(70)
        y: yscale(100);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: saveButton
        KeyNavigation.left: chanNoEdit
        KeyNavigation.down: nameButton
        onClicked: showSearch("Channel Number")
    }

    LabelText
    {
        x: xscale(30); y: yscale(150)
        text: "Name:"
    }

    BaseEdit
    {
        id: nameEdit
        x: xscale(300); y: yscale(150)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: ""
        KeyNavigation.up: chanNoEdit;
        KeyNavigation.down: plus1Edit;
        KeyNavigation.right: nameButton;
    }

    BaseButton
    {
        id: nameButton;
        x: parent.width - xscale(70)
        y: yscale(150);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: chanNoButton
        KeyNavigation.left: nameEdit
        KeyNavigation.down: plus1Button
        onClicked: showSearch("Channel Name")
    }

    LabelText
    {
        x: xscale(30); y: yscale(200)
        text: "Plus 1:"
    }

    BaseEdit
    {
        id: plus1Edit
        x: xscale(300); y: yscale(200)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: ""
        KeyNavigation.up: nameEdit
        KeyNavigation.down: categoryEdit
        KeyNavigation.right: plus1Button
    }

    BaseButton
    {
        id: plus1Button;
        x: parent.width - xscale(70)
        y: yscale(200);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: nameButton
        KeyNavigation.left: plus1Edit
        KeyNavigation.down: categoryButton
        onClicked: showSearch("Plus 1 Channel Number")
    }

    LabelText
    {
        x: xscale(30); y: yscale(250)
        text: "Category:"
    }

    BaseEdit
    {
        id: categoryEdit
        x: xscale(300); y: yscale(250)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: ""
        KeyNavigation.up: plus1Edit;
        KeyNavigation.down: definitionEdit;
        KeyNavigation.right: categoryButton;
    }

    BaseButton
    {
        id: categoryButton;
        x: parent.width - xscale(70)
        y: yscale(250);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: plus1Button
        KeyNavigation.left: categoryEdit
        KeyNavigation.down: definitionButton
        onClicked: showSearch("Category")
    }

    LabelText
    {
        x: xscale(30); y: yscale(300)
        text: "Definition:"
    }

    BaseEdit
    {
        id: definitionEdit
        x: xscale(300); y: yscale(300)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: ""
        KeyNavigation.up: categoryEdit;
        KeyNavigation.down: sdidEdit;
        KeyNavigation.right: definitionButton;

    }

    BaseButton
    {
        id: definitionButton;
        x: parent.width - xscale(70)
        y: yscale(300);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: categoryButton
        KeyNavigation.left: definitionEdit
        KeyNavigation.down: sdidButton
        onClicked: showSearch("Definition")
    }

    LabelText
    {
        x: xscale(30); y: yscale(350)
        text: "SD ID:"
    }

    BaseEdit
    {
        id: sdidEdit
        x: xscale(300); y: yscale(350)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: ""
        KeyNavigation.up: definitionEdit;
        KeyNavigation.down: iconUrlEdit;
        KeyNavigation.right: sdidButton;
    }

    BaseButton
    {
        id: sdidButton;
        x: parent.width - xscale(70)
        y: yscale(350);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: definitionButton
        KeyNavigation.left: sdidEdit
        KeyNavigation.down: iconUrlButton
        onClicked: showSearch("Schedule Direct ID")
    }

    LabelText
    {
        x: xscale(30); y: yscale(400)
        text: "Icon URL:"
    }

    BaseEdit
    {
        id: iconUrlEdit
        x: xscale(300); y: yscale(400)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: ""
        KeyNavigation.up: sdidEdit;
        KeyNavigation.down: saveButton;
        KeyNavigation.right: iconUrlButton;

    }

    BaseButton
    {
        id: iconUrlButton;
        x: parent.width - xscale(70)
        y: yscale(400);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: sdidButton
        KeyNavigation.left: iconUrlEdit
        KeyNavigation.down: saveButton
        onClicked: showSearch("Icon")
    }

    Image
    {
        id: iconImage
        x: xscale(300)
        y: yscale(470)
        width: xscale(100)
        height: yscale(100)
        source: iconUrlEdit.text
        asynchronous: true
    }

    BaseButton
    {
        id: saveButton;
        x: parent.width - width - xscale(50); y: yscale(600);
        text: "Save";
        KeyNavigation.up: iconUrlEdit
        KeyNavigation.down: chanNoEdit
        onClicked: save()
    }

    Footer
    {
        id: footer
        redText: "Cancel"
        greenText: "Save"
        yellowText: "Test"
        blueText: "Help"
    }

    SearchListDialog
    {
        id: searchDialog

        property string field: ""

        title: "Choose a " + field
        message: ""

        onAccepted:
        {
            saveResult(true, "");
        }
        onCancelled:
        {
            saveResult(false, "")
        }

        onItemSelected:
        {
            saveResult(true, itemText)
        }

        function saveResult(accepted, result)
        {
            var parts;

            if (field === "Channel Number")
            {
                chanNoButton.focus = true;
                if (accepted)
                {
                    parts = result.split("~")
                    chanNoEdit.text = parts[0];
                }
            }
            else if (field === "Channel Name")
            {
                nameButton.focus = true;
                if (accepted)
                {
                    parts = result.split("~")
                    nameEdit.text = parts[1];
                }
            }
            else if (field === "Plus 1 Channel Number")
            {
                plus1Button.focus = true;
                if (accepted)
                {
                    parts = result.split("~")
                    plus1Edit.text = parts[0];
                }
            }
            else if (field === "Category")
            {
                categoryButton.focus = true;
                if (accepted)
                    categoryEdit.text = result;
            }
            else if (field === "Definition")
            {
                definitionButton.focus = true;
                if (accepted)
                    definitionEdit.text = result;
            }
            else if (field === "Schedule Direct ID")
            {
                sdidButton.focus = true;
                if (accepted)
                {
                    parts = result.split("~")
                    sdidEdit.text = parts[2];
                }

            }
            else if (field === "Icon")
            {
                iconUrlButton.focus = true;
                if (accepted)
                    if (accepted)
                    {
                        parts = result.split("~")
                        iconUrlEdit.text = parts[2];
                    }
            }
        }
    }

    function showSearch(field)
    {
        var selectedItem = ""

        if (field == "Channel Number")
        {
            listModel.clear();

            for (var x = 0; x < sdChannelsModel.model.count; x++)
            {
                var chan = sdChannelsModel.model.get(x);
                listModel.append({"item": chan.channo + "~" + chan.name});
            }

            searchDialog.model = listModel;
            selectedItem = chanNoEdit.text;
        }
        else if (field == "Channel Name")
        {
            listModel.clear();

            for (var x = 0; x < sdChannelsModel.model.count; x++)
            {
                var chan = sdChannelsModel.model.get(x);
                listModel.append({"item": chan.channo + "~" + chan.name});
            }

            searchDialog.model = listModel;
            selectedItem = nameEdit.text;
        }
        else if (field == "Plus 1 Channel Number")
        {
            listModel.clear();

            for (var x = 0; x < sdChannelsModel.model.count; x++)
            {
                var chan = sdChannelsModel.model.get(x);
                listModel.append({"item": chan.channo + "~" + chan.name});
            }

            searchDialog.model = listModel;
            selectedItem = plus1Edit.text;
        }
        else if (field == "Category")
        {
            searchDialog.model = channelList.categoryList;
            selectedItem = categoryEdit.text;
        }
        else if (field == "Definition")
        {
            searchDialog.model = channelList.definitionList;
            selectedItem = definitionEdit.text;
        }
        else if (field == "Schedule Direct ID")
        {
            listModel.clear();

            for (var x = 0; x < sdChannelsModel.model.count; x++)
            {
                var chan = sdChannelsModel.model.get(x);
                listModel.append({"item": chan.channo + "~" + chan.name + "~" + chan.sdid});
                selectedItem = sdidEdit.text;
            }

            searchDialog.model = listModel;
        }
        else if (field == "Icon")
        {
            listModel.clear();

            for (var x = 0; x < sdChannelsModel.model.count; x++)
            {
                var chan = sdChannelsModel.model.get(x);
                listModel.append({"item": chan.channo + "~" + chan.name + "~" + chan.icon});
                selectedItem = iconUrlEdit.text;
            }

            searchDialog.model = listModel;
        }
        else
            return;

        searchDialog.field = field;
        searchDialog.showSelected(selectedItem);
    }

    function channelChanged()
    {
        if (channelIndex === -1)
        {
            // we are adding a new tivo channel
            showTitle(true, "Add Tivo Channel");
            channelNoEdit.text = "";
            plus1Edit.text = "";
            categoryEdit.text = "";
            definitionEdit.text = "";
            SDIDEdit.text = "";
            iconUrlEdit.text = ""
        }
        else
        {
            // we are amending an existing tivo channel
            showTitle(true, "Edit Tivo Channel");
            chanNoEdit.text = channelList.model.get(channelIndex).channo;
            nameEdit.text = channelList.model.get(channelIndex).name;
            plus1Edit.text = channelList.model.get(channelIndex).plus1;
            categoryEdit.text = channelList.model.get(channelIndex).category;
            definitionEdit.text = channelList.model.get(channelIndex).definition;
            sdidEdit.text = channelList.model.get(channelIndex).sdid;
            iconUrlEdit.text = channelList.model.get(channelIndex).icon;

            checkChannel();
        }
    }

    function checkChannel()
    {
        var chanNo = channelList.model.get(channelIndex).channo;
        var name = channelList.model.get(channelIndex).name;
        var plus1 = channelList.model.get(channelIndex).plus1;
        var category = channelList.model.get(channelIndex).category;
        var definition = channelList.model.get(channelIndex).definition;
        var sdid = channelList.model.get(channelIndex).sdid;
        var iconUrl = channelList.model.get(channelIndex).icon;
        var found = false;

        // check with Virgin channel
        for (var x = 0; x < virginChannels.model.count; x++)
        {
            var chan = virginChannels.model.get(x);
            if (chanNo == chan.channelNumber)
            {
                if (name != chan.title)
                    showNotification("Virgin: Channel Name is different - '" + chan.title + "'", settings.osdTimeoutMedium);

                found = true;
                break;
            }
        }

        if (!found)
        {
            showNotification("Virgin: Channel not found", settings.osdTimeoutMedium);
            return;
        }

        // check with SD channel


    }

    function save()
    {
        if (channelIndex === -1)
        {
            // we need to add a new tivo channel
            var channelid = dbUtils.addTivoChannel(chanNoEdit.text, nameEdit.text, plus1Edit.text, categoryEdit.text, definitionEdit.text, sdidEdit.text, iconUrlEdit.text);
            channelList.loadFromDB();
        }
        else
        {
            // we need to update a tivo channel
            dbUtils.updateTivoChannel(channelList.model.get(channelIndex).chanid, chanNoEdit.text, nameEdit.text, plus1Edit.text, categoryEdit.text, definitionEdit.text, sdidEdit.text, iconUrlEdit.text);
            channelList.loadFromDB();
        }

        returnSound.play();
        stack.pop();
    }
}
