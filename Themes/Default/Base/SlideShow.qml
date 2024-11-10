import QtQuick
import Qt.labs.folderlistmodel

Rectangle
{
    id: root

    //Slideshow options :
    property alias folder: folderModel.folder
    property int slideDuration: 28000 //ms
    property int fadeDuration: 8000
    property bool doShuffle: true
    property bool doZoom: true
    property bool doFade: true
    property bool doMove: true

    property alias currentIndex: folderModel.index

    signal imageChanged(int index)

    width: xscale(1280)
    height: yscale(720)
    color: "black"
    clip: true

    // Load 2 slides
    Loader { id:img1; transformOrigin: Item.TopLeft; sourceComponent: slide; }
    Loader { id:img2; transformOrigin: Item.TopLeft; sourceComponent: slide; }
    property variant currentImg: img1

    // Input images files
    FolderListModel
    {
        id: folderModel

        folder: ""
        nameFilters: ["*.jpg", "*.jpeg", "*.png"]
        showDirs : false

        property int index: 0
        property variant rlist: []

        function getNextUrl()
        {
            if (index >= rlist.length)
                shuffleList();
            else
                index++;

            return folderModel.get(rlist[index], "fileURL");
        }

        // Fisher-Yates shuffle algorithm.
        function shuffleArray(array)
        {
            for (var i = array.length - 1; i > 0; i--)
            {
                var j = Math.floor(Math.random() * (i + 1));
                var temp = array[i];
                array[i] = array[j];
                array[j] = temp;
            }

            return array;
        }

        function shuffleList()
        {
            var list = [];
            for (var i = 0; i < folderModel.count; i++)
                list.push(i);

            if (doShuffle)
                shuffleArray(list);

            rlist = list;
            index = 0;
        }

        onStatusChanged:
        {
            if (status == FolderListModel.Ready)
            {
                if (count === 0)
                {
                    mtimer.stop();
                    return;
                }

                shuffleList();
                img1.item.asynchronous = false
                img1.item.source = folderModel.get(rlist[index], "fileURL")
                img1.item.fadein();
                img2.item.loadNextSlide();
                img1.item.asynchronous = true;

                if (root.visible)
                    mtimer.start();
            }
        }
    }

    // Main timer
    Timer
    {
        id: mtimer
        running: root.visible
        interval: slideDuration - fadeDuration
        repeat: true
        triggeredOnStart: true

        onTriggered:
        {
            currentImg.item.fadein();
            currentImg = (currentImg == img1 ? img2 : img1); //Swap img
            currentImg.item.fadeout();
        }
    }

    // Slide component
    Component
    {
        id: slide

        Image
        {
            id: img
            asynchronous: true
            cache: false
            fillMode: Image.PreserveAspectFit
            opacity: 0
            width: root.width
            height: root.height

            // Max painted size (RPI limitations)
            sourceSize.width: xscale(1280)
            sourceSize.height: yscale(720)

            property real from_scale: 1
            property real to_scale: 1

            property real from_x: 0
            property real to_x: 0

            property real from_y: 0
            property real to_y: 0

            function randRange(a, b){return Math.random()*Math.abs(a-b) + Math.min(a,b);}
            function randChoice(n){return Math.round(Math.random()*(n-1));}
            function randDirection(){return (Math.random() >= 0.5) ? 1 : -1;}

            function fadein()
            {
                //Check image loading...
                if (status != Image.Ready)
                {
                    console.log("LOAD ERROR: " + source);
                    return;
                }

                //Fit in view
                var img_ratio = paintedWidth / paintedHeight;
                var scale = (height == paintedHeight) ? width / paintedWidth : height / paintedHeight;

                //Find random directions
                if (img_ratio < 1)
                {
                    //Rotated
                    from_scale = scale * 0.8;//Un-zoom on 16/9 viewer...
                    to_scale = from_scale;
                    from_y = 0;
                    to_y = 0;
                    from_x = randDirection() * (paintedHeight * from_scale-height) / 2;
                    to_x = 0;
                }
                else if (img_ratio > 2)
                {
                    //Panorama
                    from_scale = scale;
                    to_scale = from_scale;
                    from_y = randDirection() * (paintedWidth * from_scale - width) / 2;
                    to_y = -from_y;
                    from_x = 0;
                    to_x = 0;
                }
                else
                {
                    //Normal
                    var type = randChoice(3);
                    switch(type)
                    {
                        case 0:
                            //Zoom in

                            from_scale = scale;
                            to_scale = scale * 1.4;
                            from_y = 0;
                            to_y = 0;
                            from_x = 0;
                            to_x = 0;
                            break;
                        case 1:
                            //Zoom out
                            from_scale = scale * 1.4;
                            to_scale = scale;
                            from_y = 0;
                            to_y = 0;
                            from_x = 0;
                            to_x = 0;
                            break;
                        default:
                            //Fixed zoom
                            from_scale = scale * 1.2;
                            to_scale = from_scale;
                            break;
                    }

                    //Random x,y
                    var from_max_y = (paintedWidth * from_scale - width) / 2;
                    var to_max_y = (paintedWidth * to_scale-width) / 2;
                    from_y = randRange(-from_max_y, from_max_y);
                    to_y = randRange(-to_max_y, to_max_y);

                    var from_max_x = (paintedHeight * from_scale-height) / 2;
                    var to_max_x = (paintedHeight * to_scale - height) / 2;
                    from_x = randRange(-from_max_x, from_max_x);
                    to_x = randRange(-to_max_x, to_max_x);
                }

                if (!doZoom)
                {
                    from_scale = 1.0;
                    to_scale = 1.0;
                }

                if (!doMove)
                {
                    from_x = 0;
                    to_x = 0;
                    from_y = 0;
                    to_y = 0;
                }

                visible = true;
                afadein.start();
            }

            function fadeout()
            {
                afadeout.start();
            }

            function loadNextSlide()
            {
                visible = false;
                source = folderModel.getNextUrl();
            }

            ParallelAnimation
            {
                id: afadein
                NumberAnimation {target: img; property: "opacity"; from: doFade ? 0 : 1; to: 1; duration: fadeDuration; easing.type: Easing.InOutQuad;}
                NumberAnimation {target: img; property: "y"; from: from_x; to: to_x; duration: slideDuration; }
                NumberAnimation {target: img; property: "x"; from: from_y; to: to_y; duration: slideDuration; }
                NumberAnimation {target: img; property: "scale"; from: from_scale; to: to_scale; duration: slideDuration; }
                onStarted:
                {
                    // send image changed signal
                    root.imageChanged(folderModel.index);
                }
            }

            SequentialAnimation
            {
                id: afadeout;
                NumberAnimation{ target: img; property: "opacity"; from: 1; to: 0; duration: fadeDuration; easing.type: Easing.InOutQuad;}
                ScriptAction { script: img.loadNextSlide(); }
            }
        }
    }
}
