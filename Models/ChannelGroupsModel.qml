import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import mythqml.net 1.0

XmlListModel
{
    id: channelGroupsModel

    source: settings.masterBackend + "Guide/GetChannelGroupList"
    query: "/ChannelGroupList/ChannelGroups/ChannelGroup"

    XmlRole { name: "GroupId"; query: "GroupId/number()" }
    XmlRole { name: "Name"; query: "Name/string()" }
    XmlRole { name: "Password"; query: "Password/string()" }

    onStatusChanged:
    {
        if (status == XmlListModel.Ready)
        {
            log.debug(Verbose.MODEL, "ChannelGroupsModel: - Found " + count + " channelgroups");
        }

        if (status === XmlListModel.Loading)
        {
            log.debug(Verbose.MODEL, "ChannelGroupsModel: LOADING - " + source.toString());
        }

        if (status === XmlListModel.Error)
        {
            log.error(Verbose.MODEL, "ChannelGroups - ERROR: " + errorString() + " - " + source.toString());
        }
    }

    function addChannelToGroup(chanId, groupId)
    {
        var http = new XMLHttpRequest();
        var url = settings.masterBackend + "Guide/AddToChannelGroup";
        var params = "ChannelGroupId=" + groupId + "&ChanId=" + chanId;
        http.open("POST", url, true);

        // Send the proper header information along with the request
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http.setRequestHeader("Content-length", params.length);
        http.setRequestHeader("Connection", "close");

        http.onreadystatechange = function()
        {
            // Call a function when the state changes.
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    if (http.responseText.endsWith("<bool>true</bool>\n"))
                    {
                        log.debug(Verbose.SERVICESAPI, "ChannelGroupsModel: addChannelToGroup: channel: " + chanId + " added to channel group: " + groupId + " OK");
                        channelGroupsModel.reload();
                    }
                    else
                    {
                        log.error(Verbose.SERVICESAPI, "ChannelGroupsModel: addChannelToGroup: failed to add channel: " + chanId + " to channel group: " + groupId);
                        log.error(Verbose.SERVICESAPI, "ChannelGroupsModel: addChannelToGroup: response was - " + http.responseText);
                    }
                }
                else
                {
                    log.error(Verbose.SERVICESAPI, "ChannelGroupsModel:addChannelToGroup error: " + http.status)
                }
            }
        }

        http.send(params);
    }

    function removeChannelFromGroup(chanId, groupId)
    {
        var http = new XMLHttpRequest();
        var url = settings.masterBackend + "Guide/RemoveFromChannelGroup";
        var params = "ChannelGroupId=" + groupId + "&ChanId=" + chanId;
        http.open("POST", url, true);

        // Send the proper header information along with the request
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http.setRequestHeader("Content-length", params.length);
        http.setRequestHeader("Connection", "close");

        http.onreadystatechange = function()
        {
            // Call a function when the state changes.
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    if (http.responseText.endsWith("<bool>true</bool>\n"))
                    {
                        log.debug(Verbose.SERVICESAPI, "ChannelGroupsModel:removeChannelFromGroup: channel: " + chanId + " removed from channel group: " + groupId + " OK");
                        channelGroupsModel.reload();
                    }
                    else
                    {
                        log.error(Verbose.SERVICESAPI, "ChannelGroupsModel: removeChannelFromGroup: failed to remove channel: " + chanId + " from channel group: " + groupId);
                        log.error(Verbose.SERVICESAPI, "ChannelGroupsModel: removeChannelFromGroup: response was - " + http.responseText);
                    }
                }
                else
                {
                    log.error(Verbose.SERVICESAPI, "ChannelGroupsModel:removeChannelFromGroup error: " + http.status)
                }
            }
        }

        http.send(params);
    }
}
