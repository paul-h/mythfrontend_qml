import QtQuick 2.0
import Models 1.0
import Base 1.0
import Dialogs 1.0
import SortFilterProxyModel 0.2
import QmlVlc 0.1
import mythqml.net 1.0

BaseScreen
{
    id: root

    property string filterTitle
    property string filterArtist
    property string filterAlbum
    property string filterGenre

    defaultFocusItem: musicList

    Component.onCompleted:
    {
        showTitle(true, "Play Music");
        setHelp("https://mythqml.net/help/play_music.php");
        showTime(false);
        showTicker(false);
    }

    property bool titleSorterActive: true;

    property list<QtObject> titleSorter:
    [
        RoleSorter { roleName: "Title"; ascendingOrder: true}
    ]

    property list<QtObject> albumSorter:
    [
        RoleSorter { roleName: "Artist" },
        RoleSorter { roleName: "Album" },
        RoleSorter { roleName: "TrackNo" }
    ]

    SortFilterProxyModel
    {
        id: musicProxyModel
        sourceModel: MusicTracksModel {}
        filters:
        [
            AllOf
            {
                RegExpFilter
                {
                    roleName: "Title"
                    pattern: filterTitle
                    caseSensitivity: Qt.CaseInsensitive
                }
                RegExpFilter
                {
                    roleName: "Artist"
                    pattern: filterArtist
                    caseSensitivity: Qt.CaseInsensitive
                }
                RegExpFilter
                {
                    roleName: "Album"
                    pattern: filterAlbum
                    caseSensitivity: Qt.CaseInsensitive
                }
                RegExpFilter
                {
                    roleName: "Genre"
                    pattern: filterGenre
                    caseSensitivity: Qt.CaseInsensitive
                }
            }
        ]
        sorters: titleSorter
    }

//     Image
//     {
//         id: fanartImage
//         x: xscale(0); y: yscale(0); width: xscale(1280); height: yscale(720)
//         source:
//         {
//             if (musicList.model.get(musicList.currentIndex).Fanart)
//                 settings.masterBackend + musicList.model.get(musicList.currentIndex).Fanart
//                 else
//                     ""
//         }
//     }

    InfoText
    {
        x: xscale(1050); y: yscale(5); width: xscale(200);
        text: (musicList.currentIndex + 1) + " of " + musicProxyModel.count;
        horizontalAlignment: Text.AlignRight
    }

    BaseBackground
    {
        x: xscale(15); y: yscale(50); width: xscale(400); height: yscale(400)
    }

    BaseBackground
    {
        x: xscale(425); y: yscale(50); width: xscale(835); height: yscale(400)
    }

    BaseBackground
    {
        x: xscale(15); y: yscale(465); width: xscale(1250); height: yscale(240)
    }

    Component
    {
        id: listRow

        ListItem
        {
            Image
            {
                id: coverImage
                x: xscale(13); y: yscale(3); height: parent.height - yscale(6); width: height
                source: mythUtils.findThemeFile("images/grid_noimage.png")
                        //if (Coverart)
                        //    settings.masterBackend + Coverart
                        //else
                        //    mythUtils.findThemeFile("images/grid_noimage.png")
            }
            ListText
            {
                x: coverImage.width + xscale(20)
                width: xscale(450); height: yscale(50)
                text: Artist + " - " + Album + " - " + Title
                fontColor: theme.labelFontColor
            }
            ListText
            {
                x: coverImage.width + xscale(480)
                width: xscale(190); height: yscale(50)
                horizontalAlignment: Text.AlignRight
                text: Qt.formatDateTime(LastPlayed, "ddd dd/MM/yy")
            }
            ListText
            {
                x: coverImage.width + xscale(680)
                width: xscale(80); height: yscale(50)
                horizontalAlignment: Text.AlignRight
                text: PlayCount
            }
        }
    }

    ButtonList
    {
        id: musicList
        x: xscale(435); y: yscale(65); width: xscale(815); height: yscale(360)

        clip: true
        model: musicProxyModel
        delegate: listRow

        Keys.onPressed:
        {
            if (event.key === Qt.Key_PageDown)
            {
                currentIndex = currentIndex + 6 >= model.count ? model.count - 1 : currentIndex + 6;
                event.accepted = true;
            }
            else if (event.key === Qt.Key_PageUp)
            {
                currentIndex = currentIndex - 6 < 0 ? 0 : currentIndex - 6;
                event.accepted = true;
            }
            else if (event.key === Qt.Key_M)
            {
                filterDialog.filterTitle = root.filterTitle;
                filterDialog.filterArtist = root.filterArtist;
                filterDialog.filterAlbum = root.filterAlbum;
                filterDialog.filterGenre = root.filterGenre;
                filterDialog.show();
            }
            else if (event.key === Qt.Key_S)
            {
                if (titleSorterActive)
                    recordingsProxyModel.sorters = albumSorter;
                else
                    recordingsProxyModel.sorters = titleSorter

                titleSorterActive = !titleSorterActive;
            }
        }

        Keys.onReturnPressed:
        {
            var hostname = model.get(currentIndex).HostName === settings.hostName ? "localhost" : model.get(currentIndex).HostName
            //var filename = "myth://" + hostname + "/" + model.get(currentIndex).FileName;
            var filename = "myth://" + "localhost:6544" + "/" + model.get(currentIndex).FileName;
            log.debug(Verbose.PLAYBACK, "MusicPlayer: Playing - " + filename);
            //stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{source1: filename }});
            musicPlayer.mrl = filename
            event.accepted = true;
            //returnSound.play();
        }
    }

    InfoText
    {
        x: xscale(30); y: yscale(480)
        width: xscale(900); height: yscale(50)
        text:
        {
            var title = musicList.model.get(musicList.currentIndex).Title;
            //var subtitle = musicList.model.get(musicList.currentIndex).SubTitle;
            //var season = musicList.model.get(musicList.currentIndex).Season;
            //var episode = musicList.model.get(musicList.currentIndex).Episode;
            //var total = musicList.model.get(musicList.currentIndex).TotalEpisodes;
            var result = "";

            if (title !== undefined && title.length > 0)
                result = title;

            //if (subtitle != undefined && subtitle.length > 0)
            //    result += " - " + subtitle;

            //if (season > 0 && episode > 0)
            //{
            //    result += " (s:" + season + " e:" + episode

            //    if (total > 0)
            //        result += " of " + total;

            //    result += ")";
            //}

            return result;
        }
    }

    Image
    {
        id: coverImage
        x: xscale(300); y: yscale(530); width: xscale(50); height: yscale(50)
        source:
        {
            //if (musicList.model.get(musicList.currentIndex).ChannelIcon)
            //    settings.masterBackend + musicList.model.get(musicList.currentIndex).ChannelIcon
            //else
                ""
        }
    }

    InfoText
    {
        x: xscale(400); y: yscale(530)
        width: xscale(900); height: yscale(50)
        //text: musicList.model.get(musicList.currentIndex).ChannelNo + " - " + musicList.model.get(musicList.currentIndex).ChannelCallSign + " - " + musicList.model.get(musicList.currentIndex).ChannelName
    }

    InfoText
    {
        x: xscale(30); y: yscale(530)
        width: xscale(900); height: yscale(50)
        //text: Qt.formatDateTime(musicList.model.get(musicList.currentIndex).StartTime, "ddd dd MMM yyyy hh:mm")
    }
    InfoText
    {
        x: xscale(30); y: yscale(580)
        width: xscale(900); height: yscale(100)
        text:
        {
            //if (musicList.model.get(musicList.currentIndex).Description != undefined)
            //    musicList.model.get(musicList.currentIndex).Description
            //else
                ""
        }
        multiline: true
    }

//     Image
//     {
//         id: bannerImage
//         x: xscale(300); y: yscale(480); height: yscale(60); width: 300
//         source:
//         {
//             if (musicList.model.get(musicList.currentIndex).Banner)
//                 settings.masterBackend + musicList.model.get(musicList.currentIndex).Banner
//             else
//                 ""
//         }
//     }

    Image
    {
        id: coverartImage
        x: xscale(980); y: yscale(480); height: yscale(200); width: 100
        source:
        {
            //if (musicList.model.get(musicList.currentIndex).Fanart)
            //    settings.masterBackend + musicList.model.get(musicList.currentIndex).Coverart
            //    else
                    mythUtils.findThemeFile("images/grid_noimage.png")
        }
    }

//     MusicFilterDialog
//     {
//         id: filterDialog
// 
//         title: "Filter Music"
//         message: ""
// 
//         musicModel: musicProxyModel.sourceModel
// 
//         width: 600; height: 500
// 
//         onAccepted:
//         {
//             musicList.focus = true;
// 
//             root.filterTitle = filterTitle;
//             root.filterArtist = filterArtist;
//             root.filterAlbum = filterAlbum;
//             root.filterGenre = filterGenre;
//         }
//         onCancelled:
//         {
//             musicList.focus = true;
//         }
//     }

    VlcPlayer
    {
        id: musicPlayer

        //onTimeChanged: if (trackArtistTitle != undefined && trackArtistTitle == playedModel.get(0).trackArtistTitle) playedModel.get(0).length = time - trackStart;

        Component.onCompleted:
        {
            // try to restore the last playing station
//             var url = dbUtils.getSetting("RadioPlayerBookmark", settings.hostName)
// 
//             for (var i = 0; i < radioStreamsModel.rowCount(); i++)
//             {
//                 var itemUrl = radioStreamsModel.data(radioStreamsModel.index(i, 4));
// 
//                 if (itemUrl == url)
//                 {
//                     streamList.currentIndex = i;
// 
//                     if (streamList.model.data(streamList.model.index(streamList.currentIndex, 1)) != "")
//                         channel.text = streamList.model.data(streamList.model.index(streamList.currentIndex, 1)) + " - " + streamList.model.data(streamList.model.index(streamList.currentIndex, 2));
//                     else
//                         channel.text = streamList.model.data(streamList.model.index(streamList.currentIndex, 2));
// 
//                     urlText.text = url;
//                     visualizer.source = streamList.model.data(streamList.model.index(streamList.currentIndex, 9));
//                     streamIcon.source = streamList.model.data(streamList.model.index(streamList.currentIndex, 9));
//                     break;
//                 }
//             }
// 
//             streamPlayer.mrl = url;

            var vol = dbUtils.getSetting("MusicPlayerVolume", settings.hostName)
            if (vol !== undefined && vol !== "")
                audio.volume = vol;
            else
                audio.volume = 80
        }

        Component.onDestruction:
        {
            dbUtils.setSetting("MusicPlayerBookmark", settings.hostName, mrl)
        }
    }
}


