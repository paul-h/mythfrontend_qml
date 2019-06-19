import QtQuick 2.0

ListModel
{
    id: zoneminderMenu
    property string logo: "title/title_setup.png"
    property string title: "ZoneMinder Menu"

    ListElement
    {
        menutext: "Show Console"
        loaderSource:"ZMConsole.qml"
        waterMark: "watermark/zoneminder.png"
    }
    ListElement
    {
        menutext: "Show Live View"
        loaderSource: "ZMLiveView.qml"
        waterMark: "watermark/zoneminder.png"
    }
    ListElement
    {
        menutext:"Show Events"
        loaderSource: "ZMEventsView.qml"
        waterMark: "watermark/zoneminder.png"
    }
}
