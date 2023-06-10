import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import SortFilterProxyModel 0.2
import mythqml.net 1.0

Item
{
    id: root

    property alias model: channelsModel
    property int  sourceId: -1
    property int  channelGroupId: -1
    property int  startIndex: -1
    property int  itemCount: -1
    property bool details: true
    property bool onlyVisible: true
    property bool orderByName: false
    property bool groupByCallsign: true

    property string _ip: settings.masterIP;
    property string _pin: settings.securityPin;

    signal loaded();
    signal loadingStatus(int status);

    onSourceIdChanged: channelsModel.updateSource()
    onChannelGroupIdChanged: channelsModel.updateSource()
    onStartIndexChanged: channelsModel.updateSource()
    onItemCountChanged: channelsModel.updateSource()
    onDetailsChanged: channelsModel.updateSource()
    onOnlyVisibleChanged: channelsModel.updateSource()
    onOrderByNameChanged:channelsModel.updateSource()
    onGroupByCallsignChanged: channelsModel.updateSource()

    Component.onCompleted: channelsModel.updateSource()

    property string _category: ""
    property string _sort: "title"
    property string _webcamFilterFavorite: "Any"

    property list<QtObject> channelsFilter:
    [
        AllOf
        {
            ExpressionFilter
            {
                id: callSignFilter
                property var callsigns: []

                expression:
                {
                    if (callsigns.indexOf(CallSign) < 0)
                    {
                        callsigns.push(CallSign);
                        return true;
                    }

                    return false;
                }
                enabled: false; //root.groupByCallsign
            }

            ExpressionFilter
            {
                id: channelGroupFilter
                property string group: ""
                expression:
                {
                    var groupList = ChannelGroups.split(",");
                    for (var x = 0; x < groupList.length; x++)
                    {

                        if (groupList[x].trim() == group)
                            return true;
                    }

                    return false;
                }
                enabled: group !== ""
            }

            ValueFilter
            {
                id: sourceIdFilter
                //property int sourceId
                roleName: "SourceId"
                value: root.sourceId
                enabled: root.sourceId != -1
            }
        }
    ]

    property list<QtObject> channelNameSorter:
    [
        RoleSorter { roleName: "ChannelName"; ascendingOrder: true}
    ]

    property list<QtObject> chanNumSorter:
    [
        RoleSorter { roleName: "ChanNum"; ascendingOrder: true}
    ]

    property list<QtObject> callSignNumSorter:
    [
        RoleSorter { roleName: "CallSign"; ascendingOrder: true}
    ]

    SortFilterProxyModel
    {
        id: proxyModel
        //filters: channelsFilter
        sorters: chanNumSorter
        sourceModel: channelsModel
    }

    XmlListModel
    {
        id: channelsModel

        query: "/ChannelInfoList/ChannelInfos/ChannelInfo"

        XmlRole { name: "ChanId"; query: "ChanId/number()" }
        XmlRole { name: "ChanNum"; query: "ChanNum/number()" }
        XmlRole { name: "CallSign"; query: "CallSign/string()" }
        XmlRole { name: "IconURL"; query: "IconURL/string()" }
        XmlRole { name: "ChannelName"; query: "ChannelName/string()" }
        XmlRole { name: "SourceId"; query: "SourceId/number()" }
        XmlRole { name: "XMLTVID"; query: "XMLTVID/string()" }
        XmlRole { name: "MplexId"; query: "MplexId/number()" }
        XmlRole { name: "ChannelGroups"; query: "ChannelGroups/string()" }

        XmlRole { name: "title"; query: "concat(ChanNum/string(), xs:string(' - '), ChannelName/string())" }
        XmlRole { name: "player"; query: "xs:string('VLC')" }
        XmlRole { name: "url"; query: "concat(xs:string('myth://type=livetv:server=" + root._ip + "'), xs:string(':encoder=1:channum='), ChanNum/string(), xs:string(':pin=" + root._pin + "'))" }
        XmlRole { name: "icon"; query: "concat(xs:string('" + settings.masterBackend + "'), xs:string('Guide/GetChannelIcon?ChanId='), ChanId/string())" }

        onStatusChanged:
        {
            if (status === XmlListModel.Ready)
            {
                log.debug(Verbose.MODEL, "ChannelsModel: Found " + count + " channels");
                root.loaded();
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "ChannelsModel: LOADING - " + source);
            }

            if (status === XmlListModel.Error)
            {
                log.error(Verbose.MODEL, "ChannelsModel: ERROR: " + errorString() + " - " + source);
            }

            if (status === XmlListModel.Null)
            {
                log.debug(Verbose.MODEL, "ChannelsModel: NULL - " + source);
            }

            root.loadingStatus(status);
        }

        function updateSource()
        {
            var url = settings.masterBackend + "Channel/GetChannelInfoList?Details=" + (root.details ? "true" : "false")

            if (root.sourceId != -1)
                url += "&SourceId=" + sourceId;

            if (root.channelGroupId != -1)
                url += "&ChannelGroupId=" + channelGroupId;

            if (root.startIndex != -1)
                url += "&StartIndex=" + startIndex;

            if (root.itemCount != -1)
                url += "&Count=" + itemCount;

            if (root.orderByName)
                url += "&OrderByName=true"

            if (root.groupByCallsign)
                url += "&GroupByCallsign=true"

            callSignFilter.callsigns = [];

            channelsModel.source = url;
        }
    }

    function extractIP(host)
    {
        var r = /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/;
        var t = host.match(r);
        return t[0];
    }

    function expandNode(tree, path, node)
    {
        var callsigns = [];

        node.expanded  = true

        if (node.type === SourceTreeModel.NodeType.Root_Title)
        {
            node.subNodes.append({"parent": node, "itemTitle": "<All Channels>", "itemData": "AllChannels", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.MythTV_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Genres", "itemData": "Genres", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.MythTV_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Sources", "itemData": "Sources", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.MythTV_Filters})
        }
        else if (node.type === SourceTreeModel.NodeType.MythTV_Filters)
        {
            var x;
            var chan;

            if (node.itemData === "AllChannels")
            {
                for (x = 0; x < proxyModel.count; x++)
                {
                    chan = proxyModel.get(x);

                    // filter out duplicate channels with same callSign
                    if (callsigns.indexOf(chan.CallSign) < 0)
                    {
                        callsigns.push(chan.CallSign);

                        node.subNodes.append({
                                                 "parent": node, "itemTitle": chan.title + "(" + chan.CallSign + ")", "itemData": String(chan.ChanId), "checked": false, "expanded": true, "icon": chan.icon, "subNodes": [], type: SourceTreeModel.NodeType.MythTV_Channel,
                                                 "player": chan.player, "url": chan.url, "genre": chan.ChannelGroups, "ChannelName": chan.ChannelName, "SourceId": chan.SourceId, "XMLTVID": chan.XMLTVID, "MPlexId": chan.MplexId
                                             })
                    }
               }
            }
            else if (node.itemData === "Genres")
            {
                for (x = 0; x < playerSources.channelGroups.count; x++)
                    node.subNodes.append({"parent": node, "itemTitle": playerSources.channelGroups.get(x).Name, "itemData": String(playerSources.channelGroups.get(x).GroupId), "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.MythTV_Filter_Genre})
            }
            else if (node.itemData === "Sources")
            {
                for (var x = 0; x < captureCardModel.count; x++)
                {
                    var card = captureCardModel.get(x);
                    node.subNodes.append({"parent": node, "itemTitle": card.DisplayName, "itemData": String(card.SourceId), "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.MythTV_Filter_Source})
                }
            }
        }
        else if (node.type === SourceTreeModel.NodeType.MythTV_Filter_Genre)
        {
            var groupId = node.itemData;

            for (x = 0; x < proxyModel.count; x++)
            {
                chan = proxyModel.get(x);

                // filter by channel group
                var groupList = chan.ChannelGroups.split(",");
                if (groupList.indexOf(groupId) >= 0)
                {
                    // filter out duplicate channels with same callSign
                    if (callsigns.indexOf(chan.CallSign) < 0)
                    {
                        callsigns.push(chan.CallSign);
                        node.subNodes.append({
                                                 "parent": node, "itemTitle": chan.title + "(" + chan.CallSign + ")", "itemData": String(chan.ChanId), "checked": false, "expanded": true, "icon": chan.icon, "subNodes": [], type: SourceTreeModel.NodeType.MythTV_Channel,
                                                 "player": chan.player, "url": chan.url, "genre": chan.ChannelGroups, "ChannelName": chan.ChannelName, "SourceId": chan.SourceId, "XMLTVID": chan.XMLTVID, "MPlexId": chan.MplexId
                                             })
                    }
                }
            }
        }
        else if (node.type === SourceTreeModel.NodeType.MythTV_Filter_Source)
        {
            var sourceId = node.itemData;

            for (x = 0; x < proxyModel.count; x++)
            {
                chan = proxyModel.get(x);

                // filter by channel sourceId
                if (sourceId === String(chan.SourceId))
                {
                    // filter out duplicate channels with same callSign
                    if (callsigns.indexOf(chan.CallSign) < 0)
                    {
                        callsigns.push(chan.CallSign);
                        node.subNodes.append({
                                                 "parent": node, "itemTitle": chan.title + "(" + chan.CallSign + ")", "itemData": String(chan.ChanId), "checked": false, "expanded": true, "icon": chan.icon, "subNodes": [], type: SourceTreeModel.NodeType.MythTV_Channel,
                                                 "player": chan.player, "url": chan.url, "genre": chan.ChannelGroups, "ChannelName": chan.ChannelName, "SourceId": chan.SourceId, "XMLTVID": chan.XMLTVID, "MPlexId": chan.MplexId
                                             })
                    }
                }
            }
        }
    }
}
