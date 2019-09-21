import QtQuick 2.0

FocusScope
{
    property alias text: editText.text

    signal textHasChanged();

    x: 0; y: 0; width: xscale(400); height: yscale(200)
    focus: false
    state: "normal"

    states:
    [
        State
        {
            name: "normal"
            PropertyChanges
            {
                target: editText;
                color: theme.txTextColorNormal;
            }
            PropertyChanges
            {
                target: background;
                gradient: theme.gradientNormal();
                border.color: theme.btBorderColorNormal;
            }
            PropertyChanges
            {
                target: textBackground;
                gradient: theme.gradientShaded(theme.txTextBackgroundColorNormal, Qt.lighter(theme.txTextBackgroundColorNormal, 1.5));
            }
        },
        State
        {
            name: "focused"
            PropertyChanges
            {
                target: editText;
                color: theme.txTextColorFocused;
            }
            PropertyChanges
            {
                target: background;
                gradient: theme.gradientFocused();
                border.color: theme.btBorderColorFocused;
            }
            PropertyChanges
            {
                target: textBackground;
                gradient: theme.gradientShaded(theme.txTextBackgroundColorFocused, Qt.lighter(theme.txTextBackgroundColorFocused, 1.5));
            }
        },
        State
        {
            name: "disabled"
            PropertyChanges
            {
                target: editText;
                color: theme.btTextColorDisabled;
            }
            PropertyChanges
            {
                target: background;
                gradient: theme.gradientDisabled();
                border.color: theme.btBorderColorDisabled;
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

    Keys.onReturnPressed: textHasChanged();

    Rectangle
    {
        id: background
        anchors {fill: parent; margins: 0}
        gradient: theme.gradientNormal();
        border.width: theme.btBorderWidth
        border.color: theme.btBorderColorNormal
        radius: theme.btBorderRadius
    }

    Rectangle
    {
        id: textBackground
        anchors {fill: parent; margins: 6}
        color: theme.txTextBackgroundColorNormal
        radius: theme.btBorderRadius
    }

    Flickable {
        id: flick

        anchors {fill: parent; margins: 10}
        contentWidth: editText.paintedWidth
        contentHeight: editText.paintedHeight
        clip: true

        function ensureVisible(r)
        {
            if (contentX >= r.x)
                contentX = r.x;
            else if (contentX+width <= r.x+r.width)
                contentX = r.x+r.width-width;
            if (contentY >= r.y)
                contentY = r.y;
            else if (contentY+height <= r.y+r.height)
                contentY = r.y+r.height-height;
        }
        TextEdit
        {
            id: editText
            focus: true
            clip: false
            width: flick.width
            height: flick.height
            onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
            wrapMode: TextEdit.WordWrap
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignTop
            font.family: "Helvetica"
            font.pointSize: 20
            color: theme.txTextColorNormal
        }
    }
}

