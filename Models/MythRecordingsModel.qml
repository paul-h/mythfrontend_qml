import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0
import SortFilterProxyModel 0.2
import RecordingsModel 1.0

Item
{
    id: root

    property alias model: listModel
    property alias count: listModel.count

    property var loadingNode: undefined
    property bool loadingFinished: false

    property var titleList: ListModel{}
    property var genreList: ListModel{}
    property var recgroupList: ListModel{}

    signal loaded();

    property list<QtObject> recordingsFilter:
    [
        AllOf
        {
            ValueFilter
            {
                id: titleFilter
                roleName: "title"
                value: ""
                enabled: value !== ""
            }
            ValueFilter
            {
                id: genreFilter
                roleName: "Category"
                value: ""
                enabled: value !== ""
            }
            ExpressionFilter
            {
                id: recGroupFilter
                property string recGroup: ""
                expression:
                {
                    return (RecGroup === recGroup);
                }
                enabled: recGroup !== ""
            }
        }
    ]

    //FIXME: these need updating
    property list<QtObject> titleSorter:
    [
        RoleSorter { roleName: "itemTitle"; ascendingOrder: true}
    ]

    property list<QtObject> idSorter:
    [
        RoleSorter { roleName: "id"; ascendingOrder: true}
    ]

    property list<QtObject> countrySorter:
    [
        RoleSorter { roleName: "countries"; ascendingOrder: true},
        RoleSorter { roleName: "title" }
    ]

    property list<QtObject> languageSorter:
    [
        RoleSorter { roleName: "languages"; ascendingOrder: true},
        RoleSorter { roleName: "title" }
    ]

    property list<QtObject> genreSorter:
    [
        RoleSorter { roleName: "genre"; ascendingOrder: true},
        RoleSorter { roleName: "title" }
    ]

    property list<QtObject> proxyRoles2:
    [
        ExpressionRole { name: "title"; expression: model.Title },
        ExpressionRole { name: "icon"; expression: getIconURL(model.Artwork); },
        ExpressionRole { name: "player"; expression: "Internal" }
    ]

    SortFilterProxyModel
    {
        id: proxyModel
        filters: recordingsFilter
        sorters: titleSorter
        //proxyRoles: proxyRoles2
        //proxyRoles: ExpressionRole { name: "title"; expression: model.Title }
        sourceModel: listModel
    }

    ListModel
    {
        id: listModel
    }

    XmlListModel
    {
        id: recordingDetailsModel

        signal loaded();

        source: settings.masterBackendV2 + "/Dvr/GetRecordedList?Descending=True&Details=False&IncCast=False&IncRecording=False&IncChannel=False&IgnoreLiveTV=True&IgnoreDeleted=True&start=0&count=1"

        query: "/ProgramList"
        XmlRole { name: "TotalItems"; query: "TotalAvailable/number()" }

        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                log.debug(Verbose.MODEL, "recordingDetailsModel: READY - Found " + count + " details");
                log.info(Verbose.MODEL, "recordingDetailsModel: Found " + get(0).TotalItems + " recordings");
                recordingsModel.totalRecordings = get(0).TotalItems;
                recordingsModel.start();
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "recordingDetailsModel: LOADING - " + source);
            }

            if (status === XmlListModel.Error)
            {
                log.error(Verbose.MODEL, "recordingDetailsModel: ERROR: " + errorString() + " - " + source);
            }
        }
    }

    XmlListModel
    {
        id: recordingsModel

        property int startIndex: 0
        property int itemCount: 100
        property int totalRecordings: 0

        signal loaded();

        query: "/ProgramList/Programs/Program"
        XmlRole { name: "Title"; query: "Title/string()" }
        XmlRole { name: "SubTitle"; query: "SubTitle/string()" }
        XmlRole { name: "Description"; query: "Description/string()" }
        XmlRole { name: "Category"; query: "Category/string()" }
        //XmlRole { name: "Duration"; query: "Details/Duration/number()" }
        XmlRole { name: "ChanId"; query: "Channel/ChanId/string()" }
        XmlRole { name: "ChanNum"; query: "Channel/ChanNum/string()" }
        XmlRole { name: "CallSign"; query: "Channel/CallSign/string()" }
        XmlRole { name: "ChannelName"; query: "Channel/ChannelName/string()" }
        XmlRole { name: "RecGroup"; query: "Recording/RecGroup/string()" }
        XmlRole { name: "StartTime"; query: "StartTime/string()" }
        XmlRole { name: "AirDate"; query: "AirDate/string()" }
        XmlRole { name: "FileName"; query: "FileName/string()" }
        XmlRole { name: "HostName"; query: "HostName/string()" }

        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                log.debug(Verbose.MODEL, "recordingsModel: READY - Found " + count + " recordings");
                doLoad();
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "recordingsModel: LOADING - " + source);
            }

            if (status === XmlListModel.Error)
            {
                log.error(Verbose.MODEL, "recordingsModel: ERROR: " + errorString() + " - " + source);
            }
        }

        function start()
        {
            listModel.clear();
            startIndex = 0;
            var _itemCount = Math.min(itemCount, totalRecordings);
            source = settings.masterBackendV2 + "/Dvr/GetRecordedList?Descending=True&Details=True&IncCast=False&IncRecording=True&IncChannel=True&IgnoreLiveTV=True&IgnoreDeleted=True&StartIndex=" + startIndex + "&Count=" + itemCount
        }

        function doLoad()
        {
            var x;

            for (x = 0; x < count; x++)
            {
                listModel.append({"id": startIndex + x, "title": get(x).Title, "description": get(x).Description, "icon": "", "player": "VLC", "url": "", "Duration": 0,
                                  "ChannelName": get(x).ChannelName, "Category": get(x).Category, "RecGroup": get(x).RecGroup, "StartTime": get(x).StartTime, "AirDate": get(x).AirDate === undefined ? "" : get(x).AirDate,
                                  "FileName": get(x).FileName, "HostName": get(x).HostName
                                 });
            }

            startIndex += count;

            if (startIndex >= totalRecordings)
            {
                var titles = [];
                var genres = [];
                var recgroups = [];

                root.titleList.clear();
                root.genreList.clear();
                root.recgroupList.clear();

                for (x = 0; x < listModel.count; x++)
                {
                    if (titles.indexOf(listModel.get(x).title) < 0)
                        titles.push(listModel.get(x).title);

                    if (genres.indexOf(listModel.get(x).Category) < 0)
                        genres.push(listModel.get(x).Category);

                    if (recgroups.indexOf(listModel.get(x).RecGroup) < 0)
                        recgroups.push(listModel.get(x).RecGroup);
                }

                titles.sort();

                for (x = 0; x < titles.length; x++)
                    root.titleList.append({"item": titles[x]});

                genres.sort();

                for (x = 0; x < genres.length; x++)
                    root.genreList.append({"item": genres[x]});

                recgroups.sort();

                for (x = 0; x < recgroups.length; x++)
                    root.recgroupList.append({"item": recgroups[x]});

                root.loadingFinished = true;
                root.loadingNode.subNodes.clear();

                expandNode(undefined, "", root.loadingNode);
                root.loaded();
            }
            else
            {
                if (root.loadingNode !== undefined && root.loadingNode.itemData === "Recordings")
                    root.loadingNode.subNodes.get(0).itemTitle = "Loading " + parseInt((startIndex / totalRecordings) * 100) + "% ...";

                var _itemCount = Math.min(itemCount, totalRecordings - startIndex);
                source = settings.masterBackendV2 + "/Dvr/GetRecordedList?Descending=True&Details=True&IncCast=False&IncRecording=True&IncChannel=True&IgnoreLiveTV=True&IgnoreDeleted=True&StartIndex=" + startIndex + "&Count=" + _itemCount
            }
        }
    }

    function expandNode(tree, path, node)
    {
        var x;

        node.expanded  = true

        // if we are still loading data just show a loading node
        if (!root.loadingFinished)
        {
            if (node.itemData === "Recordings")
            {
                root.loadingNode = node;
                node.subNodes.append({"parent": node, "itemTitle": "Loading 0% ...", "itemData": "LoadingRecordings", "checked": false, "expanded": true, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Loading})
                return;
            }
        }

        if (node.type === SourceTreeModel.NodeType.Root_Title)
        {
            node.subNodes.append({"parent": node, "itemTitle": "<All Recordings>", "itemData": "AllRecordings", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Recordings_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Titles", "itemData": "Titles", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Recordings_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Genres", "itemData": "Genres", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Recordings_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Record Groups", "itemData": "SGroups", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Recordings_Filters})
        }
        else if (node.type === SourceTreeModel.NodeType.Recordings_Filters)
        {
            if (node.itemData === "AllRecordings")
            {
                for (x = 0; x < proxyModel.count; x++)
                {
                    var prog = proxyModel.get(x);
                    node.subNodes.append({
                                             "parent": node, "itemTitle": prog.title, "itemData": String(prog.RecordingID), "checked": false, "expanded": true, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Recordings_Program,
                                             "player": "VLC", "url": prog.FileName, "genre": prog.Category, "AirDate": prog.AirDate, "Description": prog.description, "StartTime": prog.StartTime, "ChannelName": prog.ChannelName
                                         })
                }
            }
            else if (node.itemData === "Titles")
            {
                for (x = 0; x < root.titleList.count; x++)
                    node.subNodes.append({"parent": node, "itemTitle": root.titleList.get(x).item, "itemData": root.titleList.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Recordings_Filter_Title})
            }
            else if (node.itemData === "Genres")
            {
                for (x = 0; x < root.genreList.count; x++)
                    node.subNodes.append({"parent": node, "itemTitle": root.genreList.get(x).item, "itemData": root.genreList.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Recordings_Filter_Genre})
            }
            else if (node.itemData === "SGroups")
            {
                for (x = 0; x < root.recgroupList.count; x++)
                    node.subNodes.append({"parent": node, "itemTitle": root.recgroupList.get(x).item, "itemData": root.recgroupList.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Recordings_Filter_RecGroup})
            }
        }
        else if (node.type === SourceTreeModel.NodeType.Recordings_Filter_Title)
        {
            genreFilter.value = "";
            recGroupFilter.recGroup = "";
            titleFilter.value = node.itemData;

            for (x = 0; x < proxyModel.count; x++)
            {
                var prog = proxyModel.get(x);
                node.subNodes.append({
                                         "parent": node, "itemTitle": prog.title, "itemData": String(prog.RecordingID), "checked": false, "expanded": true, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Recordings_Program,
                                         "player": "VLC", "url": prog.FileName, "genre": prog.Category, "airdate": prog.AirDate, "Description": prog.description, "StartTime": prog.StartTime, "ChannelName": prog.ChannelName
                                     })
            }
        }
        else if (node.type === SourceTreeModel.NodeType.Recordings_Filter_Genre)
        {
            recGroupFilter.recGroup = "";
            titleFilter.value = "";
            genreFilter.value = node.itemData;

            for (x = 0; x < proxyModel.count; x++)
            {
                var prog = proxyModel.get(x);
                node.subNodes.append({
                                         "parent": node, "itemTitle": prog.title, "itemData": String(prog.RecordingID), "checked": false, "expanded": true, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Recordings_Program,
                                         "player": "VLC", "url": prog.FileName, "genre": prog.Category, "airdate": prog.AirDate, "Description": prog.description, "StartTime": prog.StartTime, "ChannelName": prog.ChannelName
                                     })
            }
        }
        else if (node.type === SourceTreeModel.NodeType.Recordings_Filter_RecGroup)
        {
            genreFilter.value = "";
            titleFilter.value = "";
            recGroupFilter.recGroup = "";
            recGroupFilter.recGroup = node.itemData;

            for (x = 0; x < proxyModel.count; x++)
            {
                var prog = proxyModel.get(x);
                node.subNodes.append({
                                         "parent": node, "itemTitle": prog.title, "itemData": String(prog.RecordingID), "checked": false, "expanded": true, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Recordings_Program,
                                         "player": "VLC", "url": prog.FileName, "genre": prog.Category, "airdate": prog.AirDate, "Description": prog.description, "StartTime": prog.StartTime, "ChannelName": prog.ChannelName
                                     })
            }
        }
    }

    function getIconURL(artwork)
    {
        if (!artwork || !artwork.ArtworkInfos || artwork.ArtworkInfos === undefined)
        {
            return mythUtils.findThemeFile("images/grid_noimage.png");
        }

        var coverArt = "";
        var fanArt = "";
        var banner = "";

        for (let x = 0; x < artwork.ArtworkInfos.length; x++)
        {
            if (artwork.ArtworkInfos[x].Type === "coverart")
                coverArt = artwork.ArtworkInfos[x].URL;
            else if (artwork.ArtworkInfos[x].Type === "fanart")
                fanArt = artwork.ArtworkInfos[x].URL;
            else if (artwork.ArtworkInfos[x].Type === "banner")
                banner = artwork.ArtworkInfos[x].URL;
        }

        if (coverArt !== "")
            return settings.masterBackendV2 + coverArt;

        if (fanArt !== "")
            return settings.masterBackendV2 + fanArt;

        if (banner !== "")
            return settings.masterBackendV2 + banner;

        return mythUtils.findThemeFile("images/grid_noimage.png");
    }
}
