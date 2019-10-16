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
            }
        }

        ListView
        {
            id: listView
            width: parent.width; height: parent.height
            delegate: menuDelegate
            highlight: Image {cache: false; source: mythUtils.findThemeFile("ui/button_on.png")}
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

                    popupMenu.addMenuItem("", "Volume...", "volume");

                    popupMenu.show();
                }
                else if (event.key === Qt.Key_BracketLeft)
                {
                    // background video volume down
                    if (window.backgroundVideoVolume * 100 >= 1.00)
                        window.backgroundVideoVolume -= 0.01;

                    dbUtils.setSetting("Qml_backgroundVideoVolume", settings.hostName, window.backgroundVideoVolume);

                    showNotification("Background Volume: " + Math.round(backgroundVideoVolume * 100) + "%");
                }
                else if (event.key === Qt.Key_BracketRight)
                {
                    // background video volume up
                    if (window.backgroundVideoVolume * 100 <= 99)
                        window.backgroundVideoVolume += 0.01;

                    dbUtils.setSetting("Qml_backgroundVideoVolume", settings.hostName, window.backgroundVideoVolume);

                    showNotification("Background Volume: " + Math.round(backgroundVideoVolume * 100) + "%");
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
                    stack.push({item: mythUtils.findThemeFile("Screens/WebBrowser.qml"), properties:{url: url, fullscreen: false, zoomFactor: zoom}});
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

            onCurrentItemChanged: watermark.swapImage(mythUtils.findThemeFile(model.get(currentIndex).waterMark))
        }
    }

    FadeImage
    {
        id: watermark
        x: xscale(832); y: yscale(196); width: xscale(300); height: yscale(300)
        source: mythUtils.findThemeFile("watermark/tv.png")
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
                reboot();
            }
            else if (itemData === "shutdown")
            {
                shutdown();
            }
            else if (itemData === "exit")
            {
                quit();
            }
            else if (itemData === "volume")
            {
                volumeDialog.oldEffectsVolume = window.soundEffectsVolume;
                volumeDialog.oldBackgroundVideoVolume = window.backgroundVideoVolume;

                var index = window.soundEffectsVolume * 100.0;
                effectsSelector.selectItem(volumeModel.get(index).itemText);

                index = window.backgroundVideoVolume * 100.0;
                backgroundSelector.selectItem(volumeModel.get(index).itemText);

                volumeDialog.show();
                return;
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

        title: "MythQML"
        message: '<font  color="yellow"><b>Version: </font></b>' + version  +
                 '<br><font color="yellow"><b>Date: </font></b>' + buildtime +
                 '<br><font  color="yellow"><b>Qt Version: </font></b>' + qtversion +
                 '<br><br>(c) Paul Harrison 2019'

        rejectButtonText: ""
        acceptButtonText: "OK"

        width: xscale(600); height: yscale(300)

        onAccepted: listView.focus = true;
        onCancelled: listView.focus = true;
    }

    ListModel
    {
        id: volumeModel

        Component.onCompleted:
        {
            append({ "volume": 0, "itemText": "Muted"});

            for (var x = 1; x <= 100; x++)
            {
                append({ "volume": x, "itemText": x + "%"});
            }
        }
    }

    BaseDialog
    {
        id: volumeDialog
        title: "Volume"
        message: "Set sound effects and background video volume"
        width: xscale(500)
        height: yscale(400)

        property double oldEffectsVolume: -1
        property double oldBackgroundVideoVolume: -1

        onAccepted:
        {
            listView.focus = true;
            window.soundEffectsVolume = volumeModel.get(effectsSelector.currentIndex).volume / 100;
            window.backgroundVideoVolume = volumeModel.get(backgroundSelector.currentIndex).volume / 100;

            dbUtils.setSetting("Qml_soundEffectsVolume", settings.hostName, window.soundEffectsVolume);
            dbUtils.setSetting("Qml_backgroundVideoVolume", settings.hostName, window.backgroundVideoVolume);
        }

        onCancelled:
        {
            listView.focus = true;

            window.soundEffectsVolume = oldEffectsVolume;
            window.backgroundVideoVolume = oldBackgroundVideoVolume;
        }

        content: Item
        {
            anchors.fill: parent

            LabelText
            {
                text: "Sound Effects"
                x: xscale(10); y: 0; width: xscale(250);
            }

            BaseSelector
            {
                id: effectsSelector
                x: xscale(260); y: yscale(0);
                model: volumeModel
                focus: true;
                KeyNavigation.up: rejectButton;
                KeyNavigation.down: backgroundSelector;

                onItemSelected:
                {
                    if (volumeDialog.oldEffectsVolume !== -1)
                    {
                        window.soundEffectsVolume = volumeModel.get(effectsSelector.currentIndex).volume / 100;
                        returnSound.play();
                    }
                }
            }
            LabelText
            {
                text: "Background Video"
                x: xscale(10); y: yscale(60); width: xscale(250);
            }

            BaseSelector
            {
                id: backgroundSelector
                x: xscale(260); y: yscale(60);
                model: volumeModel
                KeyNavigation.up: effectsSelector;
                KeyNavigation.down: acceptButton;

                onItemSelected:
                {
                    if (volumeDialog.oldBackgroundVideoVolume !== -1)
                    {
                         window.backgroundVideoVolume = volumeModel.get(backgroundSelector.currentIndex).volume / 100;
                    }

                }
            }
        }

        buttons:
        [
            BaseButton
            {
                id: acceptButton
                text: "OK"
                visible: text != ""

                KeyNavigation.left: rejectButton;
                KeyNavigation.right: rejectButton;
                KeyNavigation.up: backgroundSelector;
                KeyNavigation.down: effectsSelector;
                onClicked:
                {
                    volumeDialog.state = "";
                    volumeDialog.accepted();
                }
            },

            BaseButton
            {
                id: rejectButton
                text: "Cancel"
                visible: text != ""

                KeyNavigation.left: acceptButton;
                KeyNavigation.right: acceptButton;
                KeyNavigation.up: backgroundSelector;
                KeyNavigation.down: effectsSelector;

                onClicked:
                {
                    volumeDialog.state = "";
                    volumeDialog.cancelled();
                }
            }
        ]
    }
}

