import QtQuick
import QtQml.XmlListModel

import mythqml.net 1.0

XmlListModel
{
    id: mxmlModel
    source: ""
    query: "/metadata/item"
    XmlListModelRole { name: "title"; elementName: "title" }
    XmlListModelRole { name: "subtitle"; elementName: "subtitle" }
    XmlListModelRole { name: "description"; elementName: "description" }
    XmlListModelRole { name: "season"; elementName: "season" }
    XmlListModelRole { name: "episode"; elementName: "episode" }
    XmlListModelRole { name: "tagline"; elementName: "tagline" }
    XmlListModelRole { name: "categories"; elementName: "string-join(categories/category/@name, ',')" } // FIXME QT6
    XmlListModelRole { name: "contenttype"; elementName: "contenttype" }
    XmlListModelRole { name: "nsfw"; elementName: "boolean(nsfw)" } //FIXME QT6
    XmlListModelRole { name: "inetref"; elementName: "inetref" }
    XmlListModelRole { name: "hash"; elementName: "hash" }
    XmlListModelRole { name: "website"; elementName: "website" }
    XmlListModelRole { name: "studio"; elementName: "studio" }
    XmlListModelRole { name: "coverart"; elementName: "coverart" }
    XmlListModelRole { name: "fanart"; elementName: "fanart" }
    XmlListModelRole { name: "banner"; elementName: "banner" }
    XmlListModelRole { name: "screenshot"; elementName: "screenshot" }
    XmlListModelRole { name: "front"; elementName: "front" }
    XmlListModelRole { name: "back"; elementName: "back" }

    XmlListModelRole { name: "channum"; elementName: "channum" }
    XmlListModelRole { name: "callsign"; elementName: "callsign" }
    XmlListModelRole { name: "startts"; elementName: "startts" }
    XmlListModelRole { name: "releasedate"; elementName: "releasedate" }
    XmlListModelRole { name: "runtime"; elementName: "runtime" }
    XmlListModelRole { name: "runtimesecs"; elementName: "runtimesecs" }
    XmlListModelRole { name: "dateadded"; elementName: "dateadded" }
    XmlListModelRole { name: "datemodified"; elementName: "datemodified" }
    XmlListModelRole { name: "status"; elementName: "status" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "MythMetadataXMLModel: READY - found " + count + " items")
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "MythMetadataXMLModel: LOADING - " + mxmlModel.source)
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "MythMetadataXMLModel: ERROR - " + errorString() + " - " + source);
        }
    }
}
