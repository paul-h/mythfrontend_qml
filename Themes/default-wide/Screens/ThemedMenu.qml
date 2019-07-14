import QtQuick 2.0
import Base 1.0
import Dialogs 1.0
import Process 1.0

BaseScreen
{
    property alias model: listView.model

    defaultFocusItem: listView

    Component.onCompleted:
    {
        showTitle(true, model.title);
        showTime(true);
        showTicker(true);
        showVideo(true);

        title.source = settings.themePath + model.logo
    }

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
        x: xscale(30); y: yscale(594)
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
        source: mythUtils.findThemeFile("ui/horizon.png")
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
                width: parent.width; height: yscale(60)
                TitleText
                {
                    text: menutext
                    fontFamily: theme.menuFontFamily
                    fontPixelSize: xscale(theme.menuFontPixelSize)
                    fontBold: theme.menuFontBold
                    fontColor: theme.menuFontColor
                    shadowAlpha: theme.menuShadowAlpha
                    shadowColor: theme.menuShadowColor
                    shadowXOffset: theme.menuShadowXOffset
                    shadowYOffset: theme.menuShadowYOffset
                    x: xscale(10); width: parent.width - xscale(20);
                    anchors.verticalCenter: parent.verticalCenter
                }

                MouseArea
                {
                    anchors.fill: parent
                    onClicked:
                    {
                        listView.currentIndex = index
                    }
                }
            }
        }

        ListView
        {
            id: listView
            width: parent.width; height: parent.height
            delegate: menuDelegate
            highlight: Image {source: mythUtils.findThemeFile("ui/button_on.png")}
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
                    popupMenu.addMenuItem("", "Show Version...", "version");
                    popupMenu.addMenuItem("", "Exit", "exit");

                    if (settings.rebootCommand !== "")
                        popupMenu.addMenuItem("", "Reboot", "reboot");

                    if (settings.shutdownCommand !== "")
                        popupMenu.addMenuItem("", "Shutdown", "shutdown");

                    popupMenu.addMenuItem("", "Background Volume...", "volume");

                    popupMenu.show();
                }
            }

            Keys.onReturnPressed:
            {
                event.accepted = true;
                returnSound.play();

                if (model.get(currentIndex).loaderSource === "ThemedMenu.qml")
                {
                    menuLoader.source = settings.menuPath + model.get(currentIndex).menuSource;
                    stack.push({item: Qt.resolvedUrl("ThemedMenu.qml"), properties:{model: menuLoader.item}});
                }
                else if (model.get(currentIndex).loaderSource === "WebBrowser.qml")
                {
                    var url = model.get(currentIndex).url
                    var zoom = xscale(model.get(currentIndex).zoom)
                    stack.push({item: Qt.resolvedUrl("WebBrowser.qml"), properties:{url: url, fullscreen: true, zoomFactor: zoom}});
                }
                else if (model.get(currentIndex).loaderSource === "InternalPlayer.qml")
                {
                    var layout = model.get(currentIndex).layout
                    var feedSource = model.get(currentIndex).feedSource
                    stack.push({item: Qt.resolvedUrl("InternalPlayer.qml"), properties:{layout: layout, defaultFeedSource: feedSource, defaultCurrentFeed: 0}});
                }
                else
                {
                    stack.push({item: Qt.resolvedUrl(model.get(currentIndex).loaderSource)})
                }

                event.accepted = true;
            }

            onCurrentItemChanged: watermark.swapImage(mythUtils.findThemeFile(model.get(currentIndex).waterMark))
        }
    }

    FadeImage
    {
        id: watermark
        x: xscale(832); y: yscale(196); width: xscale(300); height: yscale(300)
        source: mythUtils.findThemeFile("watermark/tv.png")
    }

    Process
    {
        id: shutdownProcess
    }

    PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "Menu Options"

        onItemSelected:
        {
            if (itemData === "version")
            {
                versionDialog.show();
                return;
            }
            else if (itemData === "reboot")
            {
                if (settings.rebootCommand != "")
                {
                    console.log("Rebooting!!!!")
                    shutdownProcess.start(settings.rebootCommand);
                }
            }
            else if (itemData === "shutdown")
            {
                if (settings.shutdownCommand != "")
                {
                    console.log("Shutting Down!!!!")
                    shutdownProcess.start(settings.shutdownCommand);
                }
            }
            else if (itemData === "exit")
            {
                Qt.quit();
                return;
            }
            else if (itemData === "volume")
            {

            }

            listView.focus = true;
        }

        onCancelled:
        {
            listView.focus = true;
        }
    }

    OkCancelDialog
    {
        id: versionDialog

        title: "MythfrontendQML"
        message: '<font  color="yellow"><b>Version: </font></b>v0.0.1 alpha<br><font  color="yellow"><b>Date:</font></b> 14th July 2019<br><br>(c) Paul Harrison 2019'

        rejectButtonText: ""
        acceptButtonText: "OK"

        width: xscale(600); height: yscale(300)

        onAccepted:
        {
            listView.focus = true;
        }
        onCancelled:
        {
            listView.focus = true;
        }
    }
}

