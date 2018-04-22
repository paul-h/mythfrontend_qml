import QtQuick 2.0

ListModel
{
    id: videoMenu
    property string logo: "title/title_video.png"
    property string title: "Video Menu"

    ListElement
    {
        menutext: "Browse Videos"
        loaderSource:"VideosGrid.qml"
        waterMark: "watermark/video.png"
    }
    ListElement
    {
        menutext: "Video List"
        loaderSource: "VideosGridFolder.qml"
        waterMark: "watermark/video_settings.png"
    }
    ListElement
    {
        menutext:"Video Gallery"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/video.png"
    }
    ListElement
    {
        menutext: "Video Manager"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/video_settings.png"
    }
    ListElement
    {
        menutext:"Play a DVD or Blu-ray"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/dvd.png"
    }
    ListElement
    {
        menutext:"Eject Media"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/dvd_eject.png"
    }
    ListElement
    {
        menutext:"Video Settings"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/video_settings.png"
    }
}
