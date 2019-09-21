import QtQuick 2.0

Item
{
    x: xscale(0); y: yscale(682); width: xscale(1280); height: yscale(32)

    property alias redText: red.text
    property alias greenText: green.text
    property alias yellowText: yellow.text
    property alias blueText: blue.text

    Image
    {
        x: xscale(30); y: yscale(0); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/red_bullet.png")
    }

    InfoText
    {
        id: red
        x: xscale(65); y: yscale(0); width: xscale(285); height: yscale(32)
        text: ""
    }

    Image
    {
        x: xscale(350); y: yscale(0); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/green_bullet.png")
    }

    InfoText
    {
        id: green
        x: xscale(385); y: yscale(0); width: xscale(285); height: yscale(32)
        text: ""
    }

    Image
    {
        x: xscale(670); y: yscale(0); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/yellow_bullet.png")
    }

    InfoText
    {
        id: yellow
        x: xscale(705); y: yscale(0); width: xscale(285); height: yscale(32)
        text: ""
    }

    Image
    {
        x: xscale(990); y: yscale(0); width: xscale(32); height: yscale(32)
        source: mythUtils.findThemeFile("images/blue_bullet.png")
    }

    InfoText
    {
        id: blue
        x: xscale(1025); y: yscale(0); width: xscale(285); height: yscale(32)
        text: ""
    }
}
