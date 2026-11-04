import QtQuick
import Qt.labs.folderlistmodel

import mythqml.net 1.0
import SortFilterProxyModel 0.2
import "../Util.js" as Util

Item
{
    id: root

    property alias model: fileModel
    property alias count: fileModel.count

    property alias folder: folderModel.folder
    property alias nameFilters: folderModel.nameFilters

    // private
    property bool _folderLock: false
    property var _nodeMap: new Map()

    signal loaded();

    property list<QtObject>fileBaseNameFilter:
    [
        AllOf
        {
            RegExpFilter
            {
                id: fileBaseName
                roleName: "fileBaseName"
                pattern: ""
                caseSensitivity: Qt.CaseInsensitive
            }
        }
    ]

    property list<QtObject> fileBaseNameSorter:
    [
        RoleSorter { roleName: "fileBaseName"; ascendingOrder: true}
    ]

    property list<QtObject> fileModifiedSorter:
    [
        RoleSorter { roleName: "fileModified"; ascendingOrder: true}
    ]

    SortFilterProxyModel
    {
        id: proxyModel
        filters: fileBaseNameFilter
        sorters: fileBaseNameSorter
        sourceModel: fileModel
    }

    WorkerScript
    {
        id: workerScript
        source: "FileBrowserModel.mjs"

        onMessage:
        {
            if (messageObject.status === "Ready")
            {

            }
            else if (messageObject.status === "Loading")
            {

            }
        }
    }

    FolderListModel
    {
        id: folderModel
        nameFilters: ["*.mp4", "*.flv", "*.mp2", "*.wmv", "*.avi", "*.mkv", "*.mpg", "*.iso", "*.ISO", "*.mov", "*.webm"]
        showDirsFirst: true
        caseSensitive: false
        showOnlyReadable: true
        onStatusChanged:
        {
            var statusStr = "Unknown";
            if (status === FolderListModel.Ready)
                statusStr = "Ready";
            else if (status === FolderListModel.Null)
                statusStr = "Null";
            else if (status === FolderListModel.Loading)
                statusStr = "Loading";

            if (folderModel.status == FolderListModel.Ready)
            {
                _folderLock = true;

                var folderPath = folder.toString();

                doLoad(folderPath)
                loaded();

                // if there is an associated node load that
                if (_nodeMap.has(folderPath))
                    expandDirNode(folderPath);

                // if there are nodes waiting process the next one
                if (_nodeMap.size)
                {
                    var newFolder = _nodeMap.keys().next().value;
                    if (newFolder != undefined)
                    {
                        //folder = "";
                        folder = newFolder;
                    }
                }

                _folderLock = false;
            }
        }
    }

    ListModel
    {
        id: fileModel
    }

    function get(x)
    {
        return fileModel.get(x);
    }

    function doLoad(folder)
    {
        fileModel.clear();

        for (var x = 0; x < folderModel.count; x++)
        {
            fileModel.append({"fileName": folderModel.get(x, "fileName"), "filePath": folderModel.get(x, "filePath"), "fileUrl": folderModel.get(x, "fileUrl").toString(), "fileBaseName": folderModel.get(x, "fileBaseName"),
                              "fileSuffix": folderModel.get(x, "fileSuffix"), "fileSize": folderModel.get(x, "fileSize"), "fileModified": folderModel.get(x, "fileModified"), "fileAccessed": folderModel.get(x, "fileAccessed"),
                              "fileIsDir": folderModel.get(x, "fileIsDir")
                             });
        }
    }


    function expandNode(tree, path, node)
    {
        var folder;

        if (node.itemData === "Loading")
            return;

        if (node.type === SourceTreeModel.NodeType.Root_Title || node.type === SourceTreeModel.NodeType.FileBrowser_Directory)
        {
            if (node.itemData === "VideoFiles")
                folder = settings.videoPath;
            else if (node.itemData === "FileBrowser")
                folder = folderModel.folder.toString();
            else
                folder = node.itemData;

            if (!_nodeMap.has(folder))
            {
                _nodeMap.set(folder, node);
                node.subNodes.append({"parent": node, "itemTitle": "Loading ...", "itemData": "Loading", "checked": false, "expanded": true, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Loading})
            }

            if (!_folderLock && folderModel.status != FolderListModel.Loading)
            {
                folderModel.folder = "";
                folderModel.folder = folder;
            }
        }
    }

    function expandDirNode(folder)
    {
        if (!_nodeMap.has(folder))
            return;

        var node = _nodeMap.get(folder);
        node.subNodes.clear();

        if (fileModel.count > 0)
        {
            for (var x = 0; x < fileModel.count; x++)
            {
                var fileNode = fileModel.get(x);
                node.subNodes.append({
                                         "parent": node, "itemTitle": fileNode.fileName, "itemData": fileNode.fileUrl, "checked": false, "expanded": fileNode.fileIsDir ? false : true,
                                         "icon": findCoverImage(fileNode), "subNodes": [], type: fileNode.fileIsDir ?  SourceTreeModel.NodeType.FileBrowser_Directory : SourceTreeModel.NodeType.FileBrowser_File,
                                         "title": fileNode.fileBaseName, "player": "VLC", "url": fileNode.fileUrl, "fileIsDir": fileNode.fileIsDir, "filePath": fileNode.filePath
                                     })
            }
        }
        else
        {
            node.subNodes.append({"parent": node, "itemTitle": "No Files found!", "itemData": "NoFiles", "checked": false, "expanded": true, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.No_Result})
        }

        node.expanded = true;
        _nodeMap.delete(folder);
    }

    function findCoverImage(fileNode)
    {
        var result = "";

        if (fileNode.fileIsDir)
        {
            result = mythUtils.findThemeFile("images/directory.png");
        }
        else
        {
            result = mythUtils.findThemeFile(fileNode.filePath + ".png");

            if (result === "")
                result = mythUtils.findThemeFile(fileNode.filePath + ".jpg");

            if (result === "")
                result = mythUtils.findThemeFile(Util.removeExtension(fileNode.filePath) + ".png");

            if (result === "")
                result = mythUtils.findThemeFile(Util.removeExtension(fileNode.filePath) + ".jpg");

            if (result === "")
                result = mythUtils.findThemeFile("images/grid_noimage.png");
        }

        return result;
    }
}
