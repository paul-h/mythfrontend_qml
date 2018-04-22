import QtQuick 2.0
import ".."

ListModel
{
    id: mainMenu
    property string logo: "title/title_tv.png"
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
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/tv.png"
    }
    ListElement
    {
        menutext:"Music"
        loaderSource: "ThemedMenu.qml"
        waterMark: "watermark/info.png"
        menuSource: "MusicMenu.qml"
    }
    ListElement
    {
        menutext: "Videos"
        loaderSource: "ThemedMenu.qml"
        waterMark: "watermark/dvd.png"
        menuSource: "VideoMenu.qml"
    }
    ListElement
    {
        menutext:"Images"
        loaderSource: "IconView.qml"
        waterMark: "watermark/tv.png"
    }
    ListElement
    {
        menutext:"Weather"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/weather.png"
    }
    ListElement
    {
        menutext:"Weather Station"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/weather.png"
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
    }
    ListElement
    {
        menutext:"Archive Files"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/weather.png"
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
        menutext: "Advent Calender"
        loaderSource:"AdventCalender.qml"
        waterMark: "watermark/adventcalender.jpg"
    }
    ListElement
    {
        menutext: "Test Pages"
        loaderSource: "ThemedMenu.qml"
        waterMark: "watermark/setup.png"
        menuSource: "TestMenu.qml"
    }
    ListElement
    {
        menutext:"Setup"
        loaderSource: "ThemedMenu.qml"
        waterMark: "watermark/setup.png"
        menuSource: "SettingsMenu.qml"
    }
}
