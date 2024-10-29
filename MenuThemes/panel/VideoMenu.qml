import QtQuick

ListModel
{
    id: videoMenu
    property string logo: "title/title_video.png"
    property string title: "Video Menu"

    ListElement
    {
        menutext: "Browse MythTV Videos"
        loaderSource:"VideosGrid.qml"
        waterMark: "watermark/video.png"
    }
    ListElement
    {
        menutext: "Browse Folder Videos"
        loaderSource: "VideosGridFolder.qml"
        waterMark: "watermark/video_settings.png"
    }
    ListElement
    {
        menutext: "Feed Sources Settings"
        loaderSource: "settings/FeedSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
}
