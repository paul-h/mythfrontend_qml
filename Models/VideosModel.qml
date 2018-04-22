import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel
{
    id: videoModel

    property var titleList: ListModel{}
    property var genreList: ListModel{}
    property var typeList: ListModel{}

    source: settings.masterBackend + "Video/GetVideoList"
    query: "/VideoMetadataInfoList/VideoMetadataInfos/VideoMetadataInfo"
    XmlRole { name: "Id"; query: "Id/string()" }
    XmlRole { name: "Title"; query: "Title/string()" }
    XmlRole { name: "SubTitle"; query: "SubTitle/string()" }
    XmlRole { name: "Tagline"; query: "Tagline/string()" }
    XmlRole { name: "Director"; query: "Director/string()" }
    XmlRole { name: "Studio"; query: "Studio/string()" }
    XmlRole { name: "Description"; query: "Description/string()" }
    XmlRole { name: "Inetref"; query: "Inetref/string()" }
    XmlRole { name: "Collectionref"; query: "Collectionref/string()" }
    XmlRole { name: "HomePage"; query: "HomePage/string()" }
    XmlRole { name: "ReleaseDate"; query: "ReleaseDate/string()" }
    XmlRole { name: "AddDate"; query: "AddDate/string()" }
    XmlRole { name: "UserRating"; query: "UserRating/string()" }
    XmlRole { name: "Length"; query: "Length/string()" }
    XmlRole { name: "PlayCount"; query: "PlayCount/string()" }
    XmlRole { name: "Season"; query: "Season/number()" }
    XmlRole { name: "Episode"; query: "Episode/number()" }
    XmlRole { name: "ParentalLevel"; query: "ParentalLevel/string()" }
    XmlRole { name: "Visible"; query: "Visible/string()" }
    XmlRole { name: "Watched"; query: "Watched/string()" }
    XmlRole { name: "Processed"; query: "Processed/string()" }
    XmlRole { name: "ContentType"; query: "ContentType/string()" }
    XmlRole { name: "Genre"; query: "string-join(Genres/GenreList/Genre/Name, ', ')" }
    XmlRole { name: "FileName"; query: "FileName/string()" }
    XmlRole { name: "Hash"; query: "Hash/string()" }
    XmlRole { name: "HostName"; query: "HostName/string()" }
    XmlRole { name: "Coverart"; query: "Coverart/string()" }
    XmlRole { name: "Fanart"; query: "Fanart/string()" }
    XmlRole { name: "Banner"; query: "Banner/string()" }
    XmlRole { name: "Screenshot"; query: "Screenshot/string()" }
    XmlRole { name: "Trailer"; query: "Trailer/string()" }

    signal loaded();

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            screenBackground.showBusyIndicator = false;

            updateLists();

            loaded();
        }

        if (status === XmlListModel.Loading)
        {
            screenBackground.showBusyIndicator = true;
        }

        if (status === XmlListModel.Error)
        {
            screenBackground.showBusyIndicator = false;
            console.log("Error: " + errorString + "\n \n \n " + videoModel.source.toString());
        }
    }

    function updateLists()
    {
        var title;
        var genre;
        var type;

        var titles = [];
        var genres = [];
        var types = [];

        titleList.clear();
        typeList.clear();
        genreList.clear();

        for (var x = 0; x < count; x++)
        {
            title = get(x).Title;
            genre = get(x).Genre;
            type = get(x).ContentType;

            if (titles.indexOf(title) < 0)
                titles.push(title);

            if (types.indexOf(type) < 0)
                types.push(type);

            var splitGenres = genre.split(",");

            for (var y = 0; y < splitGenres.length; y++)
            {
                genre = splitGenres[y].trim();

                if (genres.indexOf(genre) < 0)
                    genres.push(genre);
            }
        }

        titles.sort();
        types.sort();
        genres.sort();

        for (var x = 0; x < titles.length; x++)
            titleList.append({"item": titles[x]});

        for (var x = 0; x < genres.length; x++)
            genreList.append({"item": genres[x]});

        for (var x = 0; x < types.length; x++)
            typeList.append({"item": types[x]});
    }
}
