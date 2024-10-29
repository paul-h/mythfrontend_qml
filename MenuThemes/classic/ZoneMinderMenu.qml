import QtQuick

ListModel
{
    id: zoneminderMenu
    property string logo: "title/title_setup.png"
    property string title: "ZoneMinder Menu"

    ListElement
    {
        menutext: "Show Console"
        loaderSource: "zoneminder/ZMConsole.qml"
        waterMark: "watermark/zoneminder.png"
    }
    ListElement
    {
        menutext: "Show Live View"
        loaderSource: "InternalPlayer.qml"
        waterMark: "watermark/zoneminder.png"
        layout: 6
        feedSource: "ZoneMinder Cameras"
    }
    ListElement
    {
        menutext:"Show Events"
        loaderSource: "zoneminder/ZMEventsView.qml"
        waterMark: "watermark/zoneminder.png"
    }
}
