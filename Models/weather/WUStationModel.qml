import QtQuick 2.0
import QtQuick.XmlListModel 2.0

import Process 1.0
import mythqml.net 1.0

Item
{
    id: root

    property string stationID: settings.wuStationId
    property string units: "m"      // m or e
    property string key: settings.wuAPIKey
    property alias weatherStation: station
    property alias currentConditions: current
    property alias dailySummary: summary
    property var observations: null

//    property var observations: WeatherConditionsModel[]

    signal currentConditionsLoaded();
    signal dailySummaryLoaded();
    signal observationLoaded();
    signal identityLoaded();

    Component.onCompleted:
    {
        getIdentity();
        getCurrentConditions();
        getDailySummary();
        getObservations();
    }

    WeatherStationModel
    {
        id: station
    }

    WeatherSummaryModel
    {
        id: summary
    }

    WeatherConditionsModel
    {
        id: current
    }

    function apiRequest(method, url, callback)
    {
        var http = new XMLHttpRequest();

        http.open(method, url, true);

        http.onerror = function ()
        {
          console.log("** An error occurred during the transaction '" + http.statusText);
        };

        http.onreadystatechange = function()
        {
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    var json = JSON.parse(http.responseText)
                    if (typeof(callback === 'function'))
                        callback(json)
                }
                else
                {
                    log.error(Verbose.MODEL, "apiRequest ERROR: got status '" + http.statusText + "' - " + http.responseText)
                    log.error(Verbose.MODEL, "Headers '" + http.getAllResponseHeaders())
                }
            }
        }

        http.send("");
    }

    function getCurrentConditions()
    {
        var url = "https://api.weather.com/v2/pws/observations/current?apiKey=%KEY%&stationId=%STATIONID%&numericPrecision=decimal&format=json&units=%UNITS%";
        url = url.replace("%KEY%", root.key);
        url = url.replace("%STATIONID%", root.stationID);
        url = url.replace("%UNITS%", root.units);

        console.log("getCurrentConditions: " + url);
        apiRequest("GET", url, function(json)
            {
                const sectors = ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW","N"]
//              console.log(JSON.stringify(json, null, 4));

                current.source = "Weather Underground";
                current.rawJSON = json;

                current.units = "metric";

                current.description = "n/a"; //FIXME
                current.conditions = "n/a"
                current.icon = ""

                current.obsTimeUtc = json.observations[0].obsTimeUtc;
                current.obsTimeLocal = json.observations[0].obsTimeLocal;
                current.epoch = json.observations[0].epoch;

                current.neighborhood = json.observations[0].neighborhood;
                current.softwareType = json.observations[0].softwareType;
                current.country = json.observations[0].country;
                current.lon = json.observations[0].lon;
                current.lat = json.observations[0].lat;
                current.elev = json.observations[0].metric.elev;

                current.solarRadiation = json.observations[0].solarRadiation;
                current.uv = json.observations[0].uv;
                current.solarEnergy = -1;

                current.winddir = json.observations[0].winddir;
                current.windSector = sectors[parseInt(current.winddir / 22.5)];
                current.windChill = json.observations[0].metric.windChill;
                current.windSpeed = json.observations[0].metric.windSpeed;
                current.windGust = json.observations[0].metric.windGust;

                current.temp = json.observations[0].metric.temp;
                current.feelsLike = current.temp; //FIXME
                current.heatIndex = json.observations[0].metric.heatIndex;
                current.dewpt = json.observations[0].metric.dewpt;
                current.pressure = json.observations[0].metric.pressure;
                current.humidity = json.observations[0].humidity;

                current.precipRate = json.observations[0].metric.precipRate;
                current.precipTotal = json.observations[0].metric.precipTotal;
                current.precipProbability = -1;
                current.precipType = ""; //FIXME

                current.snow = -1; //FIXME
                current.snowDepth = -1; //FIXME

                current.visibility = -1; //FIXME
                current.cloudCover = -1; //FIXME

                current.sunrise = "";
                current.sunriseEpoch = 0
                current.sunset = ""
                current.sunsetEpoch = 0
                current.moonphase = -1

                current.qcStatus = json.observations[0].qcStatus;
                current.realtimeFrequency = json.observations[0].realtimeFrequency;

                root.currentConditionsLoaded();
            })
    }

    function getDailySummary()
    {
        var url = "https://api.weather.com/v2/pws/dailysummary/1day?apiKey=%KEY%&stationId=%STATIONID%&numericPrecision=decimal&format=json&units=%UNITS%";
        url = url.replace("%KEY%", root.key);
        url = url.replace("%STATIONID%", root.stationID);
        url = url.replace("%UNITS%", root.units);

        apiRequest("GET", url, function(json)
            {
                console.log(JSON.stringify(json, null, 4));
                summary.source = "Weather Underground";
                summary.rawJSON = json;
                summary.units = "metric";
                summary.obsTimeUtc = json.summaries[0].obsTimeUtc;
                summary.obsTimeLocal = json.summaries[0].obsTimeLocal
                summary.epoch = json.summaries[0].epoch;

                summary.lon = json.summaries[0].lon;
                summary.lat = json.summaries[0].lat;

                summary.solarRadiationHigh = json.summaries[0].solarRadiationHigh;
                summary.uvHigh = json.summaries[0].uvHigh;

                summary.winddirAverage = json.summaries[0].winddirAvg;
                summary.windChillHigh = json.summaries[0].metric.windchillHigh;
                summary.windChillLow = json.summaries[0].metric.windchillLow;
                summary.windChillAverage = json.summaries[0].metric.windchillAvg;

                summary.windSpeedHigh = json.summaries[0].metric.windspeedHigh;
                summary.windSpeedLow = json.summaries[0].metric.windspeedLow;
                summary.windSpeedAverage = json.summaries[0].metric.windspeedAvg;

                summary.windGustHigh = json.summaries[0].metric.windgustHigh;
                summary.windGustLow = json.summaries[0].metric.windgustLow;
                summary.windGustAverage = json.summaries[0].metric.windgustAvg;

                summary.tempHigh = json.summaries[0].metric.tempHigh;
                summary.tempLow = json.summaries[0].metric.tempLow;
                summary.tempAverage = json.summaries[0].metric.tempAvg;

                summary.heatIndexHigh = json.summaries[0].metric.heatindexHigh;
                summary.heatIndexLow = json.summaries[0].metric.heatindexLow;
                summary.heatIndexAverage = json.summaries[0].metric.heatindexAvg;

                summary.dewptHigh = json.summaries[0].metric.dewptHigh;
                summary.dewptLow = json.summaries[0].metric.dewptLow;
                summary.dewptAverage = json.summaries[0].metric.dewptAvg;

                summary.pressureMin = json.summaries[0].metric.pressureMin;
                summary.pressureMax = json.summaries[0].metric.pressureMax;
                summary.pressureTrend = json.summaries[0].metric.pressureTrend;

                summary.humidityHigh = json.summaries[0].humidityHigh;
                summary.humidityLow = json.summaries[0].humidityLow;
                summary.humidityAverage = json.summaries[0].humidityAvg;

                summary.precipRate = json.summaries[0].metric.precipRate;
                summary.precipTotal = json.summaries[0].metric.precipTotal;

                summary.qcStatus = json.summaries[0].qcStatus;

                root.dailySummaryLoaded();
            })
    }

    function getObservations()
    {
        var url = "https://api.weather.com/v2/pws/observations/all/1day?apiKey=%KEY%&stationId=%STATIONID%&numericPrecision=decimal&format=json&units=%UNITS%";
        url = url.replace("%KEY%", root.key);
        url = url.replace("%STATIONID%", root.stationID);
        url = url.replace("%UNITS%", root.units);
        console.log("getObservations: " + url);

        apiRequest("GET", url, function(json)
            {
//                console.log(JSON.stringify(json, null, 4));
                root.observations = json;
                root.observationLoaded();
            })
    }

    function getIdentity()
    {
        var url = "https://api.weather.com/v2/pwsidentity?apiKey=%KEY%&stationId=%STATIONID%&format=json&units=%UNITS%";
        url = url.replace("%KEY%", root.key);
        url = url.replace("%STATIONID%", root.stationID);
        url = url.replace("%UNITS%", root.units);
        console.log("getIdentity: " + url);
        apiRequest("GET", url, function(json)
            {
//                console.log(JSON.stringify(json, null, 4));
                station.source = "Weather Underground";
                station.rawJSON = json;
                station.id = json.ID;
                station.location = json.neighborhood;
                station.lastUpdate = json.lastUpdateTime;
                station.description = "";
                root.identityLoaded();
            })
    }
}
