import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: videoMultiplexModel

    property int sourceId: -1

    source: settings.masterBackend + "Channel/GetVideoMultiplexList?SourceID=" + sourceId
    query: "/VideoMultiplexList/VideoMultiplexes/VideoMultiplex"

    XmlRole { name: "MplexId"; query: "MplexId/number()" }
    XmlRole { name: "SourceId"; query: "SourceId/number()" }
    XmlRole { name: "TransportId"; query: "TransportId/number()" }
    XmlRole { name: "NetworkId"; query: "NetworkId/number()" }
    XmlRole { name: "Frequency"; query: "Frequency/number()" }
    XmlRole { name: "Inversion"; query: "Inversion/string()" }
    XmlRole { name: "SymbolRate"; query: "SymbolRate/number()" }
    XmlRole { name: "FEC"; query: "FEC/string()" }
    XmlRole { name: "Polarity"; query: "Polarity/string()" }
    XmlRole { name: "Modulation"; query: "Modulation/string()" }
    XmlRole { name: "Bandwidth"; query: "Bandwidth/string()" }
    XmlRole { name: "LPCodeRate"; query: "LPCodeRate/string()" }
    XmlRole { name: "HPCodeRate"; query: "HPCodeRate/string()" }
    XmlRole { name: "TransmissionMode"; query: "TransmissionMode/string()" }
    XmlRole { name: "GuardInterval"; query: "GuardInterval/string()" }
    XmlRole { name: "Visible"; query: "Visible/string()" }
    XmlRole { name: "Constellation"; query: "Constellation/string()" }
    XmlRole { name: "Hierarchy"; query: "Hierarchy/string()" }
    XmlRole { name: "ModulationSystem"; query: "ModulationSystem/string()" }
    XmlRole { name: "RollOff"; query: "RollOff/string()" }
    XmlRole { name: "SIStandard"; query: "SIStandard/string()" }
    XmlRole { name: "ServiceVersion"; query: "ServiceVersion/string()" }
    XmlRole { name: "UpdateTimeStamp"; query: "UpdateTimeStamp/string()" }
    XmlRole { name: "DefaultAuthority"; query: "DefaultAuthority/string()" }

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
            log.debug(Verbose.MODEL, "VideoMultiplexModel: LOADING - " + source.toString());
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "VideoMultiplexModel: ERROR: " + errorString() + " - " + source.toString());
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
