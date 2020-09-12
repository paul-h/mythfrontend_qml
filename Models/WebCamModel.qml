import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

Item
{
    id: root

    property var webcamList: webcamListModel
    property int webcamListIndex: 0
    property var model: listModel
    property var categoryList: ListModel{}

    signal loaded();

    onWebcamListIndexChanged:
    {
        // sanity check index
        if (webcamListIndex >= 0 && webcamListIndex < webcamListModel.count)
            webcamModel.source = webcamListModel.get(webcamListIndex).url
    }

    ListModel
    {
        id: listModel
    }

    XmlListModel
    {
        id: webcamListModel

        signal loaded();

        query: "/items/item"
        XmlRole { name: "id"; query: "id/number()" }
        XmlRole { name: "title"; query: "title/string()" }
        XmlRole { name: "description"; query: "description/string()" }
        XmlRole { name: "url"; query: "url/string()" }

        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                log.debug(Verbose.MODEL, "WebcamListModel: READY - Found " + count + " webcam lists");
                loaded();

                webcamModel.source = webcamListModel.get(root.webcamListIndex).url
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "WebcamListModel: LOADING - " + source.toString());
            }

            if (status === XmlListModel.Error)
            {
                log.error(Verbose.MODEL, "WebcamListModel: ERROR: " + errorString() + " - " + source.toString());
            }
        }

        Component.onCompleted:
        {
            var webcamFile = settings.webcamListFile;
            if (webcamFile == "" || webcamFile == "https://mythqml.net/download.php?f=webcams_list.xml")
                webcamFile = "https://mythqml.net/download.php?f=webcams_list.xml&v=" + version + "&s=" + systemid;

            source = webcamFile;
        }
    }

    XmlListModel
    {
        id: webcamModel

        source: ""
        query: "/webcams/webcam"
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
                log.debug(Verbose.MODEL, "WebCamModel: READY - Found " + count + " webcams");
                doLoad();
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "WebCamModel: LOADING - " + source.toString());
            }

            if (status === XmlListModel.Error)
            {
                log.error(Verbose.MODEL, "WebCamModel: ERROR: " + errorString() + " - " + source.toString());
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
            categoryList.append({"item": "<All Webcams>"});

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
        var id = webcamList.get(webcamListIndex).id;
        var favorites = dbUtils.getSetting("WebcamFavorites_" + id, settings.hostName, "");

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

        var id = webcamList.get(webcamListIndex).id;
        dbUtils.setSetting("WebcamFavorites_" + id, settings.hostName, setting);
    }

    function reload()
    {
        webcamModel.reload();
    }
}
