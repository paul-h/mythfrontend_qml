import QtQuick

import mythqml.net 1.0
import SortFilterProxyModel 0.2
import SqlQueryModel 1.0

Item
{
    id: root

    property alias model: proxyModel
    property alias count: proxyModel.count

    property string menu: ""

    property var menuList: ListModel{}

    property alias logo: proxyModel.logo
    property alias title: proxyModel.title

    signal loaded();

    Component.onCompleted:
    {
        loadFromDB();
    }

    property list<QtObject> itemsFilter:
    [
        AllOf
        {
            ValueFilter
            {
                id: menuFilter
                roleName: "menu"
                value: root.menu
                enabled: value !== ""
            }
        }
    ]

    property list<QtObject> positionSorter:
    [
        RoleSorter { roleName: "position"; ascendingOrder: true}
    ]

    property list<QtObject> idSorter:
    [
        RoleSorter { roleName: "itemid"; ascendingOrder: true}
    ]

    property list<QtObject> menuSorter:
    [
        RoleSorter { roleName: "menu"; ascendingOrder: true},
        RoleSorter { roleName: "position" }
    ]

    SqlQueryModel
    {
        id: menuItemsModel
        sql: "SELECT itemid, menu, position, menuText, loaderSource, waterMark, url, zoom, fullscreen, layout, exec FROM menuitems";
    }

    SortFilterProxyModel
    {
        id: proxyModel
        filters: menuFilter
        sorters: positionSorter
        sourceModel: listModel

        property string logo: ""
        property string title: ""    }

    ListModel
    {
        id: listModel
    }

    function loadFromDB()
    {
        var x;
        var menus = [];

        root.menuList.clear();
        listModel.clear();

        menuItemsModel.reload();

        for (x = 0; x < menuItemsModel.rowCount(); x++)
        {
            var itemid = menuItemsModel.data(menuItemsModel.index(x, 0));
            var menu = menuItemsModel.data(menuItemsModel.index(x, 1));
            var position = menuItemsModel.data(menuItemsModel.index(x, 2));
            var menuText = menuItemsModel.data(menuItemsModel.index(x, 3));
            var loaderSource = menuItemsModel.data(menuItemsModel.index(x, 4));
            var waterMark = menuItemsModel.data(menuItemsModel.index(x, 5));
            var url = menuItemsModel.data(menuItemsModel.index(x, 6));
            var zoom = menuItemsModel.data(menuItemsModel.index(x, 7));
            var fullscreen = (menuItemsModel.data(menuItemsModel.index(x, 8)) === 1 ? "true": "false");
            var layout = menuItemsModel.data(menuItemsModel.index(x, 9));
            var exec = menuItemsModel.data(menuItemsModel.index(x, 10));
            listModel.append({"itemid": itemid, "menu": menu, "position": position, "menutext": menuText, "loaderSource": loaderSource, "waterMark": waterMark, "url": url,
                              "zoom": zoom, "fullscreen": fullscreen, "layout": layout, "exec": exec
                             });

            if (menus.indexOf(menu) < 0)
                menus.push(menu);
        }

        menus.sort();

        for (x = 0; x < menus.length; x++)
            root.menuList.append({"item": menus[x]});

        // force the proxy model to reload
        proxyModel.invalidate();

        root.loaded();
    }

    function expandNode(tree, path, node)
    {

    }

    function get(index)
    {
        return model.get(index);
    }

    function getIndexFromId(itemId)
    {
        for (var x = 0; x < listModel.count; x++)
        {
            var item = listModel.get(x);

            if (item.itemid == itemId)
                return x;
        }

        return -1;
    }
}
