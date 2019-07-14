import QtQuick 2.0

ListModel
{
    id: settingsMenu
    property string logo: "title/title_setup.png"
    property string title: "Settings Menu"

    ListElement
    {
        menutext: "General Settings"
        loaderSource: "SettingEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "Shutdown Settings"
        loaderSource: "ShutdownSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "ZoneMinder Settings"
        loaderSource: "ZMSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "Channel Editor"
        loaderSource:"ChannelEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "MythTV Channel Editor"
        loaderSource:"MythChannelEditor.qml"
        waterMark: "watermark/keys.png"
    }
}
