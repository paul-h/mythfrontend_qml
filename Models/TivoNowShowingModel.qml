import QtQuick
import QtQml.XmlListModel

import Process 1.0
import mythqml.net 1.0
import com.blackgrain.qml.quickdownload 1.0

Item
{
    id: root

    property string ip: settings.tivoIP
    property int port:  settings.tivoControlPort
    property string user: settings.tivoUserName
    property string password: settings.tivoPassword

    property var model: listModel
    property var categoryList: ListModel{}

    signal loaded();

    ListModel
    {
        id: listModel
    }

    XmlListModel
    {
        id: tivoDetailsModel

        signal loaded();

        source: "https://" + ip + "/TiVoConnect?Command=QueryContainer&Container=/NowPlaying&ItemCount=1&AnchorOffset=0&Recurse=Yes"
        //namespaceDeclarations: "declare default element namespace 'http://www.tivo.com/developer/calypso-protocol-1.6/';" // not supported in Qt6

        query: "/TiVoContainer/Details"
        XmlListModelRole { name: "TotalItems"; elementName: "TotalItems" } //number

        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                log.debug(Verbose.MODEL, "TiVoDetailsModel: READY - Found " + count + " details");
                log.info(Verbose.MODEL, "TiVoDetailsModel: Found " + get(0).TotalItems + " recordings");
                tivoNowShowingModel.totalRecordings = get(0).TotalItems;
                tivoNowShowingModel.start();
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "TiVoDetailsModel: LOADING - " + source);
            }

            if (status === XmlListModel.Error)
            {
                log.error(Verbose.MODEL, "TiVoDetailsModel: ERROR: " + errorString() + " - " + source);
            }
        }
    }

    XmlListModel
    {
        id: tivoNowShowingModel

        property int startIndex: 0
        property int itemCount: 50
        property int totalRecordings: 0

        signal loaded();

        //namespaceDeclarations: "declare default element namespace 'http://www.tivo.com/developer/calypso-protocol-1.6/';"
        query: "/TiVoContainer/Item"
        XmlListModelRole { name: "Title"; elementName: "Details/Title" }
        XmlListModelRole { name: "EpisodeTitle"; elementName: "Details/EpisodeTitle" }
        XmlListModelRole { name: "Description"; elementName: "Details/Description" }
        XmlListModelRole { name: "Duration"; elementName: "Details/Duration" } // number
        XmlListModelRole { name: "SourceChannel"; elementName: "Details/SourceChannel" }
        XmlListModelRole { name: "SourceStation"; elementName: "Details/SourceStation" }

        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                log.debug(Verbose.MODEL, "TiVoNowShowingModel: READY - Found " + count + " recordings");
                doLoad();
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "TiVoNowShowingModel: LOADING - " + source);
            }

            if (status === XmlListModel.Error)
            {
                log.error(Verbose.MODEL, "TiVoNowShowingModel: ERROR: " + errorString() + " - " + source);
            }
        }

        function start()
        {
            listModel.clear();
            startIndex = 0;
            var _itemCount = Math.min(itemCount, totalRecordings);
            source = "https://" + ip + "/TiVoConnect?Command=QueryContainer&Container=/NowPlaying&ItemCount=" + _itemCount + "&AnchorOffset=" + startIndex + "&Recurse=Yes"
        }

        function doLoad()
        {
            for (var x = 0; x < count; x++)
            {
                listModel.append({"id": startIndex + x, "title": get(x).Title, "description": get(x).Description, "icon": "", "player": "Tivo", "url": "", "Duration": get(x).Duration,
                                  "SourceChannel": get(x).SourceChannel, "SourceStation": get(x).SourceStation } );
            }

            startIndex += count;

            if (startIndex >= totalRecordings)
                root.loaded();
            else
            {
                var _itemCount = Math.min(itemCount, totalRecordings - startIndex);
                source = "https://" + ip + "/TiVoConnect?Command=QueryContainer&Container=/NowPlaying&ItemCount=" + _itemCount + "&AnchorOffset=" + startIndex + "&Recurse=Yes"
            }
        }
    }

    function expandNode(tree, path, node)
    {
        node.expanded  = true

        for (x = 0; x < listModel.count; x++)
        {
            var item = listModel.get(x);
            node.subNodes.append({"parent": node, "itemTitle": item.title, "itemData": item.title, "checked": false, "expanded": true, "icon": item.Icon, "subNodes": [], type: SourceTreeModel.NodeType.TivoTV_Channel,
                                  "title": item.title, "player": item.player, "url": item.url
                                 })
        }
    }
}
