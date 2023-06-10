import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import Base 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: treeView

    Component.onCompleted:
    {
        showTitle(true, "Test Page 2");
        showTime(false);
        showTicker(false);
        muteAudio(true);

        treeView.setFocusedNode("Root ~ BrowserBookmarks ~ AllBookmarks ~ 4");
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            treeView.basePath = "Root ~ Webcams ~ 1 ~ Favorites";
            sourceTree.setRootNode("Root ~ Webcams ~ 1 ~ Favorites");
            treeView.reset();
        }
        else if (event.key === Qt.Key_F2)
        {
            treeView.basePath = "Root ~ BrowserBookmarks ~ AllBookmarks";
            sourceTree.setRootNode("Root ~ BrowserBookmarks ~ AllBookmarks")
            treeView.reset();
        }
        else if (event.key === Qt.Key_F3)
        {
            treeView.basePath = "Root";
            sourceTree.setRootNode("");
            treeView.reset();
        }
        else if (event.key === Qt.Key_F4 || event.key === Qt.Key_A)
        {
            // add new bookmark
            stack.push({item: mythUtils.findThemeFile("Screens/settings/BrowserBookmarkEditor.qml"), properties:{bookmarkIndex: -1, bookmarkList: playerSources.browserBookmarksList}});
        }
        else if (event.key === Qt.Key_F5 || event.key === Qt.Key_E)
        {
            // edit existing bookmark
            var node = treeView.getActiveNode();

            if (node && node.type === SourceTreeModel.NodeType.Browser_Bookmark)
            {
                var bookmarkId = node.bookmarkid;
                var bookmarkIndex = playerSources.browserBookmarksList.getIndexFromId(bookmarkId);
                stack.push({item: mythUtils.findThemeFile("Screens/settings/BrowserBookmarkEditor.qml"), properties:{bookmarkIndex: bookmarkIndex, bookmarkList: playerSources.browserBookmarksList}});
            }
        }
        else if (event.key === Qt.Key_F6 || event.key === Qt.Key_D)
        {
            // delete existing bookmark
            var node = treeView.getActiveNode();

            if (node && node.type === SourceTreeModel.NodeType.Browser_Bookmark)
            {
                var bookmarkId = node.bookmarkid;
                dbUtils.deleteBrowserBookmark(bookmarkId);
            }
        }
        else
            event.accepted = true;
    }

    SourceTreeModel
    {
        id: sourceTree
    }

    BaseBackground
    {
        x: xscale(20)
        y: yscale(100)
        width: parent.width - xscale(40)
        height: yscale(600)
    }

    InfoText
    {
        id: breadCrumb
        x: xscale(30)
        y: yscale(60)
        width: parent.width - xscale(60)
        textFormat: Text.PlainText
    }

    InfoText
    {
        id: posText
        x: parent.width - width - xscale(30)
        y: yscale(60)
        width: xscale(120)
        horizontalAlignment: Text.AlignRight
        text: "xxx of xxx"
    }

    TreeButtonList
    {
        id: treeView
        x: xscale(30)
        y: xscale(120)
        width: parent.width - xscale(60)
        height: yscale(560)
        columns: 4
        spacing: xscale(10)
        sourceTree: sourceTree
        model: sourceTree.model

        onNodeSelected:
        {
            breadCrumb.text = getActiveNodePath();
        }

        onPosChanged:
        {
            posText.text = (index + 1) + " of " + count
        }

        onNodeClicked:
        {
            sourceTree.playFile(currentIndex, node)
        }
    }
}
