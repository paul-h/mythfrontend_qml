import QtQuick 2.0

ListModel
{
    id: mainMenu
    property string logo: "title/title_tv.png"
    property string title: "Recordings Menu"

    ListElement
    {
        menutext: "Watch TV"
        loaderSource: "MythTVChannelViewer.qml"
        waterMark: "watermark/tv.png"
        feedSource: "Live TV"
    }
    ListElement
    {
        menutext: "Tivo TV"
        loaderSource: "TivoTVChannelViewer.qml"
        waterMark: "watermark/tivo.svg"
        feedSource: "Tivo TV"
    }
    ListElement
    {
        menutext:"Watch Recordings"
        loaderSource: "WatchRecordings.qml"
        waterMark: "watermark/play.png"
    }
    ListElement
    {
        menutext: "Programme Guide"
        loaderSource:"ProgramGuide.qml"
        waterMark: "watermark/clock.png"
    }
}
