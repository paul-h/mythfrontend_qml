import QtQuick 2.0

QtObject
{
    property string source: ""
    property var rawJSON: null

    property string units: "metric" // imperial, metric, mixed

    property string obsTimeUtc: ""
    property string obsTimeLocal: ""
    property int    epoch: 0

    property double lon: 0
    property double lat: 0

    property double solarRadiationHigh: 0
    property int    uvHigh: 0

    property int    winddirAverage: 0
    property double windChillHigh: 0
    property double windChillLow: 0
    property double windChillAverage: 0

    property double windSpeedHigh: 0
    property double windSpeedLow: 0
    property double windSpeedAverage: 0

    property double windGustHigh: 0
    property double windGustLow: 0
    property double windGustAverage: 0

    property double tempHigh: 0
    property double tempLow: 0
    property double tempAverage: 0

    property double heatIndexHigh: 0
    property double heatIndexLow: 0
    property double heatIndexAverage: 0

    property double dewptHigh: 0
    property double dewptLow: 0
    property double dewptAverage: 0

    property double pressureMin: 0
    property double pressureMax: 0
    property double pressureTrend: 0

    property int    humidityHigh: 0
    property int    humidityLow: 0
    property int    humidityAverage: 0

    property double precipRate: 0
    property double precipTotal: 0

    property int    qcStatus: 0
    property string realtimeFrequency: ""
}
