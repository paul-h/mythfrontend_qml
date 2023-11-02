import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0
import SortFilterProxyModel 0.2
import SqlQueryModel 1.0

Item
{
    id: root

    property alias model: listModel
    property alias count: listModel.count

    property var definitionList: ListModel{}
    property var categoryList: ListModel{}

    signal loaded();

    Component.onCompleted:
    {
        loadFromDB();
    }

    property list<QtObject> channelFilter:
    [
        AllOf
        {
            ValueFilter
            {
                id: nameFilter
                roleName: "name"
                value: ""
                enabled: value !== ""
            }
            ValueFilter
            {
                id: categoryFilter
                roleName: "category"
                value: ""
                enabled: value !== ""
            }
        }
    ]

    property list<QtObject> chanNoSorter:
    [
        RoleSorter { roleName: "channo"; ascendingOrder: true}
    ]

    property list<QtObject> idSorter:
    [
        RoleSorter { roleName: "chanid"; ascendingOrder: true}
    ]

    property list<QtObject> nameSorter:
    [
        RoleSorter { roleName: "name"; ascendingOrder: true}
    ]

    property list<QtObject> categorySorter:
    [
        RoleSorter { roleName: "category"; ascendingOrder: true},
        RoleSorter { roleName: "title" }
    ]

    SqlQueryModel
    {
        id: channelModel

        sql: "SELECT chanid, channo, name, plus1, category, definition, sdid, icon
              FROM tivochannels ORDER BY channo";
    }

    SortFilterProxyModel
    {
        id: proxyModel
        filters: channelFilter
        sorters: chanNoSorter
        sourceModel: listModel
    }

    ListModel
    {
        id: listModel
    }

    function loadFromDB()
    {
        var x;
        var definitions = [];
        var categories = [];

        root.definitionList.clear();
        root.categoryList.clear();
        listModel.clear();

        channelModel.reload();

        while (channelModel.canFetchMore(channelModel.index(-1, -1)))
            channelModel.fetchMore(channelModel.index(-1, -1));

        for (x = 0; x < channelModel.rowCount(); x++)
        {
            var chanid = channelModel.data(channelModel.index(x, 0));
            var channo = channelModel.data(channelModel.index(x, 1));
            var name = channelModel.data(channelModel.index(x, 2));
            var plus1 = channelModel.data(channelModel.index(x, 3));
            var category = channelModel.data(channelModel.index(x, 4));
            var definition = channelModel.data(channelModel.index(x, 5));
            var sdid = channelModel.data(channelModel.index(x, 6));
            var icon = channelModel.data(channelModel.index(x, 7));
            listModel.append({"chanid": chanid, "channo": channo, "name": name, "plus1": plus1, "category": category, "definition": definition, "sdid": sdid, "icon": icon });

            if (definitions.indexOf(definition) < 0)
                definitions.push(definition);

            if (categories.indexOf(category) < 0)
                categories.push(category);
        }

        definitions.sort();

        for (x = 0; x < definitions.length; x++)
            root.definitionList.append({"item": definitions[x]});

        categories.sort();

        for (x = 0; x < categories.length; x++)
            root.categoryList.append({"item": categories[x]});

        // force the proxy model to reload
        proxyModel.invalidate();

        root.loaded();
    }

    function expandNode(tree, path, node)
    {
        var callsigns = [];

        node.expanded  = true

        if (node.type === SourceTreeModel.NodeType.Root_Title)
        {
            node.subNodes.append({"parent": node, "itemTitle": "<All Channels>", "itemData": "AllChannels", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.TivoTV_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Genres", "itemData": "Genres", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.TivoTV_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Definitions", "itemData": "Definitions", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.TivoTV_Filters})
        }
        else if (node.type === SourceTreeModel.NodeType.TivoTV_Filters)
        {
            var x;
            var chan;

            if (node.itemData === "AllChannels")
            {
                for (x = 0; x < listModel.count; x++)
                {
                    chan = listModel.get(x);

                    node.subNodes.append({
                                             "parent": node, "itemTitle": chan.channo + " - " + chan.name, "itemData": String(chan.chanid), "checked": false, "expanded": true, "icon": chan.icon, "subNodes": [], type: SourceTreeModel.NodeType.TivoTV_Channel,
                                             "title": chan.name, "player": "Tivo", "url": String(chan.channo), "genre": chan.category, "chanid": chan.chanid, "ChannelName": chan.name, "SDID": chan.sdid
                                         })
                }
            }
            else if (node.itemData === "Genres")
            {
                for (x = 0; x < categoryList.count; x++)
                    node.subNodes.append({"parent": node, "itemTitle": categoryList.get(x).item, "itemData": categoryList.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.TivoTV_Filter_Genre})
            }
            else if (node.itemData === "Definitions")
            {
                for (x = 0; x < definitionList.count; x++)
                    node.subNodes.append({"parent": node, "itemTitle": definitionList.get(x).item, "itemData": definitionList.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.TivoTV_Filter_Definition})
            }
        }
        else if (node.type === SourceTreeModel.NodeType.TivoTV_Filter_Genre)
        {
            var genre = node.itemData;

            for (x = 0; x < listModel.count; x++)
            {
                chan = listModel.get(x);

                // filter by Category/genre
                if (chan.Category === genre)
                    node.subNodes.append({
                                             "parent": node, "itemTitle": chan.title, "itemData": String(chan.chanid), "checked": false, "expanded": true, "icon": chan.icon, "subNodes": [], type: SourceTreeModel.NodeType.TivoTV_Channel,
                                             "title": chan.name, "player": "Tivo", "url": String(chan.channo), "genre": chan.category, "ChannelName": chan.name, "SDID": chan.sdid
                                         })
            }
        }
        else if (node.type === SourceTreeModel.NodeType.TivoTV_Filter_Definition)
        {
            var definition = node.itemData;

            for (x = 0; x < listModel.count; x++)
            {
                chan = listModel.get(x);

                // filter by definition
                if (chan.Definition === definition)
                    node.subNodes.append({
                                             "parent": node, "itemTitle": chan.title, "itemData": String(chan.chanid), "checked": false, "expanded": true, "icon": chan.icon, "subNodes": [], type: SourceTreeModel.NodeType.TivoTV_Channel,
                                             "title": chan.name, "player": "Tivo", "url": String(chan.url), "genre": chan.category, "ChannelName": chan.name, "SDID": chan.sdid
                                         })
            }
        }
    }

    function get(index)
    {
        return listModel.get(index);
    }

    function getIndexFromId(chanId)
    {
        for (var x = 0; x < listModel.count; x++)
        {
            var channel = listModel.get(x);

            if (channel.chanid == chanId)
                return x;
        }

        return -1;
    }
}
