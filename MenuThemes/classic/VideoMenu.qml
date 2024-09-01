import QtQuick 2.0

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
        menutext: "Browse Media"
        loaderSource: "MediaViewer.qml"
        waterMark: "watermark/video_settings.png"
    }
    ListElement
    {
        menutext: "WebVideo Viewer"
        loaderSource:"WebVideoViewer.qml"
        waterMark: "watermark/video.png"
    }
    ListElement
    {
        menutext: "Play DVD"
        loaderSource:"External Program"
        waterMark: "watermark/dvd.png"
        exec: "setting://DvdCommand"
        parameters: "setting://DvdParameters"
    }
    ListElement
    {
        menutext: "Feed Sources Settings"
        loaderSource: "settings/FeedSettingsEditor.qml"
        waterMark: "watermark/keys.png"
    }
}
