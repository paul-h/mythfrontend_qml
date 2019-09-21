import QtQuick 2.4

Column
{
    width: parent.width
    height: parent.height

    property alias model: columnRepeater.model

    Repeater
    {
        id: columnRepeater
        delegate: accordion
    }

    Component
    {
        id: accordion
        Column
        {
            width: parent.width

            Item
            {
                id: infoRow

                width: parent.width
                height: childrenRect.height
                property bool expanded: false

                MouseArea
                {
                    anchors.fill: parent
                    onClicked: infoRow.expanded = !infoRow.expanded
                    enabled: modelData.children ? true : false
                }

                Image
                {
                    id: carot

                    anchors
                    {
                        top: parent.top
                        left: parent.left
                        margins: 5
                    }

                    sourceSize.width: 16
                    sourceSize.height: 16
                    source: '../images/triangle.svg'
                    visible: modelData.children ? true : false
                    transform: Rotation
                    {
                        origin.x: 5
                        origin.y: 10
                        angle: infoRow.expanded ? 90 : 0
                        Behavior on angle { NumberAnimation { duration: 150 } }
                    }
                }

                Text
                {
                    anchors
                    {
                        left: carot.visible ? carot.right : parent.left
                        top: parent.top
                        margins: 5
                    }

                    font.pointSize: 12
                    visible: parent.visible

                    color: 'white'
                    text: modelData.label
                }

                Text
                {
                    font.pointSize: 12
                    visible: infoRow.visible

                    color: 'white'
                    text: modelData.value

                    anchors
                    {
                        top: parent.top
                        right: parent.right
                        margins: 5
                    }
                }
            }

            ListView
            {
                id: subentryColumn
                x: 20
                width: parent.width - x
                height: childrenRect.height * opacity
                visible: opacity > 0
                opacity: infoRow.expanded ? 1 : 0
                delegate: accordion
                model: modelData.children ? modelData.children : []
                interactive: false
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }
}

