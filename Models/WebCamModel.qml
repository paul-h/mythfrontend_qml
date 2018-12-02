import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel
{
    id: webcamModel

    property var categoryList: ListModel{}

    source: ""
    query: "/webcam/item"
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
            console.log("READY >> Found " + count + " webcams")
            updateLists();
        }

        if (status === XmlListModel.Loading)
        {
            console.log("LOADING >> " + webcamModel.source.toString())
        }

        if (status === XmlListModel.Error)
        {
            console.log("Error: " + errorString + "\n \n \n " + webcamModel.source.toString());
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
