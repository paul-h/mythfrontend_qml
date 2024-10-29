import QtQuick
import QtCharts

import Base 1.0
import Dialogs 1.0
import Models 1.0
import SqlQueryModel 1.0
import "../../../Util.js" as Util

BaseScreen
{
    id: root

    defaultFocusItem: transInList

    property var startDate: new Date();
    property var endDate: new Date();

    property string range: "Week"
    property string show: "Table"

    Component.onCompleted:
    {
        showTitle(true, "Banking Viewer");
        showTime(true);
        showTicker(false);
        muteAudio(true);

        startDate = Util.addDays(startDate, -7);
        endDate = Util.addDays(startDate, 7);
        loadData();
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            // RED - previous period
            returnSound.play();
            if (range === "Week")
            {
                startDate = Util.addDays(startDate, -7);
                endDate = Util.addDays(startDate, 7);
            }
            else if (range === "Month")
            {
                var month = startDate.getMonth() - 1;
                startDate.setMonth(month);

                endDate = new Date(startDate);
                endDate.setMonth(month + 1);
            }
            else if (range === "Year")
            {
                var year = startDate.getFullYear() - 1;
                startDate.setYear(year);
                startDate.setDate(1);
                startDate.setMonth(0);
                endDate = new Date(startDate);
                endDate.setYear(year + 1)
            }

            loadData();
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN - next period
            returnSound.play();
            if (range === "Week")
            {
                startDate = Util.addDays(startDate, 7);
                endDate = Util.addDays(startDate, 7);
            }
            else if (range === "Month")
            {
                var month = startDate.getMonth() + 1;
                startDate.setMonth(month);
                endDate = new Date(startDate);
                endDate.setMonth(month + 1);
            }
            else if (range === "Year")
            {
                var year = startDate.getFullYear() + 1;
                startDate.setYear(year);
                startDate.setDate(1);
                startDate.setMonth(0);
                endDate = new Date(startDate);
                endDate.setYear(startDate.getFullYear() + 1);
            }

            loadData();
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW - range
            if (range === "Week")
            {
                startDate.setDate(1);
                endDate = new Date(startDate);
                endDate.setMonth(startDate.getMonth() + 1);
                range = "Month";
            }
            else if (range === "Month")
            {
                startDate.setDate(1)
                startDate.setMonth(0)
                endDate = new Date(startDate);
                endDate.setYear(startDate.getFullYear() + 1);
                range = "Year";
            }
            else if (range === "Year")
            {
                // change the day to be on a monday
                startDate = Util.addDays(startDate, startDate.getDay() - 1);
                endDate = Util.addDays(startDate, 7);
                range = "Week";
            }

            footer.yellowText = "Period (" + range + ")";

            loadData();
        }
        else if (event.key === Qt.Key_F4)
        {
            // BLUE - show
            if (show === "Table")
                show = "Chart";
            else
                show = "Table";

            footer.blueText = "Showing (" + show + ")";

            loadData();
        }
        else
            event.accepted = false;
    }

    SqlQueryModel
    {
        id: transOutModel
        property double total: 0.0

        sql: "SELECT * FROM transactions";

        database: "transactions"

        onSqlChanged:
        {
            while (canFetchMore(index(-1, -1)))
                fetchMore(index(-1, -1));

            total = 0.0

            for (var x = 0; x < rowCount(); x++)
            {
                total = total + get(x, "value");
            }

            totalOut.text = '£' +  Math.abs(total).toFixed(2);

            var diff = total + transInModel.total
            difference.text = '£' + Math.abs(diff).toFixed(2)

            if (diff < 0)
                difference.fontColor = "Red"
            else
                difference.fontColor = "Green"

            if (rowCount())
            {
                balanceIn.text = "£" + get(0, "balance").toFixed(2);
                balanceOut.text = "£" + get(rowCount() -1, "balance").toFixed(2);
            }
            else
            {
                balanceIn.text = "£0.00";
                balanceOut.text = "£0.00";
            }
        }
    }

    SqlQueryModel
    {
        id: transInModel
        property double total: 0.0

        sql: "SELECT * FROM transactions";

        database: "transactions"

        onSqlChanged:
        {
            while (canFetchMore(index(-1, -1)))
                fetchMore(index(-1, -1));

            total = 0.0

            for (var x = 0; x < rowCount(); x++)
            {
                total = total + get(x, "value");
            }

            totalIn.text = '£' + total.toFixed(2);

            var diff = total + transOutModel.total
            difference.text = '£' + Math.abs(diff).toFixed(2);

            if (diff < 0)
                difference.fontColor = "Red"
            else
                difference.fontColor = "Green"
        }
    }

    SqlQueryModel
    {
        id: chartModel

        sql: "SELECT * FROM transactions";

        database: "transactions"

        onSqlChanged:
        {
            while (canFetchMore(index(-1, -1)))
                fetchMore(index(-1, -1));

            updateChart();
        }
    }

    BaseBackground
    {
        x: xscale(20); y: yscale(50); width: parent.width - xscale(40); height: yscale(80)
    }

    TitleText
    {
        id: title
        x: (parent.width / 2) - (width / 2)
        y: yscale(40)
        width: xscale(1000)
        height: yscale(50)
        horizontalAlignment: Text.AlignHCenter
        fontPixelSize: xscale(18)
        text: "Transactions for week starting 1 June 2024"
    }

    LabelText
    {
        x: xscale(140)
        y: yscale(65)
        width: xscale(200)
        height: yscale(50)
        horizontalAlignment: Text.AlignRight
        fontPixelSize: xscale(16)
        text: "Money In: "
    }

    InfoText
    {
        id: totalIn
        x: xscale(350)
        y: yscale(65)
        width: xscale(100)
        height: yscale(50)
        horizontalAlignment: Text.AlignLeft
        text: ""
        fontColor: "green"
    }

    LabelText
    {
        x: xscale(430)
        y: yscale(65)
        width: xscale(200)
        height: yscale(50)
        horizontalAlignment: Text.AlignRight
        fontPixelSize: xscale(16)
        text: "Money Out: "
    }

    InfoText
    {
        id: totalOut
        x: xscale(640)
        y: yscale(65)
        width: xscale(100)
        height: yscale(50)
        horizontalAlignment: Text.AlignLeft
        text: ""
        fontColor: "red"
    }

    LabelText
    {
        x: xscale(720)
        y: yscale(65)
        width: xscale(200)
        height: yscale(50)
        horizontalAlignment: Text.AlignRight
        fontPixelSize: xscale(16)
        text: "Difference: "
    }

    InfoText
    {
        id: difference
        x: xscale(930)
        y: yscale(65)
        width: xscale(100)
        height: yscale(50)
        horizontalAlignment: Text.AlignLeft
        text: ""
        fontColor: "green"
    }

    LabelText
    {
        x: xscale(320)
        y: yscale(90)
        width: xscale(200)
        height: yscale(50)
        horizontalAlignment: Text.AlignRight
        fontPixelSize: xscale(16)
        text: "Start Balance: "
    }

    InfoText
    {
        id: balanceIn
        x: xscale(530)
        y: yscale(90)
        width: xscale(100)
        height: yscale(50)
        horizontalAlignment: Text.AlignLeft
        text: ""
        fontColor: "yellow"
    }

    LabelText
    {
        x: xscale(630)
        y: yscale(90)
        width: xscale(200)
        height: yscale(50)
        horizontalAlignment: Text.AlignRight
        fontPixelSize: xscale(16)
        text: "End Balance: "
    }

    InfoText
    {
        id: balanceOut
        x: xscale(840)
        y: yscale(90)
        width: xscale(100)
        height: yscale(50)
        horizontalAlignment: Text.AlignLeft
        text: ""
        fontColor: "yellow"
    }

    Item
    {
        id: table
        visible: root.show === "Table"
        anchors.fill: parent

        BaseBackground
        {
            x: xscale(20); y: yscale(140); width: parent.width - xscale(40); height: yscale(520)
        }

        Component
        {
            id: transInRow

            Item
            {
                width: transInList.width; height: yscale(50)
                z: 99

                property bool selected: ListView.isCurrentItem
                property bool focused: transInList.focus

                ListText
                {
                    x: xscale(10)
                    width: transInList.width - xscale(120); height: yscale(30)
                    text: description
                    fontPixelSize: xscale(14)
                }

                LabelText
                {
                    x: transInList.width - xscale(110)
                    width: xscale(100); height: yscale(30)
                    text: '£' + value.toFixed(2)
                    fontPixelSize: xscale(19)
                    horizontalAlignment: Text.AlignRight
                    fontColor: "green"
                }

                LabelText
                {
                    x: xscale(10)
                    y: yscale(20)
                    width: xscale(100); height: yscale(20)
                    text: date
                    fontPixelSize: xscale(12)
                    horizontalAlignment: Text.AlignLeft
                    fontColor: "grey"
                }

                LabelText
                {
                    x: xscale(300)
                    y: yscale(20)
                    width: xscale(190); height: yscale(20)
                    text: type
                    fontPixelSize: xscale(12)
                    horizontalAlignment: Text.AlignLeft
                    fontColor:
                    {
                        if (type == "CASHBACK")
                            "gold"
                        else if (type == "CREDIT IN")
                            "skyblue"
                        else if (type == "INTEREST")
                            "maroon"
                        else
                            "grey"
                    }
                }

                LabelText
                {
                    x: transOutList.width - xscale(110)
                    y: yscale(20)
                    width: xscale(100); height: yscale(20)
                    text: '£' + balance.toFixed(2)
                    fontPixelSize: xscale(12)
                    horizontalAlignment: Text.AlignRight
                    fontColor: "grey"
                }

            }
        }

        ButtonList
        {
            id: transInList
            x: xscale(30); y: yscale(150); width: parent.width / 2 - xscale(40); height: yscale(500)
            spacing: 3
            clip: true
            model: transInModel
            delegate: transInRow

            KeyNavigation.left: previousFocusItem ? previousFocusItem : transOutList;
            KeyNavigation.right: transOutList;
        }

        Component
        {
            id: transOutRow

            Item
            {
                width: transOutList.width
                height: yscale(50)

                property bool selected: ListView.isCurrentItem
                property bool focused: transOutList.focus
                property real itemSize: transOutList.itemWidth

                ListText
                {
                    x: xscale(10)
                    width: transOutList.width - xscale(120); height: yscale(30)
                    text: description
                    fontPixelSize: xscale(14)
                }

                LabelText
                {
                    x: transOutList.width - xscale(110)
                    width: xscale(100); height: yscale(30)
                    text: '£' + Math.abs(value).toFixed(2);
                    fontPixelSize: xscale(19)
                    horizontalAlignment: Text.AlignRight
                    fontColor: "red"
                }

                LabelText
                {
                    x: xscale(10)
                    y: yscale(20)
                    width: xscale(100); height: yscale(20)
                    text: date
                    fontPixelSize: xscale(12)
                    horizontalAlignment: Text.AlignLeft
                    fontColor: "grey"
                }

                LabelText
                {
                    x: xscale(300)
                    y: yscale(20)
                    width: xscale(190); height: yscale(20)
                    text: type
                    fontPixelSize: xscale(12)
                    horizontalAlignment: Text.AlignLeft
                    fontColor:                    {
                        if (type == "CASH WDL")
                            "limegreen"
                        else if (type == "CARD PAYMENT")
                            "deeppink"
                        else if (type == "DD")
                            "slateblue"
                        else if (type == "PAYMENT")
                            "goldenrod"
                        else if (type == "TRANSFER OUT")
                            "blueviolet"
                        else if (type == "MONTHLY ACCOUNT FEE")
                            "orangered"
                        else
                            "grey"
                    }
                }

                LabelText
                {
                    x: transOutList.width - xscale(110)
                    y: yscale(20)
                    width: xscale(100); height: yscale(20)
                    text: '£' + balance.toFixed(2)
                    fontPixelSize: xscale(12)
                    horizontalAlignment: Text.AlignRight
                    fontColor: "grey"
                }
            }
        }

        ButtonList
        {
            id: transOutList
            property int itemWidth: 190

            x: parent.width / 2 + xscale(10); y: yscale(150); width: parent.width / 2- xscale(40); height: yscale(500)
            model: transOutModel
            clip: true
            delegate: transOutRow
            spacing: 3

            KeyNavigation.left: transInList;
            KeyNavigation.right: transInList;
        }
    }

    Item
    {
        id: chart
        visible: root.show === "Chart"
        anchors.fill: parent

        BaseBackground
        {
            x: xscale(20); y: yscale(140); width: parent.width - xscale(40); height: yscale(520)
        }

        ChartView
        {
            id: chartView
            title: ""
            titleFont: Qt.font({pointSize: xscale(12), bold:true});
            titleColor: "magenta"
            x: xscale(30)
            y: yscale(150)
            width: parent.width - xscale(60)
            height: yscale(500)
            legend.alignment: Qt.AlignTop
            antialiasing: true
            animationOptions: ChartView.NoAnimation; // AllAnimations

            BarCategoryAxis
            {
                id: dateAxis
                titleText: "Date"
                titleFont: Qt.font({pointSize: xscale(12), bold: false});
                labelsAngle: 270
                labelsFont: Qt.font({pointSize: xscale(8), bold: false});
            }

            ValueAxis
            {
                id: valueAxis
                min: 0
                max: 0.1
                titleText: "Balance [£]"
                titleFont: Qt.font({pointSize: xscale(12), bold:true});
                labelsFont: Qt.font({pointSize: xscale(12), bold: false});
            }

            BarSeries
            {
                id: myBarSeries
                axisX: dateAxis
                axisY: valueAxis
                barWidth: 0.8
                labelsAngle: 270
                labelsVisible: true

                BarSet
                {
                    id: daySet
                    label: startDate.toLocaleDateString(Qt.locale(), "dd/MM/yyyy")
                    labelColor: "red"
                    labelFont: Qt.font({pointSize: xscale(12), bold:true});
                }
            }
        }
    }

    LabelText
    {
        id: noData
        x: chartView.x
        y: chartView.y
        width: chartView.width
        height: chartView.height
        horizontalAlignment: Text.AlignHCenter
        fontPixelSize: xscale(25)
        text: "No data available for this period."
    }

    Footer
    {
        id: footer
        redText: "Previous " + root.range
        greenText: "Next Week " + root.range
        yellowText: "Period (" + root.range + ")"
        blueText: "Showing (Table)"
    }

    function loadData()
    {
        var day = startDate.getDate() < 10 ? "0" + startDate.getDate() : startDate.getDate();
        var month = startDate.getMonth() < 9 ? "0" + (startDate.getMonth() + 1) : startDate.getMonth() + 1;
        var year = startDate.getFullYear();

        var queryStartDate = year + "-" + month + '-' + day;

        day = endDate.getDate() < 10 ? "0" + endDate.getDate() : endDate.getDate();
        month = endDate.getMonth() < 9 ? "0" + (endDate.getMonth() + 1) : endDate.getMonth() + 1;
        year = endDate.getFullYear();
        var queryEndDate = year + "-" + month + '-' + day;

        var locale = Qt.locale()
        title.text = "Transactions for " +range +  " starting " + startDate.toLocaleDateString(locale, "ddd d MMMM yyyy") + " to " + endDate.toLocaleDateString(locale, "ddd d MMMM yyyy")

        transOutModel.sql = "SELECT * FROM transactions WHERE value < 0  AND date >= '" + queryStartDate + "' AND date < '" + queryEndDate + "' ORDER BY date";
        transInModel.sql = "SELECT * FROM transactions WHERE value > 0  AND date >= '" + queryStartDate + "' AND date < '" + queryEndDate + "' ORDER BY date";

        if (show === "Chart")
            chartModel.sql = "SELECT * FROM transactions WHERE date >= '" + queryStartDate + "' AND date < '" + queryEndDate + "' ORDER BY date";

        transInList.highlightMoveDuration = 200;
        transOutList.highlightMoveDuration = 200;

        transInList.currentIndex = 0;
        transOutList.currentIndex = 0;

        transInList.highlightMoveDuration = 500;
        transOutList.highlightMoveDuration = 500;

        noData.visible = (transInModel.rowCount() == 0 && transOutModel.rowCount() == 0);
    }

    function updateChart()
    {
        daySet.remove(0, daySet.count);

        chartView.title = "Balance for " + startDate.toLocaleDateString(Qt.locale(), "dddd, d MMMM yyyy");


        var col = 0;
        var time = 0;
        var total = 0;
        var xLabels = []; //dateAxis.categories;

        for (var x = 0; x < chartModel.rowCount(); x++)
        {
            // Set the x-axis labels to the dates of the tranaction data
            xLabels[Number(col)] = chartModel.get(x, "date") + " - #" + (x + 1);
            var value = chartModel.get(x, "balance");
            valueAxis.max = (value > valueAxis.max ? value : valueAxis.max);

            daySet.append(value);
            col++
        }

        dateAxis.categories = xLabels;
        dateAxis.visible = true;
        dateAxis.min = 0;
        dateAxis.max = xLabels.length;
    }
}
