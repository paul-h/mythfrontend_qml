import QtQuick

QtObject
{
    property string source: ""
    property var rawJSON: null

    property string units: "metric" // imperial, metric, mixed

    property string datetime: ""
    property int    datetimeEpoch: 0
    property string description: ""
    property string location: ""
    property string fullLocation: ""
    property double lon: 0
    property double lat: 0

    property var days:  ListModel {}
}
