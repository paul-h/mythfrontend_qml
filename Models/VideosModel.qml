import QtQuick 2.0
import QtQuick.XmlListModel 2.0
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
        XmlRole { name: "Id"; query: "Id/string()" }
        XmlRole { name: "Title"; query: "Title/string()" }
        XmlRole { name: "SubTitle"; query: "SubTitle/string()" }
        XmlRole { name: "Tagline"; query: "Tagline/string()" }
        XmlRole { name: "Director"; query: "Director/string()" }
        XmlRole { name: "Studio"; query: "Studio/string()" }
        XmlRole { name: "Description"; query: "Description/string()" }
        XmlRole { name: "Inetref"; query: "Inetref/string()" }
        XmlRole { name: "Collectionref"; query: "Collectionref/string()" }
        XmlRole { name: "HomePage"; query: "HomePage/string()" }
        XmlRole { name: "ReleaseDate"; query: "ReleaseDate/string()" }
        XmlRole { name: "AddDate"; query: "AddDate/string()" }
        XmlRole { name: "UserRating"; query: "UserRating/string()" }
        XmlRole { name: "Length"; query: "Length/string()" }
        XmlRole { name: "PlayCount"; query: "PlayCount/string()" }
        XmlRole { name: "Season"; query: "Season/number()" }
        XmlRole { name: "Episode"; query: "Episode/number()" }
        XmlRole { name: "ParentalLevel"; query: "ParentalLevel/string()" }
        XmlRole { name: "Visible"; query: "Visible/string()" }
        XmlRole { name: "Watched"; query: "Watched/string()" }
        XmlRole { name: "Processed"; query: "Processed/string()" }
        XmlRole { name: "ContentType"; query: "ContentType/string()" }
        XmlRole { name: "Genre"; query: "string-join(Genres/GenreList/Genre/Name, ', ')" }
        XmlRole { name: "FileName"; query: "FileName/string()" }
        XmlRole { name: "Hash"; query: "Hash/string()" }
        XmlRole { name: "HostName"; query: "HostName/string()" }
        XmlRole { name: "Coverart"; query: "Coverart/string()" }
        XmlRole { name: "Fanart"; query: "Fanart/string()" }
        XmlRole { name: "Banner"; query: "Banner/string()" }
        XmlRole { name: "Screenshot"; query: "Screenshot/string()" }
        XmlRole { name: "Trailer"; query: "Trailer/string()" }

        XmlRole { name: "title"; query: "Title/string()" }
        XmlRole { name: "url"; query: "concat(xs:string('myth://type=video:server='), HostName/string(), xs:string(':pin=" + videoModel._pin + "'), xs:string(':port=6543:sgroup=video:filename='), FileName/string())" }
        XmlRole { name: "player"; query: "xs:string('VLC')" }

        onStatusChanged:
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
