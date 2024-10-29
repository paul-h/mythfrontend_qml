import QtQuick
import QtQuick.Layouts

import Screens 1.0
import Base 1.0
import Models 1.0
import SvgImage 1.0


BaseScreen
{
    defaultFocusItem: topGrid

    property var weather: vcWeather

    Component.onCompleted:
    {
        showTitle(false, "Current Conditions (VC)");
    }

    VCWeatherModel
    {
        id: vcWeather
        onForecastLoaded:  updateForecast();
    }

    WUStationModel
    {
        id: wuStation
    }

    Rectangle
    {
        anchors.fill: parent
        color: "black"
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            // red
            stack.push(Qt.resolvedUrl("Forecast.qml"), {forecast:  vcWeather.forecast});
        }
        else if (event.key === Qt.Key_F2)
        {
            // green
        }
        else if (event.key === Qt.Key_Left && ((currentIndex % 6) === 0 && previousFocusItem))
        {
        }
        else if (event.key === Qt.Key_M)
        {
        }
        else
            event.accepted = false;
    }

    GridLayout
    {
        id: topGrid
        x: xscale(5)
        y: yscale(5)
        width: parent.width - xscale(10)
        height: yscale(100)
        columns: 4
        rows: 1
        columnSpacing: xscale(5)

        Rectangle
        {
            color: "#24262c"
            Layout.fillWidth: true
            Layout.fillHeight: true

            InfoText
            {
                x: 5
                y: 0
                width: parent.width
                height: yscale(25)
                text: 'ⓘ WEATHER STATION <font  color="orange"><b>TIME </font>'
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            DigitalClock
            {
                x: xscale(110)
                y: yscale(20)
                width: xscale(180)
                height: yscale(25)
                format: "ddd MMM d yyyy"
                horizontalAlignment: Text.AlignHCenter
                timeText.fontPixelSize: xscale(16)
                timeText.fontColor: "white"
            }

            Rectangle
            {
                x: xscale(145)
                y: yscale(50)
                width: xscale(110)
                height: yscale(35)
                color: "#af4b3d"
                radius: xscale(4)

                DigitalClock
                {
                    anchors.fill: parent
                    format: "hh:mm:ss"
                    horizontalAlignment: Text.AlignHCenter
                    timeText.fontPixelSize: xscale(16)
                    timeText.fontColor: "white"
                }

            }
        }

        Rectangle
        {
            color: "#24262c"
            Layout.fillWidth: true
            Layout.fillHeight: true

            InfoText
            {
                x: 5
                y: 0
                width: parent.width
                height: yscale(25)
                text: 'ⓘ NEWS <font  color="#87ceeb"><b>BBC News</font>'
                fontColor: "white"
                fontPixelSize: xscale(12)
            }
        }

        Rectangle
        {
            color: "#24262c"
            Layout.fillWidth: true
            Layout.fillHeight: true

            InfoText
            {
                x: 5
                y: 0
                width: parent.width
                height: yscale(25)
                text: 'ⓘ WARNINGS <font  color="#fa8072"><b>METEOALARM</font>'
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InfoText
            {
                x: xscale(5)
                y: yscale(30)
                width: parent.width - xscale(10)
                height: parent.height - yscale(35)
                text: weather.currentConditions.conditions
                fontPixelSize: xscale(12)
                multiline: true
            }
        }

        Rectangle
        {
            color: "#24262c"
            Layout.fillWidth: true
            Layout.fillHeight: true

            InfoText
            {
                x: 5
                y: 0
                width: parent.width
                height: yscale(25)
                text: 'ⓘ WEATHER  <font  color="#fa8072"><b>ALERT</font>'
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InfoText
            {
                x: xscale(5)
                y: yscale(30)
                width: parent.width - xscale(10)
                height: parent.height - yscale(35)
                text: weather.currentConditions.description
                fontPixelSize: xscale(12)
                multiline: true
            }
        }
    }

    GridLayout
    {
        id: bottomGrid
        x: xscale(5)
        y: topGrid.height + yscale(10)
        anchors.margins: xscale(5)
        width: parent.width - xscale(10)
        height: parent.height - y - yscale(5)
        columns: 3
        rows: 3
        columnSpacing: xscale(5)
        rowSpacing: yscale(5)

        Rectangle
        {
            color: "#24262c"
            Layout.fillWidth: true
            Layout.fillHeight: true

            InfoText
            {
                x: 0
                y: 0
                width: parent.width
                height: yscale(25)
                text: "Temperature °C"
                horizontalAlignment: Text.AlignHCenter
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InfoText
            {
                x: (parent.width / 5) * 4
                y: 0
                width: xscale(100)
                height: yscale(25)
                text: '<font  color="green">⬤</font><font  color="white">&nbsp;16:56:21</font>'
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            Item
            {
                x: xscale(20)
                y: yscale(30)
                width: xscale(150)
                height: width

                Rectangle
                {
                    anchors.fill: parent
                    rotation: 90
                    gradient: Gradient
                    {
                        GradientStop { position: 0.0; color: "#91b12a" }
                        GradientStop { position: 1.0; color: "#fe7c39" }
                    }
                }

                InfoText
                {
                    x: xscale(10)
                    y: 0
                    width: parent.width - xscale(20)
                    height: yscale(30)
                    text: weather.dailySummary.tempHigh + "°C | " + weather.dailySummary.tempLow + "°C"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontColor: "white"
                    fontPixelSize: xscale(12)
                }

                InfoText
                {
                    x: xscale(10)
                    y: yscale(10)
                    width: parent.width - xscale(20)
                    height: parent.height - yscale(20)
                    text: weather.currentConditions.temp + "°C"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontColor: "white"
                    fontPixelSize: xscale(25)
                }

                Rectangle
                {
                    x: 0
                    y: parent.height - height
                    width: parent.width
                    height: yscale(25)
                    color: "#38383c"

                    InfoText
                    {
                        anchors.fill: parent
                        text: "Trend 📉 Steady"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        fontColor: "white"
                        fontPixelSize: xscale(12)
                    }
                }
            }

            // humidity
            Item
            {
                x: xscale(200)
                y: yscale(35)
                width: xscale(100)
                height: yscale(60)

                InfoText
                {
                    x: 0
                    y: 0
                    width: parent.width
                    height: yscale(20)
                    text: "Humidity"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontColor: "white"
                    fontPixelSize: xscale(12)
                }

                Rectangle
                {
                    x: 0
                    y: yscale(20)
                    width: parent.width
                    height: yscale(20)
                    color: "transparent"
                    border.width: xscale(1)
                    border.color: "gray"
                }

                Rectangle
                {
                    x: 0
                    y: yscale(20)
                    width: xscale(7)
                    height: yscale(20)
                    color: "orange"
                }

                InfoText
                {
                    x: xscale(10)
                    y: yscale(20)
                    width: parent.width - xscale(10)
                    height: yscale(20)
                    text: weather.currentConditions.humidity + "%   📉"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontColor: "white"
                    fontPixelSize: xscale(16)
                }
            }

            // dewpoint
            Item
            {
                x: xscale(310)
                y: yscale(35)
                width: xscale(100)
                height: yscale(60)

                InfoText
                {
                    x: 0
                    y: 0
                    width: parent.width
                    height: yscale(20)
                    text: "Dewpoint"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontColor: "white"
                    fontPixelSize: xscale(12)
                }

                Rectangle
                {
                    x: 0
                    y: yscale(20)
                    width: parent.width
                    height: yscale(20)
                    color: "transparent"
                    border.width: xscale(1)
                    border.color: "gray"
                }

                Rectangle
                {
                    x: 0
                    y: yscale(20)
                    width: xscale(7)
                    height: yscale(20)
                    color: "orange"
                }

                InfoText
                {
                    x: xscale(10)
                    y: yscale(20)
                    width: parent.width - xscale(10)
                    height: yscale(20)
                    text: weather.currentConditions.dewpt + "°C"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontColor: "white"
                    fontPixelSize: xscale(16)
                }
            }

            // feels like
            Item
            {
                x: xscale(200)
                y: yscale(120)
                width: xscale(100)
                height: yscale(60)

                InfoText
                {
                    x: 0
                    y: 0
                    width: parent.width
                    height: yscale(20)
                    text: "Feels Like"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontColor: "white"
                    fontPixelSize: xscale(12)
                }

                Rectangle
                {
                    x: 0
                    y: yscale(20)
                    width: parent.width
                    height: yscale(20)
                    color: "transparent"
                    border.width: xscale(1)
                    border.color: "gray"
                }

                Rectangle
                {
                    x: 0
                    y: yscale(20)
                    width: xscale(7)
                    height: yscale(20)
                    color: "orange"
                }

                InfoText
                {
                    x: xscale(10)
                    y: yscale(20)
                    width: parent.width - xscale(10)
                    height: yscale(20)
                    text: weather.currentConditions.feelsLike + "°C"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontColor: "white"
                    fontPixelSize: xscale(16)
                }
            }

            // Average Temp
            Item
            {
                x: xscale(310)
                y: yscale(80)
                width: xscale(100)
                height: yscale(60)

                InfoText
                {
                    x: 0
                    y: 0
                    width: parent.width
                    height: yscale(20)
                    text: "Average Today"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontColor: "white"
                    fontPixelSize: xscale(12)
                }

                Rectangle
                {
                    x: 0
                    y: yscale(20)
                    width: parent.width
                    height: yscale(20)
                    color: "transparent"
                    border.width: xscale(1)
                    border.color: "gray"
                }

                Rectangle
                {
                    x: 0
                    y: yscale(20)
                    width: xscale(7)
                    height: yscale(20)
                    color: "orange"
                }

                InfoText
                {
                    x: xscale(10)
                    y: yscale(20)
                    width: parent.width - xscale(10)
                    height: yscale(20)
                    text: weather.dailySummary.tempAverage + "°C"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontColor: "white"
                    fontPixelSize: xscale(16)
                }
            }
        }

        Rectangle
        {
            color: "#24262c"
            Layout.fillWidth: true
            Layout.fillHeight: true

            InfoText
            {
                x: 0
                y: 0
                width: parent.width
                height: yscale(25)
                text: "Current Conditions"
                horizontalAlignment: Text.AlignHCenter
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InternalPlayer
            {
                id: internalPlayer
                objectName: "webcam"
                x: xscale(65)
                y: yscale(25)
                width: parent.width - xscale(130)
                height: width / 1.77777777

                defaultFeedSource: "ZoneMinder Cameras"
                defaultCurrentFeed: 4
            }
        }

        Rectangle
        {
            color: "#24262c"
            Layout.fillWidth: true
            Layout.fillHeight: true

            InfoText
            {
                x: 0
                y: 0
                width: parent.width
                height: yscale(25)
                text: "Forecast"
                horizontalAlignment: Text.AlignHCenter
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InfoText
            {
                x: (parent.width / 5) * 4
                y: 0
                width: xscale(100)
                height: yscale(25)
                text: '<font  color="green">⬤</font><font  color="white">&nbsp;16:56:21</font>'
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            // today
            Item
            {
                id: todayForecast
                x: 0
                y: 20
                width: parent.width / 3
                height: parent.height - yscale(20)

                ListText
                {
                    id: day1Date
                    x: 0
                    y: yscale(5)
                    width: parent.width; height: yscale(30)
                    horizontalAlignment: Text.AlignHCenter
                    fontColor: theme.labelFontColor
                }
                Image
                {
                    id: day1Icon
                    x: (parent.width - width) / 2
                    y: yscale(25)
                    width: yscale(50)
                    height: width
                }
                ListText
                {
                    id: day1Conditions
                    x: 0
                    y: yscale(65)
                    width: parent.width;
                    height: yscale(30)
                    horizontalAlignment: Text.AlignHCenter
                    fontPixelSize: xscale(14)
                }

                ListText
                {
                    id: day1Temp
                    x: 0
                    y: yscale(80)
                    width: parent.width; height: yscale(50)
                    horizontalAlignment: Text.AlignHCenter
                }

                Image
                {
                    x: (parent.width - width) / 2
                    y: yscale(120)
                    width: yscale(25)
                    height: width
                    source: mythUtils.findThemeFile("weather/rain_drops.png");
                }
                ListText
                {
                    id: day1Rain
                    x: 0
                    y: yscale(140)
                    width: parent.width
                    height: yscale(40)
                    horizontalAlignment: Text.AlignHCenter
                    fontPixelSize: xscale(14)
                    multiline: true
                }

                ListText
                {
                    id: day1Wind
                    x: 0
                    y: yscale(160)
                    width: parent.width; height: yscale(50)
                    horizontalAlignment: Text.AlignHCenter
                    fontPixelSize: xscale(14)
                }
            }
        }

        Rectangle
        {
            color: "#24262c"
            Layout.fillWidth: true
            Layout.fillHeight: true

            InfoText
            {
                x: 0
                y: 0
                width: parent.width
                height: yscale(25)
                text: "Wind | Gust"
                horizontalAlignment: Text.AlignHCenter
                fontColor: "white"
                fontPixelSize: xscale(12)

                InfoText
                {
                    x: (parent.width / 5) * 4
                    y: 0
                    width: xscale(100)
                    height: yscale(25)
                    text: '<font  color="green">⬤</font><font  color="white">&nbsp;16:56:21</font>'
                    fontColor: "white"
                    fontPixelSize: xscale(12)
                }

                InfoText
                {
                    x: xscale(10)
                    y: yscale(10)
                    width: parent.width - xscale(20)
                    height: yscale(25)
                    text: "Wind Speed: " + weather.currentConditions.windSpeed
                    fontColor: "white"
                    fontPixelSize: xscale(12)
                }

                InfoText
                {
                    x: xscale(10)
                    y: yscale(40)
                    width: parent.width - xscale(20)
                    height: yscale(25)
                    text: "Wind Direction: " + weather.currentConditions.winddir + "° (" + weather.currentConditions.windSector + ")"
                    fontColor: "white"
                    fontPixelSize: xscale(12)
                }

                InfoText
                {
                    x: xscale(10)
                    y: yscale(70)
                    width: parent.width - xscale(20)
                    height: yscale(25)
                    text: "Wind Gust: " + weather.currentConditions.windGust
                    fontColor: "white"
                    fontPixelSize: xscale(12)
                }
            }
        }
        Rectangle
        {
            color: "#24262c"
            Layout.fillWidth: true
            Layout.fillHeight: true

            InfoText
            {
                x: 0
                y: 0
                width: parent.width
                height: yscale(25)
                text: "Barometer"
                horizontalAlignment: Text.AlignHCenter
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InfoText
            {
                x: (parent.width / 5) * 4
                y: 0
                width: xscale(100)
                height: yscale(25)
                text: '<font  color="green">⬤</font><font  color="white">&nbsp;16:56:21</font>'
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InfoText
            {
                x: xscale(10)
                y: yscale(10)
                width: parent.width -  xscale(20)
                height: yscale(25)
                text: weather.currentConditions.pressure
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InfoText
            {
                x: xscale(10)
                y: yscale(40)
                width: parent.width - xscale(10)
                height: yscale(20)
                text: "Icon: " + weather.currentConditions.icon
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontColor: "white"
                fontPixelSize: xscale(16)
            }

            Image
            {
                id: forecastImage
                x: xscale(50); y: yscale(50); width: xscale(60); height: width
                source: if (weather.currentConditions.icon)
                            mythUtils.findThemeFile(weather.currentConditions.icon);
                        else
                            mythUtils.findThemeFile("images/grid_noimage.png");
            }

            InfoText
            {
                x: xscale(10)
                y: yscale(70)
                width: parent.width - xscale(10)
                height: yscale(20)
                text: "Visibility: " +weather.currentConditions.visibility + " miles"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontColor: "white"
                fontPixelSize: xscale(16)
            }

            InfoText
            {
                x: xscale(10)
                y: yscale(100)
                width: parent.width - xscale(10)
                height: yscale(20)
                text: "Cloud Cover: " + weather.currentConditions.cloudCover + "%"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontColor: "white"
                fontPixelSize: xscale(16)
            }
        }

        Rectangle
        {
            color: "#24262c"
            Layout.fillWidth: true
            Layout.fillHeight: true

            InfoText
            {
                x: 0
                y: 0
                width: parent.width
                height: yscale(25)
                text: "Daylight"
                horizontalAlignment: Text.AlignHCenter
                fontColor: "white"
                fontPixelSize: xscale(12)

                InfoText
                {
                    x: (parent.width / 5) * 4
                    y: 0
                    width: xscale(100)
                    height: yscale(25)
                    text: '<font  color="green">⬤</font><font  color="white">&nbsp;16:56:21</font>'
                    fontColor: "white"
                    fontPixelSize: xscale(12)
                }

                InfoText
                {
                    x: xscale(10)
                    y: yscale(10)
                    width: parent.width - xscale(20)
                    height: yscale(25)
                    text: "Sunrise: " + weather.currentConditions.sunrise
                    fontColor: "white"
                    fontPixelSize: xscale(12)
                }

                InfoText
                {
                    x: xscale(10)
                    y: yscale(40)
                    width: parent.width - xscale(20)
                    height: yscale(25)
                    text: "Sunset: " + weather.currentConditions.sunset
                    fontColor: "white"
                    fontPixelSize: xscale(12)
                }

                InfoText
                {
                    x: xscale(10)
                    y: yscale(80)
                    width: parent.width - xscale(20)
                    height: yscale(25)
                    text: "Moon Phase: " + weather.currentConditions.moonphase
                    fontColor: "white"
                    fontPixelSize: xscale(12)
                }
            }
        }

        Rectangle
        {
            color: "#24262c"
            Layout.fillWidth: true
            Layout.fillHeight: true

            InfoText
            {
                x: 0
                y: 0
                width: parent.width
                height: yscale(25)
                text: "Rainfall Today"
                horizontalAlignment: Text.AlignHCenter
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InfoText
            {
                x: (parent.width / 5) * 4
                y: 0
                width: xscale(100)
                height: yscale(25)
                text: '<font  color="green">⬤</font><font  color="white">&nbsp;16:56:21</font>'
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InfoText
            {
                x: xscale(10)
                y: yscale(10)
                width: parent.width - xscale(20)
                height: yscale(25)
                text: "Rain Rate: " + weather.currentConditions.precipRate
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InfoText
            {
                x: xscale(10)
                y: yscale(40)
                width: parent.width - xscale(20)
                height: yscale(25)
                text: "Rain Total: " + weather.currentConditions.precipTotal
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InfoText
            {
                x: xscale(10)
                y: yscale(70)
                width: parent.width - xscale(20)
                height: yscale(25)
                text: "Rain Probability: " + weather.currentConditions.precipProbability
                fontColor: "white"
                fontPixelSize: xscale(12)
            }
        }

        Rectangle
        {
            color: "#24262c"
            Layout.fillWidth: true
            Layout.fillHeight: true

            InfoText
            {
                x: 0
                y: 0
                width: parent.width
                height: yscale(25)
                text: "Solar | UV-Index | Lux"
                horizontalAlignment: Text.AlignHCenter
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InfoText
            {
                x: (parent.width / 5) * 4
                y: 0
                width: xscale(100)
                height: yscale(25)
                text: '<font  color="green">⬤</font><font  color="white">&nbsp;16:56:21</font>'
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InfoText
            {
                x: xscale(10)
                y: yscale(10)
                width: parent.width - xscale(20)
                height: yscale(25)
                text: "UV Index: " + weather.currentConditions.uv
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InfoText
            {
                x: xscale(10)
                y: yscale(40)
                width: parent.width - xscale(20)
                height: yscale(25)
                text: "Solar Radiation: " + weather.currentConditions.solarRadiation + "W/m²"
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InfoText
            {
                x: xscale(10)
                y: yscale(80)
                width: parent.width - xscale(20)
                height: yscale(25)
                text: "Solar Energy: " + weather.currentConditions.solarEnergy + "MJ/m²"
                fontColor: "white"
                fontPixelSize: xscale(12)
            }
        }

        Rectangle
        {
            color: "#24262c"
            Layout.fillWidth: true
            Layout.fillHeight: true

            InfoText
            {
                x: 0
                y: 0
                width: parent.width
                height: xscale(25)
                text: "Air Quality Index"
                horizontalAlignment: Text.AlignHCenter
                fontColor: "white"
                fontPixelSize: xscale(12)
            }

            InfoText
            {
                x: (parent.width / 5) * 4
                y: 0
                width: xscale(100)
                height: xscale(25)
                text: '<font  color="green">⬤</font><font  color="white">&nbsp;16:56:21</font>'
                fontColor: "white"
                fontPixelSize: xscale(12)
            }
        }
    }

    Keys.onLeftPressed: previousFocusItem.focus = true;

    function updateForecast()
    {
        // today's forecast
        var date = new Date(weather.forecast.days.get(0).datetimeEpoch * 1000);
        day1Date.text = Qt.formatDateTime(date, "ddd");

        if (weather.forecast.days.get(0).icon)
            day1Icon.source = mythUtils.findThemeFile(weather.forecast.days.get(0).icon);
        else
            day1Icon.source = mythUtils.findThemeFile("images/grid_noimage.png");

        day1Conditions.text =  weather.forecast.days.get(0).conditions;

        day1Temp.text = formatTemp(weather.forecast.days.get(0).temp, true);

        day1Rain.text =  weather.forecast.days.get(0).precipprob <= 0 ?
                    formatDefault("", "0%", "#87ceeb") : formatDefault("", weather.forecast.days.get(0).precipprob + "%", "#87ceeb");

        day1Wind.text = formatDefault("Wind Speed: ", weather.forecast.days.get(0).windspeed + "mph", "#ff00ff") + formatDefault("<br>Wind Direction: ",  weather.forecast.days.get(0).winddir + " (" + weather.forecast.days.get(0).windsector + ")","#ff00ff");
    }

    function formatDefault(label, value, color)
    {
        return label + '<font  color="' + color + '"><b>' + value + '</b></font>';
    }

    function formatTemp(temp, metric)
    {
        const colors = ["#ff00ff","#9e00ff","#0000ff","#007eff","#00ccff","#05f7f7","#7fff00","#f7f705","#ffcc00","#ff9900","#ff4f00","#cc0000","#a90303","#ba3232"];
//                      -25      -20       -15      -10        -5       0        5         10         15        20        25        30        35        40        45+
        var colorIndex = parseInt((temp + 25) / 5);
        if (colorIndex < 0)
            colorIndex = 0;

        if (colorIndex > 13)
            colorIndex = 13;

        var color = colors[colorIndex];

        if (metric)
            return '<font  color="' + color + '"><b>' + Math.round(temp) + '°C</b></font>'
        else
            return '<font  color="' + color + '"><b>' + Math.round((temp * 9/5) + 32) + '°F</b></font>'
    }

    function formatUVIndex(uvindex)
    {
        const levels = ["no risk", "low",    "moderate", "high",   "very high", "extreme"]
        const colors = ["#cccccc", "#f7f705","#ffcc00",  "#ff9900","#ff4f00",   "#cc0000"];
//                          0        1 - 2     3 - 5       6 - 7     8 - 9         10
        var colorIndex = 0;

        if (uvindex <= 0)
            colorIndex = 0;

        if (uvindex === 1 || uvindex === 2)
            colorIndex = 1;

        if (uvindex === 3 || uvindex === 4 || uvindex === 5)
            colorIndex = 2;

        if (uvindex === 6 || uvindex === 7 || uvindex === 8)
            colorIndex = 3;

        if (uvindex === 9)
            colorIndex = 4;

        if (uvindex > 9)
            colorIndex = 5;

        var color = colors[colorIndex];
        var level = levels[colorIndex];

        return '<font  color="' + color + '"><b>' + uvindex + ' (' + level + ')' + '</b></font>';
    }
}
