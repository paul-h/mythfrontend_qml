import { jsonPath, parseJSONString } from "jsonpath.mjs"

WorkerScript.onMessage = function(msg)
{
    WorkerScript.sendMessage({model: "JSONListModel", status: "Loading"});

    var folderModel = msg.folderModel;
    var fileModel = msg.fileModel;
    var folder = msg.folder

    doLoad(folder)
    jsonModel.sync();

    WorkerScript.sendMessage({model: "JSONListModel", status: "Ready"});
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
        _folderLock = false;
    }
