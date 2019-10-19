import QtQuick 2.0

ListModel
{
    id: musicMenu
    property string logo: "title/title_music.png"
    property string title: "Music Menu"

    ListElement
    {
        menutext: "Play Music"
        loaderSource:"MusicPlayer.qml"
        waterMark: "watermark/music.png"
    }
    ListElement
    {
        menutext: "Play Radio Streams"
        loaderSource: "RadioPlayer.qml"
        waterMark: "watermark/radio.png"
    }
}
