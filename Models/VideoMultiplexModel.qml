import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

XmlListModel
{
    id: videoMultiplexModel

    property int sourceId: -1

    source: settings.masterBackend + "Channel/GetVideoMultiplexList?SourceID=" + sourceId
    query: "/VideoMultiplexList/VideoMultiplexes/VideoMultiplex"

    XmlListModelRole { name: "MplexId"; elementName: "MplexId" } //number
    XmlListModelRole { name: "SourceId"; elementName: "SourceId" } //number
    XmlListModelRole { name: "TransportId"; elementName: "TransportId" }  //number
    XmlListModelRole { name: "NetworkId"; elementName: "NetworkId" } //number
    XmlListModelRole { name: "Frequency"; elementName: "Frequency" } //number
    XmlListModelRole { name: "Inversion"; elementName: "Inversion" }
    XmlListModelRole { name: "SymbolRate"; elementName: "SymbolRate" } //number
    XmlListModelRole { name: "FEC"; elementName: "FEC" }
    XmlListModelRole { name: "Polarity"; elementName: "Polarity" }
    XmlListModelRole { name: "Modulation"; elementName: "Modulation" }
    XmlListModelRole { name: "Bandwidth"; elementName: "Bandwidth" }
    XmlListModelRole { name: "LPCodeRate"; elementName: "LPCodeRate" }
    XmlListModelRole { name: "HPCodeRate"; elementName: "HPCodeRate" }
    XmlListModelRole { name: "TransmissionMode"; elementName: "TransmissionMode" }
    XmlListModelRole { name: "GuardInterval"; elementName: "GuardInterval" }
    XmlListModelRole { name: "Visible"; elementName: "Visible" }
    XmlListModelRole { name: "Constellation"; elementName: "Constellation" }
    XmlListModelRole { name: "Hierarchy"; elementName: "Hierarchy" }
    XmlListModelRole { name: "ModulationSystem"; elementName: "ModulationSystem" }
    XmlListModelRole { name: "RollOff"; elementName: "RollOff" }
    XmlListModelRole { name: "SIStandard"; elementName: "SIStandard" }
    XmlListModelRole { name: "ServiceVersion"; elementName: "ServiceVersion" }
    XmlListModelRole { name: "UpdateTimeStamp"; elementName: "UpdateTimeStamp" }
    XmlListModelRole { name: "DefaultAuthority"; elementName: "DefaultAuthority" }

    signal loaded();

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "VideoMultiplexModel: READY - Found " + count + " video multiplexes");
            loaded();
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "VideoMultiplexModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "VideoMultiplexModel: ERROR: " + errorString() + " - " + source);
        }
    }

    function findById(Id)
    {
        for (var x = 0; x < count; x++)
        {
            if (get(x).MplexId === Id)
                return x;
        }

        return -1;
    }
}
