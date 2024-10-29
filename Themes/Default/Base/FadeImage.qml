import QtQuick

Item
{
    id: root
    property alias source: image1.source
    property bool doFade: true
    property bool doScale: true

    property bool _image1Active: true

    Image
    {
        id: image1
        source: ""
        anchors.fill: parent
        opacity: 1
        visible: root.visible

        onStatusChanged: if (status == Image.Ready) doSwapImage();

        Behavior on opacity
        {
            NumberAnimation
            {
                duration: 300
            }
        }
        Behavior on scale
        {
            NumberAnimation
            {
                duration: 300
                easing
                {
                    type: Easing.OutBack
                    //amplitude: 1.0
                    //period: 0.5
                }
            }
        }
    }

    Image
    {
        id: image2
        source: ""
        anchors.fill: parent
        opacity: if (doFade) 0; else 1;
        visible: root.visible

        onStatusChanged: if (status == Image.Ready) doSwapImage();

        Behavior on opacity
        {
            NumberAnimation
            {
                duration: 300
            }
        }
        Behavior on scale
        {
            NumberAnimation
            {
                duration: 300
                easing
                {
                    type: Easing.OutBack
                    //amplitude: 1.0
                    //period: 0.5
                }
            }
        }
    }

    function swapImage(newImage)
    {
        if (!root.visible)
            return;

        _image1Active = !_image1Active;

        if (_image1Active)
        {
            image1.source = newImage;
        }
        else
        {
            image2.source = newImage;
        }
    }

    function doSwapImage(newImage)
    {
        if (!root.visible)
            return;

        if (_image1Active)
        {
            if (doFade)
            {
                image1.opacity = 1;
                image2.opacity = 0;
            }
            else
            {
                image1.visible = true
                image2.visible = false
            }

            if (doScale)
            {
                image1.scale = 1;
                image2.scale = 0;
            }

            image2.source = "";
        }
        else
        {
            if (doFade)
            {
                image1.opacity = 0;
                image2.opacity = 1;
            }
            else
            {
                image2.visible = true
                image1.visible = false
            }

            if (doScale)
            {
                image1.scale = 0;
                image2.scale = 1;
            }

            image1.source = "";
        }
    }
}
