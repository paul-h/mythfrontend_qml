import QtQuick 2.0

ListModel
{
    id: testMenu
    property string logo: "title/title_setup.png"
    property string title: "Test Menu"

    ListElement
    {
        menutext: "Test 1"
        loaderSource:"tests/TestPage1.qml"
        waterMark: "watermark/setup.png"
    }
    ListElement
    {
        menutext: "Sidebar"
        loaderSource:"tests/TestPage3.qml"
        waterMark: "watermark/setup.png"
    }
    ListElement
    {
        menutext: "Tree Component Test"
        loaderSource: "tests/TestPage2.qml"
        waterMark: "watermark/setup.png"
    }
    ListElement
    {
        menutext: "Rich Text Test"
        loaderSource: "tests/TestPage4.qml"
        waterMark: "watermark/setup.png"
    }
    ListElement
    {
        menutext: "Nested Lists Test"
        loaderSource: "tests/TestPage5.qml"
        waterMark: "watermark/setup.png"
    }
    ListElement
    {
        menutext: "Sliding Panel"
        loaderSource: "tests/TestPage5.qml"
        waterMark: "watermark/setup.png"
    }
    ListElement
    {
        menutext:"QmlVlc Player Test"
        loaderSource: "tests/TestQmlVlc.qml"
        waterMark: "watermark/setup.png"
    }
    ListElement
    {
        menutext:"VLC-Qt Player Test"
        loaderSource: "tests/TestVlcQt.qml"
        waterMark: "watermark/setup.png"
    }
    ListElement
    {
        menutext:"MDK SDK Player Test"
        loaderSource: "tests/TestMDK.qml"
        waterMark: "watermark/setup.png"
    }
}
