import QtQuick

ListModel
{
    id: internetVideoMenu
    property string logo: "title/title_tv.png"
    property string title: "Internet Video"

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
    ListElement
    {
        menutext: "YouTube TV"
        loaderSource:"YouTube.qml"
        waterMark: "watermark/youtube.png"
    }
    ListElement
    {
        menutext: "YouTube Subscriptions"
        loaderSource:"YouTubeFeeds.qml"
        waterMark: "watermark/youtube.png"
    }

    ListElement
    {
        menutext: "IPTV Channel Viewer"
        loaderSource:"IPTVViewer.qml"
        waterMark: "watermark/video.png"
    }
}
