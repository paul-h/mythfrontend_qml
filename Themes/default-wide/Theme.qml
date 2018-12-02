import QtQuick 2.0

//pragma Singleton

QtObject
{
    id: root

    // screen background
    property string backgroundVideo:     "video/blue_motion_background.mp4"

    // main menu font
    property string menuFontFamily:     "Liberation Sans"
    property int    menuFontPixelSize:  30
    property bool   menuFontBold:       true
    property color  menuFontColor:      "white"
    property real   menuShadowAlpha:    100 / 255
    property color  menuShadowColor:    "#000000"
    property int    menuShadowXOffset:  3
    property int    menuShadowYOffset:  3

    // title text
    property string titleFontFamily:     "Liberation Sans"
    property int    titleFontPixelSize:  30
    property bool   titleFontBold:       true
    property color  titleFontColor:      "#00ff00"
    property real   titleShadowAlpha:    100 / 255
    property color  titleShadowColor:    "#000000"
    property int    titleShadowXOffset:  3
    property int    titleShadowYOffset:  3

    // label text
    property string labelFontFamily:     "Droid Sans"
    property int    labelFontPixelSize:  20
    property bool   labelFontBold:       true
    property color  labelFontColor:      "#ff00ff"
    property real   labelShadowAlpha:    100 / 255
    property color  labelShadowColor:    "#000000"
    property int    labelShadowXOffset:  2
    property int    labelShadowYOffset:  2

    // info text
    property string infoFontFamily:     "Liberation Sans"
    property int    infoFontPixelSize:  20
    property bool   infoFontBold:       false
    property color  infoFontColor:      "#ffffff"
    property real   infoShadowAlpha:    100 / 255
    property color  infoShadowColor:    "#000000"
    property int    infoShadowXOffset:  0
    property int    infoShadowYOffset:  0

    // clock text
    property string clockFontFamily:     "Liberation Sans"
    property int    clockFontPixelSize:  25
    property bool   clockFontBold:       false
    property color  clockFontColor:      "#00ff00"
    property real   clockShadowAlpha:    100 / 255
    property color  clockShadowColor:    "#000000"
    property int    clockShadowXOffset:  1
    property int    clockShadowYOffset:  1

    // base backgound
    property color bgColor:       "black"
    property real  bgOpacity:     60 / 255
    property color bgBorderColor: "white"
    property int   bgBorderWidth: 2
    property int   bgRadius:      12

    // list view
    property color lvRowBackgroundNormal:   "#20000000"; // not selected or focused
    property color lvRowBackgroundFocused:  "#20000000"; // focused
    property color lvRowBackgroundActive:   "#2000dd00"; // selected not focused
    property color lvRowBackgroundSelected: "#8000dd00"; // selected and focused

    property color lvRowTextNormal:   "#8000ffff"; // not selected or focused
    property color lvRowTextFocused:  "#a000ffff"; // focused
    property color lvRowTextActive:   "#8000ffff"; // selected not focused
    property color lvRowTextSelected: "#a000ffff"; // selected and focused

    property real  lvBackgroundOpacity:      1.0;
    property color lvBackgroundBorderColor:  "transparent";
    property int   lvBackgroundBorderWidth:  0;
    property int   lvBackgroundBorderRadius: 0;

    // ticker text
    property color tiTextColor:       "green"
    property color tiBackgroundColor: "#88101010"

}
