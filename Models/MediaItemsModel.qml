import QtQuick

import mythqml.net 1.0
import SqlQueryModel 1.0

Item
{
    id: root

    property alias model: mediaItemsModel

    signal loaded();

    SqlQueryModel
    {
        id: mediaItemsModel

        property string mediaType: ""
        property string contentType: ""
        property string genre: ""
        property string nsfw: ""
        property string sortField: "title"
        property bool   sortReversed: false

        onSqlChanged:
        {
            while (canFetchMore(index(-1, -1)))
                fetchMore(index(-1, -1));
        }

        function updateSQL()
        {
            var newSQL = "SELECT * FROM mediaitems";
            var whereAdded = false;

            if (genre != "")
                newSQL = newSQL + ", json_each(mediaitems.genres)";

            if (mediaType !== "")
            {
                if (whereAdded)
                    newSQL = newSQL + " AND mediatype = '" + mediaType + "'";
                else
                {
                    whereAdded = true;
                    newSQL = newSQL + " WHERE mediatype = '" + mediaType + "'";
                }
            }

            if (contentType !== "")
            {
                if (whereAdded)
                    newSQL = newSQL + " AND contenttype = '" + contentType + "'";
                else
                {
                    whereAdded = true;
                    newSQL = newSQL + " WHERE contenttype = '" + contentType + "'";
                }
            }

            if (nsfw !== "")
            {
                if (whereAdded)
                    newSQL = newSQL + " AND nsfw = " + (nsfw == "Yes" ? 1 : 0);
                else
                {
                    whereAdded = true;
                    newSQL = newSQL + " WHERE nsfw = " + (nsfw == "Yes" ? 1 : 0);
                }
            }

            if (genre !== "")
            {
                if (whereAdded)
                    newSQL = newSQL + " AND json_each.value = '" + genre + "'";
                else
                {
                    whereAdded = true;
                    newSQL = newSQL + " WHERE json_each.value = '" + genre + "'";
                }
            }

            newSQL = newSQL + " ORDER BY " + sortField + (sortReversed ? " DESC" : " ASC");

            sql = newSQL;
        }
    }

    function expandNode(tree, path, node)
    {
        var chan;
        var x;
        var sort = "title";
        var genre = "";
        var mediaType = "";
        var contentType = "";
        var nsfw = "";

        var fNode = node;

        while (fNode && fNode.parent !== null)
        {
            if (fNode.type === SourceTreeModel.NodeType.Media_Filter_MediaType)
                mediaType = fNode.itemData;
            else if (fNode.type === SourceTreeModel.NodeType.Media_Filter_ContentType)
                contentType = fNode.itemData;
            else if (fNode.type === SourceTreeModel.NodeType.Media_Filter_Genre)
                genre = fNode.itemData;
            else if (fNode.type === SourceTreeModel.NodeType.Media_Filter_NSFW)
                nsfw = fNode.itemData;

            fNode = fNode.parent;
        }

        node.expanded  = true

        if (node.type === SourceTreeModel.NodeType.Root_Title)
        {
            node.subNodes.append({"parent": node, "itemTitle": "<All Media Items>", "itemData": "AllMediaItems", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Media Type", "itemData": "MediaType", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Content Type", "itemData": "ContentType", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Genre", "itemData": "Genres", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "NSFW", "itemData": "NSFW", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filters})
        }
        else if (node.type === SourceTreeModel.NodeType.Media_Filters)
        {
            if (node.itemData === "AllMediaItems")
            {
                mediaItemsModel.mediaType = mediaType;
                mediaItemsModel.contentType = contentType;
                mediaItemsModel.genre = genre;
                mediaItemsModel.nsfw = nsfw
                mediaItemsModel.sortField = "title"
                mediaItemsModel.updateSQL();

                for (x = 0; x < mediaItemsModel.rowCount(); x++)
                {
                    var id = mediaItemsModel.get(x, "id");
                    var title = mediaItemsModel.get(x, "title");
                    var icon = mediaItemsModel.get(x, "front");
                    var genres = mediaItemsModel.get(x, "genres");
                    var url = "file://" + mediaItemsModel.get(x, "folder") + '/' + mediaItemsModel.get(x, "filename");

                    node.subNodes.append({
                                             "parent": node, "itemTitle": title, "itemData": String(id), "checked": false, "expanded": true, "icon": icon, "subNodes": [], type: SourceTreeModel.NodeType.Media_File,
                                             "player": "Internal", "url": url, "genres": genres
                                         })
                }
            }
            else if (node.itemData === "NSFW")
            {
                node.subNodes.append({"parent": node, "itemTitle": "Yes", "itemData": "Yes", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filter_NSFW})
                node.subNodes.append({"parent": node, "itemTitle": "No", "itemData": "No", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filter_NSFW})

            }
            else if (node.itemData === "MediaType")
            {
                node.subNodes.append({"parent": node, "itemTitle": "Video", "itemData": "VIDEO", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filter_MediaType})
                node.subNodes.append({"parent": node, "itemTitle": "DVD", "itemData": "DVD", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filter_MediaType})
            }
            else if (node.itemData === "ContentType")
            {
                node.subNodes.append({"parent": node, "itemTitle": "TV", "itemData": "TV", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filter_ContentType})
                node.subNodes.append({"parent": node, "itemTitle": "Movie", "itemData": "MOVIE", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filter_ContentType})
            }
            else if (node.itemData === "Genres")
            {
                if (mediaType === "" && contentType === "" && genre === "" && nsfw === "")
                {
                    // get the full list of genres
                    mediaItemsModel.sql = "select DISTINCT(value) FROM mediaitems, json_each(genres) ORDER BY value;"
                    for (x = 0; x < mediaItemsModel.rowCount(); x++)
                    {
                        node.subNodes.append({"parent": node, "itemTitle": mediaItemsModel.get(x, "value"), "itemData": mediaItemsModel.get(x, "value"), "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filter_Genre})
                    }
                }
                else
                {
                    // get a filtered list of genres
                    var genreArr = [];

                    for (x = 0; x < node.parent.subNodes.get(0).subNodes.count; x++)
                    {
                        var genreJson = JSON.parse(node.parent.subNodes.get(0).subNodes.get(x).genres);
                        for (var g in genreJson)
                        {
                            if (genreArr.indexOf(genreJson[g]) < 0)
                                genreArr.push(genreJson[g]);
                        }
                    }

                    genreArr.sort();

                    for (x = 0; x < genreArr.length; x++)
                    {
                        node.subNodes.append({"parent": node, "itemTitle": genreArr[x], "itemData": genreArr[x], "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.IPTV_Filter_Genre})
                    }
                }
            }
        }
        else if (node.type === SourceTreeModel.NodeType.Media_Filter_MediaType || node.type === SourceTreeModel.NodeType.Media_Filter_ContentType || node.type === SourceTreeModel.NodeType.Media_Filter_NSFW || node.type === SourceTreeModel.NodeType.Media_Filter_Genre || node.type === SourceTreeModel.NodeType.Media_Filter_All)
        {
            if (node.type !== SourceTreeModel.NodeType.Media_Filter_All && (genre === "" || mediaType === "" || contentType === "" || nsfw === ""))
            {
                node.subNodes.append({"parent": node, "itemTitle": "<All Media Items>", "itemData": "AllMediaItems", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filter_All})

                if (nsfw === "")
                    node.subNodes.append({"parent": node, "itemTitle": "NSFW", "itemData": "NSFW", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filters})

                if (genre === "")
                    node.subNodes.append({"parent": node, "itemTitle": "Genres", "itemData": "Genres", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filters});

                if (contentType === "")
                    node.subNodes.append({"parent": node, "itemTitle": "ContentType", "itemData": "ContentType", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filters});

                if (mediaType === "")
                    node.subNodes.append({"parent": node, "itemTitle": "MediaType", "itemData": "MediaType", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Media_Filters});
            }
            else
            {
                mediaItemsModel.contentType = contentType;
                mediaItemsModel.mediaType = mediaType;
                mediaItemsModel.genre = genre;
                mediaItemsModel.nsfw = nsfw;
                mediaItemsModel.sortField = "title"
                mediaItemsModel.updateSQL();

                for (x = 0; x < mediaItemsModel.rowCount(); x++)
                {
                    var id = mediaItemsModel.get(x, "id");
                    var title = mediaItemsModel.get(x, "title");
                    var icon = mediaItemsModel.get(x, "front");
                    var genres = mediaItemsModel.get(x, "genres");
                    var url = "file://" + mediaItemsModel.get(x, "folder") + '/' + mediaItemsModel.get(x, "filename");

                    node.subNodes.append({
                                             "parent": node, "itemTitle": title, "itemData": String(id), "checked": false, "expanded": true, "icon": icon, "subNodes": [], type: SourceTreeModel.NodeType.Media_File,
                                             "player": "Internal", "url": url, "genres": genres
                                         })
                }
            }
        }
    }

    function getIconURL(iconURL)
    {
        if (iconURL && iconURL != "")
            return iconURL;

        return "https://archive.org/download/icon-default/icon-default.png";
    }
}
