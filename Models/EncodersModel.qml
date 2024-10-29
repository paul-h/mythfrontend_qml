import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

XmlListModel
{
    id: encoderModel

    source: settings.masterBackend + "Dvr/GetEncoderList"
    query: "/EncoderList/Encoders/Encoder"

    XmlListModelRole { name: "Id"; elementName: "Id" }
    XmlListModelRole { name: "HostName"; elementName: "HostName" }
    XmlListModelRole { name: "Local"; elementName: "xs:boolean(Local)" }
    XmlListModelRole { name: "Connected"; elementName: "xs:boolean(Connected)" }
    XmlListModelRole { name: "State"; elementName: "SourceId" }
    XmlListModelRole { name: "SleepStatus"; elementName: "SleepStatus" }
    XmlListModelRole { name: "LowOnFreeSpace"; elementName: "xs:boolean(LowOnFreeSpace)" }
    XmlListModelRole { name: "SourceIds"; elementName: "string-join(Inputs/Input/SourceId, ', ')" }

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
