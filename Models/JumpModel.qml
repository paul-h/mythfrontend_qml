import QtQuick 2.0
import ".."

ListModel
{
    // TV
    ListElement
    {
        jumpText: "TV|Live TV|Watch TV"
        loaderSource:"MythTVChannelViewer.qml"
    }
    ListElement
    {
        jumpText:"Watch Recordings|Recordings"
        loaderSource: "WatchRecordings.qml"
    }
    ListElement
    {
        jumpText: "Programme Guide|EPG"
        loaderSource:"ProgramGuide.qml"
    }

    // Internet Video
    ListElement
    {
        jumpText: "YouTube"
        loaderSource:"YouTube.qml"
    }
    ListElement
    {
        jumpText: "WebCam Viewer|Webcams"
        loaderSource:"WebCamViewer.qml"
    }
    ListElement
    {
        jumpText: "Web Video Viewer|Web Videos"
        loaderSource:"WebVideoViewer.qml"
        waterMark: "watermark/video.png"
    }

    // Music
    ListElement
    {
        jumpText: "Play Music|Music"
        loaderSource:"MusicPlayer.qml"
    }
    ListElement
    {
        jumpText: "Play Radio Streams|Play Radio|Internet Radio|Radio Stream|Radio"
        loaderSource: "RadioPlayer.qml"
    }

    // Image Gallery
    ListElement
    {
        jumpText: "Images|Picture"
        loaderSource: "IconView.qml"
    }

    // News Feeds
    ListElement
    {
        jumpText: "News Feeds"
        loaderSource: "RSSFeeds.qml"
    }

    // Weather
    ListElement
    {
        jumpText: "Weather|Current Weather|Current Conditions"
        loaderSource: "weather/CurrentConditions.qml"
    }

    // Web Browser
    ListElement
    {
        jumpText: "Web|Browser|Web Browser"
        loaderSource: "WebBrowser.qml"
        url: "https://www.google.co.uk"
        zoom: 1.0
    }

    // What's New
    ListElement
    {
        jumpText: "What's New|What Is New"
        loaderSource: "WhatsNew.qml"
    }

    // Advent Calendar
    ListElement
    {
        jumpText: "Advent Calendar"
        loaderSource:"AdventCalendar.qml"
    }

    // Zoneminder
    ListElement
    {
        jumpText: "Zoneminder Show Console"
        loaderSource: "zoneminder/ZMConsole.qml"
    }
    ListElement
    {
        jumpText: "Zoneminder Show Live View"
        loaderSource: "InternalPlayer.qml"
        layout: 6
        feedSource: "ZoneMinder Cameras"
    }
    ListElement
    {
        jumpText:"Zoneminder Show Events"
        loaderSource: "zoneminder/ZMEventsView.qml"
    }
}
