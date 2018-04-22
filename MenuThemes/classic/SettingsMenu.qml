import QtQuick 2.0

ListModel
{
    id: settingsMenu
    property string logo: "title/title_setup.png"
    property string title: "Settings Menu"

    ListElement
    {
        menutext: "Channel Editor"
        loaderSource:"ChannelEditor.qml"
        waterMark: "watermark/keys.png"
    }
    ListElement
    {
        menutext: "General Settings"
        loaderSource: "SettingEditor.qml"
        waterMark: "watermark/keys.png"
    }
}
