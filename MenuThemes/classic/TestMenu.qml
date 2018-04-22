import QtQuick 2.0

ListModel
{
    id: zoneminderMenu
    property string logo: "title/title_setup.png"
    property string title: "Test Menu"

    ListElement
    {
        menutext: "Test 1"
        loaderSource:"TestPage1.qml"
        waterMark: "watermark/setup.png"
    }
    ListElement
    {
        menutext: "Sidebar"
        loaderSource:"TestPage3.qml"
        waterMark: "watermark/setup.png"
    }
    ListElement
    {
        menutext: "Tree Component Test"
        loaderSource: "TestPage2.qml"
        waterMark: "watermark/setup.png"
    }
    ListElement
    {
        menutext:"QtAV Player Test"
        loaderSource: "TestQtAv.qml"
        waterMark: "watermark/setup.png"
    }
    ListElement
    {
        menutext:"QmlVlc Player Test"
        loaderSource: "TestQmlVlc.qml"
        waterMark: "watermark/setup.png"
    }
    ListElement
    {
        menutext:"VLC-Qt Player Test"
        loaderSource: "TestVlcQt.qml"
        waterMark: "watermark/setup.png"
    }
}
