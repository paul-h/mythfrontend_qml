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
        menutext: "Schedule Recordings"
        loaderSource: "ThemedMenu.qml"
        waterMark: "watermark/checklist.png"
        menuSource: "ScheduleMenu.qml"
    }
    ListElement
    {
        menutext:"Watch Recordings"
        loaderSource: "WatchRecordings.qml"
        waterMark: "watermark/play.png"
    }
    ListElement
    {
        menutext: "Previously Recorded"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/checklist.png"
    }
    ListElement
    {
        menutext:"Systems Status"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/info.png"
    }
    ListElement
    {
        menutext:"TV Settings"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/setup.png"
    }
}
