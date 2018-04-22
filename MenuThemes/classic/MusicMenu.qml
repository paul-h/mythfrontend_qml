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
    ListElement
    {
        menutext:"Select Music"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/music.png"
    }
    ListElement
    {
        menutext: "Import CD"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/cd_rip.png"
    }
    ListElement
    {
        menutext:"Import Music"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/music.png"
    }
    ListElement
    {
        menutext:"Scan For New  Music"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/music.png"
    }
    ListElement
    {
        menutext:"Eject CD"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/dvd_eject.png"
    }
    ListElement
    {
        menutext:"Music Settings"
        loaderSource: "ComingSoon.qml"
        waterMark: "watermark/music_settings.png"
    }
}
