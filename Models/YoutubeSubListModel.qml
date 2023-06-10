import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: youtubeSubListModel

    signal loaded();

    property var lastNode: undefined

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

        playerSources.youtubeFeedList.onStatusChanged.connect(addYouTubeVideos);
    }

    Component.onDestruction:
    {
        playerSources.youtubeFeedList.onStatusChanged.disconnect(addYouTubeVideos);
    }

    function expandNode(tree, path, node)
    {
        if (node.type === SourceTreeModel.NodeType.Root_Title)
        {
            // add YouTube channels
            for (x = 0; x < count; x++)
            {
                node.subNodes.append({"parent": node, "itemTitle": get(x).name, "itemData": get(x).url, "checked": false, "expanded": false, "icon": get(x).icon, "subNodes": [], type: SourceTreeModel.NodeType.YouTube_Channel})
            }
        }
        else if (node.type === SourceTreeModel.NodeType.YouTube_Channel)
        {
            // add videos for YouTube channel
            lastNode = node;
            playerSources.youtubeFeedList.source = node.itemData;
            node.subNodes.append({"parent": node, "itemTitle": "Loading ...", "itemData": "Loading", "checked": false, "expanded": true, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.YouTube_Loading})
        }
    }

    function addYouTubeVideos()
    {
        if (playerSources.youtubeFeedList.status == XmlListModel.Ready)
        {
            lastNode.subNodes.clear();

            if (count > 0)
            {
                for (var x = 0; x < playerSources.youtubeFeedList.count; x++)
                {
                    var video = playerSources.youtubeFeedList.get(x);
                    lastNode.subNodes.append({
                                                 "parent": lastNode, "itemTitle": video.title, "itemData": video.id, "checked": false, "expanded": true, "icon": video.image, "subNodes": [], type: SourceTreeModel.NodeType.YouTube_Video,
                                                 "title": video.title, "player": "YouTube", "url": video.link, "link": video.link, "description": video.description, "published": video.published, "updated": video.updated
                                            })
                }
            }
            else
            {
                node.subNodes.append({"parent": node, "itemTitle": "No YouTube Videos found!", "itemData": "NoVideos", "checked": false, "expanded": true, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.YouTube_Error})
            }
        }

        if (playerSources.youtubeFeedList.status === XmlListModel.Error)
        {
            lastNode.subNodes.clear();
            lastNode.subNodes.append({"parent": lastNode, "itemTitle": "ERROR: " + playerSources.youtubeFeedList.errorString(), "itemData": "Error", "checked": false, "expanded": true, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.YouTube_Error})
        }
    }
}
