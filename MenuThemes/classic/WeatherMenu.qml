import QtQuick 2.0

ListModel
{
    id: weatherMenu
    property string logo: "title/title_setup.png"
    property string title: "Weather Menu"

    ListElement
    {
        menutext: "Current Conditions"
        loaderSource:"WebBrowser.qml"
        waterMark: "watermark/weather.png"
        url: "http://192.168.1.33/weewx/ss/index.html"
        zoom: 1.0
    }
    ListElement
    {
        menutext: "BBC Forecast"
        loaderSource:"WebBrowser.qml"
        waterMark: "watermark/weather.png"
        url: "https://www.bbc.co.uk/weather/0/2644547"
        zoom: 1.0
    }
    ListElement
    {
        menutext: "Met Office Forecast"
        loaderSource:"WebBrowser.qml"
        waterMark: "watermark/weather.png"
        url: "https://www.metoffice.gov.uk/public/weather/forecast/gcw16xq5y"
        zoom: 1.0
    }
    ListElement
    {
        menutext: "Lightning Map"
        loaderSource: "WebBrowser.qml"
        waterMark: "watermark/weather.png"
        url: "https://www.lightningmaps.org/blitzortung/europe/index.php?bo_page=archive&bo_map=uk&bo_animation=now"
        zoom: 1.25
    }
    ListElement
    {
        menutext:"Rain Radar"
        loaderSource: "WebBrowser.qml"
        waterMark: "watermark/weather.png"
        url: "http://192.168.1.33/weewx/simple/radar.html"
        zoom: 1.0
    }
    ListElement
    {
        menutext: "Met Office Video Forecast"
        loaderSource:"WebBrowser.qml"
        waterMark: "watermark/weather.png"
        url: "http://192.168.1.33/weewx/simple/video_forecast.html"
        zoom: 1.0
    }
}
