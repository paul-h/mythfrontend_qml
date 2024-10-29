import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0
import SortFilterProxyModel 0.2

Item
{
    id: root

    property var webcamList: webcamListModel
    property var models: []
    property int status: XmlListModel.Null

    property int webcamListIndex: 0

    property string _category: ""
    property string _sort: "title"
    property string _webcamFilterFavorite: "Any"

    property list<QtObject> webcamFilter:
    [
        AllOf
        {
            ExpressionFilter
            {
                id: categoryFilter
                property string category: ""
                expression:
                {
                    var catList = categories.split(",");
                    for (var x = 0; x < catList.length; x++)
                    {
                        if (catList[x].trim() == root._category)
                            return true;
                    }

                    return false;
                }
                enabled: root._category !== ""
            }

            ValueFilter
            {
                enabled: (_webcamFilterFavorite !== "Any")
                roleName: "favorite"
                value: (_webcamFilterFavorite === "Yes")
            }

            AnyOf
            {
                ValueFilter
                {
                    roleName: "status"
                    value: "Working"
                }

                ValueFilter
                {
                    roleName: "status"
                    value: "Temporarily Offline"
                }
            }
        }
    ]

    property list<QtObject> titleSorter:
    [
        RoleSorter { roleName: "title"; ascendingOrder: true}
    ]

    SortFilterProxyModel
    {
        id: proxyModel
        filters: webcamFilter
        sorters: titleSorter
    }

    XmlListModel
    {
        id: webcamListModel

        query: "/items/item"
        XmlListModelRole { name: "id"; elementName: "id" }
        XmlListModelRole { name: "title"; elementName: "title" }
        XmlListModelRole { name: "description"; elementName: "description" }
        XmlListModelRole { name: "url"; elementName: "url" }

        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                log.debug(Verbose.MODEL, "WebcamListModel: READY - Found " + count + " webcam lists");
                loadModels();
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "WebcamListModel: LOADING - " + source);
            }

            if (status === XmlListModel.Error)
            {
                log.error(Verbose.MODEL, "WebcamListModel: ERROR: " + errorString() + " - " + source);
            }
        }

        Component.onCompleted:
        {
            var webcamFile = settings.webcamListFile;
            if (webcamFile == "" || webcamFile == "https://mythqml.net/download.php?f=webcams_list.xml")
                webcamFile = "https://mythqml.net/download.php?f=webcams_list.xml&v=" + version + "&s=" + systemid;

            source = webcamFile;
        }

        function get(i)
        {
            var o = {}
            for (var j = 0; j < roles.length; ++j)
            {
                o[roles[j].name] = data(index(i,0), Qt.UserRole + j)
            }
            return o
        }
    }

    Component
    {
        id: listModelTemplate

        Item
        {
            id: listModel
            property int id: -1
            property alias url: webcamModel.source
            property alias model: model

            property var categoryList: ListModel{}

            signal loaded();
            signal loadingStatus(int status);

            ListModel
            {
                id: model

                property alias status: webcamModel.status

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
                    var favorites = dbUtils.getSetting("WebcamFavorites_" + listModel.id, settings.hostName, "");

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

                    dbUtils.setSetting("WebcamFavorites_" + listModel.id, settings.hostName, setting);
                }

                function reload()
                {
                    webcamModel.reload();
                }
            }

            XmlListModel
            {
                id: webcamModel

                source: ""
                query: "/webcams/webcam"
                XmlListModelRole { name: "id"; elementName: "id"} //number
                //XmlListModelRole { name: "id"; elementName: "id/number()"; isKey: true } // isKey not supported in Qt6
                XmlListModelRole { name: "title"; elementName: "title" }
                XmlListModelRole { name: "description"; elementName: "description" }
                XmlListModelRole { name: "icon"; elementName: "icon" }
                XmlListModelRole { name: "website"; elementName: "website" }
                XmlListModelRole { name: "zoom"; elementName: "zoom" } //number
                XmlListModelRole { name: "dateadded"; elementName: "dateadded" } //FIXME
                XmlListModelRole { name: "datemodified"; elementName: "datemodified" } //FIXME
                XmlListModelRole { name: "status"; elementName: "status" }
                XmlListModelRole { name: "categories"; elementName: "categories/category"; attributeName: "name" } //FIXME
                //XmlListModelRole { name: "links"; elementName: "string-join(links/link/(concat(@type, '=', @name)), '\n')" } //FIXME
                XmlListModelRole { name: "links"; elementName: "links/link" } //FIXME

                XmlListModelRole { name: "player"; elementName: "player" }
                XmlListModelRole { name: "url"; elementName: "url" }

                onStatusChanged:
                {
                    if (status == XmlListModel.Ready)
                    {
                        log.debug(Verbose.MODEL, "WebCamModel: READY - Found " + count + " webcams");
                        doLoad();
                    }

                    if (status === XmlListModel.Loading)
                    {
                        log.debug(Verbose.MODEL, "WebCamModel: LOADING - " + source);
                    }

                    if (status === XmlListModel.Error)
                    {
                        log.error(Verbose.MODEL, "WebCamModel: ERROR: " + errorString() + " - " + source);
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

                    listModel.categoryList.append({"item": "<All Webcams>"});

                    for (var x = 0; x < categories.length; x++)
                        listModel.categoryList.append({"item": categories[x]});

                    model.loadFavorites();

                    listModel.loaded();
                }

                function get(i)
                {
                    var o = {}
                    for (var j = 0; j < roles.length; ++j)
                    {
                        o[roles[j].name] = data(index(i,0), Qt.UserRole + j)
                    }
                    return o
                }
            }
        }
    }

    function loadModels()
    {
        root.status = XmlListModel.Loading;

        for (var x = 0; x < webcamListModel.count; x++)
        {
            var id = webcamListModel.get(x).id;
            var url = webcamListModel.get(x).url;
            var model = listModelTemplate.createObject(root, {id: id, url: url})
            root.models.push(model);
        }

        root.status = XmlListModel.Ready;
    }

    function updateModel(index)
    {
        models[index].reload();
    }

    function expandNode(tree, path, node)
    {
        node.expanded  = true

        if (node.type === SourceTreeModel.NodeType.Root_Title)
        {
            // add file lists
            for (var x = 0; x < root.webcamList.count; x++)
            {
                 node.subNodes.append({"parent": node, "itemTitle": root.webcamList.get(x).title, "itemData": String(x),    "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Webcam_File})
            }
        }
        else if (node.type === SourceTreeModel.NodeType.Webcam_File)
        {
            node.subNodes.append({"parent": node, "itemTitle": "<All Webcams>", "itemData": "<All Webcams>", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Webcam_Category})
            node.subNodes.append({"parent": node, "itemTitle": "Favorites",     "itemData": "Favorites",     "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Webcam_Category})

            var categories = root.models[parseInt(node.itemData)].categoryList;

            for (x = 1; x < categories.count; x++)
            {
                node.subNodes.append({"parent": node, "itemTitle": categories.get(x).item, "itemData": categories.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Webcam_Category})
            }
        }
        else if (node.type === SourceTreeModel.NodeType.Webcam_Category)
        {
            var category = node.itemTitle;

            root.webcamListIndex = parseInt(node.parent.itemData);
            var model = models[parseInt(node.parent.itemData)].model;

            proxyModel.sourceModel =  model

            // add the webcams for this category
            if (category === "Favorites")
            {
                _webcamFilterFavorite = "Yes";
                category = "";
            }
            else
            {
                _webcamFilterFavorite = "Any";
            }

            root._category = "";
            root._category = category === "<All Webcams>" ? "" : category;

            for (var y = 0; y < proxyModel.count; y++)
            {
                node.subNodes.append({"parent": node, "itemTitle": proxyModel.get(y).title, "itemData": String(proxyModel.get(y).id), "checked": false, "expanded": true, "icon": getIconURL(proxyModel.get(y).icon), "subNodes": [], type: SourceTreeModel.NodeType.Webcam_Item,
                                      "id": proxyModel.get(y).id, "title": proxyModel.get(y).title, "description": proxyModel.get(y).description, "website": proxyModel.get(y).website, "zoom": proxyModel.get(y).zoom,
                                      "dateadded": proxyModel.get(y).dateadded, "datemodified": proxyModel.get(y).datemodified, "status": proxyModel.get(y).status, "categories": proxyModel.get(y).categories, "links": proxyModel.get(y).links,
                                      "player": proxyModel.get(y).player, "url": proxyModel.get(y).url, "favorite": false, "offline": false
                                     })
            }
        }
    }

    function getIconURL(iconURL)
    {
        if (iconURL)
        {
            if (iconURL.startsWith("file://") || iconURL.startsWith("http://") || iconURL.startsWith("https://"))
                return iconURL;
            else
            {
                // try to get the icon from the same URL the webcam list was loaded from
                var url = webcamList.get(webcamListIndex).url
                var r = /[^\/]*$/;
                url = url.replace(r, '');
                return url + iconURL;
            }
        }

        return ""
    }
}
