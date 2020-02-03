import QtQuick 2.0

Item
{
    x: xscale(30); y: yscale(682); width: xscale(1280 - 60); height: yscale(32)

    property alias redText: red.text
    property alias greenText: green.text
    property alias yellowText: yellow.text
    property alias blueText: blue.text

    Item
    {
        // red
        x: 0
        y: 0
        width: parent.width / 4
        height: parent.height

        Image
        {
            id: redImage
            x: 0; y: 0; width: xscale(32); height: yscale(32)
            source: mythUtils.findThemeFile("images/red_bullet.png")
        }

        InfoText
        {
            id: red
            x: redImage.x + redImage.width + xscale(5)
            y: 0;
            width: parent.width - x - xscale(5)
            height: parent.height
            text: ""
        }
    }

    Item
    {
        // green
        x: parent.width / 4
        y: 0
        width: parent.width / 4
        height: parent.height

        Image
        {
            id: greenImage
            x: 0
            y: 0
            width: xscale(32)
            height: yscale(32)
            source: mythUtils.findThemeFile("images/green_bullet.png")
        }

        InfoText
        {
            id: green
            x: greenImage.x + greenImage.width + xscale(5)
            y: 0
            width: parent.width - x - xscale(5)
            height: parent.height
            text: ""
        }
    }

    Item
    {
        // yellow
        x: (parent.width / 4) * 2
        y: 0
        width: parent.width / 4
        height: parent.height

        Image
        {
            id: yellowImage
            x: 0
            y: 0
            width: xscale(32)
            height: yscale(32)
            source: mythUtils.findThemeFile("images/yellow_bullet.png")
        }

        InfoText
        {
            id: yellow
            x: yellowImage.x + yellowImage.width + xscale(5)
            y: 0
            width: parent.width - x - xscale(5)
            height: parent.height
            text: ""
        }
    }

    Item
    {
        // blue
        x: (parent.width / 4) * 3
        y: 0
        width: parent.width / 4
        height: parent.height

        Image
        {
            id: blueImage
            x: 0
            y: 0
            width: xscale(32)
            height: yscale(32)
            source: mythUtils.findThemeFile("images/blue_bullet.png")
        }

        InfoText
        {
            id: blue
            x: blueImage.x + blueImage.width + xscale(5)
            y: 0
            width: parent.width - x - xscale(5)
            height: parent.height
            text: ""
        }
    }
}
