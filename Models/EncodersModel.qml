import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: encoderModel

    source: settings.masterBackend + "Dvr/GetEncoderList"
    query: "/EncoderList/Encoders/Encoder"

    XmlRole { name: "Id"; query: "Id/number()" }
    XmlRole { name: "HostName"; query: "HostName/string()" }
    XmlRole { name: "Local"; query: "xs:boolean(Local)" }
    XmlRole { name: "Connected"; query: "xs:boolean(Connected)" }
    XmlRole { name: "State"; query: "SourceId/number()" }
    XmlRole { name: "SleepStatus"; query: "SleepStatus/number()" }
    XmlRole { name: "LowOnFreeSpace"; query: "xs:boolean(LowOnFreeSpace)" }
    XmlRole { name: "SourceIds"; query: "string-join(Inputs/Input/SourceId, ', ')" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "EncodersModel: READY - Found " + count + " encoders");
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "EncodersModel: LOADING - " + source);
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "EncodersModel: ERROR - " + errorString() + " - " + source);
        }
    }
}
