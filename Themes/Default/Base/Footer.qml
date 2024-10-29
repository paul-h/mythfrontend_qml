import QtQuick

Item
{
    x: xscale(30); y: yscale(682); width: parent.width - xscale(60); height: yscale(32)
    implicitWidth: 1280 - 60; implicitHeight: 32

    property alias redText: red.text
    property alias greenText: green.text
    property alias yellowText: yellow.text
    property alias blueText: blue.text

    // private properties
    property double _wmult: 1
    property double _hmult: 1

    onWidthChanged: _wmult = width / implicitWidth
    onHeightChanged: _hmult = height / implicitHeight

    function _xscale(x)
    {
        return x * _wmult
    }

    function _yscale(y)
    {
        return y * _hmult
    }

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
            x: 0
            y: 0
            width: _xscale(32)
            height: _yscale(32)
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
            fillMode: Image.PreserveAspectFit
            source: mythUtils.findThemeFile("images/red_bullet.png")
        }

        InfoText
        {
            id: red
            x: redImage.x + redImage.width + _xscale(5)
            y: 0;
            width: parent.width - x - _xscale(5)
            height: parent.height
            fontPixelSize: (_xscale(theme.infoFontPixelSize) + _yscale(theme.infoFontPixelSize)) / 2
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
            width: _xscale(32)
            height: _yscale(32)
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
            fillMode: Image.PreserveAspectFit
            source: mythUtils.findThemeFile("images/green_bullet.png")
        }

        InfoText
        {
            id: green
            x: greenImage.x + greenImage.width + _xscale(5)
            y: 0
            width: parent.width - x - _xscale(5)
            height: parent.height
            fontPixelSize: (_xscale(theme.infoFontPixelSize) + _yscale(theme.infoFontPixelSize)) / 2
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
            width: _xscale(32)
            height: _yscale(32)
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
            fillMode: Image.PreserveAspectFit
            source: mythUtils.findThemeFile("images/yellow_bullet.png")
        }

        InfoText
        {
            id: yellow
            x: yellowImage.x + yellowImage.width + _xscale(5)
            y: 0
            width: parent.width - x - _xscale(5)
            height: parent.height
            fontPixelSize: (_xscale(theme.infoFontPixelSize) + _yscale(theme.infoFontPixelSize)) / 2
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
            width: _xscale(32)
            height: _yscale(32)
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
            fillMode: Image.PreserveAspectFit
            source: mythUtils.findThemeFile("images/blue_bullet.png")
        }

        InfoText
        {
            id: blue
            x: blueImage.x + blueImage.width + _xscale(5)
            y: 0
            width: parent.width - x - _xscale(5)
            height: parent.height
            fontPixelSize: (_xscale(theme.infoFontPixelSize) + _yscale(theme.infoFontPixelSize)) / 2
            text: ""
        }
    }
}
