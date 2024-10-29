import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

Item
{
    id: root

    property alias model: channelsModel
    property alias count: channelsModel.count

    property var categoryList: ListModel{}
    property var definitionList: ListModel{}

    XmlListModel
    {
        id: channelsModel
        source: "https://mythqml.net/download.php?f=channels.xml&v=" + version + "&s=" + systemid;
        query: "/channels/channel"
        XmlListModelRole { name: "ChanNo"; elementName: "ChanNo" } //number
        XmlListModelRole { name: "Name"; elementName: "Name" }
        XmlListModelRole { name: "Plus1"; elementName: "Plus1" } //number
        XmlListModelRole { name: "Definition"; elementName: "Definition" }
        XmlListModelRole { name: "Category"; elementName: "Category" }
        XmlListModelRole { name: "Icon"; elementName: "Icon" }
        XmlListModelRole { name: "SDId"; elementName: "SDId" }

        XmlListModelRole { name: "title"; elementName: "concat(ChanNo/string(), xs:string(' - '), Name/string())" } //FIXME Qt6
        XmlListModelRole { name: "player"; elementName: "xs:string('Tivo')" } //FIXME Qt6
        XmlListModelRole { name: "url"; elementName: "ChanNo" } // number
        XmlListModelRole { name: "icon"; elementName: "Icon" }

        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                log.debug(Verbose.MODEL, "TivoChannelsModel: READY - Found " + count + " channels");
                doLoad();
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "TivoChannelsModel: LOADING - " + source);
            }

            if (status === XmlListModel.Error)
            {
                log.error(Verbose.MODEL, "TivoChannelsModel: ERROR: " + errorString() + " - " + source);
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

        function doLoad()
        {
            var category;
            var categories = [];
            var definition;
            var definitions = [];
            var x;

            for (x = 0; x < count; x++)
            {
                category = get(x).Category;

                if (categories.indexOf(category) < 0)
                    categories.push(category);

                definition = get(x).Definition;

                if (definitions.indexOf(definition) < 0)
                    definitions.push(definition);
            }

            categories.sort();
            definitions.sort();

            for (x = 0; x < categories.length; x++)
                categoryList.append({"item": categories[x]});

            for (x = 0; x < definitions.length; x++)
                definitionList.append({"item": definitions[x]});
        }
    }

    function get(index)
    {
        return channelsModel.get(index);
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
                for (x = 0; x < channelsModel.count; x++)
                {
                    chan = channelsModel.get(x);

                    node.subNodes.append({
                                             "parent": node, "itemTitle": chan.title, "itemData": String(chan.ChanNo), "checked": false, "expanded": true, "icon": chan.Icon, "subNodes": [], type: SourceTreeModel.NodeType.TivoTV_Channel,
                                             "title": chan.title, "player": chan.player, "url": String(chan.url), "genre": chan.Category, "ChannelName": chan.Name, "SDID": chan.SDId
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

            for (x = 0; x < channelsModel.count; x++)
            {
                chan = channelsModel.get(x);

                // filter by Category/genre
                if (chan.Category === genre)
                    node.subNodes.append({
                                             "parent": node, "itemTitle": chan.title, "itemData": String(chan.ChanNo), "checked": false, "expanded": true, "icon": chan.Icon, "subNodes": [], type: SourceTreeModel.NodeType.TivoTV_Channel,
                                             "title": chan.title, "player": chan.player, "url": String(chan.url), "genre": chan.Category, "ChannelName": chan.Name, "SDID": chan.SDId
                                         })
            }
        }
        else if (node.type === SourceTreeModel.NodeType.TivoTV_Filter_Definition)
        {
            var definition = node.itemData;

            for (x = 0; x < channelsModel.count; x++)
            {
                chan = channelsModel.get(x);

                // filter by definition
                if (chan.Definition === definition)
                    node.subNodes.append({
                                             "parent": node, "itemTitle": chan.title, "itemData": String(chan.ChanNo), "checked": false, "expanded": true, "icon": chan.Icon, "subNodes": [], type: SourceTreeModel.NodeType.TivoTV_Channel,
                                             "title": chan.title, "player": chan.player, "url": String(chan.url), "genre": chan.Category, "ChannelName": chan.Name, "SDID": chan.SDId
                                         })
            }
        }
    }

    function getIndexFromId(channelId)
    {
        for (var x = 0; x < channelsModel.count; x++)
        {
            var channel = channelsModel.get(x);

            if (channel.ChanNo == channelId)
                return x;
        }

        return -1;
    }
}
