import QtQuick 2.0
import Base 1.0
import Dialogs 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: menuSelector

    property int itemIndex: -1
    property var itemList: undefined
    property var defaults: {"menu": "", "position": 0, "menuText": "", "loaderSource": "", "waterMark": "", "url": "", "zoom": 1.0, "fullscreen": 0, "layout": 0, "exec": ""};
    Component.onCompleted:
    {
        setHelp("https://mythqml.net/help/settings_menu_editor.php#top");
        showTime(true);
        showTicker(false);

        if (itemIndex === -1)
        {
            // we are adding a new menu item
            showTitle(true, "Add Menu Item");
            menuSelector.selectItem(defaults.menu);
            positionEdit.text = defaults.position;
            menuTextEdit.text = defaults.menuText;
            loaderSourceEdit.text = defaults.loaderSource;
            waterMarkEdit.text = defaults.waterMark;
            urlEdit.text = defaults.url;
            zoomEdit.text = defaults.zoom;
            fullscreenCheck.checked = defaults.fullscreen === 'true' ;
            layoutEdit.text = defaults.layout
            execEdit.text = defaults.exec
        }
        else
        {
            // we are amending an existing menu item
            showTitle(true, "Edit Menu Item");
            menuSelector.selectItem(itemList.model.get(itemIndex).menu);
            positionEdit.text = itemList.model.get(itemIndex).position;
            menuTextEdit.text = itemList.model.get(itemIndex).menutext;
            loaderSourceEdit.text = itemList.model.get(itemIndex).loaderSource;
            waterMarkEdit.text = itemList.model.get(itemIndex).waterMark;
            urlEdit.text = itemList.model.get(itemIndex).url;
            zoomEdit.text = itemList.model.get(itemIndex).zoom;
            fullscreenCheck.checked = itemList.model.get(itemIndex).fullscreen === 'true';
            layoutEdit.text = itemList.model.get(itemIndex).layout;
            execEdit.text = itemList.model.get(itemIndex).exec;
        }
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
        else if (event.key === Qt.Key_F3)
        {

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
        x: xscale(30); y: yscale(60)
        text: "Menu:"
    }

    ListModel
    {
        id: menuModel

        ListElement
        {
            itemText: "web_browser"
        }
        ListElement
        {
            itemText: "home_assistant"
        }
    }

    BaseSelector
    {
        id: menuSelector
        x: xscale(300); y: yscale(53)
        width: xscale(400)
        height: yscale(50)
        model: menuModel
        KeyNavigation.up: saveButton
        KeyNavigation.down: positionEdit
    }

    LabelText
    {
        x: xscale(30); y: yscale(110)
        text: "Position:"
    }

    BaseEdit
    {
        id: positionEdit
        x: xscale(300); y: yscale(110)
        width: xscale(200)
        height: yscale(50)
        text: ""
        KeyNavigation.up: menuSelector;
        KeyNavigation.down: menuTextEdit;
    }

    LabelText
    {
        x: xscale(30); y: yscale(160)
        text: "Menu Text:"
    }

    BaseEdit
    {
        id: menuTextEdit
        x: xscale(300); y: yscale(160)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: ""
        KeyNavigation.up: positionEdit;
        KeyNavigation.down: loaderSourceEdit;
    }

    LabelText
    {
        x: xscale(30); y: yscale(210)
        text: "Loader Source:"
    }

    BaseEdit
    {
        id: loaderSourceEdit
        x: xscale(300); y: yscale(210)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: ""
        KeyNavigation.up: menuTextEdit;
        KeyNavigation.down: urlEdit;
    }

    LabelText
    {
        x: xscale(30); y: yscale(260)
        text: "Url:"
    }

    BaseEdit
    {
        id: urlEdit
        x: xscale(300); y: yscale(260)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: ""
        KeyNavigation.up: loaderSourceEdit;
        KeyNavigation.down: waterMarkEdit;
    }

    LabelText
    {
        x: xscale(30); y: yscale(310)
        text: "Watermark:"
    }

    BaseEdit
    {
        id: waterMarkEdit
        x: xscale(300); y: yscale(310)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: ""
        KeyNavigation.up: urlEdit;
        KeyNavigation.down: zoomEdit;
        onTextEdited: watermarkImage.source = mythUtils.findThemeFile(text)
    }

    LabelText
    {
        x: xscale(30); y: yscale(360)
        text: "Zoom:"
    }

    BaseEdit
    {
        id: zoomEdit
        x: xscale(300); y: yscale(360)
        width: xscale(200)
        height: yscale(50)
        text: ""
        KeyNavigation.up: waterMarkEdit;
        KeyNavigation.down: fullscreenCheck;
    }

    LabelText
    {
        x: xscale(30); y: yscale(410)
        text: "Fullscreen:"
    }

    BaseCheckBox
    {
        id: fullscreenCheck
        x: xscale(300); y: yscale(415)
        KeyNavigation.up: zoomEdit;
        KeyNavigation.down: layoutEdit;
    }

    LabelText
    {
        x: xscale(30); y: yscale(460)
        text: "Layout:"
    }

    BaseEdit
    {
        id: layoutEdit
        x: xscale(300); y: yscale(460)
        width: xscale(200)
        height: yscale(50)
        text: ""
        KeyNavigation.up: fullscreenCheck;
        KeyNavigation.down: execEdit;
    }

    LabelText
    {
        x: xscale(30); y: yscale(510)
        text: "Exec:"
    }

    BaseEdit
    {
        id: execEdit
        x: xscale(300); y: yscale(510)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: ""
        KeyNavigation.up: layoutEdit;
        KeyNavigation.down: saveButton;
    }

    Image
    {
        id: watermarkImage
        x: xscale(1055)
        y: yscale(360)
        width: xscale(150)
        height: yscale(150)
        source: ""
        asynchronous: true
    }

    BaseButton
    {
        id: saveButton;
        x: parent.width - width - xscale(50); y: yscale(600);
        text: "Save";
        KeyNavigation.up: execEdit
        KeyNavigation.down: menuSelector
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
        var menu = menuSelector.getSelected();
        var position = parseInt(positionEdit.text);
        var menuText = menuTextEdit.text;
        var loaderSource = loaderSourceEdit.text;
        var waterMark = waterMarkEdit.text;
        var url = urlEdit.text;
        var zoom = parseFloat(zoomEdit.text);
        var fullscreen = fullscreenCheck.checked;
        var layout = parseInt(layoutEdit.text);
        var exec = execEdit.text;

        if (itemIndex === -1)
        {
            // we need to add a new menu item
            var bookmarkid = dbUtils.addMenuItem(menu, position, menuText, loaderSource, waterMark, url, zoom, fullscreen, layout, exec);
            itemList.loadFromDB();
        }
        else
        {
            // we need to update a menu item
            dbUtils.updateMenuItem(itemList.model.get(itemIndex).itemid, menu, position, menuText, loaderSource, waterMark, url, zoom, fullscreen, layout, exec);
            itemList.loadFromDB();
        }

        returnSound.play();
        stack.pop();
    }
}
