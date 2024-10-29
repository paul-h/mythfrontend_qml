import QtQuick

QtObject
{
    property string source: ""
    property var rawJSON: null

    property string units: "metric" // imperial, metric, mixed

    property string description: ""
    property string conditions: ""
    property string icon: ""

    property string obsTimeUtc: ""
    property string obsTimeLocal: ""
    property int    epoch: 0

    property string neighborhood: ""
    property string softwareType: ""
    property string country: ""
    property double lon: 0
    property double lat: 0
    property double elev: 0

    property double solarRadiation: 0
    property int    uv: 0
    property double solarEnergy: 0

    property int    winddir: 0
    property string windSector: ""
    property double windChill: 0
    property double windSpeed: 0
    property double windGust: 0

    property double temp: 0
    property double feelsLike: 0
    property double heatIndex: 0
    property double dewpt: 0
    property double pressure: 0
    property int    humidity: 0

    property double precipRate: 0
    property double precipTotal: 0
    property int    precipProbability: 0
    property string precipType: "n/a"

    property double snow: 0
    property int    snowDepth: 0

    property double visibility: 0
    property int    cloudCover: 0

    property string  sunrise: ""
    property int     sunriseEpoch: 0
    property string  sunset: ""
    property int     sunsetEpoch: 0
    property double  moonphase: 0

    property int    qcStatus: 0
    property string realtimeFrequency: ""
}
