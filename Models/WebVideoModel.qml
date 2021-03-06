import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

Item
{
    id: root

    property var webvideoList: webvideoListModel
    property var models: []
    property int status: XmlListModel.Null

    XmlListModel
    {
        id: webvideoListModel

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
                loadModels();
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "WebvideoListModel: LOADING - " + source);
            }

            if (status === XmlListModel.Error)
            {
                log.error(Verbose.MODEL, "WebvideoListModel: ERROR: " + errorString() + " - " + source);
            }
        }

        Component.onCompleted:
        {
            var webvideoFile = settings.webvideoListFile;
            if (webvideoFile == "" || webvideoFile == "https://mythqml.net/download.php?f=webvideos_list.xml")
                webvideoFile = "https://mythqml.net/download.php?f=webvideos_list.xml&v=" + version + "&s=" + systemid;

            source = webvideoFile;
        }
    }

    Component
    {
        id: listModelTemplate

        Item
        {
            id: listModel
            property int id: -1
            property alias url: webvideoModel.source
            property alias model: model

            property var categoryList: ListModel{}

            signal loaded();
            signal loadingStatus(int status);

            ListModel
            {
                id: model

                property alias status: webvideoModel.status

                signal loaded();
                signal loadingStatus(int status);

                function findById(Id)
                {
                    for (var x = 0; x < count; x++)
                    {
                        if (get(x).id == Id)
                            return x;
                    }

                    return -1;
                }

                function loadFavorites()
                {
                    var favorites = dbUtils.getSetting("WebvideoFavorites_" + listModel.id, settings.hostName, "");

                    if (favorites.length)
                    {
                        var splitFavorites = favorites.split(",");

                        for (var y = 0; y < splitFavorites.length; y++)
                        {
                            var favorite = parseInt(splitFavorites[y].trim());
                            var id = findById(favorite);
                            if (id != -1)
                                get(id).favorite = true;
                        }
                    }
                }

                function saveFavorites()
                {
                    var setting = "";

                    for (var x = 0; x < count; x++)
                    {
                        if (get(x).favorite === true)
                        {
                            if (setting === "")
                                setting = get(x).id;
                            else
                                setting += "," + get(x).id;
                        }
                    }

                    dbUtils.setSetting("WebvideoFavorites_" + listModel.id, settings.hostName, setting);
                }

                function reload()
                {
                    webvideoModel.reload();
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
                        log.debug(Verbose.MODEL, "WebvideoModel: READY - Found " + count + " webvideos");
                        doLoad();
                    }

                    if (status === XmlListModel.Loading)
                    {
                        log.debug(Verbose.MODEL, "WebvideoModel: LOADING - " + source);
                    }

                    if (status === XmlListModel.Error)
                    {
                        log.error(Verbose.MODEL, "WebvideoModel: ERROR: " + errorString() + " - " + source);
                    }

                    model.loadingStatus(status);
                }

                // copy the XmlListModel model to our ListModel so we can modify it
                function doLoad()
                {
                    var category;
                    var categories = [];

                    listModel.categoryList.clear();
                    model.clear();

                    for (var x = 0; x < count; x++)
                    {
                        model.append({"id": get(x).id, "title": get(x).title, "description": get(x).description, "icon": get(x).icon,
                                             "website": get(x).website, "zoom": get(x).zoom, "dateadded": get(x).dateadded, "datemodified": get(x).datemodified,
                                             "status": get(x).status, "categories": get(x).categories, "links": get(x).links, "player": get(x).player,
                                             "url": get(x).url, "favorite": false, "offline": false});

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
                    listModel.categoryList.append({"item": "<All Web Videos>"});

                    for (var x = 0; x < categories.length; x++)
                        listModel.categoryList.append({"item": categories[x]});

                    model.loadFavorites();

                    listModel.loaded();
                }
            }
        }
    }

    function loadModels()
    {
        root.status = XmlListModel.Loading;

        for (var x = 0; x < webvideoListModel.count; x++)
        {
            var id = webvideoListModel.get(x).id;
            var url = webvideoListModel.get(x).url;
            var model = listModelTemplate.createObject(root, {id: id, url: url})
            root.models.push(model);
        }

        root.status = XmlListModel.Ready;
    }

    function updateModel(index)
    {
        models[index].reload();
    }
}
