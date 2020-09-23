import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: channelsModel
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

    onSourceIdChanged: updateSource()
    onChannelGroupIdChanged: updateSource()
    onStartIndexChanged: updateSource()
    onItemCountChanged: updateSource()
    onDetailsChanged: updateSource()
    onOnlyVisibleChanged: updateSource()
    onOrderByNameChanged: updateSource()
    onGroupByCallsignChanged: updateSource()

    function updateSource()
    {
        var url = settings.masterBackend + "Channel/GetChannelInfoList?Details=" + (details ? "true" : "false")

        if (sourceId != -1)
            url += "&SourceId=" + sourceId;

        if (channelGroupId != -1)
            url += "&ChannelGroupId=" + channelGroupId;

        if (startIndex != -1)
            url += "&StartIndex=" + startIndex;

        if (itemCount != -1)
            url += "&Count=" + itemCount;

        if (orderByName)
            url += "&OrderByName=true"

        if (groupByCallsign || sourceId == -1)
            url += "&GroupByCallsign=true"

        source = url;
    }

    query: "/ChannelInfoList/ChannelInfos/ChannelInfo"

    XmlRole { name: "ChanId"; query: "ChanId/number()" }
    XmlRole { name: "ChanNum"; query: "ChanNum/number()" }
    XmlRole { name: "CallSign"; query: "CallSign/string()" }
    XmlRole { name: "IconURL"; query: "IconURL/string()" }
    XmlRole { name: "ChannelName"; query: "ChannelName/string()" }
    XmlRole { name: "SourceId"; query: "SourceId/number()" }
    XmlRole { name: "XMLTVID"; query: "XMLTVID/string()" }
    XmlRole { name: "MplexId"; query: "MplexId/number()" }

    XmlRole { name: "title"; query: "concat(ChanNum/string(), xs:string(' - '), ChannelName/string())" }
    XmlRole { name: "player"; query: "xs:string('VLC')" }
    XmlRole { name: "url"; query: "concat(xs:string('myth://type=livetv:server=" + _ip + "'), xs:string(':encoder=1:channum='), ChanNum/string(), xs:string(':pin=" + _pin + "'))" }
    XmlRole { name: "icon"; query: "concat(xs:string('" + settings.masterBackend + "'), xs:string('Guide/GetChannelIcon?ChanId='), ChanId/string())" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "ChannelsModel: Found " + count + " channels");
            loaded();
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "ChannelsModel: LOADING - " + source.toString());
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "ChannelsModel: ERROR: " + errorString() + " - " + source.toString());
        }
    }

    function extractIP(host)
    {
        var r = /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/;

        var t = host.match(r);
        return t[0];
    }
}
