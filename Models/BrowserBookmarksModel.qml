import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0
import SortFilterProxyModel 0.2
import SqlQueryModel 1.0

Item
{
    id: root

    property alias model: listModel
    property alias count: listModel.count

    //property var loadingNode: undefined
    //property bool loadingFinished: false

    property var websiteList: ListModel{}
    property var categoryList: ListModel{}

    signal loaded();

    Component.onCompleted:
    {
        loadFromDB();
    }

    property list<QtObject> bookmarksFilter:
    [
        AllOf
        {
            ValueFilter
            {
                id: websiteFilter
                roleName: "website"
                value: ""
                enabled: value !== ""
            }
            ValueFilter
            {
                id: categoryFilter
                roleName: "category"
                value: ""
                enabled: value !== ""
            }
        }
    ]

    property list<QtObject> websiteSorter:
    [
        RoleSorter { roleName: "website"; ascendingOrder: true},
        RoleSorter { roleName: "title"; ascendingOrder: true}

    ]

    property list<QtObject> idSorter:
    [
        RoleSorter { roleName: "bookmarkid"; ascendingOrder: true}
    ]

    property list<QtObject> categorySorter:
    [
        RoleSorter { roleName: "category"; ascendingOrder: true},
        RoleSorter { roleName: "title" }
    ]

    property list<QtObject> dateVistedSorter:
    [
        RoleSorter { roleName: "date_visited"; ascendingOrder: true},
        RoleSorter { roleName: "title" }
    ]

    property list<QtObject> dateAddedSorter:
    [
        RoleSorter { roleName: "date_added"; ascendingOrder: true},
        RoleSorter { roleName: "title" }
    ]

    property list<QtObject> visitedCountSorter:
    [
        RoleSorter { roleName: "visitedcount"; ascendingOrder: true},
        RoleSorter { roleName: "title" }
    ]

    SqlQueryModel
    {
        id: browserBookmarkModel

        sql: "SELECT bookmarkid, website, title, category, url, iconurl, date_added,
              date_modified, date_visited, visited_count FROM bookmarks ORDER BY website, title";
    }

    SortFilterProxyModel
    {
        id: proxyModel
        filters: bookmarksFilter
        sorters: websiteSorter
        sourceModel: listModel
    }

    ListModel
    {
        id: listModel
    }

    function loadFromDB()
    {
        var x;
        var websites = [];
        var categories = [];

        root.websiteList.clear();
        root.categoryList.clear();
        listModel.clear();

        browserBookmarkModel.reload();

        for (x = 0; x < browserBookmarkModel.rowCount(); x++)
        {
            var bookmarkid = browserBookmarkModel.data(browserBookmarkModel.index(x, 0));
            var website = browserBookmarkModel.data(browserBookmarkModel.index(x, 1));
            var title = browserBookmarkModel.data(browserBookmarkModel.index(x, 2));
            var category = browserBookmarkModel.data(browserBookmarkModel.index(x, 3));
            var url = browserBookmarkModel.data(browserBookmarkModel.index(x, 4));
            var iconurl = browserBookmarkModel.data(browserBookmarkModel.index(x, 5));
            var date_added = browserBookmarkModel.data(browserBookmarkModel.index(x, 6));
            var date_modified = browserBookmarkModel.data(browserBookmarkModel.index(x, 7));
            var date_visited = browserBookmarkModel.data(browserBookmarkModel.index(x, 8));
            var visited_count = browserBookmarkModel.data(browserBookmarkModel.index(x, 9));
            listModel.append({"bookmarkid": bookmarkid, "website": website, "title": title, "category": category, "icon": iconurl, "player": "WebBrowser", "url": url,
                              "date_added": date_added, "date_modified": date_modified, "date_visited": date_visited, "visited_count": visited_count
                             });

            if (websites.indexOf(website) < 0)
                websites.push(website);

            if (categories.indexOf(category) < 0)
                categories.push(category);
        }

        websites.sort();

        for (x = 0; x < websites.length; x++)
            root.websiteList.append({"item": websites[x]});

        categories.sort();

        for (x = 0; x < categories.length; x++)
            root.categoryList.append({"item": categories[x]});

        // force the proxy model to reload
        proxyModel.invalidate();

        root.loaded();
    }

    function expandNode(tree, path, node)
    {
        var x;

        node.expanded  = true

        if (node.type === SourceTreeModel.NodeType.Root_Title)
        {
            node.subNodes.append({"parent": node, "itemTitle": "<All Bookmarks>", "itemData": "AllBookmarks", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Browser_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Websites", "itemData": "Websites", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Browser_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Categories", "itemData": "Categories", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Browser_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Recently Added", "itemData": "RecentlyAdded", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Browser_Filters})
            node.subNodes.append({"parent": node, "itemTitle": "Most Visited", "itemData": "MostVisited", "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Browser_Filters})
        }
        else if (node.type === SourceTreeModel.NodeType.Browser_Filters)
        {
            if (node.itemData === "AllBookmarks")
            {
                for (x = 0; x < proxyModel.count; x++)
                {
                    var bookmark = proxyModel.get(x);
                    node.subNodes.append({
                                             "parent": node, "itemTitle": bookmark.website + " ~ " + bookmark.title, "bookmarkid": String(bookmark.bookmarkid), "itemData": String(bookmark.bookmarkid), "checked": false, "expanded": true, "icon": getIconURL(bookmark), "subNodes": [], type: SourceTreeModel.NodeType.Browser_Bookmark,
                                             "player": "WebBrowser", "url": bookmark.url, "genre": bookmark.Category, "DateAdded": bookmark.DateAdded, "DateVisited": bookmark.DateVisited, "VisitedCount": bookmark.VisitedCount
                                         });
                }
            }
            else if (node.itemData === "Websites")
            {
                for (x = 0; x < root.websiteList.count; x++)
                    node.subNodes.append({"parent": node, "itemTitle": root.websiteList.get(x).item, "itemData": root.websiteList.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Browser_Filter_Website})
            }
            else if (node.itemData === "Categories")
            {
                for (x = 0; x < root.categoryList.count; x++)
                    node.subNodes.append({"parent": node, "itemTitle": root.categoryList.get(x).item, "itemData": root.categoryList.get(x).item, "checked": false, "expanded": false, "icon": "", "subNodes": [], type: SourceTreeModel.NodeType.Browser_Filter_Category})
            }

            //TODO add recently added and most visited
        }
        else if (node.type === SourceTreeModel.NodeType.Browser_Filter_Website)
        {
            websiteFilter.value = node.itemData;
            categoryFilter.value = "";

            for (x = 0; x < proxyModel.count; x++)
            {
                var bookmark = proxyModel.get(x);
                node.subNodes.append({
                                         "parent": node, "itemTitle": bookmark.website + " ~ " + bookmark.title, "bookmarkid": String(bookmark.bookmarkid), "itemData": String(bookmark.bookmarkid), "checked": false, "expanded": true, "icon": getIconURL(bookmark), "subNodes": [], type: SourceTreeModel.NodeType.Browser_Bookmark,
                                         "player": "WebBrowser", "url": bookmark.url, "genre": bookmark.Category, "DateAdded": bookmark.DateAdded, "DateVisited": bookmark.DateVisited, "VisitedCount": bookmark.VisitedCount
                                     });
            }
        }
        else if (node.type === SourceTreeModel.NodeType.Browser_Filter_Category)
        {
            websiteFilter.value = "";
            categoryFilter.value = node.itemData;

            for (x = 0; x < proxyModel.count; x++)
            {
                var bookmark = proxyModel.get(x);
                node.subNodes.append({
                                         "parent": node, "itemTitle": bookmark.website + " ~ " + bookmark.title, "bookmarkid": String(bookmark.bookmarkid), "itemData": String(bookmark.bookmarkid), "checked": false, "expanded": true, "icon": getIconURL(bookmark), "subNodes": [], type: SourceTreeModel.NodeType.Browser_Bookmark,
                                         "player": "WebBrowser", "url": bookmark.url, "genre": bookmark.Category, "DateAdded": bookmark.DateAdded, "DateVisited": bookmark.DateVisited, "VisitedCount": bookmark.VisitedCount
                                     });
            }
        }
    }

    function getIndexFromId(bookmarkId)
    {
        for (var x = 0; x < listModel.count; x++)
        {
            var bookmark = listModel.get(x);

            if (bookmark.bookmarkid == bookmarkId)
                return x;
        }

        return -1;
    }

    function getIconURL(bookmark)
    {
        return bookmark.icon;
    }
}
