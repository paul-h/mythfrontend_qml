import QtQuick 2.0
import Base 1.0
import Dialogs 1.0

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

    Image
    {
        id: title
        x: xscale(24); y: yscale(28)
        width: xscale(sourceSize.width)
        height: yscale(sourceSize.height)
        source: mythUtils.findThemeFile("title/title_tv.png")
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

            Keys.onPressed:
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

                    popupMenu.clearMenuItems();

                    popupMenu.addMenuItem("", "Radio...", "radioplayer");
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
                        radioPlayerDialog.volume = window.radioPlayerVolume * 100;

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

            Keys.onReturnPressed:
            {
                event.accepted = true;
                returnSound.play();

                if (model.get(currentIndex).loaderSource === "ThemedMenu.qml")
                {
                    menuLoader.source = settings.menuPath + model.get(currentIndex).menuSource;
                    stack.push({item: mythUtils.findThemeFile("Screens/ThemedMenu.qml"), properties:{model: menuLoader.item}});
                }
                else if (model.get(currentIndex).loaderSource === "WebBrowser.qml")
                {
                    var url = model.get(currentIndex).url
                    var zoom = xscale(model.get(currentIndex).zoom)
                    var fullscreen = model.get(currentIndex).fullscreen
                    stack.push({item: mythUtils.findThemeFile("Screens/WebBrowser.qml"), properties:{url: url, fullscreen: fullscreen, zoomFactor: zoom}});
                }
                else if (model.get(currentIndex).loaderSource === "InternalPlayer.qml")
                {
                    var layout = model.get(currentIndex).layout
                    var feedSource = model.get(currentIndex).feedSource
                    stack.push({item: mythUtils.findThemeFile("Screens/InternalPlayer.qml"), properties:{layout: layout, defaultFeedSource: feedSource, defaultCurrentFeed: 0}});
                }
                else if (model.get(currentIndex).loaderSource === "External Program")
                {
                    var message = model.get(currentIndex).menutext + " will start shortly.\nPlease Wait.....";
                    var timeOut = 10000;
                    showBusyDialog(message, timeOut);
                    var command = model.get(currentIndex).exec
                    externalProcess.start(command, []);
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
                    stack.push({item: mythUtils.findThemeFile("Screens/" + model.get(currentIndex).loaderSource)})
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
}

