import QtQuick 2.0

ListModel
{
    id: weatherMenu
    property string logo: "title/title_setup.png"
    property string title: "Weather Menu"

    ListElement
    {
        menutext: "Current Conditions (VisualCrossing)"
        loaderSource: "weather/CurrentConditions.qml"
        waterMark: "watermark/weather.png"
    }
    ListElement
    {
        menutext: "Current Conditions"
        loaderSource:"WebBrowser.qml"
        waterMark: "watermark/weather.png"
        url: "setting://WeatherCurrentConditions"
        zoom: 1.0
    }
    ListElement
    {
        menutext: "BBC Forecast"
        loaderSource:"WebBrowser.qml"
        waterMark: "watermark/weather.png"
        url: "setting://WeatherBBCForecast"
        zoom: 1.0
    }
    ListElement
    {
        menutext: "Met Office Forecast"
        loaderSource:"WebBrowser.qml"
        waterMark: "watermark/weather.png"
        url: "setting://WeatherMetOfficeForecast"
        zoom: 1.0
    }
    ListElement
    {
        menutext: "Lightning Map"
        loaderSource: "WebBrowser.qml"
        waterMark: "watermark/weather.png"
        url: "setting://WeatherLightningMap"
        zoom: 1.25
    }
    ListElement
    {
        menutext:"Rain Radar"
        loaderSource: "WebBrowser.qml"
        waterMark: "watermark/weather.png"
        url: "setting://WeatherRainRadar"
        zoom: 1.0
    }
    ListElement
    {
        menutext: "Met Office Video Forecast"
        loaderSource:"WebBrowser.qml"
        waterMark: "watermark/weather.png"
        url: "setting://WeatherVideoForecast"
        zoom: 1.0
        fullscreen: true
    }
}
