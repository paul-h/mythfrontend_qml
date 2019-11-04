import QtQuick 2.5
import QtQuick.XmlListModel 2.0
import QtGraphicalEffects 1.0


Item
{
    id: root

    x: 0
    y: parent.height - height
    width: parent.width
    height: yscale(32)

    property string defaultImage: mythUtils.findThemeFile("images/rss.png") // default image if RSS entry has no image
    property var feedType: ["atom"]
    property var urls: []
    property var namespaces: ["http://www.w3.org/2005/Atom"]
    property bool showTitle: true
    property bool showDescription: true
    property int scrollSpeed: 50          // ms per letter
    property int scrollTime: 0            // if 0, time will be calculated using scrollSpeed
    property int flipDuration: 1000       // duration of the flip animation
    property int fetchInterval: 3600000   // fetch feeds every hour

    property bool autoLoop: true
    property var rssLists: []
    property var frontItem
    property var backItem
    property int index: -1
    property int listIndex: 0
    property bool flipReady: false
    property bool running: false
    property bool entriesAvailable: false

    function scenePreload()
    {
        var o

        // create objects that will fetch and parse the RSS feeds
        for (var i = 0; i < urls.length; i++)
        {
            if (feedType[i] == "rss")
            {
                o = rssEntryTemplate.createObject(root,
                                                  {
                                                      "source": urls[i],
                                                      "query" : "/rss/channel/item",
                                                      "namespaceDeclarations": "declare namespace content = '" + namespaces[i] + "';"
                                                  })
            }
            else
            {
                o = atomEntryTemplate.createObject(root,
                                                   {
                                                       "source": urls[i],
                                                       "query" : "/feed/entry",
                                                       "namespaceDeclarations": "declare default element namespace '" + namespaces[i] + "';"
                                                   })
            }
            root.rssLists.push(o)
        }
    }

    function sceneStart()
    {
        if (autoLoop)
        {
            running = true
            if (entriesAvailable && flipReady)
                flip()
        }
    }

    function scenePause()
    {
        running = false
    }

    Component.onCompleted:
    {
        if (root.autoStart)
        {
            running = true
            scenePreload()
        }
    }

    // set text and image
    function fillPlate(plate)
    {
        // show both title and decription
        if (root.showTitle && root.showDescription)
            plate.text = rssLists[listIndex].get(index).title + " ~ " + rssLists[listIndex].get(index).description

        // show title only
        if (root.showTitle && !root.showDescription)
            plate.text = rssLists[listIndex].get(index).title

        // show description only
        if (root.showDescription && !root.showDescription)
            plate.text = rssLists[listIndex].get(index).description

        // show neither title or description!
        if (!root.showTitle && !root.showDescription)
            plate.text = rssLists[listIndex].get(index).title

        if (rssLists[listIndex].get(index).enclosure && rssLists[listIndex].get(index).enclosure != "")
            plate.img = rssLists[listIndex].get(index).enclosure
        else
            plate.img = defaultImage

        if (plate.img == "")
            plate.img = defaultImage
    }

    function getNextIndex()
    {
        if (rssLists.length == 0)
            return false

        // get next RSS entry
        index++;
        if (index >= rssLists[listIndex].count)
        {
            listIndex++;
            if (listIndex >= urls.length)
                listIndex = 0
            index = 0;
        }

        if (rssLists[listIndex].count == 0)
        {
            var stopAt = listIndex

            listIndex++
            for ( ; listIndex != stopAt; listIndex++)
            {
                if (listIndex >= urls.length)
                {
                    listIndex = -1
                    continue
                }
                if (rssLists[listIndex].count > 0)
                    break
            }

            if (listIndex == stopAt)
            {
                console.log(root.type + ": error, no entry found")
                return false
            }

            index = 0;
        }

        return true
    }

    // init widget
    function init()
    {
        frontItem = plates.itemAt(0)
        backItem = plates.itemAt(1)

        if (getNextIndex() == false)
            return

        fillPlate(backItem)

        root.flipReady = true
        if (root.running)
            flip();
    }

    // flip plates
    function flip()
    {
        if (getNextIndex() == false)
            return

        root.flipReady = false

        frontItem.z = 1
        frontItem.angle = 90 // swing down current plate

        // swap front/back plate
        var o = frontItem
        frontItem = backItem
        backItem = o

        frontItem.visible=1 // make next plate visible
        frontItem.z = 2
        frontItem.angle = 0 // swing up next plate
    }

    // white background
    Rectangle
    {
        anchors.fill: parent;
        color: "#ffffff";
        opacity: 0.7
    }

    // top border line
    Rectangle
    {
        z: 2
        width: parent.width
        height: 1
        color: "#999999"
    }

    // background gradient bright to dark
    LinearGradient
    {
        z: 1
        opacity: 0.5
        anchors.fill: parent

        start: Qt.point(0, 0)
        end: Qt.point(0, parent.height)

        gradient: Gradient
        {
            GradientStop { position: 0.0; color: "#cccccc" }
            GradientStop { position: 1.0; color: "black" }
        }
    }

    /* normally the end of the scrolling animation will trigger a flip
     * if scrolling is not necessary, this timer will be started and trigger
     * a flip
     */
    Timer
    {
        id: flipTimer
        running: false
        repeat: false

        onTriggered: flip()
    }

    // timer that reloads the feeds
    Timer
    {
        interval: root.fetchInterval; running: true; repeat: true
        onTriggered:
        {
            console.log("reload feeds")

            for (var i = 0; i < rssLists.length; i++)
            {
                rssLists[i].source = ""
                rssLists[i].source = root.urls[i]
            }

            getNextIndex()
        }
    }

    // make two out of one plate prototype
    Repeater
    {
        id: plates
        model: 2

        Item
        {
            id: plate

            height: parent.height
            width: parent.width
            x: 0
            y: 0
            z: 1

            visible: false
            opacity: 1

            property alias angle: rotTransform.angle
            property alias text: tickerText.text
            property alias img: thumbnail.source

            Rectangle
            {
                id: imageBackground

                y:1
                height:parent.height - yscale(2)
                width: parent.height + xscale(10)
                color: "#ffffff"

                // background gradient
                LinearGradient
                {
                    opacity: 0.5
                    anchors.fill: parent

                    start: Qt.point(0, 0)
                    end: Qt.point(0, parent.height)

                    gradient: Gradient
                    {
                        GradientStop { position: 0.0; color: "white" }
                        GradientStop { position: 1.0; color: "#666666" }
                    }
                }

                // thumbnail of the RSS entry
                Image
                {
                    id: thumbnail

                    x: xscale(10)
                    y: yscale(5)
                    height: parent.height - yscale(10)
                    width: parent.height - xscale(10)

                    fillMode: Image.PreserveAspectFit
                }
            }

            // line between image and text area
            Rectangle
            {
                id: line
                width: 1
                height: parent.height
                anchors.left: imageBackground.right
                color: "#666666"
            }

            // item encloses and clips the scrolling text
            Item
            {
                id: tickerTextCanvas

                anchors.left: line.right
                anchors.leftMargin: xscale(5)
                anchors.rightMargin: xscale(10)
                y: 0
                width: parent.width - x - xscale(5)
                height: parent.height

                clip: true

                // item that adds a linear gradient over the movable text
                // this item will be moved to the left in order to keep
                // the text and the opacitymask in sync
                Item
                {
                    id: tickerTextBox
                    height: parent.height
                    width: parent.width
                    x: 10
                    Text
                    {
                        id: tickerText

                        anchors.fill: parent
                        anchors.rightMargin: xscale(10)
                        color: "red"
                        // visible:false
                        font.pixelSize: parent.height - xscale(6)
                        verticalAlignment: Text.AlignVCenter

                        onTextChanged:
                        {
                            tickerTextBox.width = tickerText.contentWidth
                        }
                    }

                    /*
                     * gradient disabled due to rendering problems on the RPi
                     */

                    // gradient from gray to black
                    LinearGradient
                    {
                        id: textGradient

                        anchors.fill: parent
                        anchors.rightMargin: xscale(10)

                        visible: false
                        opacity: 0.5

                        start: Qt.point(0, 0)
                        end: Qt.point(0, parent.height)

                        gradient: Gradient
                        {
                            GradientStop { position: 0.0; color: "#888888" }
                            GradientStop { position: 1.0; color: "red" }
                        }
                    }

                    // blend text with gradient
                    OpacityMask
                    {
                        id: mask2

                        anchors.fill: parent
                        anchors.rightMargin: xscale(10)

                        source: textGradient
                        maskSource: tickerText
                    }

                    // animation if text is larger than width of text display
                    Behavior on x
                    {
                        id: textBehavior
                        SequentialAnimation
                        {
                            NumberAnimation
                            {
                                id: textBehaviorAnim

                                easing.type: Easing.InOutSine;

                            }

                            PauseAnimation
                            {
                                duration: 2500
                            }

                            onRunningChanged:
                            {
                                if (this.running == false)
                                {
                                    if (root.running && root.autoLoop)
                                        root.flip()
                                    else
                                        root.flipReady = true
                                }
                            }
                        }

                    }
                }
            }

            transform: Rotation
            {
                id: rotTransform

                origin.x: parent.width/2
                origin.y: root.height
                axis { x: 1; y: 0; z: 0 }
                angle: -90

                Behavior on angle
                {
                    RotationAnimation
                    {
                        duration: root.flipDuration
                        direction: RotationAnimator.Clockwise

                        onRunningChanged:
                        {
                            // reset plate?
                            if (this.running == false && plate.transform[0].angle == 90)
                            {
                                plate.visible = 0

                                // reset position
                                plate.transform[0].angle = -90

                                // next RSS entry
                                fillPlate(plate)

                                // reset scrolling
                                textBehavior.enabled = false
                                tickerTextBox.x = 10
                                textBehavior.enabled = true
                            }

                            // start scrolling?
                            if (this.running == false && plate.transform[0].angle == 0)
                            {
                                // do we need to scroll?
                                if (tickerText.contentWidth > tickerTextCanvas.width)
                                {
                                    if (root.scrollTime == 0)
                                    {
                                        // adjust scroll duration according to text length
                                        textBehaviorAnim.duration = tickerText.text.length * root.scrollSpeed
                                    }
                                    else
                                    {
                                        textBehaviorAnim.duration = root.scrollTime
                                    }

                                    // calculate scrolling distance plus margin
                                    tickerTextBox.x = (tickerTextCanvas.width - tickerText.contentWidth) - xscale(20) //tickerTextCanvas.width/10
                                }
                                else
                                {
                                    if (root.autoLoop)
                                    {
                                        if (root.scrollTime == 0)
                                        {
                                            // adjust scroll duration according to text length
                                            flipTimer.interval = tickerText.text.length * root.scrollSpeed
                                        }
                                        else
                                        {
                                            flipTimer.interval = root.scrollTime
                                        }

                                        flipTimer.running = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // template for the XmlListModel that will fetch and parse a RSS feed for us
    Component
    {
        id: rssEntryTemplate

        XmlListModel
        {
            id: listModel
            XmlRole {name: "title"; query: "title/string()"}
            XmlRole {name: "description"; query: "description/string()"}
            // image URL
            XmlRole {name: "enclosure"; query: "enclosure/@url/string()"}

            onCountChanged:
            {
                if (root.entriesAvailable == false)
                {
                    root.entriesAvailable = true
                    root.init()
                }
            }
        }
    }

    Component
    {
        id: atomEntryTemplate

        XmlListModel
        {
            XmlRole {name: "title"; query: "title/string()"}
            XmlRole {name: "description"; query: "summary/string()"}
            // image URL
            XmlRole {name: "enclosure"; query: "enclosure/@url/string()"}

            onCountChanged:
            {
                if (root.entriesAvailable == false)
                {
                    root.entriesAvailable = true
                    root.init()
                }
            }
        }
    }
}
