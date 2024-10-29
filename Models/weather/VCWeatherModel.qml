import QtQuick

import Process 1.0
import mythqml.net 1.0

Item
{
    id: root

    signal loaded();

    property string baseURL: "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/"
    property string location: settings.vcLocation
    property string units: "metric"      // us, uk or metric
    property string key: settings.vcAPIKey

    property alias weatherStation: station
    property alias currentConditions: current
    property alias dailySummary: summary
    property var observations: null
    property alias forecast: forecastModel

    signal currentConditionsLoaded();
    signal dailySummaryLoaded();
    signal observationLoaded();
    signal identityLoaded();
    signal forecastLoaded();

    property string _iconPath: "weather/VC1/"

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

    WeatherForecastModel
    {
        id: forecastModel
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

    function getIdentity()
    {
//        apiRequest("GET", url, function(json)
//            {
//                station.source = "Visual Crossing";
//                station.rawJSON = json;
//                station.id = json.ID;
//                station.location = json.neighborhood;
//                station.lastUpdate = json.lastUpdateTime;
//                station.description = "";
//                root.identityLoaded();
//            })
    }

    function getDailySummary()
    {
//        apiRequest("GET", baseURL + location + "?unitGroup=" + units + "&key=" + key + "&contentType=json", function(json)
//            {
//                console.log(JSON.stringify(json, null, 4));
//                summary.source = "Weather Underground";
//                summary.rawJSON = json;
//                summary.units = "metric";
//                summary.obsTimeUtc = json.summaries[0].obsTimeUtc;
//                summary.obsTimeLocal = json.summaries[0].obsTimeLocal
//                summary.epoch = json.summaries[0].epoch;

//                summary.lon = json.summaries[0].lon;
//                summary.lat = json.summaries[0].lat;

//                summary.solarRadiationHigh = json.summaries[0].solarRadiationHigh;
//                summary.uvHigh = json.summaries[0].uvHigh;

//                summary.winddirAverage = json.summaries[0].winddirAvg;
//                summary.windChillHigh = json.summaries[0].metric.windchillHigh;
//                summary.windChillLow = json.summaries[0].metric.windchillLow;
//                summary.windChillAverage = json.summaries[0].metric.windchillAvg;

//                summary.windSpeedHigh = json.summaries[0].metric.windspeedHigh;
//                summary.windSpeedLow = json.summaries[0].metric.windspeedLow;
//                summary.windSpeedAverage = json.summaries[0].metric.windspeedAvg;

//                summary.windGustHigh = json.summaries[0].metric.windgustHigh;
//                summary.windGustLow = json.summaries[0].metric.windgustLow;
//                summary.windGustAverage = json.summaries[0].metric.windgustAvg;

//                summary.tempHigh = json.summaries[0].metric.tempHigh;
//                summary.tempLow = json.summaries[0].metric.tempLow;
//                summary.tempAverage = json.summaries[0].metric.tempAvg;

//                summary.heatIndexHigh = json.summaries[0].metric.heatindexHigh;
//                summary.heatIndexLow = json.summaries[0].metric.heatindexLow;
//                summary.heatIndexAverage = json.summaries[0].metric.heatindexAvg;

//                summary.dewptHigh = json.summaries[0].metric.dewptHigh;
//                summary.dewptLow = json.summaries[0].metric.dewptLow;
//                summary.dewptAverage = json.summaries[0].metric.dewptAvg;

//                summary.pressureMin = json.summaries[0].metric.pressureMin;
//                summary.pressureMax = json.summaries[0].metric.pressureMax;
//                summary.pressureTrend = json.summaries[0].metric.pressureTrend;

//                summary.humidityHigh = json.summaries[0].humidityHigh;
//                summary.humidityLow = json.summaries[0].humidityLow;
//                summary.humidityAverage = json.summaries[0].humidityAvg;

//                summary.precipRate = json.summaries[0].metric.precipRate;
//                summary.precipTotal = json.summaries[0].metric.precipTotal;

//                summary.qcStatus = json.summaries[0].qcStatus;

//                root.dailySummaryLoaded();
//            })
    }

    function getObservations()
    {

    }

    function getForeCast()
    {

    }

    function getCurrentConditions()
    {
        apiRequest("GET", baseURL + location + "?unitGroup=" + units + "&key=" + key + "&contentType=json", function(json)
            {

                //console.log(JSON.stringify(json, null, 4));

                // current conditions
                current.source = "Visual Crossing";
                current.rawJSON = json;
                current.units = "metric";

                current.description = json.description;
                current.conditions = json.currentConditions.conditions
                current.icon = _iconPath + json.currentConditions.icon + ".png";

                current.obsTimeUtc = json.currentConditions.datetime;
                current.obsTimeLocal = json.currentConditions.datetime; //FIXEME
                current.epoch = json.currentConditions.datetimeEpoch;

                current.neighborhood = json.address;
                current.softwareType = "n/a";
                current.country = "n/a";
                current.lon = json.latitude;
                current.lat = json.longitude;
                current.elev = NaN;

                current.solarRadiation = json.currentConditions.solarradiation;
                current.uv = json.currentConditions.uvindex;
                current.solarEnergy = json.currentConditions.solarenergy ? json.currentConditions.solarenergy : 0

                current.winddir = json.currentConditions.winddir;
                current.windSector = winddirToSector(json.currentConditions.winddir);
                current.windChill = json.currentConditions.temp; //FIXME
                current.windSpeed = json.currentConditions.windspeed;
                current.windGust = json.currentConditions.windgust === null ? json.currentConditions.windspeed: json.currentConditions.windgust;

                current.temp = json.currentConditions.temp;
                current.feelsLike = json.currentConditions.feelslike;
                current.heatIndex = 0; //FIXME
                current.dewpt = json.currentConditions.dew;
                current.pressure = json.currentConditions.pressure;
                current.humidity = json.currentConditions.humidity;

                current.precipRate = json.currentConditions.precip;
                current.precipTotal = 0; //FIXME
                current.precipProbability = json.currentConditions.precipprob === null ? -1 : json.currentConditions.precipprob;
                current.precipType = json.currentConditions.preciptype == null ? "" : json.currentConditions.preciptype;

                current.snow = json.currentConditions.snow;
                current.snowDepth = json.currentConditions.snowdepth;

                current.visibility = json.currentConditions.visibility;
                current.cloudCover = json.currentConditions.cloudcover;

                current.sunrise = json.currentConditions.sunrise;
                current.sunriseEpoch = json.currentConditions.sunriseEpoch
                current.sunset = json.currentConditions.sunset
                current.sunsetEpoch = json.currentConditions.sunsetEpoch
                current.moonphase = json.currentConditions.moonphase

                current.qcStatus = 0; //FIXME
                current.realtimeFrequency = "n/a";

                root.currentConditionsLoaded();

                // forecast data
                forecast.source = "Visual Crossing";
                forecast.rawJSON = json;
                forecast.units = "metric";

                forecast.datetime = json.currentConditions.datetime;
                forecast.datetimeEpoch = json.currentConditions.datetimeEpoch;
                forecast.description = json.description;
                forecast.location = json.address;
                forecast.fullLocation = json.resolvedAddress
                forecast.lat = json.latitude;
                forecast.lon = json.longitude;

                var days = json.days

                for (var x = 0; x < days.length; x++)
                {
                    forecast.days.append({
                                "datetime": days[x].datetime,
                                "datetimeEpoch": days[x].datetimeEpoch,
                                "tempmax": days[x].tempmax,
                                "tempmin": days[x].tempmin,
                                "temp": days[x].temp,
                                "feelslikemax": days[x].feelslikemax,
                                "feelslikemin": days[x].feelslikemin,
                                "feelslike": days[x].feelslike,
                                "dew": days[x].dew,
                                "humidity": days[x].humidity,
                                "precip": days[x].precip,
                                "precipprob": days[x].precipprob === null ? -1 : days[x].precipprob,
                                "precipcover": days[x].precipcover,
                                "preciptype": days[x].preciptype === null ? "n/a" : days[x].preciptype.join(),
                                "snow": days[x].snow,
                                "snowdepth": days[x].snowdepth,
                                "windgust": days[x].windgust === null ? days[x].windspeed : days[x].windgust,
                                "windspeed": days[x].windspeed,
                                "winddir": days[x].winddir,
                                "windsector": winddirToSector(days[x].winddir),
                                "pressure": days[x].pressure,
                                "cloudcover": days[x].cloudcover,
                                "visibility": days[x].visibility,
                                "solarradiation": days[x].solarradiation,
                                "solarenergy": days[x].solarenergy === null ? 0 : days[x].solarenergy,
                                "uvindex": days[x].uvindex,
                                "severerisk": days[x].severerisk,
                                "sunrise": days[x].sunrise,
                                "sunriseEpoch": days[x].sunriseEpoch,
                                "sunset": days[x].sunset,
                                "sunsetEpoch": days[x].sunsetEpoch,
                                "moonphase": days[x].moonphase,
                                "conditions": days[x].conditions,
                                "description": days[x].description,
                                "icon": _iconPath + days[x].icon + ".png",
                                "hours": getHourData(days[x].hours)
                                });
                }

                root.forecastLoaded();
            })
    }

    function getHourData(hours)
    {
        var hoursList = Qt.createQmlObject('import QtQuick; ListModel {}', root);

        // this should be an array of hour forecasts
        for (var x = 0; x < hours.length; x++)
        {
            hoursList.append({
                        "datetime": hours[x].datetime,
                        "datetimeEpoch": hours[x].datetimeEpoch,
                        "temp": hours[x].temp,
                        "feelslike": hours[x].feelslike,
                        "dew": hours[x].dew,
                        "humidity": hours[x].humidity,
                        "precip": hours[x].precip,
                        "precipprob": hours[x].precipprob,
                        "preciptype": hours[x].preciptype === null ? "n/a" : hours[x].preciptype.join(),
                        "snow": hours[x].snow,
                        "snowdepth": hours[x].snowdepth,
                        "windgust": hours[x].windgust,
                        "windspeed": hours[x].windspeed,
                        "winddir": hours[x].winddir,
                        "windsector": winddirToSector(hours[x].winddir),
                        "pressure": hours[x].pressure,
                        "cloudcover": hours[x].cloudcover,
                        "visibility": hours[x].visibility,
                        "solarradiation": hours[x].solarradiation,
                        "solarenergy": hours[x].solarenergy === null ? 0 : hours[x].solarenergy,
                        "uvindex": hours[x].uvindex,
                        "severerisk": hours[x].severerisk,
                        "conditions": hours[x].conditions,
                        "icon": _iconPath + hours[x].icon + ".png",
                        });
        }

        return hoursList;
    }

    function winddirToSector(winddir)
    {
        const sectors = ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW","N"];
        return sectors[parseInt(winddir / 22.5)];
    }
}
