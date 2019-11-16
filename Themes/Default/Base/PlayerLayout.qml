import QtQuick 2.0
import QtWebEngine 1.3
import Base 1.0

Item
{
    id: root

    x: 0
    y: 0
    width: parent.width
    height: parent.height

    property bool showHeader: true
    property bool showChat: false
    property bool showRailCam: false

    property int chatWidth: xscale(400)
    property int railcamHeight: yscale(250)
    property int playerLayout: 1

    property var activeItem: player1

    property alias mediaPlayer1: player1
    property alias mediaPlayer2: player2
    property alias mediaPlayer3: player3
    property alias mediaPlayer4: player4

    property alias chatTitle: chatTitle
    property alias chatBrowser: chatBrowser

    property alias railcamBrowser: railcamBrowser

    state: ""

    // make sure we don't change the screen title or show time properties
    // before they have been saved in BaseScreen
    Component.onCompleted: parent.onStateSaved.connect(initState)

    onShowChatChanged: changeState()
    onShowRailCamChanged: changeState()
    onShowHeaderChanged: changeState()
    onPlayerLayoutChanged: changePlayerLayout()

    function initState()
    {
        changeState();
        changePlayerLayout();
    }

    function changeState()
    {
        if (!showChat && !showRailCam && showHeader)
            state = "fullscreen";

        if (!showChat && !showRailCam && !showHeader)
            state = "playersonly";

        if (showChat && !showRailCam)
            state = "showchat";

        if (!showChat && showRailCam)
            state = "showrailcam";

        if (showChat && showRailCam)
            state = "showboth";
    }

    function changePlayerLayout()
    {
        if (playerLayout === 1)
            playerArea.state = "layout1";
        else if (playerLayout === 2)
            playerArea.state = "layout2";
        else if (playerLayout === 3)
            playerArea.state = "layout3";
        else if (playerLayout === 4)
            playerArea.state = "layout4";
        else if (playerLayout === 5)
            playerArea.state = "layout5";
        else if (playerLayout === 6)
            playerArea.state = "layout6";
        else
            playerArea.state = "layout1";
    }

    function changeFocus(item)
    {
        if (activeItem != item)
        {
            activeItem.focus = false;
            activeItem = item;
        }
    }

    states:
    [
        State
        {
            name: "fullscreen"
            PropertyChanges { target: root; y: 0; height: parent.height; }
            PropertyChanges { target: chat; width: 0 }
            PropertyChanges { target: railcam; height: 0 }
            PropertyChanges { target: videoTitle1; height: 0 }
            PropertyChanges { target: playerArea; x: 0; y: 0; width: parent.width; height: parent.height }
            StateChangeScript { script: doShowHeader(false); }
        },
        State
        {
            name: "playersonly"
            PropertyChanges { target: root; y: yscale(50); height: parent.height - yscale(50); }
            PropertyChanges { target: chat; width: 0 }
            PropertyChanges { target: railcam; height: 0 }
            PropertyChanges { target: videoTitle1; height: yscale(30) }
            PropertyChanges { target: playerArea; height: root.height - playerArea.y - yscale(5) }
            StateChangeScript { script: doShowHeader(true); }
        },
        State
        {
            name: "showchat"
            PropertyChanges { target: root; y: yscale(50); height: parent.height - yscale(50); }
            PropertyChanges { target: chat; width: chatWidth }
            PropertyChanges { target: railcam; height: 0 }
            PropertyChanges { target: videoTitle1; height: yscale(30) }
            PropertyChanges { target: playerArea; height: root.height - playerArea.y - yscale(5) }
            StateChangeScript { script: doShowHeader(true); }
        },
        State
        {
            name: "showrailcam"
            PropertyChanges { target: root; y: yscale(50); height: parent.height - yscale(50); }
            PropertyChanges { target: chat; width: 0 }
            PropertyChanges { target: railcam; height: railcamHeight }
            PropertyChanges { target: videoTitle1; height: yscale(30) }
            PropertyChanges { target: playerArea; height: root.height - playerArea.y - yscale(5) - railcamHeight }
            StateChangeScript { script: doShowHeader(true); }
        },
        State
        {
            name: "showboth"
            PropertyChanges { target: root; y: yscale(50); height: parent.height - yscale(50); }
            PropertyChanges { target: chat; width: chatWidth }
            PropertyChanges { target: railcam; height: railcamHeight }
            PropertyChanges { target: videoTitle1; height: yscale(30) }
            PropertyChanges { target: playerArea; height: root.height - playerArea.y - yscale(5) - railcamHeight }
            StateChangeScript { script: doShowHeader(true); }
        }
    ]

    function doShowHeader(show)
    {
        player1.showBorder = show;
        parent.showTime(show);
        parent.showTitle(show);
    }

    Item
    {
        id: playerArea
        x: chat.width + xscale(5)
        y: 0
        width: parent.width - x - xscale(5)
        height: parent.height

        Behavior on height { NumberAnimation { easing.type: Easing.InOutQuad; duration: 1000 }}

        states:
        [
            State
            {
                // fullscreen
                name: "layout1"
                PropertyChanges { target: videoTitle1;
                                  x: 0;
                                  y: 0;
                                  width: playerArea.width;
                                  height: root.showHeader ? 0 : yscale(30);
                                  visible: true
                                }
                PropertyChanges { target: player1;
                                  x: 0;
                                  y: videoTitle1.y + videoTitle1.height;
                                  width: playerArea.width;
                                  height: playerArea.height - videoTitle1.height;
                                  KeyNavigation.left: chatBrowser;
                                  KeyNavigation.right: chatBrowser;
                                  KeyNavigation.up: railcamBrowser;
                                  KeyNavigation.down: railcamBrowser;
                                }
                StateChangeScript { script: player1.startPlayback() }

                StateChangeScript { script: player2.stop() }
                PropertyChanges { target: videoTitle2; width: 0 }
                PropertyChanges { target: player2; width: 0 }

                StateChangeScript { script: player3.stop() }
                PropertyChanges { target: videoTitle3; width: 0 }
                PropertyChanges { target: player3; width: 0 }

                StateChangeScript { script: player4.stop() }
                PropertyChanges { target: videoTitle4; width: 0 }
                PropertyChanges { target: player4; width: 0 }

                PropertyChanges { target: chatBrowser;
                                  KeyNavigation.left: player1;
                                  KeyNavigation.right: player1;
                                  KeyNavigation.up: railcamBrowser;
                                  KeyNavigation.down: railcamBrowser;
                                }
                PropertyChanges { target: railcamBrowser;
                                  KeyNavigation.left: chatBrowser;
                                  KeyNavigation.right: chatBrowser;
                                  KeyNavigation.up: player1;
                                  KeyNavigation.down: player1;
                                }

                PropertyChanges { target: root; showHeader: true; }
            },
            State
            {
                // fullscreen with PIP
                name: "layout2"
                PropertyChanges { target: videoTitle1;
                                  x: 0;
                                  y: 0;
                                  width: playerArea.width;
                                  height: yscale(30);
                                  visible: true }
                PropertyChanges { target: player1;
                                  x: 0;
                                  y: videoTitle1.height;
                                  width: playerArea.width;
                                  height: playerArea.height - videoTitle1.height;
                                  KeyNavigation.left: chatBrowser;
                                  KeyNavigation.right: player2;
                                  KeyNavigation.up: railcamBrowser;
                                  KeyNavigation.down: railcamBrowser;
                                }
                StateChangeScript { script: player1.startPlayback() }

                PropertyChanges { target: videoTitle2;
                                  x: playerArea.width - (playerArea.width / 3) - xscale(50);
                                  y: yscale(50);
                                  width: playerArea.width / 3;
                                  height: yscale(30);
                                  visible: true }
                PropertyChanges { target: player2;
                                  x: videoTitle2.x; y: videoTitle2.y + videoTitle2.height;
                                  width: videoTitle2.width;
                                  height: player2.width / 1.77777;
                                  visible: true;
                                  KeyNavigation.left: player1;
                                  KeyNavigation.right: chatBrowser;
                                  KeyNavigation.up: railcamBrowser;
                                  KeyNavigation.down: railcamBrowser;
                                 }
                StateChangeScript { script: player2.startPlayback() }

                StateChangeScript { script: player3.stop() }
                PropertyChanges { target: videoTitle3; width: 0 }
                PropertyChanges { target: player3; width: 0 }

                StateChangeScript { script: player4.startPlayback() }
                PropertyChanges { target: videoTitle4; width: 0 }
                PropertyChanges { target: player4; width: 0 }

                PropertyChanges { target: chatBrowser;
                                  KeyNavigation.left: player2;
                                  KeyNavigation.right: player1;
                                  KeyNavigation.up: railcamBrowser;
                                  KeyNavigation.down: railcamBrowser;
                                }
                PropertyChanges { target: railcamBrowser;
                                  KeyNavigation.left: chatBrowser;
                                  KeyNavigation.right: chatBrowser;
                                  KeyNavigation.up: player2;
                                  KeyNavigation.down: player1;
                                }

                PropertyChanges { target: root; showHeader: false; }
            },
            State
            {
                // PBP 1/2 screen
                name: "layout3"
                PropertyChanges { target: videoTitle1;
                                  x: 0;
                                  y: ((playerArea.height - player1.height) / 2) - yscale(15);
                                  width: playerArea.width / 2;
                                  height: yscale(30);
                                  visible: true }
                PropertyChanges { target: player1;
                                  x: 0; y: videoTitle1.y + videoTitle1.height + yscale(1);
                                  width: videoTitle1.width;
                                  height: player1.width / 1.77777;
                                  KeyNavigation.left: chatBrowser;
                                  KeyNavigation.right: player2;
                                  KeyNavigation.up: railcamBrowser;
                                  KeyNavigation.down: railcamBrowser;
                                }
                StateChangeScript { script: player1.startPlayback() }

                PropertyChanges { target: videoTitle2;
                                  x: videoTitle1.x + videoTitle1.width;
                                  y: videoTitle1.y;
                                  width: playerArea.width / 2;
                                  height: yscale(30);
                                  visible: true }
                PropertyChanges { target: player2;
                                  x: playerArea.width / 2;
                                  y: videoTitle1.y + videoTitle1.height + yscale(1);
                                  width: videoTitle1.width;
                                  height: player1.height;
                                  visible: true;
                                  KeyNavigation.left: player1;
                                  KeyNavigation.right: chatBrowser;
                                  KeyNavigation.up: railcamBrowser;
                                  KeyNavigation.down: railcamBrowser;
                                }
                StateChangeScript { script: player2.startPlayback() }

                StateChangeScript { script: player3.stop() }
                PropertyChanges { target: videoTitle3; width: 0 }
                PropertyChanges { target: player3; width: 0 }

                StateChangeScript { script: player4.stop() }
                PropertyChanges { target: videoTitle4; width: 0 }
                PropertyChanges { target: player4; width: 0 }

                PropertyChanges { target: chatBrowser;
                                  KeyNavigation.left: player2;
                                  KeyNavigation.right: player1;
                                  KeyNavigation.up: railcamBrowser;
                                  KeyNavigation.down: railcamBrowser;
                                }
                PropertyChanges { target: railcamBrowser;
                                  KeyNavigation.left: chatBrowser;
                                  KeyNavigation.right: chatBrowser;
                                  KeyNavigation.up: player2;
                                  KeyNavigation.down: player1;
                                }

                PropertyChanges { target: root; showHeader: false; }
            },
            State
            {
                // PBP 3/4 screen with overlap
                name: "layout4"
                PropertyChanges { target: videoTitle1;
                                  x: 0;
                                  y: Math.max(0, ((playerArea.height - player1.height) / 2) - yscale(15));
                                  width: playerArea.width * 0.75;
                                  height: yscale(30);
                                  visible: true
                                }
                PropertyChanges { target: player1;
                                  x: 0; y: videoTitle1.y + videoTitle1.height + 1;
                                  width: videoTitle1.width;
                                  height: Math.min(player1.width / 1.77777, playerArea.height - videoTitle1.height);
                                  KeyNavigation.left: chatBrowser;
                                  KeyNavigation.right: player2;
                                  KeyNavigation.up: railcamBrowser;
                                  KeyNavigation.down: railcamBrowser;
                                }
                StateChangeScript { script: player1.startPlayback() }

                PropertyChanges { target: videoTitle2;
                                  x: playerArea.width - player2.width;
                                  y: (playerArea.height - player2.height) / 2;
                                  width: playerArea.width / 3;
                                  height: yscale(30);
                                  visible: true;
                                }
                PropertyChanges { target: player2;
                                  x: videoTitle2.x;
                                  y: videoTitle2.y + videoTitle2.height + yscale(1);
                                  width: playerArea.width / 3;
                                  height: player2.width / 1.77777;
                                  visible: true;
                                  KeyNavigation.left: player1;
                                  KeyNavigation.right: chatBrowser;
                                  KeyNavigation.up: player2;
                                  KeyNavigation.down: railcamBrowser;
                                }
                StateChangeScript { script: player2.startPlayback() }

                StateChangeScript { script: player3.stop() }
                PropertyChanges { target: videoTitle3; width: 0 }
                PropertyChanges { target: player3; width: 0 }

                StateChangeScript { script: player4.stop() }
                PropertyChanges { target: videoTitle4; width: 0 }
                PropertyChanges { target: player4; width: 0 }


                PropertyChanges { target: chatBrowser;
                                  KeyNavigation.left: player2;
                                  KeyNavigation.right: player1;
                                  KeyNavigation.up: railcamBrowser;
                                  KeyNavigation.down: railcamBrowser;
                                }
                PropertyChanges { target: railcamBrowser;
                                  KeyNavigation.left: chatBrowser;
                                  KeyNavigation.right: chatBrowser;
                                  KeyNavigation.up: player2;
                                  KeyNavigation.down: player1;
                                }

                PropertyChanges { target: root; showHeader: false; }
            },
            State
            {
                // PBP 1 + 2
                name: "layout5"
                PropertyChanges { target: videoTitle1;
                                  x: 0;
                                  y: Math.max(0, ((playerArea.height - player1.height) / 2) - yscale(15));
                                  width: playerArea.width * 0.75;
                                  height: yscale(30);
                                  visible: true }
                PropertyChanges { target: player1;
                                  x: 0;
                                  y: videoTitle1.y + videoTitle1.height + yscale(1);
                                  width: videoTitle1.width;
                                  height: Math.min(player1.width / 1.77777, playerArea.height - videoTitle1.height);
                                  KeyNavigation.left: chatBrowser;
                                  KeyNavigation.right: player2;
                                  KeyNavigation.up: railcamBrowser;
                                  KeyNavigation.down: railcamBrowser;
                                }
                StateChangeScript { script: player1.startPlayback() }

                PropertyChanges { target: videoTitle2;
                                  x: playerArea.width - videoTitle2.width;
                                  y: player1.y;
                                  width: player2.height * 1.7777;
                                  height: yscale(30);
                                  visible: true }
                PropertyChanges { target: player2;
                                  x: videoTitle2.x;
                                  y: videoTitle2.y + videoTitle2.height;
                                  width: videoTitle2.width;
                                  height: (player1.height - (2 * videoTitle1.height)) / 2;
                                  visible: true;
                                  KeyNavigation.left: player1;
                                  KeyNavigation.right: chatBrowser;
                                  KeyNavigation.up: railcamBrowser;
                                  KeyNavigation.down: player3;
                                }
                StateChangeScript { script: player2.startPlayback() }

                PropertyChanges { target: videoTitle3;
                                  x: videoTitle2.x;
                                  y: player2.y + player2.height;
                                  width: videoTitle2.width;
                                  height: yscale(30);
                                  visible: true }
                PropertyChanges { target: player3;
                                  x: videoTitle2.x;
                                  y: videoTitle3.y + videoTitle3.height;
                                  width: player2.width;
                                  height: player2.height;
                                  visible: true;
                                  KeyNavigation.left: player1;
                                  KeyNavigation.right: chatBrowser;
                                  KeyNavigation.up: player2;
                                  KeyNavigation.down: railcamBrowser;
                                }
                StateChangeScript { script: player3.startPlayback() }

                StateChangeScript { script: player4.stop() }
                PropertyChanges { target: videoTitle4; width: 0 }
                PropertyChanges { target: player4; width: 0 }

                PropertyChanges { target: chatBrowser;
                                  KeyNavigation.left: player3;
                                  KeyNavigation.right: player1;
                                  KeyNavigation.up: railcamBrowser;
                                  KeyNavigation.down: railcamBrowser;
                                }
                PropertyChanges { target: railcamBrowser;
                                  KeyNavigation.left: chatBrowser;
                                  KeyNavigation.right: chatBrowser;
                                  KeyNavigation.up: player3;
                                  KeyNavigation.down: player1;
                                }

                PropertyChanges { target: root; showHeader: false; }
            },
            State
            {
                // Quad Screen
                name: "layout6"
                PropertyChanges { target: videoTitle1;
                                  x: 0;
                                  y: 0; width: playerArea.width / 2;
                                  height: yscale(30);
                                  visible: true }
                PropertyChanges { target: player1;
                                  x: 0;
                                  y: videoTitle1.y + videoTitle1.height + yscale(1);
                                  width: playerArea.width / 2;
                                  height: playerArea.height / 2 - yscale(30);
                                  KeyNavigation.left: chatBrowser;
                                  KeyNavigation.right: player2;
                                  KeyNavigation.up: railcamBrowser;
                                  KeyNavigation.down: player3;
                                }
                StateChangeScript { script: player1.startPlayback() }

                PropertyChanges { target: videoTitle2;
                                  x: playerArea.width / 2;
                                  y: 0;
                                  width: playerArea.width / 2;
                                  height: yscale(30);
                                  visible: true }
                PropertyChanges { target: player2;
                                  x: playerArea.width / 2;
                                  y: player1.y;
                                  width: player1.width;
                                  height: player1.height;
                                  visible: true;
                                  KeyNavigation.left: player1;
                                  KeyNavigation.right: chatBrowser;
                                  KeyNavigation.up: railcamBrowser;
                                  KeyNavigation.down: player4;
                                }
                StateChangeScript { script: player2.startPlayback() }

                PropertyChanges { target: videoTitle3;
                                  x: 0;
                                  y: player1.y + player1.height + yscale(1);
                                  width: playerArea.width / 2;
                                  height: yscale(30);
                                  visible: true;
                                }
                PropertyChanges { target: player3;
                                  x: 0;
                                  y: videoTitle3.y + videoTitle3.height + yscale(1);
                                  width: player1.width;
                                  height: player1.height;
                                  visible: true;
                                  KeyNavigation.left: chatBrowser;
                                  KeyNavigation.right: player4;
                                  KeyNavigation.up: player1;
                                  KeyNavigation.down: railcamBrowser;
                                }
                StateChangeScript { script: player3.startPlayback() }

                PropertyChanges { target: videoTitle4;
                                  x: playerArea.width / 2;
                                  y: videoTitle3.y;
                                  width: playerArea.width / 2;
                                  height: yscale(30);
                                  visible: true
                                }
                PropertyChanges { target: player4;
                                  x: playerArea.width / 2;
                                  y: player3.y;
                                  width: player1.width;
                                  height: player1.height;
                                  visible: true;
                                  KeyNavigation.left: player3;
                                  KeyNavigation.right: chatBrowser;
                                  KeyNavigation.up: player2;
                                  KeyNavigation.down: railcamBrowser;
                                }
                StateChangeScript { script: player4.startPlayback() }

                PropertyChanges { target: chatBrowser;
                                  KeyNavigation.left: player2;
                                  KeyNavigation.right: player1;
                                  KeyNavigation.up: railcamBrowser;
                                  KeyNavigation.down: railcamBrowser;
                                }
                PropertyChanges { target: railcamBrowser;
                                  KeyNavigation.left: chatBrowser;
                                  KeyNavigation.right: chatBrowser;
                                  KeyNavigation.up: player4;
                                  KeyNavigation.down: player1;
                                }

                PropertyChanges { target: root; showHeader: false; }
            }
        ]

        transitions:
        [
            Transition
            {
                from: "*"; to: "*"
                NumberAnimation
                {
                    properties: "x,y,width,height";
                    easing.type: Easing.InOutQuad;
                    duration: 1000;
                }
            }

        ]

        LabelText
        {
            id: videoTitle1
            x: 0
            y: 0
            width: 0
            height: 0
            visible: (height !== 0)
            text: "Video Title 1"

            Tracer {color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)}
        }

        MediaPlayer
        {
            id: player1
            objectName: "Player 1"
            x: 0
            y: 0
            visible: true
            width: parent.width
            height: parent.height
            enabled: visible

            onFocusChanged: if (focus) changeFocus(this);
            onPlaybackEnded: if (layout === 1) { stop(); stack.pop(); }
            onActiveFeedChanged:
            {
                if (feed.feedList.get(feed.currentFeed).title !== "")
                    videoTitle1.text = feed.feedList.get(feed.currentFeed).title;
                else
                    videoTitle1.text = feed.feedList.get(feed.currentFeed).url;
            }
            Tracer { color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)}
        }

        LabelText
        {
            id: videoTitle2
            x: parent.width / 2
            y: parent.height / 2
            width: 0
            height: 0
            visible: (width !== 0)
            text: "Video Title 2"

            Tracer {color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)}
        }

        MediaPlayer
        {
            id: player2
            objectName: "Player 2"
            x: parent.width / 2
            y: parent.height / 2
            visible: (width !== 0)
            width: 0
            height: 0
            enabled: visible

            onFocusChanged: if (focus) changeFocus(this);
            onVisibleChanged: if (!visible && focus) { focus = false; player1.focus = true; }
            onActiveFeedChanged:
            {
                if (feed.feedList.get(feed.currentFeed).title !== "")
                    videoTitle2.text = feed.feedList.get(feed.currentFeed).title;
                else
                    videoTitle2.text = feed.feedList.get(feed.currentFeed).url;
            }

            Tracer {color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)}
        }

        LabelText
        {
            id: videoTitle3
            x: parent.width / 2
            y: parent.height / 2
            width: 0
            height: 0
            visible: (width !== 0)
            text: "Video Title 3"

            Tracer {color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)}
        }

        MediaPlayer
        {
            id: player3
            objectName: "Player 3"
            x: parent.width / 2
            y: parent.height / 2
            visible: (width !== 0)
            width: 0
            height: 0
            enabled: visible

            onFocusChanged: if (focus) changeFocus(this);
            onVisibleChanged: if (!visible && focus) { focus = false; player1.focus = true; }
            onActiveFeedChanged:
            {
                if (feed.feedList.get(feed.currentFeed).title !== "")
                    videoTitle3.text = feed.feedList.get(feed.currentFeed).title;
                else
                    videoTitle3.text = feed.feedList.get(feed.currentFeed).url;
            }

            Tracer {color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)}
        }

        LabelText
        {
            id: videoTitle4
            x: parent.width / 2
            y: parent.height / 2
            width: 0
            height: 0
            visible: (width !== 0)
            text: "Video Title 4"

            Tracer {color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)}
        }

        MediaPlayer
        {
            id: player4
            objectName: "Player 4"
            x: parent.width / 2
            y: parent.height / 2
            visible: (width !== 0)
            width: 0
            height: 0
            enabled: visible

            onFocusChanged: if (focus) changeFocus(this);
            onVisibleChanged: if (!visible && focus) { focus = false; player1.focus = true; }
            onActiveFeedChanged:
            {
                if (feed.feedList.get(feed.currentFeed).title !== "")
                    videoTitle4.text = feed.feedList.get(feed.currentFeed).title;
                else
                    videoTitle4.text = feed.feedList.get(feed.currentFeed).url;
            }

            Tracer {color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)}
        }

        Tracer {}
    }

    Item
    {
        id: chat

        property bool showBorder: true

        x: xscale(5)
        y: 0
        visible: (width !== 0)
        width: 0
        height: parent.height - y - yscale(5)

        onVisibleChanged: if (!visible && chatBrowser.focus) { chatBrowser.focus = false; player1.focus = true; }

        Tracer {}

        Behavior on width { NumberAnimation { easing.type: Easing.InOutQuad; duration: 1000 }}

        LabelText
        {
            id: chatTitle
            x: 0
            y: 0
            width: parent.width
            height: yscale(30)
            text: "Chat Title"

            Tracer {}
        }

        Rectangle
        {
            id: chatRect
            x: 0
            y: chatTitle.height
            width: parent.width
            height: parent.height - y
            color: "black"
            radius: theme.bgRadius
        }

        WebEngineView
        {
            id: chatBrowser
            objectName: "Chat Browser"
            x: xscale(5)
            y: chatTitle.height + yscale(5)
            width: parent.width - xscale(10)
            height: parent.height - y - yscale(5)
            zoomFactor: xscale(1)
            focus: false
            enabled: visible
            backgroundColor: "black"
            settings.pluginsEnabled: true

            onFocusChanged: if (focus) changeFocus(this);

            profile:  WebEngineProfile
                      {
                          storageName: "MythQML"
                          offTheRecord: false
                          httpCacheType: WebEngineProfile.DiskHttpCache
                          persistentCookiesPolicy: WebEngineProfile.AllowPersistentCookies
                      }

            Tracer {}
        }

        Rectangle
        {
            id: chatBorder
            x: 0
            y: chatTitle.height
            width: parent.width
            height: parent.height - y
            color: "transparent"
            border.color: chatBrowser.focus ? theme.lvBackgroundBorderColor : theme.bgBorderColor
            border.width: chat.showBorder ? xscale(5) : 0
            radius: theme.bgRadius
        }

        InfoText
        {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            text: "No Chat Available For This Channel"
            visible: (chatBrowser.url == "about:blank")
        }
    }

    Item
    {
        id: railcam

        x: playerArea.x
        y: playerArea.y + playerArea.height
        width: playerArea.width
        height: 0
        visible: (height != 0)

        onVisibleChanged: if (!visible && railcamBrowser.focus) { railcamBrowser.focus = false; player1.focus = true; }

        Rectangle
        {
            id: railcamRect
            anchors.fill: parent
            color: "black"
            radius: theme.bgRadius
        }

        WebEngineView
        {
            id: railcamBrowser
            objectName: "RailCam Browser"
            x: xscale(5)
            y: yscale(5)
            width: parent.width - xscale(10)
            height: parent.height - yscale(10)
            zoomFactor: width / xscale(1280)
            visible: (height != 0)
            enabled: visible
            backgroundColor: "black"
            focus: false
            url: "about:blank"

            onFocusChanged: if (focus) changeFocus(this);

            settings.pluginsEnabled: true

            onLoadingChanged:
            {
                if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus)
                {
                                    zoomFactor = (height / contentsSize.height)- 0.01;
                                    zoomFactor = (height / contentsSize.height) - 0.02;
                    //                x = (parent.width - contentsSize.width) / 2;
                    //                y = parent.height - contentsSize.height - yscale(20);
                    //                width = contentsSize.width;
                    //                height = contentsSize.height;
                }
            }

            profile:  WebEngineProfile
            {
                storageName: "MythQML"
                offTheRecord: false
                httpCacheType: WebEngineProfile.DiskHttpCache
                persistentCookiesPolicy: WebEngineProfile.AllowPersistentCookies
            }
        }

        Rectangle
        {
            id: railcamBorder
            anchors.fill: parent
            color: "transparent"
            border.color: railcamBrowser.focus ? theme.lvBackgroundBorderColor : theme.bgBorderColor
            border.width: chat.showBorder ? xscale(5) : 0
            radius: theme.bgRadius
        }

        InfoText
        {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            text: "No RailCam Information Available For This Channel"
            visible: (railcamBrowser.url == "about:blank")
        }

        Tracer {}
    }
}
