import QtQuick 2.0

ListModel
{
    id: settingsMenu
    property string logo: "title/title_setup.png"
    property string title: "Settings Menu"

    ListElement
    {
        menutext: "Myth Backend"
        loaderSource: "settings/BackendSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "Theme Settings"
        loaderSource: "settings/ThemeSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "Feed Sources Settings"
        loaderSource: "settings/FeedSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "DVD Settings"
        loaderSource: "settings/DVDSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "Virgin Tivo Settings"
        loaderSource:"settings/TivoSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "Schedules Direct Settings"
        loaderSource:"settings/SDSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "Shutdown Settings"
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
        loaderSource: "zoneminder/ZMSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "Channel Editor"
        loaderSource:"settings/ChannelEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "MythTV Channel Editor"
        loaderSource:"settings/MythChannelEditor.qml"
        waterMark: "watermark/keys.png"
    }
}
