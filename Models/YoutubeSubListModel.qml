import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: youtubeSubListModel

    signal loaded();

    query: "/items/item"
    XmlRole { name: "id"; query: "id/number()" }
    XmlRole { name: "name"; query: "name/string()" }
    XmlRole { name: "icon"; query: "icon/string()" }
    XmlRole { name: "url"; query: "url/string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "YoutubeSubListModel: READY - Found " + count + " youtube subscriptions lists");
            loaded();
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "YoutubeSubListModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "YoutubeSubListModel: ERROR: " + errorString() + " - " + source);
        }
    }

    Component.onCompleted:
    {
        var youtubeFile = settings.youtubeSubListFile;
        if (youtubeFile == undefined ||  youtubeFile == "" || youtubeFile == "https://mythqml.net/download.php?f=youtube_sub_list.xml")
            youtubeFile = "https://mythqml.net/download.php?f=youtube_sub_list.xml&v=" + version + "&s=" + systemid;

        source = youtubeFile;
    }
}
