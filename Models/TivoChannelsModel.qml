import QtQuick 2.15
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

Item
{
    id: root

    property alias model: channelsModel
    property alias count: channelsModel.count

    property var categoryList: ListModel{}
    property var definitionList: ListModel{}

    XmlListModel
    {
        id: channelsModel
        source: "https://mythqml.net/download.php?f=channels.xml&v=" + version + "&s=" + systemid;
        query: "/channels/channel"
        XmlRole { name: "ChanNo"; query: "ChanNo/number()" }
        XmlRole { name: "Name"; query: "Name/string()" }
        XmlRole { name: "Plus1"; query: "Plus1/number()" }
        XmlRole { name: "Definition"; query: "Definition/string()" }
        XmlRole { name: "Category"; query: "Category/string()" }
        XmlRole { name: "Icon"; query: "Icon/string()" }
        XmlRole { name: "SDId"; query: "SDId/string()" }

        XmlRole { name: "title"; query: "concat(ChanNo/string(), xs:string(' - '), Name/string())" }
        XmlRole { name: "player"; query: "xs:string('Tivo')" }
        XmlRole { name: "url"; query: "ChanNo/number()" }
        XmlRole { name: "icon"; query: "Icon/string()" }

        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                log.debug(Verbose.MODEL, "TivoChannelsModel: READY - Found " + count + " channels");
                doLoad();
            }

            if (status === XmlListModel.Loading)
            {
                log.debug(Verbose.MODEL, "TivoChannelsModel: LOADING - " + source);
            }

            if (status === XmlListModel.Error)
            {
                log.error(Verbose.MODEL, "TivoChannelsModel: ERROR: " + errorString() + " - " + source);
            }
        }

        function doLoad()
        {
            var category;
            var categories = [];
            var definition;
            var definitions = [];
            var x;

            for (x = 0; x < count; x++)
            {
                category = get(x).Category;

                if (categories.indexOf(category) < 0)
                    categories.push(category);

                definition = get(x).Definition;

                if (definitions.indexOf(definition) < 0)
                    definitions.push(definition);
            }

            categories.sort();
            definitions.sort();

            for (x = 0; x < categories.length; x++)
                categoryList.append({"item": categories[x]});

            for (x = 0; x < definitions.length; x++)
                definitionList.append({"item": definitions[x]});
        }
    }

    function get(index)
    {
        return channelsModel.get(index);
    }
}
