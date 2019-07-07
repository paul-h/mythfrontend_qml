#include <QJsonDocument>

#include "settings.h"
#include "zmeventsmodel.h"

ZMEventsModel::ZMEventsModel(void) : MythIncrementalModel()
{
    // show oldest first by default
    m_descending = false;

    // event
    addRole("Id");
    addRole("MonitorId");
    addRole("StorageId");
    addRole("Name");
    addRole("Cause");
    addRole("StartTime");
    addRole("EndTime");
    addRole("Width");
    addRole("Height");
    addRole("Length");
    addRole("Frames");
    addRole("AlarmFrames");
    addRole("DefaultVideo");
    addRole("SaveJPEGs");
    addRole("TotScore");
    addRole("AvgScore");
    addRole("MaxScore");
    addRole("Archived");
    addRole("Videoed");
    addRole("Uploaded");
    addRole("Emailed");
    addRole("Messaged");
    addRole("Executed");
    addRole("Notes");
    addRole("Orientation");
    addRole("DiskSpace");
    addRole("Scheme");
    addRole("Locked");
    addRole("StateId");
    addRole("MaxScoreFrameId");

    // we want to load all events so we can get the full list of event dates and monitors
    m_count = 100;
    m_loadAll = true;

    startDownload();
}

void ZMEventsModel::setAuth(const QString &auth)
{
    m_auth = auth;
    reload();
}


void ZMEventsModel::setMonitorID(const QString &monitorID)
{
    m_monitorID = monitorID;
}

void ZMEventsModel::setDate(const QDate &date)
{
    m_date = date;
}

void ZMEventsModel::setDescending(bool descending)
{
    m_descending = descending;
}

void ZMEventsModel::setSort(const QString &sort)
{
    m_sort = sort;
}

// construct the download URL and start the download
void ZMEventsModel::startDownload(void)
{
    if (m_auth.isEmpty() || m_pendingDownloads.isEmpty())
        return;

    // defaults
    int startIndex = 0;
    int count = m_count;
    int page = 0;

    // use the first and last pending items
    std::sort(m_pendingDownloads.begin(), m_pendingDownloads.end());
    startIndex =  m_pendingDownloads.first();
    count = qMax(m_count, m_pendingDownloads.last() - startIndex + 1);

    // the max the ZM API will allow is 100?
    if (count > 100)
        count = 100;

    page = int((startIndex / count) + 1);

    QString monitor;
    if (!m_monitorID.isEmpty() && m_monitorID != "-1")
        monitor = QString("/MonitorId:%1").arg(m_monitorID);

    QString dateRange;
    if (m_date > QDate(1970, 1, 1))
    {
        QString startTime = m_date.toString("yyyy-MM-dd 00:00:00");
        QString endTime = m_date.addDays(1).toString("yyyy-MM-dd 00:00:00");
        dateRange = QString("/StartTime >=:%1/EndTime <=:%2").arg(startTime).arg(endTime);
    }

    QString descending = (m_descending ? "desc" : "asc");

    QString sUrl = QString("http://" + gSettings->zmIP() + "/zm/api/events");

    if (!monitor.isEmpty() || !dateRange.isEmpty())
        sUrl += "/index";

    if (!monitor.isEmpty())
        sUrl += monitor;

    if (!dateRange.isEmpty())
        sUrl += dateRange;

    sUrl += QString(".json?page=%1&sort=StartTime&direction=%2&limit=%3&%4").arg(page).arg(descending).arg(count).arg(m_auth);

    // start download of json from server
     QUrl url(sUrl);
    m_downloadManager->append(url);
}

// process the XML extracting the data we need for the model
void ZMEventsModel::processDownload(QByteArray buffer)
{
    if (buffer.isEmpty())
    {
        qWarning() << "ZMEventsModel: got an empty buffer!";
        return;
    }

    // parse the json
    QJsonParseError parseError;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(buffer, &parseError);

    if (parseError.error != QJsonParseError::NoError)
    {
        qWarning() << "Failed to parse json - Location: " << parseError.offset << " Error: " << parseError.errorString();
        qDebug() << buffer;
        return;
    }

    //Check the type of the feed
    if (jsonDoc.isObject() && jsonDoc.object().contains("events") && jsonDoc.object().contains("pagination"))
    {
        QJsonValue pageinationNode = jsonDoc.object()["pagination"];

        // get the total available recordings
        QJsonValue countNode =  pageinationNode.toObject()["count"];
        if (!countNode.isNull())
        {
            int totalAvailable = countNode.toInt();
            qDebug() << "TotalAvailable  found: " << totalAvailable;

            if (totalAvailable == 0)
            {
                m_totalAvailable = 0;
                m_pendingDownloads.clear();
                emit totalAvailableChanged();
                return;
            }

            if (m_totalAvailable < totalAvailable)
            {
                beginResetModel();
                for (int x = 0; x < totalAvailable - m_totalAvailable; x++)
                {
                    if (m_loadAll)
                        m_pendingDownloads.append(x);

                    m_data.append(nullptr);
                }

                m_totalAvailable = m_data.count();
                emit totalAvailableChanged();
                endResetModel();
            }
        }
        else
        {
            qDebug() << "count node not found";
        }

        // get the StartIndex
        int startIndex = 0;
        QJsonValue pageNode = pageinationNode.toObject()["page"];
        QJsonValue currentNode = pageinationNode.toObject()["current"];
        QJsonValue limitNode = pageinationNode.toObject()["limit"];

        if (!pageNode.isNull() && !currentNode.isNull() && !limitNode.isNull())
            startIndex = (pageNode.toInt() - 1) * limitNode.toInt();

        QJsonArray events = jsonDoc.object()["events"].toArray();

        for (int x = 0; x < events.count(); x++)
        {
            QJsonValue eventNode = events.at(x).toObject()["Event"];
            RowData *data = m_data.at(startIndex + x);
            if (m_pendingDownloads.contains(startIndex + x))
                m_pendingDownloads.removeAll(startIndex + x);

            if (data)
            {
                // we already have it so just update it?
                //qDebug() << "ZMEventsModel: event found in events at: " << startIndex + x;
            }
            else
            {
                // not found so add it to the model
                //qDebug() << "ZMEventsModel: adding new event: " << startIndex + x;
                data = addNewRow();
                m_data[startIndex + x] = data;

                addIntData(data, eventNode, "Id");
                addIntData(data, eventNode, "MonitorId");
                addIntData(data, eventNode, "StorageId");
                addStringData(data, eventNode, "Name");
                addStringData(data, eventNode, "Cause");
                addDateTimeData(data, eventNode, "StartTime", "yyyy-MM-dd hh:mm:ss");
                addDateTimeData(data, eventNode, "EndTime", "yyyy-MM-dd hh:mm:ss");
                addIntData(data, eventNode, "Width");
                addIntData(data, eventNode, "Height");
                addStringData(data, eventNode, "Length");
                addIntData(data, eventNode, "Frames");
                addIntData(data, eventNode, "AlarmFrames");
                addStringData(data, eventNode, "DefaultVideo");
                addBoolData(data, eventNode, "SaveJPEGs");
                addIntData(data, eventNode, "TotScore");
                addIntData(data, eventNode, "AvgScore");
                addIntData(data, eventNode, "MaxScore");
                addIntData(data, eventNode, "Archived");
                addIntData(data, eventNode, "Videoed");
                addIntData(data, eventNode, "Uploaded");
                addIntData(data, eventNode, "Emailed");
                addIntData(data, eventNode, "Messaged");
                addIntData(data, eventNode, "Executed");
                addStringData(data, eventNode, "Notes");
                addStringData(data, eventNode, "Orientation");
                addIntData(data, eventNode, "DiskSpace");
                addStringData(data, eventNode, "Scheme");
                addBoolData(data, eventNode, "Locked");
                addIntData(data, eventNode, "StateId");
                addIntData(data, eventNode, "MaxScoreFrameId");

                QDate startDate = (*data)[m_roleMap["StartTime"]].toDate();
                if (!m_dateList.contains(startDate))
                {
                    m_dateList.append(startDate);
                }
            }
        }

        std::sort(m_dateList.begin(), m_dateList.end());

        QModelIndex topLeft = createIndex(startIndex, 0);
        QModelIndex bottomRight = createIndex(startIndex + events.count() - 1, 0);
        QVector<int> roles;

        for (QHash<int, QByteArray>::const_iterator it = m_roleNames.begin(); it != m_roleNames.end(); ++it)
            roles.append(it.key());

        emit dataChanged(topLeft, bottomRight, roles);
    }
    else
    {
        qWarning() << "ZMEventsModel: Doesn't look like valid recording list XML!";
        return;
    }

    // if we still have pending downloads get some more
    if (!m_pendingDownloads.isEmpty())
    {
        startDownload();

        QString list;
        for (int x = 0; x < m_pendingDownloads.count(); x++)
            list += QString("%1, ").arg(m_pendingDownloads.at(x));
    }
    else
    {
        emit loaded();
    }
}
