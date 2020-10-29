import QtQuick 2.0
import ".."

ListModel
{
    id: mainMenu
    property string logo: "title/title_tv.png"
    property string title: "MythTV Launcher"

    ListElement
    {
        menutext: "QML Frontend"
        loaderSource: "External Program"
        waterMark: "watermark/qml_frontend.png"
        exec: "mythfrontend_qml"
    }
    ListElement
    {
        menutext: "Legacy Frontend"
        loaderSource: "External Program"
        waterMark: "watermark/legacy_frontend.png"
        exec: "mythfrontend"
    }
    ListElement
    {
        menutext:"KODI"
        loaderSource: "External Program"
        waterMark: "watermark/kodi.png"
        exec: "kodi"
    }
    ListElement
    {
        menutext:"Shutdown"
        loaderSource: "shutdown"
        waterMark: "watermark/shutdown.png"
    }
    ListElement
    {
        menutext:"Reboot"
        loaderSource: "reboot"
        waterMark: "watermark/reboot.png"
    }
        ListElement
    {
        menutext:"Exit"
        loaderSource: "quit"
        waterMark: "watermark/close.png"
    }
    ListElement
    {
        menutext:"Setup"
        loaderSource: "ThemedMenu.qml"
        waterMark: "watermark/setup.png"
        menuSource: "SettingsMenu.qml"
    }
}
