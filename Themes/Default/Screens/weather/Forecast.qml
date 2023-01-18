import QtQuick 2.0
import Base 1.0

BaseScreen
{
    defaultFocusItem: dayList

    property var forecast: null

    Component.onCompleted:
    {
        showTitle(true, "Weather Forecast");
        showTime(true);
    }

    Component
    {
        id: dayRow

        ListItem
        {
            x: 0
            width: (dayList.width - (5 * dayList.spacing)) / 6; height:dayList.height

            Rectangle
            {
                anchors.fill: parent
                color: theme.bgColor
                opacity: theme.bgOpacity
                radius: xscale(theme.lvBackgroundBorderRadius)
            }

            ListText
            {
                x: 0
                y: yscale(5)
                width: parent.width; height: yscale(30)
                text:
                {
                    var date = new Date(datetime);
                    return Qt.formatDateTime(date, "ddd MMM d");
                }
                horizontalAlignment: Text.AlignHCenter
                fontColor: theme.labelFontColor
            }
            Image
            {
                id: coverImage
                x: (parent.width - width) / 2
                y: yscale(25)
                width: yscale(50)
                height: width
                source: if (icon)
                            mythUtils.findThemeFile(icon);
                        else
                            mythUtils.findThemeFile("images/grid_noimage.png");
            }
            ListText
            {
                x: 0
                y: yscale(65)
                width: parent.width;
                height: yscale(30)
                horizontalAlignment: Text.AlignHCenter
                text: conditions
                fontPixelSize: xscale(14)
            }

            ListText
            {
                x: 0
                y: yscale(80)
                width: parent.width; height: yscale(50)
                horizontalAlignment: Text.AlignHCenter
                text: formatTemp(temp, true);
            }
            ListText
            {
                x: 0
                y: yscale(105)
                width: parent.width; height: yscale(50)
                horizontalAlignment: Text.AlignHCenter
                text: "Min: " + formatTemp(tempmin, true) + " | Max: " +formatTemp(tempmax, true)
                fontPixelSize: xscale(14)
            }

            ListText
            {
                x: 0
                y: yscale(140)
                width: parent.width
                height: yscale(50)
                horizontalAlignment: Text.AlignHCenter
                text: precipprob <= 0 ?
                          formatDefault("", "No chance of rain", "#87ceeb") :
                          formatDefault("Chance of Rain: ", precipprob + "%", "#87ceeb") + formatDefault("<br>Total Expected: ", precip + "mm", "#87ceeb");
                fontPixelSize: xscale(14)
                multiline: true
            }

            ListText
            {
                x: 0
                y: yscale(180)
                width: parent.width; height: yscale(50)
                horizontalAlignment: Text.AlignHCenter
                text: formatDefault("Pressure: ", pressure, "#ff00ff");
                fontPixelSize: xscale(14)
            }

            ListText
            {
                x: 0
                y: yscale(210)
                width: parent.width; height: yscale(50)
                horizontalAlignment: Text.AlignHCenter
                text: formatDefault("Humidity: ", humidity + "%", "#ff00ff");
                fontPixelSize: xscale(14)
            }

            ListText
            {
                x: 0
                y: yscale(250)
                width: parent.width; height: yscale(50)
                horizontalAlignment: Text.AlignHCenter
                text: formatDefault("Wind Speed: ", windspeed + "mph", "#ff00ff") + formatDefault("<br>Wind Direction: ",  winddir + " (" + windsector + ")","#ff00ff");
                fontPixelSize: xscale(14)
            }

            ListText
            {
                x: 0
                y: yscale(295)
                width: parent.width; height: yscale(70)
                horizontalAlignment: Text.AlignHCenter
                text: "UV Index: " + formatUVIndex(uvindex) + formatDefault("<br>Sunrise: ", sunrise,"#ff00ff") + formatDefault("<br>Sunset: ", sunset,"#ff00ff")
                fontPixelSize: xscale(14)
                multiline: true
            }
        }
    }

    ButtonList
    {
        id: dayList
        x: xscale(20); y: yscale(55); width: xscale(1240); height: yscale(370)

        spacing: xscale(3)

        orientation: ListView.Horizontal
        clip: true
        model: forecast.days

        delegate: dayRow

        KeyNavigation.up: hourList;
        KeyNavigation.down: hourList;
        KeyNavigation.left: hourList;
        KeyNavigation.right: hourList;
    }

    Component
    {
        id: hourRow

        ListItem
        {
            Image
            {
                id: coverImage
                x: xscale(13); y: yscale(3); height: parent.height - yscale(6); width: height
                source: if (icon)
                            mythUtils.findThemeFile(icon);
                        else
                            mythUtils.findThemeFile("images/grid_noimage.png");
            }
            ListText
            {
                x: coverImage.width + xscale(20)
                width: xscale(600); height: yscale(50)
                text:
                {
                    var date = new Date(datetimeEpoch * 1000);
                    return Qt.formatDateTime(date, "hh:mm");
                }
                fontColor: theme.labelFontColor
            }
            ListText
            {
                x: coverImage.width + xscale(625)
                width: xscale(250); height: yscale(50)
                horizontalAlignment: Text.AlignRight
                text: conditions
            }
            ListText
            {
                x: coverImage.width + xscale(880)
                width: xscale(300); height: yscale(50)
                horizontalAlignment: Text.AlignRight
                text: formatTemp(temp, true);
            }
        }
    }

    Component
    {
        id: hourDelegate
        Item
        {
            id: root

            property bool selected: GridView.isCurrentItem
            property bool focused: GridView.view.focus

            x: 0
            y: 0
            width: hourList.cellWidth - xscale(3)
            height: hourList.cellHeight
            Rectangle
            {
                anchors.fill: parent
                color: theme.bgColor
                opacity: theme.bgOpacity
                radius: xscale(theme.lvBackgroundBorderRadius)
            }

            ListText
            {
                x: 0
                y: yscale(5)
                width: parent.width; height: yscale(30)
                text:
                {
                    var date = new Date(datetimeEpoch * 1000);
                    return Qt.formatDateTime(date, "hh:mm");
                }
                horizontalAlignment: Text.AlignHCenter
                fontColor: theme.labelFontColor
            }
            Image
            {
                id: coverImage
                x: (parent.width - width) / 2
                y: yscale(25)
                width: yscale(50)
                height: width
                source: if (icon)
                            mythUtils.findThemeFile(icon);
                        else
                            mythUtils.findThemeFile("images/grid_noimage.png");
            }
            ListText
            {
                x: 0
                y: yscale(65)
                width: parent.width;
                height: yscale(30)
                horizontalAlignment: Text.AlignHCenter
                text: conditions
                fontPixelSize: xscale(14)
            }

            ListText
            {
                x: 0
                y: yscale(80)
                width: parent.width; height: yscale(50)
                horizontalAlignment: Text.AlignHCenter
                text: formatTemp(temp, true);
            }
            ListText
            {
                x: 0
                y: yscale(105)
                width: parent.width; height: yscale(50)
                horizontalAlignment: Text.AlignHCenter
                text: "Feels Like: " + formatTemp(feelslike, true)
                fontPixelSize: xscale(14)
            }

            ListText
            {
                x: 0
                y: yscale(140)
                width: parent.width
                height: yscale(40)
                horizontalAlignment: Text.AlignHCenter
                text: precipprob <= 0 ?
                          formatDefault("", "No chance of rain", "#87ceeb") :
                          formatDefault("Chance of Rain: ", precipprob + "%", "#87ceeb") + formatDefault("<br>Total Expected: ", precip + "mm", "#87ceeb");
                fontPixelSize: xscale(14)
                multiline: true
            }

            ListText
            {
                x: 0
                y: yscale(170)
                width: parent.width; height: yscale(50)
                horizontalAlignment: Text.AlignHCenter
                text: formatDefault("Wind Speed: ", windspeed + "mph", "#ff00ff") + formatDefault("<br>Wind Direction: ",  winddir + " (" + windsector + ")","#ff00ff");
                fontPixelSize: xscale(14)
            }
        }
    }

    ButtonGrid
    {
        id: hourList
        x: xscale(20)
        y: yscale(440)
        width: parent.width - xscale(40)
        height: yscale(260)
        cellWidth:  width / 6
        cellHeight: height
        model: forecast.days.get(dayList.currentIndex).hours
        delegate: hourDelegate

        KeyNavigation.up: dayList;
        KeyNavigation.down: dayList;
        KeyNavigation.left: dayList;
        KeyNavigation.right: dayList;
    }

    function formatDefault(label, value, color)
    {
        return label + '<font  color="' + color + '"><b>' + value + '</b></font>';
    }

    function formatTemp(temp, metric)
    {
        const colors = ["#ff00ff","#9e00ff","#0000ff","#007eff","#00ccff","#05f7f7","#7fff00","#f7f705","#ffcc00","#ff9900","#ff4f00","#cc0000","#a90303","#ba3232"];
//                      -25      -20       -15      -10        -5       0        5         10         15        20        25        30        35        40        45+
        var colorIndex = parseInt((temp + 25) / 5);
        if (colorIndex < 0)
            colorIndex = 0;

        if (colorIndex > 13)
            colorIndex = 13;

        var color = colors[colorIndex];

        if (metric)
            return '<font  color="' + color + '"><b>' + Math.round(temp) + '°C</b></font>'
        else
            return '<font  color="' + color + '"><b>' + Math.round((temp * 9/5) + 32) + '°F</b></font>'
    }

    function formatUVIndex(uvindex)
    {
        const levels = ["no risk", "low",    "moderate", "high",   "very high", "extreme"]
        const colors = ["#cccccc", "#f7f705","#ffcc00",  "#ff9900","#ff4f00",   "#cc0000"];
//                          0        1 - 2     3 - 5       6 - 7     8 - 9         10
        var colorIndex = 0;

        if (uvindex <= 0)
            colorIndex = 0;

        if (uvindex === 1 || uvindex === 2)
            colorIndex = 1;

        if (uvindex === 3 || uvindex === 4 || uvindex === 5)
            colorIndex = 2;

        if (uvindex === 6 || uvindex === 7 || uvindex === 8)
            colorIndex = 3;

        if (uvindex === 9)
            colorIndex = 4;

        if (uvindex > 9)
            colorIndex = 5;

        var color = colors[colorIndex];
        var level = levels[colorIndex];

        return '<font  color="' + color + '"><b>' + uvindex + ' (' + level + ')' + '</b></font>';
    }
}
