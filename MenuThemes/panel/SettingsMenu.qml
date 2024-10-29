import QtQuick

ListModel
{
    id: settingsMenu
    property string logo: "title/title_setup.png"
    property string title: "Settings Menu"

    ListElement
    {
        menutext: "Myth Backend"
        panelSource: "settings/BackendSettingsEditor.qml"
        loaderSource: "settings/BackendSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "Theme Settings"
        panelSource: "settings/ThemeSettingsEditor.qml"
        loaderSource: "settings/ThemeSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "Feed Sources Settings"
        panelSource: "settings/FeedSettingsEditor.qml"
        loaderSource: "settings/FeedSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "Data Sources Settings"
        loaderSource: "settings/DataSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "Shutdown Settings"
        panelSource: "settings/ShutdownSettingsEditor.qml"
        loaderSource: "settings/ShutdownSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "Weather Settings"
        loaderSource:"settings/WeatherSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "ZoneMinder Settings"
        panelSource: "zoneminder/ZMSettingsEditor.qml"
        loaderSource: "zoneminder/ZMSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "Channel Editor"
        panelSource: "settings/ChannelEditor.qml"
        loaderSource:"settings/ChannelEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "MythTV Channel Editor"
        panelSource: "settings/MythChannelEditor.qml"
        loaderSource:"settings/MythChannelEditor.qml"
        waterMark: "watermark/keys.png"
    }
}
