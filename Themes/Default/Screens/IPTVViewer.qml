import QtQuick 2.0
import Base 1.0
import Dialogs 1.0
import Models 1.0
import SortFilterProxyModel 0.2
import "../../../Util.js" as Util
import mythqml.net 1.0

BaseScreen
{
    id: root

    defaultFocusItem: iptvGrid

    Component.onCompleted:
    {
        showTime(false);
        showTicker(false);

        while (stack.busy) {};

        showTitle(true, "IPTV Channel Viewer");
        setHelp("https://mythqml.net/help/iptv_channelviewer.php#top");

        feedSource.sort = "Title"

        var filter = feedSource.sort + "," + feedSource.genre + "," + feedSource.country + "," + feedSource.language;
        feedSource.switchToFeed("IPTV", filter, 0);

        feedSource.feedModelLoaded.connect(function() { iptvGrid.currentIndex = 0; });

        iptvGrid.currentIndex = 0;
    }

    FeedSource
    {
        id: feedSource
        objectName: "IPTVViewer"
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_M)
        {
            popupMenu.clearMenuItems();

            popupMenu.addMenuItem("", "Clear Filters");
            popupMenu.addMenuItem("", "Search");
            popupMenu.addMenuItem("", "Help");
            popupMenu.show();
        }
        else if (event.key === Qt.Key_F1)
        {
            var id = iptvGrid.model.get(iptvGrid.currentIndex).id;

            if (feedSource.sort === "Title")
            {
                feedSource.sort = "Genre";
                footer.redText = "Sort (Genre)";
            }
            else if (feedSource.sort === "Genre")
            {
                feedSource.sort = "Country";
                footer.redText = "Sort (Country)";
            }
            else if (feedSource.sort === "Country")
            {
                feedSource.sort = "Language";
                footer.redText = "Sort (Language)";
            }
            else
            {
                feedSource.sort = "Title";
                footer.redText = "Sort (Title)";
            }

            var index = feedSource.findById(id);

            iptvGrid.currentIndex = (index != -1 ? index : 0);
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN
            searchDialog.model = playerSources.iptvList.genreList;
            searchDialog.field = "Genre";
            searchDialog.show();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW
            searchDialog.model = playerSources.iptvList.countryList;
            searchDialog.field = "Country";
            searchDialog.show();
         }
        else if (event.key === Qt.Key_F4)
        {
            //BLUE
            searchDialog.model = playerSources.iptvList.languageList;
            searchDialog.field = "Language";
            searchDialog.show();
        }
        else
            event.accepted = false;
    }

    BaseBackground
    {
        id: listBackground
        x: xscale(10); y: yscale(45); width: parent.width - x - xscale(10); height: yscale(410)
    }

    BaseBackground { x: xscale(10); y: yscale(465); width: parent.width - xscale(20); height: yscale(210) }

    InfoText
    {
        x: parent.width - xscale(210); y: yscale(5); width: xscale(200);
        text: (iptvGrid.currentIndex + 1) + " of " + iptvGrid.model.count;
        horizontalAlignment: Text.AlignRight
    }

    ButtonGrid
    {
        id: iptvGrid
        x: xscale(22)
        y: yscale(55)
        width: parent.width - xscale(44)
        height: yscale(390)
        cellWidth: width / (root.isPanel ? 4 : 5);
        cellHeight: yscale(130)

        Component
        {
            id: iptvDelegate
            Item
            {
                x: 0;
                y: 0;
                width: iptvGrid.cellWidth;
                height: iptvGrid.cellHeight;
                Image
                {
                    opacity: 0.80
                    asynchronous: true
                    anchors.fill: parent
                    anchors.margins: xscale(5)
                    source: getIconURL(icon);
                    onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/no_image.png");
                }
                LabelText
                {
                    x: 5;
                    y: iptvGrid.cellHeight - yscale(40)
                    width: iptvGrid.cellWidth - xscale(10)
                    text: title
                    horizontalAlignment: Text.AlignHCenter;
                    fontPixelSize: xscale(14)
                }
            }
        }

        model: feedSource.feedList
        delegate: iptvDelegate
        focus: true

        Keys.onReturnPressed:
        {
            var filter = feedSource.sort + "," + feedSource.genre + "," + feedSource.country + "," + feedSource.language

            returnSound.play();

            if (!root.isPanel)
            {
                var item = stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{defaultFeedSource:  "IPTV", defaultFilter:  filter, defaultCurrentFeed: iptvGrid.currentIndex}});
                item.feedChanged.connect(feedChanged);
            }
            else
            {
                internalPlayer.previousFocusItem = iptvGrid;
                feedSelected("IPTV", filter, iptvGrid.currentIndex);
            }

            event.accepted = true;
        }

        Keys.onPressed:
        {
            if (event.key === Qt.Key_Left && ((currentIndex % 4) === 0 && previousFocusItem))
            {
                event.accepted = true;
                escapeSound.play();
                previousFocusItem.focus = true;
            }
            else
                event.accepted = false;
        }

        onCurrentIndexChanged: updateChannelDetails();
    }

    TitleText
    {
        id: title
        x: xscale(30); y: yscale(470)
        width: parent.width - _xscale(1280 - 900); height: yscale(75)
        verticalAlignment: Text.AlignTop
        multiline: true
    }

    Image
    {
        id: channelIcon
        x: parent.width - _xscale(1280 - 950); y: yscale(480); width: _xscale(300); height: _yscale(178)
        asynchronous: true
        onStatusChanged: if (status == Image.Error) source = mythUtils.findThemeFile("images/no_image.png")
    }

    InfoText
    {
        id: description
        x: xscale(30); y: yscale(540)
        width: parent.width - _xscale(1280 - 900); height: yscale(100)
        verticalAlignment: Text.AlignTop
        multiline: true
    }

    InfoText
    {
        id: category
        x: xscale(30); y: yscale(630); width: _xscale(900)
        fontColor: "grey"
    }

    InfoText
    {
        id: country
        x: channelIcon.x - xscale(20) - width; y: yscale(630); width: _xscale(500); height: yscale(30)
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignBottom
        fontColor: "grey"
    }

    Footer
    {
        id: footer
        redText: "Sort (Name)"
        greenText: "Genre (All Genres)"
        yellowText: "Country (All Countries)"
        blueText: "Language (All Languages)"
    }

    SearchListDialog
    {
        id: searchDialog

        property string field: "Genre"

        title: "Choose a Genre"
        message: ""

        onFieldChanged: { searchDialog.title = "Choose a " + field; reset(); }

        onAccepted:
        {
            iptvGrid.focus = true;

        }
        onCancelled:
        {
            iptvGrid.focus = true;
        }

        onItemSelected:
        {
            if (field === "Genre")
            {
                if (itemText != "<All Genres>")
                {
                    feedSource.genre = ""; // this is needed to get the ExpressionFilter to re-evaluate
                    feedSource.genre = itemText;
                    footer.greenText = "Genre (" + itemText + ")"
                }
                else
                {
                    feedSource.genre = "";
                    footer.greenText = "Genre (All Genres)"
                }
            }
            else if (field === "Country")
            {
                if (itemText != "<All Countries>")
                {
                    feedSource.country = ""; // this is needed to get the ExpressionFilter to re-evaluate
                    feedSource.country = itemText;
                    footer.yellowText = "Country (" + itemText + ")"
                }
                else
                {
                    feedSource.country = "";
                    footer.yellowText = "Country (All Countries)"
                }
            }
            else if (field === "Language")
            {
                if (itemText != "<All Languages>")
                {
                    feedSource.language = ""; // this is needed to get the ExpressionFilter to re-evaluate
                    feedSource.language = itemText;
                    footer.blueText = "Language (" + itemText + ")"
                }
                else
                {
                    feedSource.language = "";
                    footer.blueText = "Language (All Languages)"
                }
            }

            iptvGrid.focus = true;

            updateChannelDetails();
        }
    }

    PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "IPTV Channel Viewer Options"

        onItemSelected:
        {
            iptvGrid.focus = true;

            if (itemText == "Clear Filters")
            {
                feedSource.genre = "";
                footer.greenText = "Genre (All Genres)"

                feedSource.country = "";
                footer.yellowText = "Country (All Countries)"

                feedSource.language = "";
                footer.blueText = "Language (All Languages)"

                updateChannelDetails();
            }
            else if (itemText == "Search")
            {
                editDialog.show();
            }
            else if (itemText == "Help")
            {
                window.showHelp();
            }
        }

        onCancelled:
        {
            iptvGrid.focus = true;
        }
    }

    TextEditDialog
    {
        id: editDialog
        title: "Search"
        message: "Search for IPTV Channel"

        width: xscale(600); height: yscale(350)

        onResultText:
        {
            for (var x = iptvGrid.currentIndex + 1; x < iptvGrid.model.count; x++)
            {
                if (iptvGrid.model.get(x).title.includes(text))
                {
                    iptvGrid.currentIndex = x;
                    break;
                }
            }
        }
    }

    function createMenu(menu)
    {
       menu.clear();

       menu.append({"menutext": "All", "loaderSource": "IPTVViewer.qml", "menuSource": ""});
       menu.append({"menutext": "---", "loaderSource": "IPTVViewer.qml", "loaderSource": "", "menuSource": ""});

       for (var x = 1; x < playerSources.iptvList.genreList.count; x++)
       {
           menu.append({"menutext": playerSources.iptvList.genreList.get(x).item, "loaderSource": "IPTVViewer.qml", "menuSource": ""});
       }
    }

    function setFilter(filter)
    {
       var filterList;
       if (filter === "All" || filter === "<All Web Videos>")
       {
           filterList = feedSource.sort + "," + feedSource.genre + "," + feedSource.country + "," + feedSource.language;
           feedChanged("IPTV", filterList, 0);
       }
       else if (filter === "Favourite")
       {
           filterList = feedSource.sort + "," + feedSource.genre + "," + feedSource.country + "," + feedSource.language;
           feedChanged("IPTV", filterList, 0);
       }
       else if (filter === "New")
       {
           filterList = feedSource.sort + "," + feedSource.genre + "," + feedSource.country + "," + feedSource.language;
           feedChanged("IPTV", filterList, 0)
       }
       else if (filter != "---" )
       {
           filterList = feedSource.sort + "," + filter + ",,";
           feedChanged("IPTV", filterList, 0);
       }
    }

   function feedChanged(feed, filterList, currentIndex)
   {
       if (feed !== "IPTV")
           return;

       var list = filterList.split(",");
       var sort = ""
       var genre = "";
       var country = "";
       var language = "";

       if (list.length === 4)
       {
           sort = list[0]
           genre = list[1];
           country = list[2];
           language = list[3];
       }

       if (sort !== feedSource.sort)
       {
           feedSource.sort = sort;
           footer.redText = "Sort (" + sort + ")";
       }

       if (genre !== feedSource.genre)
       {
           if (genre === "")
           {
               feedSource.genre = genre;
               footer.greenText = "Genre (All Genres)"
           }
           else
           {
               feedSource.genre = genre;
               footer.greenText = "Genre (" + genre + ")"
           }
       }

       if (country !== feedSource.country)
       {
           if (country === "")
           {
               feedSource.country = country;
               footer.yellowText = "Country (All Countries)"
           }
           else
           {
               feedSource.country = country;
               footer.yellowText = "Country (" + country + ")"
           }
       }

       if (language !== feedSource.language)
       {
           if (language === "")
           {
               feedSource.language = language;
               footer.blueText = "Language (All Languages)"
           }
           else
           {
               feedSource.language = language;
               footer.blueText = "Language (" + language + ")"
           }
       }

        iptvGrid.currentIndex = currentIndex;
    }

    function getIconURL(iconURL)
    {
        if (iconURL && iconURL != "")
            return iconURL;

        return "https://archive.org/download/icon-default/icon-default.png";
    }

    function updateChannelDetails()
    {
        if (iptvGrid.currentIndex === -1)
            return;

        title.text = iptvGrid.model.get(iptvGrid.currentIndex).title;

        // description
        var desc = iptvGrid.model.get(iptvGrid.currentIndex).languages + "<br>";
        desc +="Icon: " + (iptvGrid.model.get(iptvGrid.currentIndex).icon ? iptvGrid.model.get(iptvGrid.currentIndex).icon : "N/A") + "<br>";
        desc += "URL: " + (iptvGrid.model.get(iptvGrid.currentIndex).url ? iptvGrid.model.get(iptvGrid.currentIndex).url : "N/A") + "<br>";
        description.text = desc;

        // category
        category.text = iptvGrid.model.get(iptvGrid.currentIndex).genre !== undefined ? iptvGrid.model.get(iptvGrid.currentIndex).genre : "Unknown";

        // countries
        country.text = iptvGrid.model.get(iptvGrid.currentIndex).countries; //iptvGrid.model.get(iptvGrid.currentIndex).countries.get(0) ? iptvGrid.model.get(iptvGrid.currentIndex).countries.get(0).name : "Unknown";

        // icon
        channelIcon.source = getIconURL(iptvGrid.model.get(iptvGrid.currentIndex).icon);
    }
}
