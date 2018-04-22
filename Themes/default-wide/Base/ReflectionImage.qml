import QtQuick 2.0

Rectangle
{
    id: reflectionContainer
    // main image
    x:800
    y:100
    width:  200; height: 200
    color: "#00000000"
    Image
    {
        id: originalImage
        source: themePath + "watermark/music.png"
        anchors.horizontalCenter: parent.horizontalCenter
    }

    // mirror image - album art and a gradient filled rectangle for darkening
    Item
    {
        width: originalImage.width; height: originalImage.height
        anchors.horizontalCenter: originalImage.horizontalCenter

        // transform this item (the image and rectangle) to create the
        // mirror image using the values from the Path
        transform :
        [
            Rotation
            {
                angle: 180; origin.y: originalImage.height
                axis.x: 1; axis.y: 0; axis.z: 0
            },
            Rotation
            {
                angle: 0; origin.x: originalImage.width/2
                //angle: PathView.rotateY; origin.x: originalImage.width/2
                axis.x: 0; axis.y: 1; axis.z: 0
            },
            Scale {
                xScale: 1; yScale: 1
                //xScale: PathView.scaleArt; yScale: PathView.scaleArt
                origin.x: originalImage.width/2; origin.y: originalImage.height/2
            }
        ]

        // mirror image
        Image
        {
            width: originalImage.width; height: originalImage.height
            source: originalImage.source
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // mirror image dimming gradient filled rectangle
        Rectangle
        {
            width: originalImage.width+4; height: originalImage.height
            anchors.horizontalCenter: parent.horizontalCenter
            gradient: Gradient
            {
                // TODO: no clue how to get the RGB component of the container rectangle color
                GradientStop { position: 1.0; color: Qt.rgba(1,1,1,0.4) }
                GradientStop { position: 0.3; color: reflectionContainer.color }
            }
        }
    }
}
