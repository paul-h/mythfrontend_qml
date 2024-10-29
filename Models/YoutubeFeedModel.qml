import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

XmlListModel
{
    signal loaded();

    source: ""
    query: "/feed/entry"
    // namespaceDeclarations: "declare default element namespace 'http://www.w3.org/2005/Atom'; declare namespace media = 'http://search.yahoo.com/mrss/'; "
    XmlListModelRole { name: "id"; elementName: "id" }
    XmlListModelRole { name: "title"; elementName: "media:group/media:title" }
    XmlListModelRole { name: "description"; elementName: "media:group/media:description" }
    XmlListModelRole { name: "image"; elementName: "media:group/media:thumbnail"; attributeName: "url" }
    XmlListModelRole { name: "published"; elementName: "published" }
    XmlListModelRole { name: "updated"; elementName: "updated" }
    XmlListModelRole { name: "link"; elementName: "link"; attributeName: "href" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "YoutubeFeedModel: READY - Found " + count + " Youtube feeds");
            loaded();
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "YoutubeFeedModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "YoutubeFeedModel: ERROR: " + errorString() + " - " + source);
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

    function getYouTubeVideos(videoId, callback)
    {
        var key = settings.youtubeAPIKey;
        var http = new XMLHttpRequest();
        var url = "https://youtube.googleapis.com/youtube/v3/videos"
        var params = "?part=snippet%2CcontentDetails%2Cstatistics%2CrecordingDetails%2Cplayer%2Cstatus&id=" + videoId + "&maxResults=50&key=" + key;

        http.open("GET", url + params, true);

        // Send the proper header information along with the request
        http.setRequestHeader("Accept", "application/xml");
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http.setRequestHeader("Content-length", params.length);

        http.onreadystatechange = function()
        {
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    if (typeof callback === "function")
                    {
                        callback.apply(http);
                    }
                }
                else
                {
                    log.info(Verbose.MODEL, "getYouTubeVideos: " + http.status + "\n" + http.responseText);
                    return;
                }
            }
        }

        http.send();
    }

    function getPlaylistsForChannel(channelId, callback)
    {
        var key = settings.youtubeAPIKey;
        var part = "snippet%2CcontentDetails";
        var maxResults = 50;

        var http = new XMLHttpRequest();
        var url = "https://youtube.googleapis.com/youtube/v3/playlists"
        var params = "?part=" + part + "&channelId=" + channelId + "&maxResults=" + maxResults + "&key=" + key;

        http.open("GET", url + params, true);

        // Send the proper header information along with the request
        http.setRequestHeader("Accept", "application/xml");
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http.setRequestHeader("Content-length", params.length);

        http.onreadystatechange = function()
        {
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    if (typeof callback === "function")
                    {
                        callback.apply(http);
                    }
                }
                else
                {
                    log.info(Verbose.MODEL, "getPlaylistsForChannel: " + http.status + "\n" + http.responseText);
                    return;
                }
            }
        }

        http.send();
    }

    function getPlaylistItemsForPlaylist(playlistId, callback)
    {
        var key = settings.youtubeAPIKey;
        var part = "snippet%2CcontentDetails"
        var maxResults = 50;

        var http = new XMLHttpRequest();
        var url = "https://youtube.googleapis.com/youtube/v3/playlistItems"
        var params = "?part=" + part + "&playlistId=" + playlistId + "&maxResults=" + maxResults + "&key=" + key;

        http.open("GET", url + params, true);

        // Send the proper header information along with the request
        http.setRequestHeader("Accept", "application/xml");
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http.setRequestHeader("Content-length", params.length);

        http.onreadystatechange = function()
        {
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    if (typeof callback === "function")
                    {
                        callback.apply(http);
                    }
                }
                else
                {
                    log.info(Verbose.MODEL, "getPlaylistItemsForPlaylist: " + http.status + "\n" + http.responseText);
                    return;
                }
            }
        }

        http.send();
    }
}
