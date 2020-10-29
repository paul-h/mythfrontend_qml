import QtQuick 2.0

ListModel
{
    id: mainMenu
    property string logo: "title/title_schedule.png"
    property string title: "Schedule Menu"

    ListElement
    {
        menutext: "Programme Guide"
        loaderSource:"ProgramGuide.qml"
        waterMark: "watermark/clock.png"
    }
    ListElement
    {
        menutext: "Programme Finder"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/search.png"
    }
    ListElement
    {
        menutext:"Search Listings"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/search.png"
    }
    ListElement
    {
        menutext: "Custom Record"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/record.png"
    }
    ListElement
    {
        menutext:"Manual Record"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/clock.png"
    }
    ListElement
    {
        menutext:"Recording Rules"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/priority.png"
    }
    ListElement
    {
        menutext:"Upcoming Recordings"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/record.png"
    }
}
