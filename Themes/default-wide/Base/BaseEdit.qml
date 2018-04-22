import QtQuick 2.7

FocusScope
{
    id: root
    property alias text: editText.text

    signal textEdited();
    signal editingFinished()

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

    TextInput
    {
        id: editText
        focus: true
        clip: true
        anchors {fill: parent; margins: 6}
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        font.family: "Helvetica"
        font.pointSize: 20
        color: theme.txTextColorNormal

        Keys.onReturnPressed: root.editingFinished();
        onTextChanged: root.textEdited()

    }
}

