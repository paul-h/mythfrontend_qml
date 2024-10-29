import QtQuick

import Base 1.0
import Dialogs 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: websiteEdit

    property int bookmarkIndex: -1
    property var bookmarkList: undefined

    Component.onCompleted:
    {
        setHelp("https://mythqml.net/help/settings_bookmark_editor.php#top");
        showTime(true);
        showTicker(false);

        if (bookmarkIndex === -1)
        {
            // we are adding a new bookmark
            showTitle(true, "Add Browser Bookmark");
            websiteEdit.text = "";
            titleEdit.text = "";
            categoryEdit.text = "";
            urlEdit.text = "";
            iconUrlEdit.text = "";
        }
        else
        {
            // we are amending an existing bookmark
            showTitle(true, "Edit Browser Bookmark");
            websiteEdit.text = bookmarkList.model.get(bookmarkIndex).website;
            titleEdit.text = bookmarkList.model.get(bookmarkIndex).title;
            categoryEdit.text = bookmarkList.model.get(bookmarkIndex).category;
            urlEdit.text = bookmarkList.model.get(bookmarkIndex).url;
            iconUrlEdit.text = bookmarkList.model.get(bookmarkIndex).icon;
        }
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            // RED - cancel
            returnSound.play();
            stack.pop();
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN - save
            save();
        }
        else if (event.key === Qt.Key_F3)
        {
            var url = urlEdit.text;
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

            stack.push(mythUtils.findThemeFile("Screens/WebBrowser.qml"), {url: url, fullscreen: fullscreen, zoomFactor: zoom});
        }
        else if (event.key === Qt.Key_F4)
        {
            // BLUE - help
            window.showHelp();
        }
        else
            event.accepted = false;
    }

    LabelText
    {
        x: xscale(30); y: yscale(100)
        text: "Website:"
    }

    BaseEdit
    {
        id: websiteEdit
        x: xscale(300); y: yscale(100)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: ""
        KeyNavigation.up: saveButton
        KeyNavigation.down: titleEdit
        KeyNavigation.right: websiteButton
    }

    BaseButton
    {
        id: websiteButton;
        x: parent.width - xscale(70);
        y: yscale(100);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: saveButton
        KeyNavigation.left: websiteEdit
        KeyNavigation.down: titleEdit
        onClicked:
        {
            searchDialog.model = bookmarkList.websiteList
            searchDialog.searchWebsites = true;
            searchDialog.show();
        }
    }

    LabelText
    {
        x: xscale(30); y: yscale(150)
        text: "Title:"
    }

    BaseEdit
    {
        id: titleEdit
        x: xscale(300); y: yscale(150)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: ""
        KeyNavigation.up: websiteEdit;
        KeyNavigation.down: categoryEdit;
    }

    LabelText
    {
        x: xscale(30); y: yscale(200)
        text: "Category:"
    }

    BaseEdit
    {
        id: categoryEdit
        x: xscale(300); y: yscale(200)
        width: parent.width - x - xscale(80)
        height: yscale(50)
        text: ""
        KeyNavigation.up: titleEdit;
        KeyNavigation.down: urlEdit;
    }

    BaseButton
    {
        id: categoryButton;
        x: parent.width - xscale(70)
        y: yscale(200);
        width: xscale(50); height: yscale(50)
        text: "X";
        KeyNavigation.up: titleEdit
        KeyNavigation.left: categoryEdit
        KeyNavigation.down: urlEdit
        onClicked:
        {
            searchDialog.model = bookmarkList.categoryList
            searchDialog.searchWebsites = false;
            searchDialog.show();
        }
    }

    LabelText
    {
        x: xscale(30); y: yscale(250)
        text: "URL:"
    }

    BaseEdit
    {
        id: urlEdit
        x: xscale(300); y: yscale(250)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: ""
        KeyNavigation.up: categoryEdit;
        KeyNavigation.down: iconUrlEdit;
    }

    LabelText
    {
        x: xscale(30); y: yscale(300)
        text: "Icon URL:"
    }

    BaseEdit
    {
        id: iconUrlEdit
        x: xscale(300); y: yscale(300)
        width: parent.width - x - xscale(20)
        height: yscale(50)
        text: ""
        KeyNavigation.up: urlEdit;
        KeyNavigation.down: saveButton;
    }

    Image
    {
        id: iconImage
        x: xscale(300)
        y: yscale(370)
        width: xscale(100)
        height: yscale(100)
        source: iconUrlEdit.text
        asynchronous: true
    }

    BaseButton
    {
        id: saveButton;
        x: parent.width - width - xscale(50); y: yscale(600);
        text: "Save";
        KeyNavigation.up: iconUrlEdit
        KeyNavigation.down: websiteEdit
        onClicked: save()
    }

    Footer
    {
        id: footer
        redText: "Cancel"
        greenText: "Save"
        yellowText: "Test"
        blueText: "Help"
    }

    SearchListDialog
    {
        id: searchDialog

        property bool searchWebsites: true
        title: "Choose a " + (searchWebsites ? "website" : "category")
        message: ""

        onAccepted:
        {
            if (searchWebsites)
                websiteButton.focus = true;
            else
                categoryButton.focus = true;
        }
        onCancelled:
        {
            if (searchWebsites)
                websiteButton.focus = true;
            else
                categoryButton.focus = true;
        }

        onItemSelected:
        {
            if (searchWebsites)
            {
                websiteEdit.text = itemText;
                websiteButton.focus = true;
            }
            else
            {
                categoryEdit.text = itemText;
                categoryButton.focus = true;
            }
        }
    }

    function save()
    {
        if (bookmarkIndex === -1)
        {
            // we need to add a new bookmark
            var bookmarkid = dbUtils.addBrowserBookmark(websiteEdit.text, titleEdit.text, categoryEdit.text, urlEdit.text, iconUrlEdit.text);
            bookmarkList.loadFromDB();

            //            var now = new Date(Date.now());
            //            bookmarkList.model.append({"bookmarkid": bookmarkid, "website": websiteEdit.text, "title": titleEdit.text, "category": categoryEdit.text, "icon": iconUrlEdit.text, "player": "WebBrowser",
            //                                       "url": urlEdit.text, "date_added": now.toISOString(), "date_modified": now.toISOString(), "date_visited": "", "visited_count": 0 });

        }
        else
        {
            // we need to update a bookmark
            dbUtils.updateBrowserBookmark(bookmarkList.model.get(bookmarkIndex).bookmarkid, websiteEdit.text, titleEdit.text, categoryEdit.text, urlEdit.text, iconUrlEdit.text);
            bookmarkList.loadFromDB();
        }

        returnSound.play();
        stack.pop();
    }
}
