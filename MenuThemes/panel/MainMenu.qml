import QtQuick 2.0
import ".."

ListModel
{
    id: mainMenu
    property string logo: "title/title_tv.png"
    property string title: "Main Menu"

    ListElement
    {
        menutext: "Home"
        loaderSource:"Home.qml"
        waterMark: "watermark/tv.png"
    }
    ListElement
    {
        menutext: "Guide"
        loaderSource:"ProgramGuide.qml"
        waterMark: "watermark/tv.png"
        menuSource: "RecordingsMenu.qml"
    }
    ListElement
    {
        menutext: "Recordings"
        loaderSource: "WatchRecordings.qml"
        waterMark: "watermark/tv.png"
        menuSource: "RecordingsMenu.qml"
    }
    ListElement
    {
        menutext:"Webcams"
        loaderSource: "WebCamViewer.qml"
        waterMark: "watermark/music.png"
        menuSource: "WebcamsMenu.qml"
    }
    ListElement
    {
        menutext: "Videos"
        loaderSource: "VideosGridFolder.qml"
        waterMark: "watermark/stream.png"
        menuSource: "InternetVideoMenu.qml"
    }
    ListElement
    {
        menutext:"Web Videos"
        loaderSource: "WebVideoViewer.qml"
        waterMark: "watermark/gallery.png"
    }
    ListElement
    {
        menutext:"CCTV Cameras"
        loaderSource: "zoneminder/ZMConsole.qml"
        waterMark: "watermark/zoneminder.png"
        menuSource: "ZoneMinderMenu.qml"
    }
    ListElement
    {
        menutext:"Pictures"
        loaderSource: "IconView.qml"
        waterMark: "watermark/news.png"
    }
    ListElement
    {
        menutext:"Music"
        loaderSource: "MusicPlayer.qml"
        waterMark: "watermark/news.png"
    }
    ListElement
    {
        menutext:"Radio"
        loaderSource: "RadioPlayer.qml"
        waterMark: "watermark/zoneminder.png"
    }
    ListElement
    {
        menutext:"News Feeds"
        loaderSource: "RSSFeeds.qml"
        waterMark: "watermark/zoneminder.png"
    }
    ListElement
    {
        menutext:"Web Browser"
        loaderSource: "WebBrowser.qml"
        waterMark: "watermark/zoneminder.png"
        url: "https://www.google.co.uk"
        zoom: 1.0
    }
    ListElement
    {
        menutext:"Weather"
        loaderSource: "WebBrowser.qml"
        waterMark: "watermark/zoneminder.png"
        menuSource: "WeatherMenu.qml"
        url: "https://www.bbc.co.uk/weather/0/2644547"
        zoom: 1.0
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
        loaderSource: "settings/BackendSettingsEditor.qml"
        waterMark: "watermark/setup.png"
        menuSource: "SettingsMenu.qml"
    }
    ListElement
    {
        menutext: "Test Pages"
        loaderSource: "TestPages.qml"
        waterMark: "watermark/setup.png"
        menuSource: "TestMenu.qml"
    }
}
