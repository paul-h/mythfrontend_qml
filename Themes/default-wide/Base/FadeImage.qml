import QtQuick 2.0

Item
{
    id: root
    property alias source: image1.source
    property bool image1Active: true

    Image
    {
        id: image1
        source: ""
        anchors.fill: parent
        opacity: 1

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
        opacity: 0
        //visible: false

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
        image1Active = !image1Active;

        if (image1Active)
        {
            image1.source = newImage;
            image1.opacity = 1;
            image2.opacity = 0;
            image1.scale = 1;
            image2.scale = 0;
        }
        else
        {
            image2.source = newImage;
            image1.opacity = 0;
            image2.opacity = 1;
            image1.scale = 0;
            image2.scale = 1;
        }
    }
}
