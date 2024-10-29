import QtQuick
import Base 1.0
import Dialogs 1.0
import Models 1.0

Item
{
    property alias listView: listView
    property alias model: listView.model
    property alias showWatermark: watermark.visible

    anchors.fill: parent

    Loader
    {
        id: menuLoader
    }

    MenuItemModel
    {
        id: menuItemModel
    }

    Image
    {
        id: title
        x: xscale(24); y: yscale(28)
        width: xscale(sourceSize.width)
        height: yscale(sourceSize.height)
        source: mythUtils.findThemeFile(model.logo)
    }

    Image
    {
        id: logo
        x: xscale(30); y: yscale(574)
        width: xscale(sourceSize.width)
        height: yscale(sourceSize.height)
        source: mythUtils.findThemeFile("ui/mythtv_logo.png")
    }

    Image
    {
        id: horizon
        x: xscale(550); y: yscale(500)
        width: xscale(sourceSize.width)
        height: yscale(sourceSize.height)
        visible: watermark.visible
        source: if (visible) mythUtils.findThemeFile("ui/horizon.png"); else "";
    }

    Rectangle
    {

        x: xscale(200); y: yscale(150)
        width: xscale(500); height: yscale(360)
        color: "#00000000"
        Component
        {
            id: menuDelegate

            Item
            {
                property bool selected: ListView.isCurrentItem

                width: parent ? parent.width : 0;
                height: yscale(60)
                TitleText
                {
                    text: menutext
                    fontFamily: theme.menuFontFamily
                    fontPixelSize: selected ? xscale(theme.menuFontPixelSize) * 1.25 : xscale(theme.menuFontPixelSize)
                    fontBold: theme.menuFontBold
                    fontColor: theme.menuFontColor
                    shadowAlpha: theme.menuShadowAlpha
                    shadowColor: theme.menuShadowColor
                    shadowXOffset: theme.menuShadowXOffset
                    shadowYOffset: theme.menuShadowYOffset
                    x: xscale(10); width: parent.width - xscale(20);
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on fontPixelSize { NumberAnimation { duration: 250 } }
                }
            }
        }

        ListView
        {
            id: listView
            width: parent.width; height: parent.height
            delegate: menuDelegate
            highlight: Image {cache: false; source: mythUtils.findThemeFile("ui/button_on.png")}
            highlightMoveDuration: 1500
            highlightResizeDuration: 0
            snapMode: ListView.SnapToItem
            focus: true
            clip: true
            keyNavigationWraps: true

            Keys.onPressed: event =>
            {
                if (event.key === Qt.Key_PageDown)
                {
                    currentIndex = currentIndex + 6 >= model.count ? model.count - 1 : currentIndex + 6;
                    event.accepted = true;
                    downSound.play();
                }
                else if (event.key === Qt.Key_PageUp)
                {
                    currentIndex = currentIndex - 6 < 0 ? 0 : currentIndex - 6;
                    event.accepted = true;
                    upSound.play()
                }
                else if (event.key === Qt.Key_Up)
                {
                    event.accepted = false;
                    upSound.play()
                }
                else if (event.key === Qt.Key_Down)
                {
                    event.accepted = false;
                    downSound.play()
                }
                else if (event.key === Qt.Key_M)
                {
                    event.accepted = true;
                    downSound.play();

                    popupMenu.title = "Menu"
                    popupMenu.message = "Main Menu Options"
                    popupMenu.clearMenuItems();

                    popupMenu.addMenuItem("", "Radio...", "radioplayer");
                    popupMenu.addMenuItem("", "ZoneMinder...", "zoneminder");
                    popupMenu.addMenuItem("", "Volume...", "volume");
                    popupMenu.addMenuItem("", "Show Version...", "version");
                    popupMenu.addMenuItem("", "Exit", "exit");

                    if (settings.rebootCommand !== "")
                        popupMenu.addMenuItem("", "Reboot", "reboot");

                    if (settings.shutdownCommand !== "")
                        popupMenu.addMenuItem("", "Shutdown", "shutdown");

                    if (settings.suspendCommand !== "")
                        popupMenu.addMenuItem("", "Suspend", "suspend");

                    popupMenu.addMenuItem("", "Help...", "showhelp");

                    popupMenu.show(listView);
                }
                else if (event.key === Qt.Key_BracketLeft || event.key === Qt.Key_BraceLeft)
                {
                    if (radioPlayerDialog.isPlaying())
                    {
                        // radio player volume down
                        if (window.radioPlayerVolume >= 1)
                            window.radioPlayerVolume -= 1;

                        dbUtils.setSetting("RadioPlayerVolume", settings.hostName, window.radioPlayerVolume);
                        radioPlayerDialog.volume = window.radioPlayerVolume;

                        showNotification("Radio Player Volume: " + radioPlayerDialog.volume + "%");
                    }
                    else
                    {
                        // background video volume down
                        if (window.backgroundVideoVolume > 0)
                            window.backgroundVideoVolume -= 1;

                        dbUtils.setSetting("BackgroundVideoVolume", settings.hostName, window.backgroundVideoVolume);

                        showNotification("Background Volume: " + window.backgroundVideoVolume + "%");
                    }
                }
                else if (event.key === Qt.Key_BracketRight || event.key === Qt.Key_BraceRight)
                {
                    if (radioPlayerDialog.isPlaying())
                    {
                        // radio player volume up
                        if (window.radioPlayerVolume < 100)
                            window.radioPlayerVolume += 1;

                        dbUtils.setSetting("RadioPlayerVolume", settings.hostName, window.radioPlayerVolume);
                        radioPlayerDialog.volume = window.radioPlayerVolume;

                        showNotification("Radio Player Volume: " + radioPlayerDialog.volume + "%");
                    }
                    else
                    {
                        // background video volume up
                        if (window.backgroundVideoVolume < 100)
                            window.backgroundVideoVolume += 1;

                        dbUtils.setSetting("BackgroundVideoVolume", settings.hostName, window.backgroundVideoVolume);

                        showNotification("Background Volume: " + window.backgroundVideoVolume + "%");
                    }
                }
            }

            Keys.onReturnPressed: event =>
            {
                event.accepted = true;
                returnSound.play();

                if (model.get(currentIndex).loaderSource === "ThemedMenu.qml")
                {
                    // load menu items from the database
                    if (model.get(currentIndex).menuSource.startsWith("database://"))
                    {
                        var menuSource = model.get(currentIndex).menuSource
                        var paramstr = menuSource.replace("database://", "");
                        var params = paramstr.split("|");
                        if (params.length === 3)
                        {
                            var key = params[0];
                            var title = params[1];
                            var logo = params[2];
                            loadFromDB(key, title, logo);
                            stack.push(mythUtils.findThemeFile("Screens/ThemedMenu.qml"), {model: menuItemModel.model});
                        }
                    }
                    // load menu items from the specified local file
                    else if (model.get(currentIndex).menuSource.startsWith("file://"))
                    {
                        menuLoader.source = model.get(currentIndex).menuSource;
                        stack.push(mythUtils.findThemeFile("Screens/ThemedMenu.qml"), {model: menuLoader.item});
                    }
                    // load the menu items from the local file specified by the setting
                    else if (model.get(currentIndex).menuSource.startsWith("setting://"))
                    {
                        var setting = model.get(currentIndex).menuSource.replace("setting://", "");
                        menuLoader.source = dbUtils.getSetting(setting, settings.hostName, "");
                        stack.push(mythUtils.findThemeFile("Screens/ThemedMenu.qml"), {model: menuLoader.item});
                    }
                    else
                    {
                        menuLoader.source = settings.menuPath + model.get(currentIndex).menuSource;
                        stack.push(mythUtils.findThemeFile("Screens/ThemedMenu.qml"), {model: menuLoader.item});
                    }
                }
                else if (model.get(currentIndex).loaderSource === "WebBrowser.qml")
                {
                    var url = model.get(currentIndex).url
                    var zoom = xscale(model.get(currentIndex).zoom)
                    var fullscreen = model.get(currentIndex).fullscreen === "true" ? true : false
                    if (url.startsWith("setting://"))
                    {
                        var setting = url.replace("setting://", "");
                        url = dbUtils.getSetting(setting, settings.hostName, "");
                    }

                    stack.push(mythUtils.findThemeFile("Screens/WebBrowser.qml"), {url: url, fullscreen: fullscreen, zoomFactor: zoom});
                }
                else if (model.get(currentIndex).loaderSource === "InternalPlayer.qml")
                {
                    var layout = model.get(currentIndex).layout
                    var feedSource = model.get(currentIndex).feedSource
                    stack.push(mythUtils.findThemeFile("Screens/InternalPlayer.qml"), {layout: layout, defaultFeedSource: feedSource, defaultCurrentFeed: 0});
                }
                else if (model.get(currentIndex).loaderSource === "External Program")
                {
                    if (model.get(currentIndex).exec === undefined)
                        return;

                    var command = model.get(currentIndex).exec;
                    if (command.startsWith("setting://"))
                    {
                        var setting = command.replace("setting://", "");
                        command = dbUtils.getSetting(setting, settings.hostName, "");
                    }

                    var parameters;
                    if (model.get(currentIndex).parameters !== undefined)
                    {
                        parameters = model.get(currentIndex).parameters;
                        if (parameters.startsWith("setting://"))
                        {
                            var setting = parameters.replace("setting://", "");
                            parameters = dbUtils.getSetting(setting, settings.hostName, "");
                        }
                        parameters = parameters.split("|");
                    }
                    else
                        parameters = [];

                    var message = model.get(currentIndex).menutext + " will start shortly.\nPlease Wait.....";
                    var timeOut = 10000;
                    showBusyDialog(message, timeOut);

                    externalProcess.start(command, parameters);
                }
                else if (model.get(currentIndex).loaderSource === "reboot")
                {
                    reboot();
                }
                else if (model.get(currentIndex).loaderSource === "shutdown")
                {
                    shutdown();
                }
                else if (model.get(currentIndex).loaderSource === "suspend")
                {
                    suspend();
                }
                else if (model.get(currentIndex).loaderSource === "quit")
                {
                    quit();
                }
                else
                {
                    stack.push(mythUtils.findThemeFile("Screens/" + model.get(currentIndex).loaderSource))
                }

                event.accepted = true;
            }

            onCurrentItemChanged: if (showWatermark) watermark.swapImage(mythUtils.findThemeFile(model.get(currentIndex).waterMark))
        }
    }

    FadeImage
    {
        id: watermark
        x: xscale(832); y: yscale(196); width: xscale(300); height: yscale(300)
        source: mythUtils.findThemeFile("watermark/tv.png")
    }

    function loadFromDB(key, title, logo)
    {
        // load menu items from database
        menuItemModel.menu = key;
        menuItemModel.title = title;
        menuItemModel.logo = logo;
        menuItemModel.loadFromDB();
    }
}

