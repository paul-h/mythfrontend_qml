import QtQuick 2.0
import QtQuick.XmlListModel 2.0

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

    source:
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

        if (groupByCallsign)
            url += "&GroupByCallsign=true"

        return url;
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

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            console.info("Status: " + "Channels - Found " + count + " channels");
        }

        if (status === XmlListModel.Loading)
        {
            console.log("Status: " + "Channels - LOADING - " + source.toString());
        }

        if (status === XmlListModel.Error)
        {
            console.log("Status: " + "Channels - ERROR: " + errorString + "\n" + source.toString());
        }
    }

    function extractIP(host)
    {
        var r = /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/;

        var t = host.match(r);
        return t[0];
    }
}
