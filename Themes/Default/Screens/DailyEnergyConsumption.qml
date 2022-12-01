import QtQuick 2.7
import QtCharts 2.15
import Base 1.0
import Dialogs 1.0
import Models 1.0
import FileIO 1.0
import "../../../Util.js" as Util

BaseScreen
{
    defaultFocusItem: chartView

    property var currentDate: new Date();
    property string fuel: "Both"
    property string show: "Cost"

    Component.onCompleted:
    {
        showTitle(true, "Daily Electric and Gas Cost and Usage");
        showTime(true);
        showTicker(false);
        muteAudio(true);

        // find the last day with data
        var tries = 0;

        while (tries < 31)
        {
            var day = currentDate.getDate() < 10 ? "0" + currentDate.getDate() : currentDate.getDate();
            var month = currentDate.getMonth() < 9 ? "0" + currentDate.getMonth() + 1: currentDate.getMonth() + 1;
            var year = currentDate.getFullYear();
            var source = settings.energyDataDir + "/daily/" + year + "_" + month + "_" + day + ".json";

            jsonFile.source = source;

            if (jsonFile.fileExists())
            {
                loadData(currentDate);
                return;
            }

            currentDate = Util.addDays(currentDate, -1);
            tries++;
        }

        // not found so use a default of 2022/11/01
        currentDate: new Date("2022-11-01");
        loadData(currentDate);
    }

    Keys.onPressed:
    {
        event.accepted = true;

        if (event.key === Qt.Key_F1)
        {
            // RED - previous day
            returnSound.play();
            currentDate = Util.addDays(currentDate, -1);

            loadData(currentDate);
        }
        else if (event.key === Qt.Key_F2)
        {
            // GREEN - next day
            returnSound.play();
            currentDate = Util.addDays(currentDate, 1);

            loadData(currentDate);
        }
        else if (event.key === Qt.Key_F3)
        {
            // YELLOW - fuel
            if (fuel === "Electric")
                fuel = "Gas";
            else if (fuel === "Gas")
                fuel = "Both";
            else if (fuel === "Both")
                fuel = "Electric";

            footer.yellowText = "Showing (" + fuel + ")";

            loadData(currentDate);
        }
        else if (event.key === Qt.Key_F4)
        {
            // BLUE - showing
            if (show === "Cost")
                show = "Energy";
            else
                show = "Cost";

            footer.blueText = "Showing (" + show + ")";

            loadData(currentDate);

        }
        else
            event.accepted = false;
    }

    FileIO
    {
        id: jsonFile
        source: ""
        onError: console.log(msg)
    }

    JSONListModel
    {
        id: dailyUsageModel

        query: "$.data.consumptionRange[*]"

        //onLoaded: updateChart()
    }

    LabelText
    {
        id: title
        x: (parent.width / 2) - (width / 2)
        y: yscale(40)
        width: xscale(1000)
        height: yscale(50)
        horizontalAlignment: Text.AlignHCenter
        fontPixelSize: xscale(25)
        text: "Electric cost for January"
    }

    InfoText
    {
        id: dayTotal
        x: (parent.width / 2) - (xscale(350) / 2)
        y: yscale(75)
        width: xscale(350)
        height: yscale(50)
        horizontalAlignment: Text.AlignHCenter
        text: ""
    }

    ChartView
    {
        id: chartView
        title: ""
        titleFont: Qt.font({pointSize: xscale(12), bold:true});
        titleColor: "magenta"
        x: xscale(10)
        y: yscale(130)
        width: parent.width - xscale(20)
        height: parent.height / 4 * 3
        legend.alignment: Qt.AlignTop
        antialiasing: true
        animationOptions: ChartView.NoAnimation; // AllAnimations

        BarCategoryAxis
        {
            id: timeAxis
            titleText: "Time"
            titleFont: Qt.font({pointSize: xscale(12), bold: false});
            labelsAngle: 270
            labelsFont: Qt.font({pointSize: xscale(8), bold: false});

        }

        ValueAxis
        {
            id: valueAxis
            min: 0
            max: 0.1
            titleText: "Electric [£]"
            titleFont: Qt.font({pointSize: xscale(12), bold:true});
            labelsFont: Qt.font({pointSize: xscale(12), bold: false});
        }

        BarSeries
        {
            id: myBarSeries
            axisX: timeAxis
            axisY: valueAxis
            barWidth: 0.8
            labelsAngle: 270
            labelsVisible: true

            BarSet
            {
                id: daySet
                label: currentDate.toLocaleDateString(Qt.locale(), "dd/MM/yyyy")
                labelColor: "red"
                labelFont: Qt.font({pointSize: xscale(12), bold:true});
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
        text: "No data available for this day."
    }

    Footer
    {
        id: footer
        redText: "Previous Day"
        greenText: "Next Day"
        yellowText: "Fuel (Both)"
        blueText: "Showing (Cost)"
    }

    function loadData(date)
    {
        var day = date.getDate() < 10 ? "0" + date.getDate() : date.getDate();
        var month = date.getMonth() < 9 ? "0" + date.getMonth() + 1: date.getMonth() + 1;
        var year = date.getFullYear();

        dailyUsageModel.source = "";

        daySet.remove(0, daySet.count);

        timeAxis.clear();
        valueAxis.max = 0.1;

        var source = settings.energyDataDir + "/daily/" + year + "_" + month + "_" + day + ".json";
        jsonFile.source = source;

        if (!jsonFile.fileExists())
        {
            dailyUsageModel.json = "";
            updateChart();
            return;
        }

        noData.visible = false;

        var json = jsonFile.read();
        json = json.replace(/"tou": null/g, '"tou": false');
        json = json.replace(/: null/g, ':""');

        dailyUsageModel.json = json;

        updateChart();
    }

    function updateChart()
    {
        if (fuel === "Electric")
        {
            if (show === "Cost")
            {
                valueAxis.titleText = "Electric Cost (£)"
                title.text = "Electric cost for "  + currentDate.toLocaleDateString(Qt.locale(), "dddd, d MMMM yyyy");
            }
            else
            {
                valueAxis.titleText = "Electric Usage (kWh)"
                title.text = "Electric usage for "  + currentDate.toLocaleDateString(Qt.locale(), "dddd, d MMMM yyyy");
            }
        }
        else if (fuel === "Gas")
        {
            if (show === "Cost")
            {
                valueAxis.titleText = "Gas Cost (£)"
                title.text = "Gas cost for "  + currentDate.toLocaleDateString(Qt.locale(), "dddd, d MMMM yyyy");
            }
            else
            {
                valueAxis.titleText = "Gas Usage (kWh)"
                title.text = "Gas usage for "  +currentDate.toLocaleDateString(Qt.locale(), "dddd, d MMMM yyyy");
            }
        }
        else if (fuel === "Both")
        {
            if (show === "Cost")
            {
                valueAxis.titleText = "Gas/Electric Cost (£)"
                title.text = "Gas and Electric cost for "  + currentDate.toLocaleDateString(Qt.locale(), "dddd, d MMMM yyyy");
            }
            else
            {
                valueAxis.titleText = "Gas/Electric Usage (kWh)"
                title.text = "Gas and Electric usage for "  + currentDate.toLocaleDateString(Qt.locale(), "dddd, d MMMM yyyy");
            }
        }

        chartView.title = "Energy Usage for " + currentDate.toLocaleDateString(Qt.locale(), "dddd, d MMMM yyyy") + " (" + fuel + ")";

        if (dailyUsageModel.model.count > 0)
        {
            noData.visible = false;

            var col = 0;
            var time = 0;
            var total = 0;

            for (var x = 0; x < dailyUsageModel.model.count; x++)
            {
                if ((dailyUsageModel.model.get(x).fuel === "gas" && fuel === "Gas") || (dailyUsageModel.model.get(x).fuel === "electricity" && fuel === "Electric") || (dailyUsageModel.model.get(x).fuel === "total" && fuel === "Both"))
                {
                    // Set the x-axis labels to the dates of the usage data
                    var xLabels = timeAxis.categories;
                    var hours = parseInt(time / 60) < 9 ? "0" + parseInt(time / 60) : parseInt(time / 60);
                    var minutes = Number(time % 60) < 9 ? "0" + Number(time % 60) : Number(time % 60);
                    xLabels[Number(col)] = hours + ":" + minutes;
                    timeAxis.categories = xLabels;
                    timeAxis.visible = true;
                    timeAxis.min = 0;
                    timeAxis.max = xLabels.length;

                    var value = 0
                    if (show === "Cost")
                        value = dailyUsageModel.model.get(x).cost;
                    else
                        value = dailyUsageModel.model.get(x).energy;

                    total += value;
                    valueAxis.max = (value > valueAxis.max ? value : valueAxis.max);

                    daySet.append(value);
                    col++
                    time = time + 30;
                }
            }

            if (show === "Cost")
                dayTotal.text = "Total: £" + total.toFixed(2);
            else
                dayTotal.text = "Total: " + total.toFixed(2) + "kWh";
        }
        else
        {
            noData.visible = true;

            // no data found
            dayTotal.text = "Total: N/A"
        }
    }
}
