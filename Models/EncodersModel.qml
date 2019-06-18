import QtQuick 2.0
import QtQuick.XmlListModel 2.0

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
            console.info("Status: " + "Encoders - Found " + count + " encoders");
        }

        if (status === XmlListModel.Loading)
        {
            console.info("Status: " + "Encoders - LOADING - " + source.toString());
        }

        if (status === XmlListModel.Error)
        {
            console.info("Status: " + "Encoders - ERROR: " + errorString + "\n" + source.toString());
        }
    }
}
