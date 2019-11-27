import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0
Item
{
    id: root

    property var webvideoList: webvideoListModel
    property int webvideoListIndex: 0
    property var model: listModel
    property var categoryList: ListModel{}

    signal loaded();

    onWebvideoListIndexChanged:
    {
        // sanity check index
        if (webvideoListIndex >= 0 && webvideoListIndex < webvideoListModel.count)
            webvideoModel.source = webvideoListModel.get(webvideoListIndex).url
    }

    ListModel
    {
        id: listModel
    }

    XmlListModel
    {
        id: webvideoListModel

        signal loaded();

        source: "https://mythqml.net/download.php?f=webvideos_list.xml&v=" + version + "&s=" + systemid

        query: "/items/item"
        XmlRole { name: "id"; query: "id/number()" }
        XmlRole { name: "title"; query: "title/string()" }
        XmlRole { name: "description"; query: "description/string()" }
        XmlRole { name: "url"; query: "url/string()" }

        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                log.debug(Verbose.MODEL, "WebvideoListModel: READY - Found " + count + " webvideo lists");
                loaded();

                webvideoModel.source = webvideoListModel.get(root.webvideoListIndex).url
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "WebvideoListModel: LOADING - " + source.toString());
            }

            if (status === XmlListModel.Error)
            {
                log.error(Verbose.MODEL, "WebvideoListModel: ERROR: " + errorString() + " - " + source.toString());
            }
        }
    }
    XmlListModel
    {
        id: webvideoModel

        source: ""
        query: "/webvideo/item"
        XmlRole { name: "id"; query: "id/number()"; isKey: true }
        XmlRole { name: "title"; query: "title/string()" }
        XmlRole { name: "description"; query: "description/string()" }
        XmlRole { name: "icon"; query: "icon/string()" }
        XmlRole { name: "website"; query: "website/string()" }
        XmlRole { name: "zoom"; query: "zoom/number()" }
        XmlRole { name: "dateadded"; query: "xs:dateTime(dateadded)" }
        XmlRole { name: "datemodified"; query: "xs:dateTime(datemodified)" }
        XmlRole { name: "status"; query: "status/string()" }
        XmlRole { name: "categories"; query: "string-join(categories/category/@name, ', ')" }
        XmlRole { name: "links"; query: "string-join(links/link/(concat(@type, '=', @name)), '\n')" }

        XmlRole { name: "player"; query: "player/string()" }
        XmlRole { name: "url"; query: "url/string()" }

        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                log.debug(Verbose.MODEL, "WebVideoModel: READY - Found " + count + " webvideos");
                doLoad();
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "WebVideoModel: LOADING - " + source.toString());
            }

            if (status === XmlListModel.Error)
            {
                log.error(Verbose.MODEL, "WebVideoModel: ERROR: " + errorString() + " - " + source.toString());
            }
        }

        // copy the XmlListModel model to our ListModel so we can modify it
        function doLoad()
        {
            var category;
            var categories = [];

            categoryList.clear();
            listModel.clear();

            for (var x = 0; x < count; x++)
            {
                listModel.append({"id": get(x).id, "title": get(x).title, "description": get(x).description, "icon": get(x).icon,
                                  "website": get(x).website, "zoom": get(x).zoom, "dateadded": get(x).dateadded, "datemodified": get(x).datemodified,
                                  "status": get(x).status, "categories": get(x).categories, "links": get(x).links, "player": get(x).player,
                                  "url": get(x).url, "favorite": false});

                category = get(x).categories;

                var splitCategories = category.split(",");

                for (var y = 0; y < splitCategories.length; y++)
                {
                    category = splitCategories[y].trim();

                    if (categories.indexOf(category) < 0)
                        categories.push(category);
                }
            }

            categories.sort();
            categoryList.append({"item": "<All Web Videos>"});

            for (var x = 0; x < categories.length; x++)
                categoryList.append({"item": categories[x]});

            loadFavorites();

            // send loaded signal
            loaded();
        }
    }

    function findById(Id)
    {
        for (var x = 0; x < listModel.count; x++)
        {
            if (listModel.get(x).id == Id)
                return x;
        }

        return -1;
    }

    function loadFavorites()
    {
        var id = webvideoList.get(webvideoListIndex).id;
        var favorites = dbUtils.getSetting("WebvideoFavorites_" + id, settings.hostName, "");

        if (favorites.length)
        {
            var splitFavorites = favorites.split(",");

            for (var y = 0; y < splitFavorites.length; y++)
            {
                var favorite = parseInt(splitFavorites[y].trim());
                var index = findById(favorite);
                if (index != -1)
                    listModel.get(index).favorite = true;
            }
        }
}

    function saveFavorites()
    {
        var setting = "";

        for (var x = 0; x < listModel.count; x++)
        {
            if (listModel.get(x).favorite === true)
            {
                if (setting === "")
                    setting = listModel.get(x).id;
                else
                    setting += "," + listModel.get(x).id;
            }
        }

        var id = webvideoList.get(webvideoListIndex).id;
        dbUtils.setSetting("WebvideoFavorites_" + id, settings.hostName, setting);
    }
}
