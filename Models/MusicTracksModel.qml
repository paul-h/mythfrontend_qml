import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

XmlListModel
{
    id: musicModel

    property var titleList: ListModel{}
    property var artistList: ListModel{}
    property var albumList: ListModel{}
    property var genreList: ListModel{}

    source: settings.masterBackend + "Music/GetTrackList?Count=100&StartIndex=200"
    query: "/MusicMetadataInfoList/MusicMetadataInfos/MusicMetadataInfo"
    XmlListModelRole { name: "Id"; elementName: "Id" } // number
    XmlListModelRole { name: "Artist"; elementName: "Artist" }
    XmlListModelRole { name: "CompilationArtist"; elementName: "Compilation/Artist/" }
    XmlListModelRole { name: "Album"; elementName: "Album" }
    XmlListModelRole { name: "Title"; elementName: "Title" }
    XmlListModelRole { name: "TrackNo"; elementName: "TrackNo" } // number
    XmlListModelRole { name: "Genre"; elementName: "Genre" }
    XmlListModelRole { name: "Year"; elementName: "Year" } // number
    XmlListModelRole { name: "PlayCount"; elementName: "PlayCount" }
    XmlListModelRole { name: "Length"; elementName: "Length" } // number
    XmlListModelRole { name: "Rating"; elementName: "Rating" } //number
    XmlListModelRole { name: "FileName"; elementName: "FileName" }
    XmlListModelRole { name: "HostName"; elementName: "HostName" }
    XmlListModelRole { name: "LastPlayed"; elementName: "xs:dateTime(LastPlayed)" } //FIXME Qt6
    XmlListModelRole { name: "Compilation"; elementName: "xs:boolean(Compilation)" } //FIXME Qt6

    signal loaded();

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "MusicTracksModel: Found " + count + " tracks");
            screenBackground.showBusyIndicator = false

            updateLists();

            loaded();
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "MusicTracksModel: LOADING - " + source);
            screenBackground.showBusyIndicator = true
        }

        if (status === XmlListModel.Error)
        {
            screenBackground.showBusyIndicator = false
            log.error(Verbose.MODEL, "MusicTracksModel: Error: " + errorString() + " - " + source);
        }
    }

    function get(i)
    {
        var o = {}
        for (var j = 0; j < roles.length; ++j)
        {
            o[roles[j].name] = data(index(i,0), Qt.UserRole + j)
        }
        return o
    }

    function updateLists()
    {
        var title;
        var artist;
        var album;
        var genre;

        var titles = [];
        var artists = [];
        var albums = [];
        var genres = [];

        titleList.clear();
        artistList.clear();
        albumList.clear();
        genreList.clear();

        for (var x = 0; x < count; x++)
        {
            title = get(x).Title;
            artist = get(x).Artist;
            album = get(x).Album;
            genre = get(x).Genre;

            if (titles.indexOf(title) < 0)
                titles.push(title);

            if (artists.indexOf(artist) < 0)
                artists.push(artist);

            if (albums.indexOf(album) < 0)
                albums.push(album);

            if (genres.indexOf(genre) < 0)
                genres.push(genre);
        }

        titles.sort();
        artists.sort();
        albums.sort();
        genres.sort();

        for (var x = 0; x < titles.length; x++)
            titleList.append({"item": titles[x]});

        for (var x = 0; x < artists.length; x++)
            artistList.append({"item": artists[x]});

        for (var x = 0; x < albums.length; x++)
            albumList.append({"item": albums[x]});

        for (var x = 0; x < genres.length; x++)
            genreList.append({"item": genres[x]});
    }
}
