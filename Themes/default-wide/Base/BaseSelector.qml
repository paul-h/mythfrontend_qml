import QtQuick 2.0

FocusScope
{
    id: root

    property alias model: selectorList.model
    property bool showBackground: true
    property int pageCount: 10
    property alias currentIndex: selectorList.currentIndex;

    signal itemSelected(int index);
    signal itemClicked(int index);

    x: 0; y: 0; width: xscale(200); height: yscale(50)
    focus: false

    state: "normal"
    states:
    [
        State
        {
            name: "normal"
            PropertyChanges
            {
                target: background;
                gradient: theme.gradientNormal();
                border.color: theme.btBorderColorNormal;
            }
            PropertyChanges
            {
                target: upButton;
                source: mythUtils.findThemeFile("images/grey_fastforward.png");
            }
            PropertyChanges
            {
                target: downButton;
                source: mythUtils.findThemeFile("images/grey_rewind.png");
            }
        },
        State
        {
            name: "focused"
            PropertyChanges
            {
                target: background;
                gradient: theme.gradientSelected();
                border.color: theme.btBorderColorSelected;
            }
            PropertyChanges
            {
                target: upButton;
                source: mythUtils.findThemeFile("images/fastforward.png");
            }
            PropertyChanges
            {
                target: downButton;
                source: mythUtils.findThemeFile("images/rewind.png");
            }
        },
        State
        {
            name: "disabled"
            PropertyChanges
            {
                target: background;
                gradient: theme.gradientDisabled();
                border.color: theme.btBorderColorDisabled;
            }
            PropertyChanges
            {
                target: upButton;
                source: mythUtils.findThemeFile("images/grey_fastforward.png");
            }
            PropertyChanges
            {
                target: downButton;
                source: mythUtils.findThemeFile("images/grey_rewind.png");
            }
        },
        State
        {
            name: "pushed"
            PropertyChanges
            {
                target: background;
                gradient: theme.gradientFocusedSelected();
                border.color: theme.btBorderColorFocusedSelected;
            }
            PropertyChanges
            {
                target: upButton;
                source: mythUtils.findThemeFile("images/grey_fastforward.png");
            }
            PropertyChanges
            {
                target: downButton;
                source: mythUtils.findThemeFile("images/grey_rewind.png");
            }
        }
    ]

    function updateState()
    {
        if (!enabled)
            state = "disabled";
        else if (focus)
            state = "focused";
        else
            state = "normal";
    }

    onFocusChanged: updateState()
    onEnabledChanged: updateState()

    Timer
    {
        id: pushTimer
        interval: 250; running: false;
        onTriggered: updateState();
    }

    Component
    {
        id: selectorRow

        Item
        {
            width: selectorList.width; height: selectorList.height
            property bool selected: ListView.isCurrentItem
            property bool focused: root.focus

            ListText
            {
                anchors.fill: parent
                text: itemText
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Image
    {
        id: downButton
        x: 0; y: yscale(5); width: xscale(40); height: yscale(40)
        source: mythUtils.findThemeFile("images/rewind.png")
    }

    Rectangle
    {
        id: background
        visible: showBackground
        x: xscale(45); y: 0; width: parent.width - xscale(90); height: parent.height
        gradient: theme.gradientNormal();
        border.width: theme.btBorderWidth
        border.color: theme.btBorderColorNormal
        radius: theme.btBorderRadius
    }

    Image
    {
        id: upButton
        x: parent.width - xscale(40); y: yscale(5); width: xscale(40); height: yscale(40)
        source: mythUtils.findThemeFile("images/fastforward.png")
    }

    ListView
    {
        id: selectorList

        anchors.fill: background
        orientation: ListView.Horizontal
        clip: true
        delegate: selectorRow
        focus: true

        Keys.onPressed:
        {
            if (event.key === Qt.Key_PageDown)
            {
                currentIndex = currentIndex + pageCount >= model.count ? model.count - 1 : currentIndex + pageCount;
                event.accepted = true;
            }
            else if (event.key === Qt.Key_PageUp)
            {
                currentIndex = currentIndex - pageCount < 0 ? 0 : currentIndex - pageCount;
                event.accepted = true;
            }
            else if (event.key === Qt.Key_Greater)
            {
                currentIndex = currentIndex + 1 >= model.count ? model.count - 1 : currentIndex + 1;
                event.accepted = true;
            }
            else if (event.key === Qt.Key_Less)
            {
                currentIndex = currentIndex - 1 < 0 ? 0 : currentIndex - 1;
                event.accepted = true;
            }
        }

        Keys.onReturnPressed:
        {
            returnSound.play();
            root.state = "pushed"
            pushTimer.start();
            itemClicked(currentIndex);
        }

        onCurrentItemChanged: itemSelected(currentIndex)
    }

    function selectNext()
    {
        selectorList.currentIndex = selectorList.currentIndex + 1 >= selectorList.model.count ? selectorList.model.count - 1 : selectorList.currentIndex + 1;
    }

    function selectPrevious()
    {
        selectorList.currentIndex = selectorList.currentIndex - 1 < 0 ? 0 : selectorList.currentIndex - 1;
    }

    function selectItem(item)
    {
        for (var x = 1; x < model.count; x++)
        {
            if (model.get(x).itemText == item)
            {
                selectorList.positionViewAtIndex(x, ListView.Beginning);
                selectorList.currentIndex = x;
                return;
            }
        }

        // didn't find it so default to the first item
        selectorList.positionViewAtIndex(0, ListView.Beginning);
        selectorList.currentIndex = 0;
    }
}

