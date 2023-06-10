import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Qt.labs.folderlistmodel 2.15
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

    FolderListModel
    {
        id: folderModel
        nameFilters: ["*.mp4", "*.flv", "*.mp2", "*.wmv", "*.avi", "*.mkv", "*.mpg", "*.iso", "*.ISO", "*.mov", "*.webm"]
        showDirsFirst: true
        caseSensitive: false
        showOnlyReadable: true
        onStatusChanged: if (folderModel.status == FolderListModel.Ready) doLoad(folder.toString())
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

        expandDirNode(folder);

        // remove this folder from map and start the next one if available
        _nodeMap.delete(folder);
        var newFolder = _nodeMap.keys().next().value;

        if (newFolder !== undefined)
            folderModel.folder = newFolder;
    }

    function expandNode(tree, path, node)
    {
        var folder;

        if (node.type === SourceTreeModel.NodeType.Root_Title || node.type === SourceTreeModel.NodeType.VideoFiles_Directory)
        {
            if (node.itemData === "VideoFiles")
                folder = "file://" + settings.videoPath;
            else
                folder = node.itemData;

            _nodeMap.set(folder, node);

            if (folderModel.status != FolderListModel.Loading)
            {
                folderModel.folder = "";
                folderModel.folder = folder;
            }

            node.subNodes.append({"parent": node, "itemTitle": "Loading ...", "itemData": "Loading", "checked": false, "expanded": true, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Loading})
        }
    }

    function expandDirNode(folder)
    {
        if (!_nodeMap.has(folder))
            return;

        if (folderModel.status == FolderListModel.Ready)
        {
            var node = _nodeMap.get(folder);

            node.subNodes.clear();

            if (fileModel.count > 0)
            {
                for (var x = 0; x < fileModel.count; x++)
                {
                    var fileNode = fileModel.get(x);

                    node.subNodes.append({
                                             "parent": node, "itemTitle": fileNode.fileName, "itemData": fileNode.fileUrl, "checked": false, "expanded": fileNode.fileIsDir ? false : true,
                                             "icon": findCoverImage(fileNode), "subNodes": [], type: fileNode.fileIsDir ?  SourceTreeModel.NodeType.VideoFiles_Directory : SourceTreeModel.NodeType.VideoFiles_File,
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
