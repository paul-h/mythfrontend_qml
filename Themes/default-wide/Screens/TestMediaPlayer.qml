import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.XmlListModel 2.0
import Base 1.0
import Dialogs 1.0
import Models 1.0
import "../../../Util.js" as Util

BaseScreen
{
    id: root

    defaultFocusItem: mediaPlayer1

    property int layout: -1

    property var webcamPaths
    property int webcamPathIndex: 0

    Component.onCompleted:
    {
        showTitle(true, "Media Player");
        showTime(false);
        showTicker(false);
        screenBackground.muteAudio(true);

        var path;

        // get list of webcam paths
        webcamPaths =  settings.webcamPath.split(",")

        path = dbUtils.getSetting("Qml_lastWebcamPath", settings.hostName, webcamPaths[0])
        path = path.replace("/WebCam.xml", "")
        webcamPathIndex = webcamPaths.indexOf(path)
        webcamModel.source = path + "/WebCam.xml"

        setLayout(0);
    }

    Component.onDestruction:
    {
        mediaPlayer1.stop();
        mediaPlayer2.stop();
        mediaPlayer3.stop();
        mediaPlayer4.stop();
        screenBackground.muteAudio(false);
    }
/*
    Action
    {
        shortcut: "Escape"
        onTriggered: if (stack.depth > 1) {stack.pop(); escapeSound.play();} else Qt.quit();
    }

    Action
    {
        shortcut: "Down"
        onTriggered: nextPlayer();
    }

    Action
    {
        shortcut: "Up"
        onTriggered: previousPlayer();
    }
*/
    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F3 || event.key === Qt.Key_Down)
        {
            nextPlayer();
        }
        else if (event.key === Qt.Key_F4)
        {
            if (stack.depth > 1) {stack.pop(); escapeSound.play();} else Qt.quit();
        }
        else if (event.key === Qt.Key_F)
        {
            if (layout === 0)
                return;

            if (mediaPlayer2.focus)
            {
                mediaPlayer1.feedList = mediaPlayer2.feedList;
                mediaPlayer1.currentFeed = mediaPlayer2.currentFeed;
            }
            else if (mediaPlayer3.focus)
            {
                mediaPlayer1.feedList = mediaPlayer3.feedList;
                mediaPlayer1.currentFeed = mediaPlayer3.currentFeed;
            }
            else if (mediaPlayer4.focus)
            {
                mediaPlayer1.feedList = mediaPlayer4.feedList;
                mediaPlayer1.currentFeed = mediaPlayer4.currentFeed;
            }

            mediaPlayer1.focus = true;
            mediaPlayer1.startPlayback();
            setLayout(0);

        }
        else if (event.key === Qt.Key_M)
        {
            popupMenu.clearMenuItems();

            popupMenu.addMenuItem("Switch Layout");
            //popupMenu.addMenuItem("Source 1");

            //if (root.layout > 0)
            //    popupMenu.addMenuItem("Source 2");

            //if (root.layout > 3)
            //    popupMenu.addMenuItem("Source 3");

            //if (root.layout > 4)
            //    popupMenu.addMenuItem("Source 4");

            //popupMenu.addMenuItem("Audio");

            popupMenu.addMenuItem("0,Full Screen");
            popupMenu.addMenuItem("0,Full screen with PIP");
            popupMenu.addMenuItem("0,PBP 1/2 screen");
            popupMenu.addMenuItem("0,PBP 3/4 screen with overlap");
            popupMenu.addMenuItem("0,PBP 1 + 2");
            popupMenu.addMenuItem("0,Quad Screen");
/*
            for (var x = 0; x < captureCardModel.count; x++)
            {
                var cardDisplayName = captureCardModel.get(x).DisplayName;
                popupMenu.addMenuItem("1," + cardDisplayName)

                // add the channels for this card
                channelsProxyModel.sourceId = captureCardModel.get(x).SourceId

                for (var y = 0; y < channelsProxyModel.count; y++)
                {
                    var title = "1," + x + "," + channelsProxyModel.get(y).ChanNum + " - " + channelsProxyModel.get(y).ChannelName;
                    var data = "source=1\nmyth://type=livetv:server=" + captureCardModel.get(x).HostName + ":encoder=" + captureCardModel.get(x).CardId + ":channum=" + channelsProxyModel.get(y).ChanNum;
                    popupMenu.addMenuItem(title, data);
                }
            }

            popupMenu.addMenuItem("1,Recording");
            popupMenu.addMenuItem("1,Video");
            for (var x = 0; x < videosModel.count; x++)
            {
                var title = "1," + (captureCardModel.count + 1) + "," + videosModel.get(x).Title + " - " + videosModel.get(x).SubTitle;
                var data = "source=1\nmyth://type=video:server=" + videosModel.get(x).HostName + ":sgroup=video:filename=" + videosModel.get(x).FileName;
                popupMenu.addMenuItem(title, data);
            }

            if (root.layout > 0)
            {
                for (var x = 0; x < captureCardModel.count; x++)
                {
                    var cardDisplayName = captureCardModel.get(x).DisplayName;
                    popupMenu.addMenuItem("2," + cardDisplayName)

                    // add the channels for this card
                    channelsProxyModel.sourceId = captureCardModel.get(x).SourceId

                    for (var y = 0; y < channelsProxyModel.count; y++)
                    {
                        var title = "2," + x + "," + channelsProxyModel.get(y).ChanNum + " - " + channelsProxyModel.get(y).ChannelName;
                        var data = "source=2\nmyth://type=livetv:server=" + captureCardModel.get(x).HostName + ":encoder=" + captureCardModel.get(x).CardId + ":channum=" + channelsProxyModel.get(y).ChanNum;
                        popupMenu.addMenuItem(title, data);
                    }
                }

                popupMenu.addMenuItem("2,Recording");
                popupMenu.addMenuItem("2,Video");
            }

            if (root.layout > 3)
            {
                for (var x = 0; x < captureCardModel.count; x++)
                {
                    var cardDisplayName = captureCardModel.get(x).DisplayName;
                    popupMenu.addMenuItem("3," + cardDisplayName)

                    // add the channels for this card
                    channelsProxyModel.sourceId = captureCardModel.get(x).SourceId

                    for (var y = 0; y < channelsProxyModel.count; y++)
                    {
                        var title = "3," + x + "," + channelsProxyModel.get(y).ChanNum + " - " + channelsProxyModel.get(y).ChannelName;
                        var data = "source=3\nmyth://type=livetv:server=" + captureCardModel.get(x).HostName + ":encoder=" + captureCardModel.get(x).CardId + ":channum=" + channelsProxyModel.get(y).ChanNum;
                        popupMenu.addMenuItem(title, data);
                    }
                }

                popupMenu.addMenuItem("3,Recording");
                popupMenu.addMenuItem("3,Video");

                for (var x = 0; x < captureCardModel.count; x++)
                {
                    var cardDisplayName = captureCardModel.get(x).DisplayName;
                    popupMenu.addMenuItem("4," + cardDisplayName)

                    // add the channels for this card
                    channelsProxyModel.sourceId = captureCardModel.get(x).SourceId

                    for (var y = 0; y < channelsProxyModel.count; y++)
                    {
                        var title = "4," + x + "," + channelsProxyModel.get(y).ChanNum + " - " + channelsProxyModel.get(y).ChannelName;
                        var data = "source=4\nmyth://type=livetv:server=" + captureCardModel.get(x).HostName + ":encoder=" + captureCardModel.get(x).CardId + ":channum=" + channelsProxyModel.get(y).ChanNum;
                        popupMenu.addMenuItem(title, data);
                    }
                }

                popupMenu.addMenuItem("4,Recording");
                popupMenu.addMenuItem("4,Video");
            }
*/
           // popupMenu.addMenuItem("2,Source 1 Toggle Mute");

            //if (root.layout > 0)
            //   popupMenu.addMenuItem("3,Source 2 Toggle Mute");

            //if (root.layout > 3)
            //{
            //    popupMenu.addMenuItem("5,Source 3 Toggle Mute");
            //    popupMenu.addMenuItem("5,Source 4 Toggle Mute");
            //}

            popupMenu.show();
        }
        else
        {
            event.accepted = false;
        }
    }

    WebCamModel
    {
        id: webcamModel 
        onStatusChanged:
        {
            if (status == XmlListModel.Ready)
            {
                console.log("** webcamModel Found " + count + " webcams")
                setLayout(0);
                mediaPlayer1.feedList = webcamModel;
                mediaPlayer1.currentFeed = 0;
                mediaPlayer1.startPlayback();

                mediaPlayer2.feedList = webcamModel;
                mediaPlayer2.currentFeed = 10;
                //mediaPlayer2.startPlayback();

                mediaPlayer3.feedList = webcamModel;
                mediaPlayer3.currentFeed = 15;
                //mediaPlayer3.startPlayback();

                mediaPlayer4.feedList = webcamModel;
                mediaPlayer4.currentFeed = 20;
                //mediaPlayer4.startPlayback();
            }
        }
    }

    MediaPlayer
    {
        id: mediaPlayer1
        visible: false
        enabled: visible
    }

    MediaPlayer
    {
        id: mediaPlayer2
        visible: false
        enabled: visible
    }

    MediaPlayer
    {
        id: mediaPlayer3
        visible: false
        enabled: visible
    }

    MediaPlayer
    {
        id: mediaPlayer4
        visible: false
        enabled: visible
    }

       PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "Media Player Options"

        onItemSelected:
        {
            console.log("PopupMenu accepted signal received!: " + itemText);
            mediaPlayer1.focus = true;

            if (itemText == "Full Screen")
            {
                setLayout(0);
            }
            else if (itemText == "Full screen with PIP")
            {
                setLayout(1);
            }
            else if (itemText == "PBP 1/2 screen")
            {
                setLayout(2);
            }
            else if (itemText == "PBP 3/4 screen with overlap")
            {
                setLayout(3);
            }
            else if (itemText == "PBP 1 + 2")
            {
                setLayout(4);
            }
            else if (itemText == "Quad Screen")
            {
                setLayout(5);
            }
            else if (itemText == "Source 1 Toggle Mute")
                mediaPlayer1.toggleMute();
            else if (itemText == "Source 2 Toggle Mute")
                mediaPlayer2.toggleMute();
            else if (itemText == "Source 3 Toggle Mute")
                mediaPlayer3.toggleMute();
            else if (itemText == "Source 4 Toggle Mute")
                mediaPlayer4.toggleMute();
            else if (itemData.startsWith("source="))
            {
               var list = itemData.split("\n");
               console.info("found source=, list size: " + list.length);

               if (list.length == 2)
                {
                    if (list[0] == "source=1")
                    {
                        dbUtils.setSetting("Qml_player1Source", settings.hostName, list[1])
                        mediaPlayer1.source = list[1];
                    }
                    else if (list[0] == "source=2")
                    {
                        dbUtils.setSetting("Qml_player2Source", settings.hostName, list[1])
                        mediaPlayer2.source = list[1];
                    }
                    else if (list[0] == "source=3")
                    {
                        dbUtils.setSetting("Qml_player3Source", settings.hostName, list[1])
                        mediaPlayer3.source = list[1];
                    }
                    else if (list[0] == "source=4")
                    {
                        dbUtils.setSetting("Qml_player3Source", settings.hostName, list[1])
                        mediaPlayer4.source = list[1];
                    }
                }
            }
        }

        onCancelled:
        {
            console.log("PopupMenu cancelled signal received.");
            mediaPlayer1.focus = true;
        }
    }

    function nextPlayer()
    {
        if (mediaPlayer1.focus && mediaPlayer2.visible)
            mediaPlayer2.focus = true;
        else if (mediaPlayer2.focus)
        {
            if (mediaPlayer3.visible)
                mediaPlayer3.focus = true;
            else
                mediaPlayer1.focus = true;
        }
        else if (mediaPlayer3.focus)
        {
            if (mediaPlayer4.visible)
                mediaPlayer4.focus = true;
            else
                mediaPlayer1.focus = true;
        }
        else if (mediaPlayer4.focus)
            mediaPlayer1.focus = true;
    }

    function previousPlayer()
    {
        //TODO
    }

    function setLayout(newLayout)
    {
        if (root.layout === newLayout)
            return;

        root.layout = newLayout;

        if (root.layout === 0)
        {
            // full screen
            showVideo(false);

            mediaPlayer1.visible = true;
            mediaPlayer2.visible = false;
            mediaPlayer3.visible = false;
            mediaPlayer4.visible = false;

            mediaPlayer1.x = 0;
            mediaPlayer1.y = 0;
            mediaPlayer1.width = root.width;
            mediaPlayer1.height = root.height;

            //if (player1.source != dbUtils.getSetting("Qml_player1Source", settings.hostName))
            //    player1.source = dbUtils.getSetting("Qml_player1Source", settings.hostName)

            mediaPlayer1.play();
            mediaPlayer2.stop();
            mediaPlayer3.stop();
            mediaPlayer4.stop();
        }
        else if (root.layout === 1)
        {
            // fullscreen with PIP
            showVideo(false);

            mediaPlayer1.visible = true;
            mediaPlayer2.visible = true;
            mediaPlayer3.visible = false;
            mediaPlayer4.visible = false;

            mediaPlayer1.x = 0;
            mediaPlayer1.y = 0;
            mediaPlayer1.width = root.width;
            mediaPlayer1.height = root.height;

            mediaPlayer2.x = root.width - xscale(50) - xscale(400);
            mediaPlayer2.y = yscale(50);
            mediaPlayer2.width = xscale(400);
            mediaPlayer2.height = yscale(225);

            //if (mediaPlayer1.source != dbUtils.getSetting("Qml_player1Source", settings.hostName))
            //    mediaPlayer1.source = dbUtils.getSetting("Qml_player1Source", settings.hostName)
            //if (mediaPlayer2.source != dbUtils.getSetting("Qml_player2Source", settings.hostName))
            //    mediaPlayer2.source = dbUtils.getSetting("Qml_player2Source", settings.hostName)

            mediaPlayer1.play();
            mediaPlayer2.play();
            mediaPlayer3.stop();
            mediaPlayer4.stop();
        }
        else if (root.layout === 2)
        {
            // PBP 1/2 screen
            showVideo(true);

            mediaPlayer1.visible = true;
            mediaPlayer2.visible = true;
            mediaPlayer3.visible = false;
            mediaPlayer4.visible = false;

            mediaPlayer1.x = 0;
            mediaPlayer1.y = yscale(250);
            mediaPlayer1.width = root.width / 2;
            mediaPlayer1.height = mediaPlayer1.width / 1.77777777;

            mediaPlayer2.x = root.width / 2;
            mediaPlayer2.y = yscale(250);
            mediaPlayer2.width = root.width / 2;
            mediaPlayer2.height = mediaPlayer2.width / 1.77777777;

            //if (mediaPlayer1.source != dbUtils.getSetting("Qml_player1Source", settings.hostName))
            //    mediaPlayer1.source = dbUtils.getSetting("Qml_player1Source", settings.hostName)
            //if (mediaPlayer2.source != dbUtils.getSetting("Qml_player2Source", settings.hostName))
            //    mediaPlayer2.source = dbUtils.getSetting("Qml_player2Source", settings.hostName)

            mediaPlayer1.play();
            mediaPlayer2.play();
            mediaPlayer3.stop();
            mediaPlayer4.stop();
        }
        else if (root.layout === 3)
        {
            // PBP 3/4 screen with overlap
            showVideo(true);

            mediaPlayer1.visible = true;
            mediaPlayer2.visible = true;
            mediaPlayer3.visible = false;
            mediaPlayer4.visible = false;

            mediaPlayer1.x = 0;
            mediaPlayer1.y = (root.height - (((root.width / 4) * 3) / 1.77777777)) / 2;
            mediaPlayer1.width = (root.width / 4) * 3;
            mediaPlayer1.height = ((root.width / 4) * 3) / 1.77777777;

            mediaPlayer2.x = root.width - xscale(400);
            mediaPlayer2.y = (root.height - 255) / 2;
            mediaPlayer2.width = xscale(400);
            mediaPlayer2.height = yscale(225);

            //if (mediaPlayer1.source != dbUtils.getSetting("Qml_player1Source", settings.hostName))
            //    mediaPlayer1.source = dbUtils.getSetting("Qml_player1Source", settings.hostName)
            //if (mediaPlayer2.source != dbUtils.getSetting("Qml_player2Source", settings.hostName))
            //    mediaPlayer2.source = dbUtils.getSetting("Qml_player2Source", settings.hostName)

            mediaPlayer1.play();
            mediaPlayer2.play();
            mediaPlayer3.stop();
            mediaPlayer4.stop();
        }
        else if (root.layout === 4)
        {
            // PBP 1 + 2
            showVideo(true);

            mediaPlayer1.visible = true;
            mediaPlayer2.visible = true;
            mediaPlayer3.visible = true;
            mediaPlayer4.visible = false;

            mediaPlayer1.x = 0;
            mediaPlayer1.y = (root.height - (((root.width / 4) * 3) / 1.77777777)) / 2;
            mediaPlayer1.width = (root.width / 4) * 3;
            mediaPlayer1.height = ((root.width / 4) * 3) / 1.77777777;

            mediaPlayer2.x = root.width - xscale(400);
            mediaPlayer2.y = yscale(100);
            mediaPlayer2.width = xscale(400);
            mediaPlayer2.height = yscale(225);

            mediaPlayer3.x = root.width - xscale(400);
            mediaPlayer3.y = yscale(400);
            mediaPlayer3.width = xscale(400);
            mediaPlayer3.height = yscale(225);

            //if (mediaPlayer1.source != dbUtils.getSetting("Qml_player1Source", settings.hostName))
            //    mediaPlayer1.source = dbUtils.getSetting("Qml_player1Source", settings.hostName)
            //if (mediaPlayer2.source != dbUtils.getSetting("Qml_player2Source", settings.hostName))
            //    mediaPlayer2.source = dbUtils.getSetting("Qml_player2Source", settings.hostName)
            //if (mediaPlayer3.source != dbUtils.getSetting("Qml_player3Source", settings.hostName))
            //    mediaPlayer3.source = dbUtils.getSetting("Qml_player3Source", settings.hostName)

            mediaPlayer1.play();
            mediaPlayer2.play();
            mediaPlayer3.play();
            mediaPlayer4.stop();
        }
        else if (root.layout === 5)
        {
            // Quad Screen
            showVideo(false);

            mediaPlayer1.visible = true;
            mediaPlayer2.visible = true;
            mediaPlayer3.visible = true;
            mediaPlayer4.visible = true;

            mediaPlayer1.x = 0;
            mediaPlayer1.y = 0;
            mediaPlayer1.width = root.width / 2;
            mediaPlayer1.height = root.height / 2;

            mediaPlayer2.x = root.width / 2;
            mediaPlayer2.y = 0;
            mediaPlayer2.width = root.width / 2;
            mediaPlayer2.height = root.height / 2;

            mediaPlayer3.x = 0;
            mediaPlayer3.y = root.height / 2;
            mediaPlayer3.width = root.width / 2;
            mediaPlayer3.height = root.height / 2;

            mediaPlayer4.x = root.width / 2;
            mediaPlayer4.y = root.height / 2;
            mediaPlayer4.width = root.width / 2;
            mediaPlayer4.height = root.height / 2;;

            //if (mediaPlayer1.source != dbUtils.getSetting("Qml_player1Source", settings.hostName))
            //    mediaPlayer1.source = dbUtils.getSetting("Qml_player1Source", settings.hostName)
            //if (mediaPlayer2.source != dbUtils.getSetting("Qml_player2Source", settings.hostName))
            //    mediaPlayer2.source = dbUtils.getSetting("Qml_player2Source", settings.hostName)
            //if (mediaPlayer3.source != dbUtils.getSetting("Qml_player3Source", settings.hostName))
            //    mediaPlayer3.source = dbUtils.getSetting("Qml_player3Source", settings.hostName)
            //if (mediaPlayer4.source != dbUtils.getSetting("Qml_player4Source", settings.hostName))
            //    mediaPlayer4.source = dbUtils.getSetting("Qml_player4Source", settings.hostName)

            mediaPlayer1.play();
            mediaPlayer2.play();
            mediaPlayer3.play();
            mediaPlayer4.play();
        }
    }
}
