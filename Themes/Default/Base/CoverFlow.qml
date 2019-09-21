import QtQuick 2.0

Rectangle {
    id: coverFlow
    property int itemWidth: 100
    property int itemHeight: 100
    property ListModel listModel
    signal indexChanged(int index)
    Component {
        id: appDelegate
        Flipable {
            id: myFlipable
            property bool flipped: false
            width: itemWidth; height: itemHeight
            z: PathView.z
            scale: PathView.iconScale
            function itemClicked()
            {
                if (PathView.isCurrentItem) {
                    myFlipable.flipped = !myFlipable.flipped
                    myPathView.interactive = !myFlipable.flipped
                }
                else if (myPathView.interactive) {
                    myPathView.currentIndex = index
                }
            }
            Keys.onReturnPressed: itemClicked()
            MouseArea {
                anchors.fill: parent
                onClicked: itemClicked()
            }
            transform: Rotation {
                id: rotation
                origin.x: myFlipable.width/2
                origin.y: myFlipable.height/2
                axis.x: 0; axis.y: 1; axis.z: 0
                angle: PathView.angle
            }
            states: State {
                name: "back"
                PropertyChanges {target: rotation; angle: 180}
                PropertyChanges {target: myFlipable; width: myPathView.width; height: myPathView.height}
                when: myFlipable.flipped
            }
            transitions: Transition {
                ParallelAnimation {
                    NumberAnimation {target: rotation; property: "angle"; duration: 250}
                    NumberAnimation {target: myFlipable; properties: "height,width"; duration: 250}
                }
            }
            front: Rectangle {
                smooth: true
                width: itemWidth; height: itemHeight
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: "black"
                border.color: "white"
                border.width: 3
                Image {
                    id: myIcon
                    anchors.centerIn: parent
                    source: icon
                    smooth: true
                }
            }
            back: Rectangle {
                anchors.fill: parent
                color: "black"
                Text {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.fill: parent
                    color: "white"
                    text: "This is the back view for " + name
                }
            }
        }
    }
    PathView {
        id: myPathView
        Keys.onRightPressed: if (!moving && interactive) incrementCurrentIndex()
        Keys.onLeftPressed: if (!moving && interactive) decrementCurrentIndex()
        anchors.fill: parent
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        focus: true
        interactive: true
        model: listModel
        delegate: appDelegate
        path: Path {
            startX: 0
            startY: coverFlow.height / 2
            PathAttribute { name: "z"; value: 0 }
            PathAttribute { name: "angle"; value: 60 }
            PathAttribute { name: "iconScale"; value: 0.5 }
            PathLine { x: coverFlow.width / 2; y: coverFlow.height / 2;  }
            PathAttribute { name: "z"; value: 100 }
            PathAttribute { name: "angle"; value: 0 }
            PathAttribute { name: "iconScale"; value: 1.0 }
            PathLine { x: coverFlow.width; y: coverFlow.height / 2; }
            PathAttribute { name: "z"; value: 0 }
            PathAttribute { name: "angle"; value: -60 }
            PathAttribute { name: "iconScale"; value: 0.5 }
        }
    }

    Component.onCompleted: {
        myPathView.currentIndexChanged.connect(function(){
            indexChanged(myPathView.currentIndex);
        })
    }
}
