import QtQuick 2.0
import QtQuick.Controls 1.4
import Base 1.0
import Screens 1.0
import Dialogs 1.0
import Models 1.0
import mythqml.net 1.0

BaseScreen
{
    id: root
    objectName: "themedpanel"

    defaultFocusItem: buttonList

    property bool videoPlayerFullscreen: false
    property string feedSource: ""
    property string feedFilter: ""
    property int feedIndex: -1

    Component.onCompleted:
    {
        showTitle(false, "");
        showTime(false);
        showTicker(false);
        muteAudio(true);

        // FIXME: should load the last shown feed here
        mediaModel.get(0).title = "Film4";
        mediaModel.get(0).url = "http://192.168.1.110:55555/Film4";

        playerSources.adhocList = mediaModel;
        internalPlayer.mediaPlayer1.feed.switchToFeed("Adhoc" , "", 0);
        internalPlayer.mediaPlayer1.startPlayback();

        internalPlayer.previousFocusItem = buttonList

        videoTitle.text = mediaModel.get(0).title;

        focus = true;
    }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_M)
        {
            //TODO add menu
        }
        else if (event.key === Qt.Key_F)
        {
            toggleFullscreenPlayer();

            event.accepted = true;
        }
    }

    ListModel
    {
        id: mediaModel
        ListElement
        {
            no: "1"
            title: ""
            icon: ""
            url: ""
            player: "Internal"
            duration: ""
        }
    }

    InternalPlayer
    {
        id: internalPlayer
        x: 0
        y: yscale(300)
        z: 100
        width: panel1.width - xscale(3)
        height: width / 1.77777777

        previousFocusItem: buttonList

        Behavior on x { NumberAnimation { easing.type: Easing.InOutQuad; duration: 1000 }}
        Behavior on y { NumberAnimation { easing.type: Easing.InOutQuad; duration: 1000 }}
        Behavior on width { NumberAnimation { easing.type: Easing.InOutQuad; duration: 1000 }}
        Behavior on height { NumberAnimation { easing.type: Easing.InOutQuad; duration: 1000 }}
    }

    Rectangle
    {
        id: playerBorder
        x: internalPlayer.x
        y: internalPlayer.y
        width: internalPlayer.width
        height: internalPlayer.height
        z: 101
        visible: internalPlayer.mediaPlayer1.focus && !internalPlayer.isFullScreen

        color: "#00000000"
        border.color: theme.lvBackgroundBorderColor
        border.width: xscale(theme.lvBackgroundBorderWidth)
        radius: xscale(theme.lvBackgroundBorderRadius)
    }

    Item
    {
        id: panel1

        x: 0
        y: 0
        width: xscale(300)
        height: parent.height

        Rectangle
        {
            x: parent.width - xscale(3)
            y: 0
            height: parent.height
            width: xscale(3)
            gradient: Gradient
            {
                GradientStop { position: 0.0; color: "lightsteelblue" }
                GradientStop { position: 1.0; color: "blue" }
            }
        }

        TitleText
        {
            id: panelTitle
            x: xscale(5)
            y: yscale(20)
            width: parent.width - xscale(10)
            height: yscale(50)
            text: "MythQML"
        }

        InfoText
        {
            id: videoTitle
            x: xscale(5)
            y: internalPlayer.y - yscale(75)
            width: parent.width - xscale(10)
            height: yscale(70)
            verticalAlignment: Text.AlignBottom
            multiline: true
            text: "Video Title"
        }

        Image
        {
            id: logo
            source: "https://www.mythtv.org/w/images/b/bc/MythTV_logo_square.png"
            x: (parent.width - width) / 2
            y: yscale(500)
            width: xscale(150)
            height: width
        }

        DigitalClock
        {
            x: 5
            y: parent.height - yscale(60)
            width: parent.width - xscale(10)
            horizontalAlignment: Text.AlignHCenter
            format: "dddd dd, hh:mm"
        }
    }

    Component
    {
        id: menuDelegate
        ListItem
        {
            ListText
            {
                x: xscale(5); y: 0
                text: menutext
            }
        }
    }

    Item
    {
        id: panel2

        x: panel1.width
        y: 0
        width: xscale(300)
        height: parent.height

        Behavior on width { NumberAnimation { easing.type: Easing.InOutQuad; duration: 1000 }}

        Rectangle
        {
            x: parent.width - xscale(3)
            y: 0
            height: parent.height
            width: xscale(3)
            gradient: Gradient
            {
                GradientStop { position: 0.0; color: "lightsteelblue" }
                GradientStop { position: 1.0; color: "blue" }
            }
        }

        TitleText
        {
            id: panel2Title
            x: xscale(5)
            y: yscale(20)
            width: parent.width - xscale(10)
            height: yscale(50)
            elide: Text.ElideNone
            text: "Home"
        }

        Loader
        {
            id: panel2Loader
            source: settings.sharePath + "qml/MenuThemes/panel/MainMenu.qml";
        }

        ButtonList
        {
            id: buttonList
            objectName: "buttonlist"

            x: xscale(5)
            y: yscale(70)
            width: parent.width - xscale(10)
            height: parent.height - yscale(80)

            focus: true
            onFocusChanged:
            {
                panel3Title.text = model.get(currentIndex).menutext;
                panel2.width = (focus ? xscale(300) : 0);
            }

            model: panel2Loader.item
            delegate: menuDelegate
            preferredHighlightBegin: 150
            preferredHighlightEnd: 200
            highlightRangeMode: ListView.StrictlyEnforceRange

            Keys.onEscapePressed:
            {
                // TODO add exit code here??

                if (focus && exitOnEscape)
                {
                    escapeSound.play();
                    showVideo(false);
                    panelStack.pop(null);
                    //stack.pop();
                    quit();
                }
                else
                    errorSound.play();
            }

            Keys.onReturnPressed: handleFocusNext()
            Keys.onLeftPressed: { internalPlayer.previousFocusItem = buttonList; internalPlayer.mediaPlayer1.focus = true; }
            Keys.onRightPressed: handleFocusNext()

            onItemSelected:
            {
                if (!focus)
                    return;

                handleSelected(buttonList, panel3Loader);
            }

            function handleFocusNext()
            {
                if (buttonList3.model && buttonList3.model.count > 0)
                    buttonList3.focus = true;
                else
                {
                    panelStack.focus = true;
                    panelStack.currentItem.defaultFocusItem.focus = true;
                    panelStack.currentItem.previousFocusItem = buttonList
                }
            }
        }
    }

    Item
    {
        id: panel3

        x: panel1.width + panel2.width
        y: 0
        width: 0
        height: parent.height

        Behavior on width { NumberAnimation { easing.type: Easing.InOutQuad; duration: 1000 }}

        Rectangle
        {
            x: parent.width - xscale(3)
            y: 0
            height: parent.height
            width: xscale(3)
            gradient: Gradient
            {
                GradientStop { position: 0.0; color: "lightsteelblue" }
                GradientStop { position: 1.0; color: "blue" }
            }
        }

        TitleText
        {
            id: panel3Title
            x: xscale(5)
            y: yscale(20)
            width: parent.width - xscale(10)
            height: yscale(50)
            text: ""
            elide: Text.ElideNone
        }

        Loader
        {
            id: panel3Loader
        }

        ButtonList
        {
            id: buttonList3
            objectName: "buttonlist3"

            x: xscale(5)
            y: yscale(70)
            width: parent.width - xscale(10)
            height: parent.height - yscale(80)

            focus: false
            onFocusChanged: panel3.width = (focus ? xscale(300): 0)

            model: panel3Loader.item
            delegate: menuDelegate
            preferredHighlightBegin: 150
            preferredHighlightEnd: 200
            highlightRangeMode: ListView.StrictlyEnforceRange
            KeyNavigation.left: buttonList

            Keys.onEscapePressed: buttonList.focus = true

            Keys.onRightPressed:
            {
                panelStack.focus = true;
                panelStack.currentItem.defaultFocusItem.focus = true;
                panelStack.currentItem.previousFocusItem = buttonList3
            }

            Keys.onReturnPressed:
            {
                panelStack.focus = true;
                panelStack.currentItem.defaultFocusItem.focus = true;
                panelStack.currentItem.previousFocusItem = buttonList3
            }

            onItemSelected:
            {
                if (!focus)
                    return;

                if (typeof panelStack.currentItem.setFilter === "function")
                    panelStack.currentItem.setFilter(model.get(currentIndex).menutext);
                else
                {
                    var themeFile = mythUtils.findThemeFile("Screens/" + buttonList3.model.get(buttonList3.currentIndex).loaderSource);

                    if (themeFile !== "")
                    {
                        panelStack.pop();
                        var item = panelStack.push({item: themeFile});
                        item.feedSelected.connect(feedSelected);
                    }

                    if (typeof panelStack.currentItem.setFilter === "function")
                        panelStack.currentItem.setFilter(model.get(currentIndex).menutext);
                }
            }
        }
    }

    Item
    {
        id: detailsPanel

        x: panel1.width + panel2.width + panel3.width
        y: 0
        width: parent.width - x
        height: parent.height

        StackView
        {
            id: panelStack
            objectName: "panelstack"

            width: parent.width; height: parent.height
            clip: true
            initialItem: Home {}
            focus: true

            onCurrentItemChanged:
            {
                if (currentItem)
                {
                    currentItem.defaultFocusItem.focus = true;
                }
            }

            Keys.onEscapePressed:
            {
                if (videoPlayerFullscreen)
                {
                    videoPlayerFullscreen = false;
                    internalPlayer.x = 0;
                    internalPlayer.y = yscale(300)
                    internalPlayer.width = panel1.width - xscale(3)
                    internalPlayer.height = (panel1.width - xscale(3)) / 1.77777777
                }
                else
                {
                    buttonList3.focus = true;
                }
            }
        }
    }

    function play(feedSource, filter, index)
    {
        feedSelected(feedSource, filter, index);
    }

    function feedSelected(feedSource, filter, index)
    {
        if (videoPlayerFullscreen)
            return;

        if (root.feedSource == feedSource && root.feedFilter == filter && root.feedIndex == index)
        {
            toggleFullscreenPlayer();
            return;
        }

        root.feedSource = feedSource;
        root.feedFilter = filter;
        root.feedIndex = index;

        internalPlayer.mediaPlayer1.feed.switchToFeed(feedSource , filter, index);
        internalPlayer.mediaPlayer1.startPlayback();

        videoTitle.text = internalPlayer.mediaPlayer1.feed.feedList.get(internalPlayer.mediaPlayer1.feed.currentFeed).title;
    }

    function getIconURL(iconURL)
    {
        if (iconURL)
        {
            if (iconURL.startsWith("file://") || iconURL.startsWith("http://") || iconURL.startsWith("https://"))
                return iconURL;
            else
            {
                // try to get the icon from the same URL the webcam list was loaded from
                var url = playerSources.webcamList.webcamList.get(playerSources.webcamList.webcamListIndex).url
                var r = /[^\/]*$/;
                url = url.replace(r, '');
                return url + iconURL;
            }
        }

        return ""
    }

    function handleEscape()
    {
        if (videoPlayerFullscreen)
            toggleFullscreenPlayer();
        else
            buttonList.focus = true;
    }

    function handleShowMenu(buttonList, loader)
    {
        if (buttonList.model.get(buttonList.currentIndex).loaderSource === "ThemedMenu.qml")
        {
            loader.source = settings.sharePath + "qml/MenuThemes/panel/" + buttonList.model.get(buttonList.currentIndex).menuSource;
        }
        else if (buttonList.model.get(buttonList.currentIndex).loaderSource === "WebBrowser.qml")
        {
            var url = buttonList.model.get(currentIndex).url
            var zoom = xscale(buttonList.model.get(currentIndex).zoom)
            var fullscreen = buttonList.model.get(currentIndex).fullscreen
            panelStack.push({item: mythUtils.findThemeFile("Panels/WebBrowser.qml"), properties:{url: url, fullscreen: fullscreen, zoomFactor: zoom}});
        }
        else if (buttonList.model.get(currentIndex).loaderSource === "InternalPlayer.qml")
        {
            var layout = buttonList.model.get(currentIndex).layout
            var feedSource = buttonList.model.get(currentIndex).feedSource
            stack.push({item: mythUtils.findThemeFile("Panels/InternalPlayer.qml"), properties:{layout: layout, defaultFeedSource: feedSource, defaultCurrentFeed: 0}});
        }
        else if (buttonList.model.get(currentIndex).loaderSource === "External Program")
        {
            var message = buttonList.model.get(currentIndex).menutext + " will start shortly.\nPlease Wait.....";
            var timeOut = 10000;
            showBusyDialog(message, timeOut);
            var command = buttonList.model.get(currentIndex).exec
            externalProcess.start(command, []);
        }
        else if (buttonList.model.get(currentIndex).loaderSource === "reboot")
        {
            reboot();
        }
        else if (buttonList.model.get(currentIndex).loaderSource === "shutdown")
        {
            shutdown();
        }
        else if (buttonList.model.get(currentIndex).loaderSource === "quit")
        {
            quit();
        }
        else
        {
            if (mythUtils.findThemeFile("Panels/" + buttonList.model.get(currentIndex).loaderSource) !== "")
                stack.push({item: mythUtils.findThemeFile("Panels/" + buttonList.model.get(currentIndex).loaderSource)});
            else
                stack.push({item: mythUtils.findThemeFile("Screens/" + buttonList.model.get(currentIndex).loaderSource)});
        }
    }

    ListModel
    {
        id: emptyList
    }

    function handleSelected(button_list, loader)
    {
        // add any menu items from the menuLoader if specified
        if (button_list.model.get(button_list.currentIndex).menuSource !== undefined)
            loader.source = settings.sharePath + "qml/MenuThemes/panel/" + button_list.model.get(button_list.currentIndex).menuSource;
        else
            loader.source = settings.sharePath + "qml/MenuThemes/panel/EmptyMenu.qml";

        while (loader.status == Loader.Loading) {}

        if (button_list.model.get(button_list.currentIndex).loaderSource === "WebBrowser.qml")
        {
            var url = button_list.model.get(button_list.currentIndex).url
            var zoom = xscale(button_list.model.get(button_list.currentIndex).zoom)
            var fullscreen = button_list.model.get(button_list.currentIndex).fullscreen
            panelStack.push({item: mythUtils.findThemeFile("Screens/WebBrowser.qml"), properties:{url: url, fullscreen: fullscreen, zoomFactor: zoom}});
        }
        else if (button_list.model.get(button_list.currentIndex).loaderSource === "InternalPlayer.qml")
        {
            var layout = button_list.model.get(button_list.currentIndex).layout
            var feedSource = button_list.model.get(button_list.currentIndex).feedSource
            panelStack.push({item: mythUtils.findThemeFile("Screens/InternalPlayer.qml"), properties:{layout: layout, defaultFeedSource: feedSource, defaultCurrentFeed: 0}});
        }
        else if (button_list.model.get(button_list.currentIndex).loaderSource === "External Program")
        {
            var message = button_list.model.get(button_list.currentIndex).menutext + " will start shortly.\nPlease Wait.....";
            var timeOut = 10000;
            showBusyDialog(message, timeOut);
            var command = button_list.model.get(button_list.currentIndex).exec
            externalProcess.start(command, []);
        }
        else if (button_list.model.get(button_list.currentIndex).loaderSource === "reboot")
        {
            reboot();
        }
        else if (button_list.model.get(button_list.currentIndex).loaderSource === "shutdown")
        {
            shutdown();
        }
        else if (button_list.model.get(button_list.currentIndex).loaderSource === "quit")
        {
            quit();
        }
        else
        {
            var themeFile = mythUtils.findThemeFile("Screens/" + button_list.model.get(button_list.currentIndex).loaderSource);

            if (themeFile !== "")
            {
                panelStack.pop();
                var item = panelStack.push({item: themeFile});

                if (item)
                {
                    if (item.feedSelected)
                        item.feedSelected.connect(feedSelected);

                    // FIXME need to update the correct buttonlist
                    if (item.createMenu)
                        item.createMenu(loader.item);
                }
            }
        }
    }

    function toggleFullscreenPlayer()
    {
        videoPlayerFullscreen = !videoPlayerFullscreen;

        panel1.visible = !videoPlayerFullscreen;
        panel2.visible = !videoPlayerFullscreen;
        panel3.visible = !videoPlayerFullscreen;
        detailsPanel.visible = !videoPlayerFullscreen;

        if (videoPlayerFullscreen)
        {
            internalPlayer.x = 0;
            internalPlayer.y = 0;
            internalPlayer.width = window.width;
            internalPlayer.height = window.height;
            internalPlayer.mediaPlayer1.focus = true;
        }
        else
        {
            internalPlayer.x = 0;
            internalPlayer.y = yscale(300);
            internalPlayer.width = panel1.width - xscale(3);
            internalPlayer.height = (panel1.width - xscale(3)) / 1.77777777;
            panelStack.focus = true; //FIXME should we focus the last focus item here?
        }
    }
}
