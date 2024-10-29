import QtQuick

import mythqml.net 1.0
import SortFilterProxyModel 0.2

Item
{
    id: root

    property alias model: jsonModel.model
    property JSONListModel jsonModel: jsonModel

    property var tagList: ListModel{}
    property var countryList: ListModel{}
    property var languageList: ListModel{}

    // private
    property var _nodeMap: new Map()

    signal loaded();

    property list<QtObject> radioFilter:
    [
        AllOf
        {
            RegExpFilter
            {
                id: radioCountry
                roleName: "countries"
                pattern: ""
                caseSensitivity: Qt.CaseInsensitive
            }
            RegExpFilter
            {
                id: radioLanguage
                roleName: "languages"
                pattern: ""
                caseSensitivity: Qt.CaseInsensitive
            }
            RegExpFilter
            {
                id: radioTag
                roleName: "tags"
                pattern: ""
                caseSensitivity: Qt.CaseInsensitive
            }
        }
    ]

    property list<QtObject> nameSorter:
    [
        RoleSorter { roleName: "name"; ascendingOrder: true}
    ]

    property list<QtObject> countrySorter:
    [
        RoleSorter { roleName: "countries"; ascendingOrder: true},
        RoleSorter { roleName: "name" }
    ]

    property list<QtObject> languageSorter:
    [
        RoleSorter { roleName: "languages"; ascendingOrder: true},
        RoleSorter { roleName: "name" }
    ]

    property list<QtObject> tagSorter:
    [
        RoleSorter { roleName: "tags"; ascendingOrder: true},
        RoleSorter { roleName: "name" }
    ]

    SortFilterProxyModel
    {
        id: proxyModel
        filters: radioFilter
        sorters: nameSorter
    }

    JSONListModel
    {
        id: jsonModel

        property alias tagList: root.tagList;
        property alias countryList: root.countryList
        property alias languageList: root.languageList

        source: "https://de1.api.radio-browser.info/json/stations"
        workerSource: "RadioBrowserModel.mjs"
        parser: myparser
        parserData: root

        function myparser(json, query, jsonModel, workerScript, parserData, debug)
        {
            var lists = {'tagList': root.tagList, 'countryList': root.countryList, 'languageList': root.languageList};
            var jsonArray = splitJson(json, 15000000);
            var msg = {'action': 'Load Model', 'jsonArray': jsonArray, 'query': query, 'jsonModel': jsonModel, 'lists': lists, 'debug': debug};

            workerScript.sendMessage(msg);
        }

        onLoaded:
        {
            root.loaded();

        }
    }

    WorkerScript
    {
        id: myWorker
        property var tree: undefined
        property bool busy: false

        source: "RadioBrowserModel.mjs"

        onMessage:
        {
            if (messageObject.status === "ExpandNode Finished")
            {
                var path = messageObject.path;
                var node = _nodeMap.get(path);

                // we need to fixup the parents of the new nodes
                for (var x = 0; x < node.subNodes.count; x++)
                    node.subNodes.get(x).parent = node;
                
                // remove this path from the map and start the next one if available
                _nodeMap.delete(path);
                var newPath = _nodeMap.keys().next().value;
                var newNode = _nodeMap.keys().next().key;

                if (newPath !== undefined && newPath !== "")
                {
                    // we have limited access in the JS engine used by the the WorkerScript so pass in everything we need
                    var defaultIcon = mythUtils.findThemeFile("images/radio.webp");
                    var lists = {'tagList': root.tagList, 'countryList': root.countryList, 'languageList': root.languageList};
                    var msg = {'action': 'Expand Node', 'tree': tree, 'path':newPath, 'node': newNode, 'defaultIcon': defaultIcon, 'jsonModel': jsonModel.model, 'lists': lists, 'proxyModel': proxyModel};

                    busy = true;
                    myWorker.sendMessage(msg);
                }
                else
                {
                    busy = false;
                }
            }
        }
    }


    function expandNode(tree, path, node)
    {
        if (myWorker.tree === undefined)
            myWorker.tree = tree;

        node.expanded  = true;
        node.subNodes.append({"parent": node, "itemTitle": "Loading ...", "itemData": "Loading", "checked": false, "expanded": true, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Loading})

        _nodeMap.set(path, node);

        if (!myWorker.busy)
        {
            // we have limited access in the JS engine used by the WorkerScript so pass in everything we need
            var defaultIcon = mythUtils.findThemeFile("images/radio.webp");
            var lists = {'tagList': root.tagList, 'countryList': root.countryList, 'languageList': root.languageList};
            var msg = {'action': 'Expand Node', 'tree': tree, 'path': path, 'node': node, 'defaultIcon': defaultIcon, 'jsonModel': jsonModel.model, 'lists': lists, 'proxyModel': proxyModel};

            myWorker.busy = true;
            myWorker.sendMessage(msg);
        }
    }

    function splitJson(json, length)
    {
        var result = [];
        var start = 0;
        var end = length;
        var x = 0;

        while(start < json.length)
        {
            if (end > json.length)
                end = json.length;

            result.push(json.substring(start, end));
            start = end;
            end = end + length;

            x++;
        }

        return result;
    }

    function getIconURL(iconURL)
    {
        if (iconURL && iconURL != "")
            return iconURL;

        return mythUtils.findThemeFile("images/radio.webp");
    }
}
