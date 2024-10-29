import QtQuick

ListModel
{
    id: videoMenu
    property string logo: "title/title_video.png"
    property string title: "Video Menu"

    ListElement
    {
        menutext: "All"
        loaderSource:"VideosGrid.qml"
        waterMark: "watermark/video.png"
    }
    ListElement
    {
        menutext: "Favorite"
        loaderSource: "VideosGridFolder.qml"
        waterMark: "watermark/video_settings.png"
    }
    ListElement
    {
        menutext: "New"
        loaderSource:"WebVideoViewer.qml"
        waterMark: "watermark/video.png"
    }
}
