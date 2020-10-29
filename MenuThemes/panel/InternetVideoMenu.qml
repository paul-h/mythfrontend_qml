import QtQuick 2.0

ListModel
{
    id: internetVideoMenu
    property string logo: "title/title_tv.png"
    property string title: "Internet Video"

    ListElement
    {
        menutext: "YouTube"
        loaderSource:"YouTube.qml"
        waterMark: "watermark/youtube.png"
    }
    ListElement
    {
        menutext: "WebCam Viewer"
        loaderSource:"WebCamViewer.qml"
        waterMark: "watermark/webcam.png"
    }
    ListElement
    {
        menutext: "WebVideo Viewer"
        loaderSource:"WebVideoViewer.qml"
        waterMark: "watermark/video.png"
    }
}
