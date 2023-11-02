import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Process 1.0
import mythqml.net 1.0
import SortFilterProxyModel 0.2

Item
{
    id: root

    property var model: treeModel

    signal branchUpdateStarted(string path)
    signal branchUpdateEnded(string path)

    enum NodeType
    {
        Root,                       // 0
        Root_Title,                 // 1
        Separator,                  // 2
        No_Result,                  // 3
        Loading,                    // 4
        Webcam_File,                // 5
        Webcam_Category,            // 6
        Webcam_Item,                // 7
        Webvideo_File,              // 8
        Webvideo_Category,          // 9
        Webvideo_Item,              // 10
        ZoneMinder_Camera,          // 11
        IPTV_Channel,               // 12
        IPTV_Filters,               // 13
        IPTV_Filter_All,            // 14
        IPTV_Filter_Genre,          // 15
        IPTV_Filter_Country,        // 16
        IPTV_Filter_Language,       // 17
        MythTV_Channel,             // 18
        MythTV_Filters,             // 19
        MythTV_Filter_All,          // 20
        MythTV_Filter_Genre,        // 21
        MythTV_Filter_Source,       // 22
        TivoTV_Channel,             // 23
        TivoTV_Filters,             // 24
        TivoTV_Filter_All,          // 25
        TivoTV_Filter_Genre,        // 26
        TivoTV_Filter_Definition,   // 27
        YouTube_Channel,            // 28
        YouTube_Video,              // 29
        YouTube_Loading,            // 30
        YouTube_Error,              // 31
        Recordings_Program,         // 32
        Recordings_Filters,         // 33
        Recordings_Filter,          // 34
        Recordings_Filter_Title,    // 35
        Recordings_Filter_Genre,    // 36
        Recordings_Filter_RecGroup, // 37
        Videos_Video,               // 38
        Videos_Filters,             // 39
        Videos_Filter_All,          // 40
        Videos_Filter_Genre,        // 41
        Videos_Filter_Title,        // 42
        Videos_Filter_Type,         // 43
        Browser_Bookmark,           // 44
        Browser_Filters,            // 45
        Browser_Filter_Website,     // 46
        Browser_Filter_Category,    // 47
        VideoFiles_File,            // 48
        VideoFiles_Directory        // 49
    }

    Connections
    {
        target: playerSources.browserBookmarksList
        function onLoaded()
        {
            branchUpdateStarted("Root ~ BrowserBookmarks");
            clearBranch("Root ~ BrowserBookmarks");
            branchUpdateEnded("Root ~ BrowserBookmarks");
        }
    }

    Connections
    {
        target: playerSources.tivoChannelList
        function onLoaded()
        {
            branchUpdateStarted("Root ~ TivoTV");
            clearBranch("Root ~ TivoTV");
            branchUpdateEnded("Root ~ TivoTV");
        }
    }

    ListModel
    {
        id: treeModel

        property var root: treeModel.get(0);

        ListElement
        {
            itemTitle: "Root"
            itemData: "Root"
            checked: false
            expanded: false
            icon: ""
            subNodes: []
            type: 0; // SourceTreeModel.NodeType.Root
            parent: null
        }

        function expandNode(path, node)
        {
            // is this the root node
            if (node.itemData === "Root")
            {
                node.expanded = true;

                if (settings.mythQLayout)
                {
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Home",                  "itemData": "Home",           "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Myth TV",               "itemData": "MythTV",         "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "IPTV",                  "itemData": "IPTV",           "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Guide",                 "itemData": "Guide",          "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Recordings",            "itemData": "Recordings",     "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Webcams",               "itemData": "Webcams",        "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "YouTube TV",            "itemData": "YouTubeTV",      "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "YouTube Subscriptions", "itemData": "YouTubeSubs",    "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Videos",                "itemData": "Videos",         "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Web Videos",            "itemData": "WebVideos",      "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "CCTV Cameras",          "itemData": "ZMCameras",      "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Pictures",              "itemData": "Pictures",       "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Music",                 "itemData": "Music",          "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "News Feeds",            "itemData": "NewsFeeds",      "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Web Browser",           "itemData": "WebBrowser",     "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Weather",               "itemData": "Weather",        "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Whats New",             "itemData": "WhatsNew",       "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Advent Calendar",       "itemData": "AdventCalendar", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Setup",                 "itemData": "Setup",          "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Test Pages",            "itemData": "Tests",          "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    return;
                }
                else
                {
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Myth TV",               "itemData": "MythTV",           "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "TiVo TV",               "itemData": "TivoTV",           "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Fire TV",               "itemData": "FireTV",           "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Webcams",               "itemData": "Webcams",          "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Web Videos",            "itemData": "Webvideos",        "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Videos",                "itemData": "Videos",           "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Video File Browser",    "itemData": "VideoFiles",       "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Recordings",            "itemData": "Recordings",       "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "ZoneMinder Cameras",    "itemData": "ZMCameras",        "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "IPTV Channels",         "itemData": "IPTVChannels",     "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "YouTube Subscriptions", "itemData": "YouTubeSubs",      "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                    node.subNodes.append({"parent": treeModel.get(0), "itemTitle": "Browser Bookmarks",     "itemData": "BrowserBookmarks", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})

                    return;
                }
            }

            // has this node already been expanded
            if (node.expanded)
                return;

            if (path.startsWith("Root ~ MythTV"))
            {
                playerSources.channelList.expandNode(treeModel, path, node);
            }
            else if (path === "Root ~ TivoTV" && node.itemData === "TivoTV")
            {
                node.expanded = true;
                node.subNodes.append({"parent": node, "itemTitle": "Live TV",     "itemData": "LiveTV",    "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
                node.subNodes.append({"parent": node, "itemTitle": "Now Showing", "itemData": "NowShowing","checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Root_Title})
            }
            else if (path.startsWith("Root ~ TivoTV ~ LiveTV"))
            {
                playerSources.tivoChannelList.expandNode(treeModel, path, node);
            }
            else if (path.startsWith("Root ~ TivoTV ~ NowShowing"))
            {
                playerSources.tivoNowShowingList.expandNode(treeModel, path, node);
            }
            else if (path.startsWith("Root ~ Webcams"))
            {
                playerSources.webcamList.expandNode(treeModel, path, node);
            }
            else if (path.startsWith("Root ~ Webvideos"))
            {
                playerSources.webvideoList.expandNode(treeModel, path, node);
            }
            else if (path.startsWith("Root ~ Recordings"))
            {
                playerSources.recordingsList.expandNode(treeModel, path, node);
            }
            else if (path.startsWith("Root ~ ZMCameras"))
            {
                playerSources.zmCameraList.expandNode(treeModel, path, node);
            }
            else if (path.startsWith("Root ~ IPTVChannels"))
            {
                playerSources.iptvList.expandNode(treeModel, path, node);
            }
            else if (path.startsWith("Root ~ YouTubeSubs"))
            {
                playerSources.youtubeSubsList.expandNode(treeModel, path, node);
            }
            else if (path.startsWith("Root ~ Videos"))
            {
                playerSources.videoList.expandNode(treeModel, path, node);
            }
            else if (path.startsWith("Root ~ VideoFiles"))
            {
                playerSources.videoFilesList.expandNode(treeModel, path, node);
            }
            else if (path.startsWith("Root ~ BrowserBookmarks"))
            {
                playerSources.browserBookmarksList.expandNode(treeModel, path, node);
            }
        }
    }

    function get(index)
    {
        return model.get(x);
    }

    function playFile(currentIndex, node)
    {
        if (node.type === SourceTreeModel.NodeType.Webcam_Item || node.type === SourceTreeModel.NodeType.IPTV_Channel || node.type === SourceTreeModel.NodeType.ZoneMinder_Camera ||
            node.type === SourceTreeModel.NodeType.MythTV_Channel || node.type === SourceTreeModel.NodeType.TivoTV_Channel || node.type === SourceTreeModel.NodeType.Webvideo_Item ||
            node.type === SourceTreeModel.NodeType.YouTube_Video || node.type === SourceTreeModel.NodeType.Videos_Video)
        {
            playerSources.adhocList = node.parent.subNodes;
            stack.push({item: mythUtils.findThemeFile("Screens/InternalPlayer.qml"), properties:{defaultFeedSource: "Adhoc", defaultFilter: "", defaultCurrentFeed: currentIndex}});
        }
        else if (node.type === SourceTreeModel.NodeType.VideoFiles_File)
        {
            if (node.fileIsDir)
            {
                if (node.filePath.endsWith("/VIDEO_TS"))
                {
                    playDVD(node.filePath)
                }
                else
                {
                    //if (root.isPanel)
                    //    panelStack.push({item: Qt.resolvedUrl("VideosGridFolder.qml"), properties:{folder: model.get(currentIndex, "filePath")}});
                    //else
                    //    stack.push({item: Qt.resolvedUrl("VideosGridFolder.qml"), properties:{folder: model.get(currentIndex, "filePath")}});
                }
            }
            else
            {
                if (node.filePath.endsWith(".ISO") || node.filePath.endsWith(".iso"))
                {
                    playDVD(node.filePath)
                }
                else
                {
                    //if (root.isPanel)
                    //{
                    //    internalPlayer.previousFocusItem = videoList;
                    //    playerSources.adhocList = mediaModel;
                    //    feedSelected("Adhoc", "", 0);
                    //}
                    //else
                    {
                        playerSources.adhocList = node.parent.subNodes;
                        var item = stack.push({item: mythUtils.findThemeFile("Screens/InternalPlayer.qml"), properties:{defaultFeedSource:  "Adhoc", defaultFilter:  "", defaultCurrentFeed: currentIndex}});
                    }
                }
            }
        }
        else if (node.type === SourceTreeModel.NodeType.Browser_Bookmark)
        {
            var url = node.url
            var zoom = xscale(1.0);
            var fullscreen = false

            if (url.startsWith("setting://"))
            {
                var setting = url.replace("setting://", "");
                url = dbUtils.getSetting(setting, settings.hostName, "");
            }
            else if (url.startsWith("file://"))
            {
                // nothing to do
            }
            else if (!url.startsWith("http://") && !url.startsWith("https://"))
                url = "http://" + url;

            stack.push({item: mythUtils.findThemeFile("Screens/WebBrowser.qml"), properties:{url: url, fullscreen: fullscreen, zoomFactor: zoom}});
        }
    }

    // cvlc player for fullscreen DVD playback
    Process
    {
        id: vlcPlayerProcess
        onFinished:
        {
            showVideo(true);
            pauseVideo(false);
        }
    }

    function playDVD(filename)
    {
        pauseVideo(true);
        showVideo(false);
        vlcPlayerProcess.start("/usr/bin/cvlc", ["--play-and-exit",  "--fullscreen",
                                                 "--key-quit", "Esc", "--key-leave-fullscreen", "Ctrl+F",
                                                 filename]);
    }

    //FIXME:
    function setRootNode(path)
    {
        if (path === "")
        {
            model = treeModel;
            return;
        }

        var list = path.split(" ~ ");
        var node = treeModel;
        var found = false;

        for (var x = 0; x < list.length; x++)
        {
            found = false;

            for (var y = 0; y < node.count; y++)
            {
                if (node.get(y).itemData == list[x])
                {
                    if (node.get(y).expanded !== undefined && node.get(y).expanded === false && (typeof node.expandNode === "function"))
                        node.expandNode(getPathFromNode(node.get(y)), node.get(y))

                    node = node.get(y).subNodes;
                    found = true;
                    break;
                }
            }

            if (!found)
                break;
        }
    }

    function getNodeFromPath(path)
    {
        var list = path.split(" ~ ");
        var node = treeModel;
        var found = false;

        for (var x = 0; x < list.length; x++)
        {
            found = false;

            for (var y = 0; y < node.count; y++)
            {
                if (node.get(y).itemData == list[x])
                {
                    if (node.get(y).expanded === false)
                        treeModel.expandNode(getPathFromNode(node.get(y)), node.get(y))

                    if (x < list.length - 1)
                        node = node.get(y).subNodes;
                    else
                        node = node.get(y);

                    found = true;
                    break;
                }
            }

            if (!found)
            {
                return undefined;
            }
        }

        return node;
    }

    function getPathFromNode(node, useData)
    {
        if (!node)
            return "";

        var result = "";

        while (node != null)
        {
            if (result != "")
                result = (useData ? node.itemData : node.itemTitle) + " ~ " + result;
            else
                result = useData ? node.itemData : node.itemTitle;

            node = node.parent;
        }

        return result;
    }

    function clearBranch(path)
    {
        var node = getNodeFromPath(path)

        if (node !== undefined)
        {
            // FIXME should recursively clear the branch?
            node.expanded = false;
            node.subNodes.clear();
        }
    }
}

