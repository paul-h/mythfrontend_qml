import QtQuick

import mythqml.net 1.0
import SortFilterProxyModel 0.2
import SqlQueryModel 1.0

Item
{
    id: root

    property alias model: proxyModel
    property alias count: proxyModel.count

    property string tivoSDLineup: settings.tivoSDLineup

    signal loaded();

    Component.onCompleted:
    {
        loadFromSD();
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
        }
    ]

    property list<QtObject> chanNoSorter:
    [
        RoleSorter { roleName: "channo"; ascendingOrder: true}
    ]

    property list<QtObject> sdidSorter:
    [
        RoleSorter { roleName: "sdid"; ascendingOrder: true}
    ]

    property list<QtObject> nameSorter:
    [
        RoleSorter { roleName: "name"; ascendingOrder: true}
    ]

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

    function loadFromSD()
    {
        playerSources.sdAPI.getLineup(tivoSDLineup, doLoadFromSD);
    }

    function doLoadFromSD(json)
    {
        var x
        var map = new Map()

        for (x = 0; x < json.map.length; x++)
        {
            map.set(json.map[x].stationID, json.map[x].channel)
        }

        for (x = 0; x < json.stations.length; x++)
        {
            var stationID = json.stations[x].stationID;
            var name = json.stations[x].name;
            var callsign = json.stations[x].callsign;
            var logo = json.stations[x].stationLogo ? json.stations[x].stationLogo[0].URL : "";
            var channo = map.get(stationID)
            var xmltvid = "I" + stationID + ".json.schedulesdirect.org"

            listModel.append({"xmltvid" : xmltvid, "sdid": stationID, "channo": channo, "name": name, "callsign": callsign, "icon": logo });
        }

        // force the proxy model to reload
        proxyModel.invalidate();

        root.loaded();
    }
}
