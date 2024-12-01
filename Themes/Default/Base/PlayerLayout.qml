import QtQuick 2.0
import QtWebEngine 1.3
import Base 1.0
import Models 1.0

Item
{
    id: root

    x: 0
    y: 0
    width: parent.width
    height: parent.height

    property int playerLayout: 1

    property bool showHeader: false
    property bool showBrowser: false
    property bool exitOnPlaybackEnded: false

    property int browserWidth: xscale(350)
    property double browserZoom: 1.0

    property var activeItem: player1

    property alias mediaPlayer1: player1
    property alias mediaPlayer2: player2
    property alias mediaPlayer3: player3
    property alias mediaPlayer4: player4

    property alias browserTitle: browserTitle
    property alias browser: browser

    state: "fullscreen"

    onShowBrowserChanged: changeState()
    onShowHeaderChanged: changeState()
    onPlayerLayoutChanged: changePlayerLayout()
    onBrowserZoomChanged:  { browser.zoomFactor = browserZoom - 0.001; browser.zoomFactor = browserZoom; }

    function changeState()
    {
        if (!showBrowser && (playerLayout === 1 || playerLayout === 2)) // fullscreen or pip
            state = "fullscreen";
        else if (!showBrowser && playerLayout != 1)
            state = "playersonly";
        else if (showBrowser)
            state = "showBrowser";
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
            PropertyChanges { target: browserPanel; width: 0 }
            StateChangeScript { script: doShowHeader(false); }
        },
        State
        {
            name: "playersonly"
            PropertyChanges { target: root; y: yscale(50); height: parent.height - yscale(50); }
            PropertyChanges { target: browserPanel; width: 0 }
            PropertyChanges { target: playerArea; height: root.height - playerArea.y - yscale(5) }
            StateChangeScript { script: doShowHeader(true); }
        },
        State
        {
            name: "showBrowser"
            PropertyChanges { target: root; y: yscale(50); height: parent.height - yscale(50); }
            PropertyChanges { target: browserPanel; width: browserWidth }
            PropertyChanges { target: playerArea; height: root.height - playerArea.y -  yscale(5) }
            StateChangeScript { script: { doShowHeader(true); browser.focus = true; } }
        }
    ]

    function doShowHeader(show)
    {
        player1.showBorder = show;
        player1.showTitle = show;
        parent.showTitle(show)
        parent.showTime(show);

        if ((layout === 3 || layout === 4 || layout === 5) && !showBrowser)
            parent.showTicker(show);
        else
            parent.showTicker(false);
    }

    Item
    {
        id: playerArea
        x: browserPanel.width ? browserPanel.width + xscale(10) : 0
        y: 0
        width: parent.width - x
        height: parent.height

        states:
        [
            State
            {
                // fullscreen
                name: "layout1"
                PropertyChanges { target: player1;
                                  x: 0;
                                  y: 0;
                                  width: playerArea.width;
                                  height: playerArea.height;
                                  showBorder: false;
                                  showTitle: false;
                                  KeyNavigation.left: browser;
                                  KeyNavigation.right: browser;
                                  KeyNavigation.up: browser;
                                  KeyNavigation.down: browser;
                                }
                StateChangeScript { script: if ( !player1.isPlaying()) player1.play(); }

                StateChangeScript { script: player2.stop() }
                PropertyChanges { target: player2; width: 0 }

                StateChangeScript { script: player3.stop() }
                PropertyChanges { target: player3; width: 0 }

                StateChangeScript { script: player4.stop() }
                PropertyChanges { target: player4; width: 0 }

                PropertyChanges { target: browser;
                                  KeyNavigation.left: player1;
                                  KeyNavigation.right: player1;
                                  KeyNavigation.up: player1;
                                  KeyNavigation.down: player1;
                                }

                PropertyChanges { target: root; showHeader: true; }
            },
            State
            {
                // fullscreen with PIP
                name: "layout2"
                PropertyChanges { target: player1;
                                  x: 0;
                                  y: 0;
                                  width: playerArea.width;
                                  height: playerArea.height;
                                  showBorder: true;
                                  showTitle: true;
                                  KeyNavigation.left: browser;
                                  KeyNavigation.right: player2;
                                  KeyNavigation.up: player2;
                                  KeyNavigation.down: player2;
                                }
                StateChangeScript { script: if ( !player1.isPlaying()) player1.play() }

                PropertyChanges { target: player2;
                                  x: playerArea.width - (playerArea.width / 3) - xscale(50);
                                  y: yscale(50);
                                  width: playerArea.width / 3;
                                  height: player2.width / 1.77777;
                                  visible: true;
                                  KeyNavigation.left: player1;
                                  KeyNavigation.right: browser;
                                  KeyNavigation.up: player1;
                                  KeyNavigation.down: player1;
                                 }
                StateChangeScript { script: if ( !player2.isPlaying()) player2.play() }

                StateChangeScript { script: player3.stop() }
                PropertyChanges { target: player3; width: 0 }

                StateChangeScript { script: player4.stop() }
                PropertyChanges { target: player4; width: 0 }

                PropertyChanges { target: browser;
                                  KeyNavigation.left: player2;
                                  KeyNavigation.right: player1;
                                  KeyNavigation.up: player1;
                                  KeyNavigation.down: player1;
                                }

                PropertyChanges { target: root; showHeader: false; }
            },
            State
            {
                // PBP 1/2 screen
                name: "layout3"
                PropertyChanges { target: player1;
                                  x: 0;
                                  y: ((playerArea.height - player1.height) / 2) - yscale(15);
                                  width: playerArea.width / 2;
                                  height: player1.width / 1.77777;
                                  showBorder: true;
                                  showTitle: true;
                                  KeyNavigation.left: browser;
                                  KeyNavigation.right: player2;
                                  KeyNavigation.up: player2;
                                  KeyNavigation.down: player2;
                                }
                StateChangeScript { script: if ( !player1.isPlaying()) player1.play() }

                PropertyChanges { target: player2;
                                  x: player1.x + player1.width;
                                  y: ((playerArea.height - player1.height) / 2) - yscale(15)
                                  width:playerArea.width / 2;
                                  height: player1.height;
                                  visible: true;
                                  KeyNavigation.left: player1;
                                  KeyNavigation.right: browser;
                                  KeyNavigation.up: player1;
                                  KeyNavigation.down: player1;
                                }
                StateChangeScript { script: if ( !player2.isPlaying()) player2.play() }

                StateChangeScript { script: player3.stop() }
                PropertyChanges { target: player3; width: 0 }

                StateChangeScript { script: player4.stop() }
                PropertyChanges { target: player4; width: 0 }

                PropertyChanges { target: browser;
                                  KeyNavigation.left: player2;
                                  KeyNavigation.right: player1;
                                  KeyNavigation.up: player1;
                                  KeyNavigation.down: player2;
                                }

                PropertyChanges { target: root; showHeader: true; }
            },
            State
            {
                // PBP 3/4 screen with overlap
                name: "layout4"
                PropertyChanges { target: player1;
                                  x: 0;
                                  y: Math.max(0, ((playerArea.height - player1.height) / 2) - yscale(15));
                                  width: playerArea.width * 0.75;
                                  height: Math.min(player1.width / 1.77777, playerArea.height);
                                  showBorder: true;
                                  showTitle: true;
                                  KeyNavigation.left: browser;
                                  KeyNavigation.right: player2;
                                  KeyNavigation.up: player2;
                                  KeyNavigation.down: player2;
                                }
                StateChangeScript { script: if ( !player1.isPlaying()) player1.play() }

                PropertyChanges { target: player2;
                                  x: playerArea.width - player2.width;
                                  y: (playerArea.height - player2.height) / 2;
                                  width: playerArea.width / 3;
                                  height: player2.width / 1.77777;
                                  visible: true;
                                  KeyNavigation.left: player1;
                                  KeyNavigation.right: browser;
                                  KeyNavigation.up: player2;
                                  KeyNavigation.down: browser;
                                }
                StateChangeScript { script: if ( !player2.isPlaying()) player2.play() }

                StateChangeScript { script: player3.stop() }
                PropertyChanges { target: player3; width: 0 }

                StateChangeScript { script: player4.stop() }
                PropertyChanges { target: player4; width: 0 }

                PropertyChanges { target: browser;
                                  KeyNavigation.left: player2;
                                  KeyNavigation.right: player1;
                                  KeyNavigation.up: player2;
                                  KeyNavigation.down: player1;
                                }

                PropertyChanges { target: root; showHeader: false; }
            },
            State
            {
                // PBP 1 + 2
                name: "layout5"
                PropertyChanges { target: player1;
                                  x: 0;
                                  y: Math.max(0, ((playerArea.height - player1.height) / 2) - yscale(15));
                                  width: playerArea.width * 0.75;
                                  height: Math.min(player1.width / 1.77777, playerArea.height);
                                  showBorder: true;
                                  showTitle: true;
                                  KeyNavigation.left: browser;
                                  KeyNavigation.right: player2;
                                  KeyNavigation.up: browser;
                                  KeyNavigation.down: browser;
                                }
                StateChangeScript { script: if ( !player1.isPlaying()) player1.play() }

                PropertyChanges { target: player2;
                                  x: playerArea.width - player2.width;
                                  y: player1.y;
                                  width: player2.height * 1.7777;
                                  height: player1.height / 2;
                                  visible: true;
                                  KeyNavigation.left: player1;
                                  KeyNavigation.right: browser;
                                  KeyNavigation.up: browser;
                                  KeyNavigation.down: player3;
                                }
                StateChangeScript { script: if ( !player2.isPlaying()) player2.play() }

                PropertyChanges { target: player3;
                                  x: player2.x;
                                  y: player2.y + player2.height;
                                  width: player2.width;
                                  height: player2.height;
                                  visible: true;
                                  KeyNavigation.left: player1;
                                  KeyNavigation.right: browser;
                                  KeyNavigation.up: player2;
                                  KeyNavigation.down: browser;
                                }
                StateChangeScript { script: if ( !player3.isPlaying()) player3.play() }

                StateChangeScript { script: player4.stop() }
                PropertyChanges { target: player4; width: 0 }

                PropertyChanges { target: browser;
                                  KeyNavigation.left: player3;
                                  KeyNavigation.right: player1;
                                  KeyNavigation.up: player3;
                                  KeyNavigation.down: player1;
                                }

                PropertyChanges { target: root; showHeader: false; }
            },
            State
            {
                // Quad Screen
                name: "layout6"
                PropertyChanges { target: player1;
                                  x: 0;
                                  y: 0;
                                  width: playerArea.width / 2;
                                  height: playerArea.height / 2;
                                  showBorder: true;
                                  showTitle: true;
                                  KeyNavigation.left: browser;
                                  KeyNavigation.right: player2;
                                  KeyNavigation.up: browser;
                                  KeyNavigation.down: player3;
                                }
                StateChangeScript { script: if ( !player1.isPlaying()) player1.play() }

                PropertyChanges { target: player2;
                                  x: playerArea.width / 2;
                                  y: player1.y;
                                  width: player1.width;
                                  height: player1.height;
                                  visible: true;
                                  KeyNavigation.left: player1;
                                  KeyNavigation.right: browser;
                                  KeyNavigation.up: browser;
                                  KeyNavigation.down: player4;
                                }
                StateChangeScript { script: if ( !player2.isPlaying()) player2.play() }

                PropertyChanges { target: player3;
                                  x: 0;
                                  y: playerArea.height / 2;
                                  width: player1.width;
                                  height: player1.height;
                                  visible: true;
                                  KeyNavigation.left: browser;
                                  KeyNavigation.right: player4;
                                  KeyNavigation.up: player1;
                                  KeyNavigation.down: browser;
                                }
                StateChangeScript { script: if ( !player3.isPlaying()) player3.play() }

                PropertyChanges { target: player4;
                                  x: playerArea.width / 2;
                                  y: player3.y;
                                  width: player1.width;
                                  height: player1.height;
                                  visible: true;
                                  KeyNavigation.left: player3;
                                  KeyNavigation.right: browser;
                                  KeyNavigation.up: player2;
                                  KeyNavigation.down: browser;
                                }
                StateChangeScript { script: if ( !player4.isPlaying()) player4.play() }

                PropertyChanges { target: browser;
                                  KeyNavigation.left: player2;
                                  KeyNavigation.right: player1;
                                  KeyNavigation.up: browser;
                                  KeyNavigation.down: browser;
                                }

                PropertyChanges { target: root; showHeader: false; }
            }
        ]

        MediaPlayers
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
            onPlaybackEnded: if (layout === 1 && exitOnPlaybackEnded) { stop(); stack.pop(); }
            Tracer { color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)}
        }

        MediaPlayers
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
            Tracer {color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)}
        }

        MediaPlayers
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
            Tracer {color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)}
        }

        MediaPlayers
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
            Tracer {color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)}
        }

        Tracer {}
    }

    Item
    {
        id: browserPanel

        objectName: "Browser"

        property bool showBorder: true

        x: xscale(5)
        y: 0
        visible: (width !== 0)
        width: 0
        height: parent.height - y - yscale(5)

        onVisibleChanged: if (!visible && browser.focus) { browser.focus = false; player1.focus = true; }

        Tracer {}

        Behavior on width { NumberAnimation { easing.type: Easing.InOutQuad; duration: 1000 }}

        LabelText
        {
            id: browserTitle
            x: 0
            y: 0
            width: parent.width
            height: yscale(30)
            text: "Chat Title"

            Tracer {}
        }

        Rectangle
        {
            id: browserRect
            x: 0
            y: browserTitle.height
            width: parent.width
            height: parent.height - y
            color: "black"
            radius: theme.bgRadius
        }

        BaseWebBrowser
        {
            id: browser

            objectName: "Browser"
            x: xscale(5)
            y: browserTitle.height + yscale(5)
            width: parent.width - xscale(10)
            height: parent.height - y - yscale(5)
            focus: false
            enabled: visible
            mouseModeShortcut: "F5"
            backgroundColor: "black"

            onFocusChanged: if (focus) changeFocus(this);

            KeyNavigation.left: player1
            KeyNavigation.right: player1
            KeyNavigation.up: player1
            KeyNavigation.down: player1

            Tracer {}
        }

        Rectangle
        {
            id: browserBorder
            x: 0
            y: browserTitle.height
            width: parent.width
            height: parent.height - y
            color: "transparent"
            border.color: browser.focus ? theme.lvBackgroundBorderColor : theme.bgBorderColor
            border.width: browserPanel.showBorder ? xscale(5) : 0
            radius: theme.bgRadius
        }

        InfoText
        {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            text: "No Web Pages Available For This Channel"
            visible: (browser.url == "about:blank")
            multiline: true
        }
    }
}
