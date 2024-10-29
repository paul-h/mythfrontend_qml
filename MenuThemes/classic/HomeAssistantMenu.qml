import QtQuick

ListModel
{
    id: weatherMenu
    property string logo: "title/title_setup.png"
    property string title: "Home Assistant Menu"

    ListElement
    {
        menutext: "Temperature Dashboard"
        loaderSource: "WebBrowser.qml"
        waterMark: "watermark/weather.png"
        url: "http://172.20.30.110:8123/dashboard-weather/temperature"
        zoom: 1.0
    }
    ListElement
    {
        menutext: "Weather Station Dashboard"
        loaderSource: "WebBrowser.qml"
        waterMark: "watermark/weather.png"
        url: "http://172.20.30.110:8123/dashboard-weather/default_view"
        zoom: 1.0
    }
    ListElement
    {
        menutext: "Humidity Dashboard"
        loaderSource: "WebBrowser.qml"
        waterMark: "watermark/weather.png"
        url: "http://172.20.30.110:8123/dashboard-weather/humidity"
        zoom: 1.0
    }
}
