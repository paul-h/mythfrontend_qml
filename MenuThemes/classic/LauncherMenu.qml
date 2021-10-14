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
        menutext: "Pluto TV"
        loaderSource:"WebBrowser.qml"
        waterMark: "watermark/pluto.png"
        url: "https://pluto.tv/live-tv/"
        zoom: 1.0
        fullscreen: true
    }
    ListElement
    {
        menutext: "Netflix"
        loaderSource:"WebBrowser.qml"
        waterMark: "watermark/netflix.png"
        url: "https://www.netflix.com/browse"
        zoom: 1.0
        fullscreen: true
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
        menutext:"Suspend"
        loaderSource: "suspend"
        waterMark: "watermark/suspend.png"
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
