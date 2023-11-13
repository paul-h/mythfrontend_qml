import QtQuick 2.0
import ".."

ListModel
{
    id: mainMenu
    property string logo: "title/title_main.png"
    property string title: "Main Menu"

    ListElement
    {
        menutext: "TV"
        loaderSource:"ThemedMenu.qml"
        waterMark: "watermark/tv.png"
        menuSource: "RecordingsMenu.qml"
    }
    ListElement
    {
        menutext: "Internet Video"
        loaderSource: "ThemedMenu.qml"
        waterMark: "watermark/stream.png"
        menuSource: "InternetVideoMenu.qml"
    }
    ListElement
    {
        menutext:"Music"
        loaderSource: "ThemedMenu.qml"
        waterMark: "watermark/music.png"
        menuSource: "MusicMenu.qml"
    }
    ListElement
    {
        menutext: "Videos"
        loaderSource: "ThemedMenu.qml"
        waterMark: "watermark/video.png"
        menuSource: "VideoMenu.qml"
    }
    ListElement
    {
        menutext:"Images"
        loaderSource: "IconView.qml"
        waterMark: "watermark/gallery.png"
    }
    ListElement
    {
        menutext:"Weather"
        loaderSource: "ThemedMenu.qml"
        waterMark: "watermark/weather.png"
        menuSource: "WeatherMenu.qml"
    }
    ListElement
    {
        menutext:"News Feeds"
        loaderSource: "RSSFeeds.qml"
        waterMark: "watermark/news.png"
    }
    ListElement
    {
        menutext:"Web"
        loaderSource: "WebBrowser.qml"
        waterMark: "watermark/browser.png"
        url: "https://www.google.co.uk"
        zoom: 1.0
    }
    ListElement
    {
        menutext:"Home Assistant"
        loaderSource: "ThemedMenu.qml"
        waterMark: "watermark/home_assistant.svg"
        menuSource: "setting://HAMenuFile"
    }
    ListElement
    {
        menutext:"ZoneMinder"
        loaderSource: "ThemedMenu.qml"
        waterMark: "watermark/zoneminder.png"
        menuSource: "ZoneMinderMenu.qml"
    }
    ListElement
    {
        menutext: "Energy Consumption"
        loaderSource: "ThemedMenu.qml"
        waterMark: "watermark/energy_consumption.png"
        menuSource: "EnergyConsumptionMenu.qml"
    }
    ListElement
    {
        menutext: "What's New"
        loaderSource: "WhatsNew.qml"
        waterMark: "watermark/whatsnew.png"
    }
    ListElement
    {
        menutext: "Advent Calendar"
        loaderSource:"AdventCalendar.qml"
        waterMark: "watermark/adventcalendar.jpg"
    }
    ListElement
    {
        menutext:"Setup"
        loaderSource: "ThemedMenu.qml"
        waterMark: "watermark/setup.png"
        menuSource: "SettingsMenu.qml"
    }
//    ListElement
//    {
//        menutext: "Test Pages"
//        loaderSource: "ThemedMenu.qml"
//        waterMark: "watermark/setup.png"
//        menuSource: "TestMenu.qml"
//    }
}
