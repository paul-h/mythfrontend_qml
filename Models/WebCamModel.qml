import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: webcamModel

    property var categoryList: ListModel{}

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
            updateLists();
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

    function updateLists()
    {
        var category;
        var categories = [];

        categoryList.clear();

        for (var x = 0; x < count; x++)
        {
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
    }
}
