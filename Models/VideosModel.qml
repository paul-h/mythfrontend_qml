import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0
import SortFilterProxyModel 0.2

Item
{
    id: root

    property alias model: videoModel
    property alias count: videoModel.count

    property var titleList: ListModel{}
    property var genreList: ListModel{}
    property var typeList: ListModel{}

    signal loaded();

    property list<QtObject> videoFilter:
    [
        AllOf
        {
            RegExpFilter
            {
                id: videoTitle
                roleName: "Title"
                pattern: ""
                caseSensitivity: Qt.CaseInsensitive
            }
            RegExpFilter
            {
                id: videoGenre
                roleName: "Genre"
                pattern: ""
                caseSensitivity: Qt.CaseInsensitive
            }
            RegExpFilter
            {
                id: videoType
                roleName: "ContentType"
                pattern: ""
                caseSensitivity: Qt.CaseInsensitive
            }
        }
    ]

    property list<QtObject> titleSorter:
    [
        RoleSorter { roleName: "Title"; ascendingOrder: true}
    ]

    property list<QtObject> idSorter:
    [
        RoleSorter { roleName: "Id"; ascendingOrder: true}
    ]

    property list<QtObject> episodeSorter:
    [
        RoleSorter { roleName: "Title" },
        RoleSorter { roleName: "Series"; ascendingOrder: true},
        RoleSorter { roleName: "Episode" }
    ]

    property list<QtObject> typeSorter:
    [
        RoleSorter { roleName: "ContentType"; ascendingOrder: true}
    ]

    property list<QtObject> genreSorter:
    [
        RoleSorter { roleName: "Genre"; ascendingOrder: true},
        RoleSorter { roleName: "title" }
    ]

    SortFilterProxyModel
    {
        id: proxyModel
        filters: videoFilter
        sorters: titleSorter
        sourceModel: videoModel
    }

    XmlListModel
    {
        id: videoModel

        property alias titleList: root.titleList
        property alias genreList: root.genreList
        property alias typeList: root.typeList

        property string _pin: settings.securityPin;

        source: settings.masterBackend + "Video/GetVideoList"
        query: "/VideoMetadataInfoList/VideoMetadataInfos/VideoMetadataInfo"
        XmlListModelRole { name: "Id"; elementName: "Id" }
        XmlListModelRole { name: "Title"; elementName: "Title" }
        XmlListModelRole { name: "SubTitle"; elementName: "SubTitle" }
        XmlListModelRole { name: "Tagline"; elementName: "Tagline" }
        XmlListModelRole { name: "Director"; elementName: "Director" }
        XmlListModelRole { name: "Studio"; elementName: "Studio" }
        XmlListModelRole { name: "Description"; elementName: "Description" }
        XmlListModelRole { name: "Inetref"; elementName: "Inetref" }
        XmlListModelRole { name: "Collectionref"; elementName: "Collectionref" }
        XmlListModelRole { name: "HomePage"; elementName: "HomePage" }
        XmlListModelRole { name: "ReleaseDate"; elementName: "ReleaseDate" }
        XmlListModelRole { name: "AddDate"; elementName: "AddDate" }
        XmlListModelRole { name: "UserRating"; elementName: "UserRating" }
        XmlListModelRole { name: "Length"; elementName: "Length" }
        XmlListModelRole { name: "PlayCount"; elementName: "PlayCount" }
        XmlListModelRole { name: "Season"; elementName: "Season" } // number
        XmlListModelRole { name: "Episode"; elementName: "Episode" } //number
        XmlListModelRole { name: "ParentalLevel"; elementName: "ParentalLevel" }
        XmlListModelRole { name: "Visible"; elementName: "Visible" }
        XmlListModelRole { name: "Watched"; elementName: "Watched" }
        XmlListModelRole { name: "Processed"; elementName: "Processed" }
        XmlListModelRole { name: "ContentType"; elementName: "ContentType" }
        XmlListModelRole { name: "Genre"; elementName: "string-join(Genres/GenreList/Genre/Name, ', ')" } //FIXME Qt6
        XmlListModelRole { name: "FileName"; elementName: "FileName" }
        XmlListModelRole { name: "Hash"; elementName: "Hash" }
        XmlListModelRole { name: "HostName"; elementName: "HostName" }
        XmlListModelRole { name: "Coverart"; elementName: "Coverart" }
        XmlListModelRole { name: "Fanart"; elementName: "Fanart" }
        XmlListModelRole { name: "Banner"; elementName: "Banner" }
        XmlListModelRole { name: "Screenshot"; elementName: "Screenshot" }
        XmlListModelRole { name: "Trailer"; elementName: "Trailer" }

        XmlListModelRole { name: "title"; elementName: "Title" }
        XmlListModelRole { name: "url"; elementName: "concat(xs:string('myth://type=video:server='), HostName/string(), xs:string(':pin=" + videoModel._pin + "'), xs:string(':port=6543:sgroup=video:filename='), FileName/string())" } //FIXME
        XmlListModelRole { name: "player"; elementName: "xs:string('VLC')" } //FIXME

        onStatusChanged: status =>
        {
            if (status == XmlListModel.Ready)
            {
                log.debug(Verbose.MODEL, "VideosModel: READY - Found " + count + " videos");
                screenBackground.showBusyIndicator = false;

                updateLists();

                root.loaded();
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "VideosModel: LOADING - " + source);
                screenBackground.showBusyIndicator = true;
            }

            if (status === XmlListModel.Error)
            {
                screenBackground.showBusyIndicator = false;
                log.error(Verbose.MODEL, "VideosModel: ERROR: " + errorString() + " - " + source);
            }
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

    function get(x)
    {
        return videoModel.get(x);
    }

    function updateLists()
    {
        var title;
        var genre;
        var type;

        var titles = [];
        var genres = [];
        var types = [];

        titleList.clear();
        typeList.clear();
        genreList.clear();

        for (var x = 0; x < count; x++)
        {
            title = get(x).Title;
            genre = get(x).Genre;
            type = get(x).ContentType;

            if (titles.indexOf(title) < 0)
                titles.push(title);

            if (types.indexOf(type) < 0)
                types.push(type);

            var splitGenres = genre.split(",");

            for (var y = 0; y < splitGenres.length; y++)
            {
                genre = splitGenres[y].trim();

                if (genre.length === 0)
                    genre = "<NONE>";

                if (genres.indexOf(genre) < 0)
                    genres.push(genre);
            }
        }

        titles.sort();
        types.sort();
        genres.sort();

        for (var x = 0; x < titles.length; x++)
            titleList.append({"item": titles[x]});

        for (var x = 0; x < genres.length; x++)
            genreList.append({"item": genres[x]});

        for (var x = 0; x < types.length; x++)
            typeList.append({"item": types[x]});
    }

    function expandNode(tree, path, node)
    {
        var chan;
        var x;
        var sort = "Title";
        var title = "";
        var genre = "";
        var type = "";

        var fNode = node;

        while (fNode && fNode.parent !== null)
        {
            if (fNode.type === SourceTreeModel.NodeType.Videos_Filter_Title)
                title = fNode.itemTitle;
            else if (fNode.type === SourceTreeModel.NodeType.Videos_Filter_Genre)
                genre = fNode.itemTitle;
            else if (fNode.type === SourceTreeModel.NodeType.Videos_Filter_Type)
                type = fNode.itemTitle;

            fNode = fNode.parent;
        }

        if (genre === "<NONE>")
            genre = "";

        node.expanded  = true

        if (node.type === SourceTreeModel.NodeType.Root_Title)
        {
            node.subNodes.append({"parent": node, "itemTitle": "<All Videos>", "itemData": "AllVideos", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Videos_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Genres", "itemData": "Genres", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Videos_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Titles", "itemData": "Titles", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Videos_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Type", "itemData": "Type", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Videos_Filters})
        }
        else if (node.type === SourceTreeModel.NodeType.Videos_Filters)
        {
            if (node.itemData === "AllVideos")
            {
                proxyModel.sorters = titleSorter;
                videoGenre.pattern = genre;
                videoTitle.pattern = title;
                videoType.pattern = type;

                for (x = 0; x < proxyModel.count; x++)
                {
                    var video = proxyModel.get(x);
                    node.subNodes.append({
                                             "parent": node, "itemTitle": video.title, "itemData": String(video.id), "checked": false, "expanded": true, "subNodes": [], type: SourceTreeModel.NodeType.Videos_Video,
                                             "player": video.player, "url": video.url, "genre": video.Genre, "SubTitle": video.SubTitle, "Description": video.Description, "AddDate": video.AddDate, "Length": video.Length,
                                             "title": video.title, "Coverart": video.Coverart, "Banner": video.Banner, "Fanart": video.Fanart, "Screenshot": video.Screenshot, "icon": getIconURL(video)
                                         })
                }
            }
            else if (node.itemData === "Titles")
            {
                for (x = 0; x < titleList.count; x++)
                {
                    node.subNodes.append({"parent": node, "itemTitle": titleList.get(x).item, "itemData": titleList.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Videos_Filter_Title})
                }
            }
            else if (node.itemData === "Genres")
            {
                for (x = 0; x < genreList.count; x++)
                {
                    node.subNodes.append({"parent": node, "itemTitle": genreList.get(x).item, "itemData": genreList.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Videos_Filter_Genre})
                }
            }
            else if (node.itemData === "Type")
            {
                for (x = 0; x < typeList.count; x++)
                {
                    node.subNodes.append({"parent": node, "itemTitle": typeList.get(x).item, "itemData": typeList.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Videos_Filter_Type})
                }
            }
        }
        else if (node.type === SourceTreeModel.NodeType.Videos_Filter_Genre || node.type === SourceTreeModel.NodeType.Videos_Filter_Title || node.type === SourceTreeModel.NodeType.Videos_Filter_Type)
        {
            if (sort === "Title")
                proxyModel.sorters = titleSorter;
            else if (sort === "Id")
                proxyModel.sorters = idSorter;
            else if (sort === "Genre")
                proxyModel.sorters = genreSorter;
            else if (sort === "Episode")
                proxyModel.sorters = episodeSorter;
            else if (sort === "Type")
                proxyModel.sorters = typeSorter;
            else
                proxyModel.sorters = idSorter;

            videoGenre.pattern = genre;
            videoTitle.pattern = title;
            videoType.pattern = type;

            for (x = 0; x < proxyModel.count; x++)
            {
                video = proxyModel.get(x);
                node.subNodes.append({

                                         "parent": node, "itemTitle": video.title, "itemData": String(video.id), "checked": false, "expanded": true, "subNodes": [], type: SourceTreeModel.NodeType.Videos_Video,
                                         "player": video.player, "url": video.url, "genre": video.Genre, "SubTitle": video.SubTitle, "Description": video.Description, "AddDate": video.AddDate, "Length": video.Length,
                                         "title": video.title, "Coverart": video.Coverart, "Banner": video.Banner, "Fanart": video.Fanart, "Screenshot": video.Screenshot, "icon": getIconURL(video)
                                     })
            }
        }
    }

    function getIconURL(video)
    {
        console.log("Coverart: " + video.CoverArt, )
        if (video.Coverart !== undefined && video.Coverart !== "")
            return settings.masterBackend + "Content/GetImageFile?StorageGroup=Coverart&FileName=" + video.Coverart;
        else if (video.Fanart !== undefined && video.Fanart !== "")
            return settings.masterBackend + "Content/GetImageFile?StorageGroup=Coverart&FileName=" +video.Fanart;
        else if (video.Screenshot !== undefined && video.Screenshot !== "")
            return settings.masterBackend + "Content/GetImageFile?StorageGroup=Coverart&FileName=" +video.Screenshot;
        else if (video.Banner !== undefined && video.Banner !== "")
            return settings.masterBackend + "Content/GetImageFile?StorageGroup=Coverart&FileName=" +video.Banner;

        return "https://archive.org/download/icon-default/icon-default.png";
    }
}
