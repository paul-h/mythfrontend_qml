import QtQuick 2.0
import QtQuick.XmlListModel 2.0
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
    XmlRole { name: "Id"; query: "Id/number()" }
    XmlRole { name: "Artist"; query: "Artist/string()" }
    XmlRole { name: "CompilationArtist"; query: "Compilation/Artist/string()" }
    XmlRole { name: "Album"; query: "Album/string()" }
    XmlRole { name: "Title"; query: "Title/string()" }
    XmlRole { name: "TrackNo"; query: "TrackNo/number()" }
    XmlRole { name: "Genre"; query: "Genre/string()" }
    XmlRole { name: "Year"; query: "Year/number()" }
    XmlRole { name: "PlayCount"; query: "PlayCount/number()" }
    XmlRole { name: "Length"; query: "Length/number()" }
    XmlRole { name: "Rating"; query: "Rating/number()" }
    XmlRole { name: "FileName"; query: "FileName/string()" }
    XmlRole { name: "HostName"; query: "HostName/string()" }
    XmlRole { name: "LastPlayed"; query: "xs:dateTime(LastPlayed)" }
    XmlRole { name: "Compilation"; query: "xs:boolean(Compilation)" }

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
            log.debug(Verbose.MODEL, "MusicTracksModel: LOADING - " + source.toString());
            screenBackground.showBusyIndicator = true
        }

        if (status === XmlListModel.Error)
        {
            screenBackground.showBusyIndicator = false
            log.error(Verbose.MODEL, "MusicTracksModel: Error: " + errorString() + " - " + source.toString());
        }
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
