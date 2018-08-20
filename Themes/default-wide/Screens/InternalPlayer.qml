import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Base 1.0
import Dialogs 1.0
import SortFilterProxyModel 0.2
import "../../../Models"

BaseScreen
{
    id: root

    defaultFocusItem: player1
    property int layout: 0
    property alias source1: player1.source
    property alias title1:  player1.title
    property alias source2: player2.source
    property alias source3: player3.source
    property alias source4: player4.source

    SortFilterProxyModel
    {
        id: channelsProxyModel

        property int sourceId

        sourceModel: ChannelsModel { groupByCallsign: false }

        filters:
        [
            ValueFilter
            {
                roleName: "SourceId"
                value: channelsProxyModel.sourceId
            }
        ]
    }

    CaptureCardModel
    {
        id: captureCardModel
    }

    VideosModel
    {
        id: videosModel
    }

    Component.onCompleted:
    {
        showTitle(false, "");
        showTime(false);
        showTicker(false);
        showVideo(false);
        muteAudio(true);

        setLayout();
    }

    Component.onDestruction:
    {
        muteAudio(false);
        showImage(false);
        showVideo(true);
    }

    onWidthChanged: setLayout();
    onHeightChanged: setLayout();

    Keys.onEscapePressed:
    {
        player1.stop();
        player2.stop();
        player3.stop();
        player4.stop();
    }

    Keys.onPressed:
    {
        if (event.key === Qt.Key_0)
        {
            layout = 0;
            setLayout();
        }
        else if (event.key === Qt.Key_1)
        {
            layout = 1;
            setLayout();
        }
        else if (event.key === Qt.Key_2)
        {
            layout = 2;
            setLayout();
        }
        else if (event.key === Qt.Key_3)
        {
            layout = 3;
            setLayout();
        }
        else if (event.key === Qt.Key_3)
        {
            layout = 4;
            setLayout();
        }
        else if (event.key === Qt.Key_3)
        {
            layout = 5;
            setLayout();
        }
        else if (event.key === Qt.Key_M)
        {
            popupMenu.clearMenuItems();

            popupMenu.addMenuItem("Switch Layout");
            popupMenu.addMenuItem("Source 1");

            if (root.layout > 0)
                popupMenu.addMenuItem("Source 2");

            if (root.layout > 3)
            {
                popupMenu.addMenuItem("Source 3");
                popupMenu.addMenuItem("Source 4");
            }

            popupMenu.addMenuItem("Audio");

            popupMenu.addMenuItem("0,Full Screen");
            popupMenu.addMenuItem("0,Full screen with PIP");
            popupMenu.addMenuItem("0,PBP 1/2 screen");
            popupMenu.addMenuItem("0,PBP 3/4 screen with overlap");
            popupMenu.addMenuItem("0,PBP 1 + 2");
            popupMenu.addMenuItem("0,Quad Screen");

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

            popupMenu.addMenuItem("2,Source 1 Toggle Mute");

            if (root.layout > 0)
                popupMenu.addMenuItem("3,Source 2 Toggle Mute");

            if (root.layout > 3)
            {
                popupMenu.addMenuItem("5,Source 3 Toggle Mute");
                popupMenu.addMenuItem("5,Source 4 Toggle Mute");
            }

            popupMenu.show();
        }
        else
        {
            event.accepted = false;
        }
    }

    VideoPlayerQmlVLC
    {
        id: player1

         onPlaybackEnded:
         {
             stop();
             stack.pop();
         }
    }

    VideoPlayerQmlVLC
    {
        id: player2
        visible: false
    }

    VideoPlayerQmlVLC
    {
        id: player3
        visible: false
    }

    VideoPlayerQmlVLC
    {
        id: player4
        visible: false
    }

    function setLayout()
    {
        if (root.layout === 0)
        {
            // full screen
            showVideo(false);

            player1.visible = true;
            player2.visible = false;
            player3.visible = false;
            player4.visible = false;

            player1.x = 0;
            player1.y = 0;
            player1.width = root.width;
            player1.height = root.height;

            //if (player1.source != dbUtils.getSetting("Qml_player1Source", settings.hostName))
            //    player1.source = dbUtils.getSetting("Qml_player1Source", settings.hostName)

            player1.play();
            player2.stop();
            player3.stop();
            player4.stop();
        }
        else if (root.layout === 1)
        {
            // fullscreen with PIP
            showVideo(false);

            player1.visible = true;
            player2.visible = true;
            player3.visible = false;
            player4.visible = false;

            player1.x = 0;
            player1.y = 0;
            player1.width = root.width;
            player1.height = root.height;

            player2.x = root.width - xscale(50) - xscale(400);
            player2.y = yscale(50);
            player2.width = xscale(400);
            player2.height = yscale(225);

            if (player1.source != dbUtils.getSetting("Qml_player1Source", settings.hostName))
                player1.source = dbUtils.getSetting("Qml_player1Source", settings.hostName)
            if (player2.source != dbUtils.getSetting("Qml_player2Source", settings.hostName))
                player2.source = dbUtils.getSetting("Qml_player2Source", settings.hostName)

            player1.play();
            player2.play();
            player3.stop();
            player4.stop();
        }
        else if (root.layout === 2)
        {
            // PBP 1/2 screen
            showVideo(true);

            player1.visible = true;
            player2.visible = true;
            player3.visible = false;
            player4.visible = false;

            player1.x = 0;
            player1.y = yscale(250);
            player1.width = root.width / 2;
            player1.height = player1.width / 1.77777777;

            player2.x = root.width / 2;
            player2.y = yscale(250);
            player2.width = root.width / 2;
            player2.height = player2.width / 1.77777777;

            if (player1.source != dbUtils.getSetting("Qml_player1Source", settings.hostName))
                player1.source = dbUtils.getSetting("Qml_player1Source", settings.hostName)
            if (player2.source != dbUtils.getSetting("Qml_player2Source", settings.hostName))
                player2.source = dbUtils.getSetting("Qml_player2Source", settings.hostName)

            player1.play();
            player2.play();
            player3.stop();
            player4.stop();
        }
        else if (root.layout === 3)
        {
            // PBP 3/4 screen with overlap
            showVideo(true);

            player1.visible = true;
            player2.visible = true;
            player3.visible = false;
            player4.visible = false;

            player1.x = 0;
            player1.y = (root.height - (((root.width / 4) * 3) / 1.77777777)) / 2;
            player1.width = (root.width / 4) * 3;
            player1.height = ((root.width / 4) * 3) / 1.77777777;

            player2.x = root.width - xscale(400);
            player2.y = (root.height - 255) / 2;
            player2.width = xscale(400);
            player2.height = yscale(225);

            if (player1.source != dbUtils.getSetting("Qml_player1Source", settings.hostName))
                player1.source = dbUtils.getSetting("Qml_player1Source", settings.hostName)
            if (player2.source != dbUtils.getSetting("Qml_player2Source", settings.hostName))
                player2.source = dbUtils.getSetting("Qml_player2Source", settings.hostName)

            player1.play();
            player2.play();
            player3.stop();
            player4.stop();
        }
        else if (root.layout === 4)
        {
            // PBP 1 + 2
            showVideo(true);

            player1.visible = true;
            player2.visible = true;
            player3.visible = true;
            player4.visible = false;

            player1.x = 0;
            player1.y = (root.height - (((root.width / 4) * 3) / 1.77777777)) / 2;
            player1.width = (root.width / 4) * 3;
            player1.height = ((root.width / 4) * 3) / 1.77777777;

            player2.x = root.width - xscale(400);
            player2.y = yscale(100);
            player2.width = xscale(400);
            player2.height = yscale(225);

            player3.x = root.width - xscale(400);
            player3.y = yscale(400);
            player3.width = xscale(400);
            player3.height = yscale(225);

            if (player1.source != dbUtils.getSetting("Qml_player1Source", settings.hostName))
                player1.source = dbUtils.getSetting("Qml_player1Source", settings.hostName)
            if (player2.source != dbUtils.getSetting("Qml_player2Source", settings.hostName))
                player2.source = dbUtils.getSetting("Qml_player2Source", settings.hostName)
            if (player3.source != dbUtils.getSetting("Qml_player3Source", settings.hostName))
                player3.source = dbUtils.getSetting("Qml_player3Source", settings.hostName)

            player1.play();
            player2.play();
            player3.play();
            player4.stop();
        }
        else if (root.layout === 5)
        {
            // Quad Screen
            showVideo(false);

            player1.visible = true;
            player2.visible = true;
            player3.visible = true;
            player4.visible = true;

            player1.x = 0;
            player1.y = 0;
            player1.width = root.width / 2;
            player1.height = root.height / 2;

            player2.x = root.width / 2;
            player2.y = 0;
            player2.width = root.width / 2;
            player2.height = root.height / 2;

            player3.x = 0;
            player3.y = root.height / 2;
            player3.width = root.width / 2;
            player3.height = root.height / 2;

            player4.x = root.width / 2;
            player4.y = root.height / 2;
            player4.width = root.width / 2;
            player4.height = root.height / 2;;

            if (player1.source != dbUtils.getSetting("Qml_player1Source", settings.hostName))
                player1.source = dbUtils.getSetting("Qml_player1Source", settings.hostName)
            if (player2.source != dbUtils.getSetting("Qml_player2Source", settings.hostName))
                player2.source = dbUtils.getSetting("Qml_player2Source", settings.hostName)
            if (player3.source != dbUtils.getSetting("Qml_player3Source", settings.hostName))
                player3.source = dbUtils.getSetting("Qml_player3Source", settings.hostName)
            if (player4.source != dbUtils.getSetting("Qml_player4Source", settings.hostName))
                player4.source = dbUtils.getSetting("Qml_player4Source", settings.hostName)

            player1.play();
            player2.play();
            player3.play();
            player4.play();
        }
    }

    PopupMenu
    {
        id: popupMenu

        title: "Menu"
        message: "LiveTV Options"

        onItemSelected:
        {
            console.log("PopupMenu accepted signal received!: " + itemText);
            player1.focus = true;

            if (itemText == "Full Screen")
            {
                root.layout = 0;
                setLayout();
            }
            else if (itemText == "Full screen with PIP")
            {
                root.layout = 1;
                setLayout();
            }
            else if (itemText == "PBP 1/2 screen")
            {
                root.layout = 2;
                setLayout();
            }
            else if (itemText == "PBP 3/4 screen with overlap")
            {
                root.layout = 3;
                setLayout();
            }
            else if (itemText == "PBP 1 + 2")
            {
                root.layout = 4;
                setLayout();
            }
            else if (itemText == "Quad Screen")
            {
                root.layout = 5;
                setLayout();
            }
            else if (itemText == "Source 1 Toggle Mute")
                player1.toggleMute();
            else if (itemText == "Source 2 Toggle Mute")
                player2.toggleMute();
            else if (itemText == "Source 3 Toggle Mute")
                player3.toggleMute();
            else if (itemText == "Source 4 Toggle Mute")
                player4.toggleMute();
            else if (itemData.startsWith("source="))
            {
               var list = itemData.split("\n");
               console.info("found source=, list size: " + list.length);

               if (list.length == 2)
                {
                    if (list[0] == "source=1")
                    {
                        dbUtils.setSetting("Qml_player1Source", settings.hostName, list[1])
                        player1.source = list[1];
                    }
                    else if (list[0] == "source=2")
                    {
                        dbUtils.setSetting("Qml_player2Source", settings.hostName, list[1])
                        player2.source = list[1];
                    }
                    else if (list[0] == "source=3")
                    {
                        dbUtils.setSetting("Qml_player3Source", settings.hostName, list[1])
                        player3.source = list[1];
                    }
                    else if (list[0] == "source=4")
                    {
                        dbUtils.setSetting("Qml_player3Source", settings.hostName, list[1])
                        player4.source = list[1];
                    }
                }
            }
        }

        onCancelled:
        {
            console.log("PopupMenu cancelled signal received.");
            player1.focus = true;
        }
    }
}
