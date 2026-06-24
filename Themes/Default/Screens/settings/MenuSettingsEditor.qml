import QtQuick 2.0
import Base 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: list

    Component.onCompleted:
    {
        showTitle(true, "Menu Editor");
        setHelp("https://mythqml.net/help/settings_menu_editor.php#top");
        showTime(true);
        showTicker(false);

        list.currentIndex = 0;
    }

    Keys.onPressed:
    {
        event.accepted = true;

        var defaults;

        if (event.key === Qt.Key_F1 || event.key === Qt.Key_A)
        {
            // RED - add item
            defaults = {"menu": "Home Assistant", "position": menuItems.count + 1, "menuText": "", "loaderSource": "WebBrowser.qml", "waterMark": "watermark/home_assistant.svg", "url": "", "zoom": 1.0, "fullscreen": 0, "layout": 0, "exec": ""};
            stack.push({item: mythUtils.findThemeFile("Screens/settings/MenuItemEditor.qml"), properties:{itemIndex: -1, itemList: menuItems, defaults: defaults}});
        }
        else if (event.key === Qt.Key_F2 || event.key === Qt.Key_D)
        {
            // GREEN - remove item
            dbUtils.deleteMenuItem(itemId);
        }
        else if (event.key === Qt.Key_F3 || event.key === Qt.Key_E)
        {
            // YELLOW - amend item
            stack.push({item: mythUtils.findThemeFile("Screens/settings/MenuItemEditor.qml"), properties:{itemIndex: list.currentIndex, itemList: menuItems}});
        }
        else if (event.key === Qt.Key_F4)
        {
            // BLUE - copy item
            defaults = {"menu": menuItems.get(list.currentIndex).menu, "position": menuItems.count + 1, "menuText": menuItems.get(list.currentIndex).menutext, "loaderSource": menuItems.get(list.currentIndex).loaderSource,
                        "waterMark": menuItems.get(list.currentIndex).waterMark, "url": menuItems.get(list.currentIndex).url, "zoom": menuItems.get(list.currentIndex).zoom, "fullscreen": menuItems.get(list.currentIndex).fullscreen,
                        "layout": menuItems.get(list.currentIndex).layzout, "exec": menuItems.get(list.currentIndex).exec};
            stack.push({item: mythUtils.findThemeFile("Screens/settings/MenuItemEditor.qml"), properties:{itemIndex: -1, itemList: menuItems, defaults: defaults}});
        }
        else
            event.accepted = false;
    }

    MenuItemModel
    {
        id: menuItems
        property string logo: ""
        property string title: ""
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
        x: xscale(40); y: yscale(65)
        width: xscale(500)
        height: yscale(50)
        showBackground: true
        pageCount: 5
        model: menuModel

        KeyNavigation.up: list
        KeyNavigation.down: list

        Component.onCompleted: selectItem(1)

        onItemSelected: {console.log("item selected: " + index); menuItems.menu = menuModel.get(index).itemText}
        onItemClicked: {console.log("item clicked: " + index); menuItems.menu = menuModel.get(index).itemText}
    }

    Component
    {
        id: listRow
        ListItem
        {
            Image
            {
                id: icon
                x: xscale(3); y: yscale(3); height: parent.height - yscale(6); width: height
                source: mythUtils.findThemeFile(waterMark)
            }
            ListText
            {
                x: xscale(70); y: 0
                text: position + " - " + menutext
            }
            ListText
            {
                x: xscale(500); y: 0
                text: menu
            }
            ListText
            {
                x: xscale(900); y: 0
                text: loaderSource
            }
        }
    }

    Item
    {
        id: topGroup
        x: xscale(20); y: yscale(130); width: xscale(1280 - 40); height: yscale(540)
        BaseBackground { anchors.fill: parent }
        ButtonList
        {
            id: list;
            spacing: 3
            anchors.fill: parent;
            anchors.margins: xscale(10)
            model: menuItems.model
            delegate: listRow
            KeyNavigation.left: menuSelector
            KeyNavigation.right: menuSelector
        }
    }

    Footer
    {
        id: footer
        redText: "Add"
        greenText: "Delete"
        yellowText: "Amend"
        blueText: "Copy"
    }
}
