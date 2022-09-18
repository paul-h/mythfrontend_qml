import QtQuick 2.4
import QtQuick.XmlListModel 2.0
import QtWebEngine 1.3
import mythqml.net 1.0

Item
{
    id: root

    property var mediaPlayer: undefined

    property alias approachLeftList: approachLeftListModel
    property alias approachRightList: approachRightListModel
    property alias trainList: trainListModel
    property alias diagramList: diagramListModel

    property string railcamImageFilename: settings.configPath + "Snapshots/railcam.png";

    signal approachDataChanged()
    signal diagramDataChanged()
    signal miniDiagramImageChanged()

    x: 0
    y: 0
    z: -100
    width: 1280
    height: 720


    onMediaPlayerChanged:
    {
        if (mediaPlayer)
        {
            mediaPlayer.activeFeedChanged.connect(feedChanged);
        }
    }

    function feedChanged()
    {
        if (mediaPlayer === undefined)
            return;

        var minidiagramURL = mediaPlayer.getLink("railcam_minidiagram");
        var diagramURL = mediaPlayer.getLink("railcam_diagram");
        var approachURL = mediaPlayer.getLink("railcam_approach");

        if (minidiagramURL !== undefined)
        {
            miniDiagramBrowser.url = minidiagramURL
        }
        else
        {
            miniDiagramBrowser.url = "";
        }

        if (diagramURL !== undefined)
        {
            diagramDataModel.source = diagramURL;
            diagramDataTimer.start();
        }
        else
        {
            diagramDataModel.source = "";
            diagramDataTimer.stop();
        }

        if (approachURL !== undefined)
        {
            approachDataModel.source = approachURL;
            approachDataTimer.start();
        }
        else
        {
            approachDataModel.source = "";
            approachDataTimer.stop();

            approachLeftList.clear();
            approachRightList.clear();
            trainList.clear();
        }
    }

    ListModel
    {
        id: approachLeftListModel
    }

    ListModel
    {
        id: approachRightListModel
    }

    ListModel
    {
        id: trainListModel
    }

    ListModel
    {
        id: diagramListModel
    }

    Timer
    {
        id: approachDataTimer
        interval: 5000; running: approachDataModel.source != ""; repeat: true
        onTriggered:
        {
            approachDataModel.reload();
            updateRailCamImage();
        }
    }

    JSONListModel
    {
        id: approachDataModel
        source: ""
        query: "$.data[*]"

        onLoaded:
        {
            approachLeftList.clear();
            approachRightList.clear();
            trainList.clear();

            for (var x = 0; x < model.count; x++)
            {
                if (model.get(x).occupied !== "0")
                {
                    var status = "";
                    var code = model.get(x).approach_ind.replace("<", "").replace(">", "");

                    if (code === "0")
                        status = "Passing";
                    else if (code === "1" || code === "2")
                        status = "Approaching";
                    else if (code === "7")
                        status = "At Platform";
                    else if (code === "8")
                        status = "Waiting";
                    else if (code === "9")
                        status = "Passed";
                    else
                        status = "Unknown"

                    if (model.get(x).approach_ind.startsWith("<"))
                    {
                        approachLeftListModel.append({"headcode": model.get(x).headcode, "approach_ind": model.get(x).approach_ind, "status" : status, "buid": model.get(x).buid});
                    }
                    else if (model.get(x).approach_ind.startsWith(">"))
                    {
                        approachRightListModel.append({"headcode": model.get(x).headcode, "approach_ind": model.get(x).approach_ind, "status" : status, "buid": model.get(x).buid});
                    }

                    trainListModel.append({"headcode": model.get(x).headcode, "approach_ind": model.get(x).approach_ind, "status" : status, "buid": model.get(x).buid});
                }
            }

            approachDataChanged();
        }
    }

    Timer
    {
        id: diagramDataTimer
        interval: 5000; running: diagramDataModel.source != ""; repeat: true
        onTriggered:
        {
            diagramDataModel.reload();
        }
    }

    JSONListModel
    {
        id: diagramDataModel
        source: ""
        query: "$.data[*]"

        onLoaded:
        {
            diagramList.clear();

            for (var x = 0; x < model.count; x++)
            {
                if (model.get(x).occupied != "0")
                {
                    diagramListModel.append({"berth_id": model.get(x).berth_id, "buid": model.get(x).berth_id, "headcode": model.get(x).headcode, "occupied": model.get(x).occupied,});
                }
            }

            diagramDataChanged();
        }
    }

    WebEngineView
    {
        id: miniDiagramBrowser
        x: window.width // move off screen so not visible but still active
        y: 0
        z: -100
        width: xscale(1280)
        height: yscale(720)
        zoomFactor: 1.0
        visible: true
        enabled: true
        backgroundColor: "black"
        focus: false
        url: ""

        settings.pluginsEnabled: true

        onLoadingChanged:
        {
            if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus)
            {
                updateRailCamImage();
            }
        }
    }

    function updateRailCamImage()
    {
        miniDiagramBrowser.grabToImage(function(result)
        {
            var cropped = mythUtils.cropRailcamImage(result.image);
            miniDiagramImageChanged();
        });
    }
}
