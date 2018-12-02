import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel
{
    id: webvideoModel

    property var categoryList: ListModel{}

    source: ""
    query: "/webvideo/item"
    XmlRole { name: "id"; query: "id/number()" }
    XmlRole { name: "title"; query: "title/string()" }
    XmlRole { name: "description"; query: "description/string()" }
    XmlRole { name: "icon"; query: "icon/string()" }
    XmlRole { name: "url"; query: "url/string()" }
    XmlRole { name: "website"; query: "website/string()" }
    XmlRole { name: "zoom"; query: "zoom/number()" }
    XmlRole { name: "player"; query: "player/string()" }
    XmlRole { name: "categories"; query: "string-join(categories/category/@name, ', ')" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            console.log("READY >> Found " + count + " webvideos")
            updateLists();
        }

        if (status === XmlListModel.Loading)
        {
            console.log("LOADING >> " + webvideoModel.source.toString())
        }

        if (status === XmlListModel.Error)
        {
            console.log("Error: " + errorString + "\n \n \n " + webvideoModel.source.toString());
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
        categoryList.append({"item": "<All Web Videos>"});

        for (var x = 0; x < categories.length; x++)
            categoryList.append({"item": categories[x]});
    }
}
