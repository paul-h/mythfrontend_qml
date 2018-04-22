#include <QDomDocument>

#include "settings.h"
#include "recordingsmodel.h"

RecordingsModel::RecordingsModel(void) : MythIncrementalModel()
{
    m_descending = true;

    // program
    addRole("Title");
    addRole("SubTitle");
    addRole("Description");
    addRole("StartTime");
    addRole("EndTime");
    addRole("Category");
    addRole("CatType");
    addRole("Repeat");
    addRole("VideoProps");
    addRole("AudioProps");
    addRole("SubProps");
    addRole("SeriesId");
    addRole("ProgramId");
    addRole("Stars");
    addRole("LastModified");
    addRole("ProgramFlags");
    addRole("Airdate");
    addRole("Inetref");
    addRole("Season");
    addRole("Episode");
    addRole("TotalEpisodes");
    addRole("FileSize");
    addRole("FileName");
    addRole("HostName");

    // recording
    addRole("RecordingId");
    addRole("RecGroup");
    addRole("Status");

    //channel
    addRole("ChanNum");
    addRole("ChannelName");
    addRole("CallSign");
    addRole("IconURL");

    //artwork
    addRole("Coverart");
    addRole("Fanart");
    addRole("Banner");

    startDownload();
}

void RecordingsModel::setTitleRegExp(const QString &title)
{
    m_title = title;
}

void RecordingsModel::setRecGroup(const QString &recGroup)
{
    m_recGroup = recGroup;
}

void RecordingsModel::setStorageGroup(const QString &storageGroup)
{
    m_storageGroup = storageGroup;
}

void RecordingsModel::setCategory(const QString &category)
{
    m_category = category;
}

void RecordingsModel::setDescending(bool descending)
{
    m_descending = descending;
}

void RecordingsModel::setSort(const QString &sort)
{
    m_sort = sort;
}

// construct the download URL and start the download
void RecordingsModel::startDownload(void)
{
    // defaults
    int startIndex = 0;
    int count = m_count;

    // use the first and last pending items
    if (!m_pendingDownloads.isEmpty())
    {
         std::sort(m_pendingDownloads.begin(), m_pendingDownloads.end());
        startIndex =  m_pendingDownloads.first();
        count = qMax(m_count, m_pendingDownloads.last() - startIndex + 1);
    }

    QString descending = (m_descending ? "true" : "false");

    // start download of xml from server
    QString sUrl = QString("%1Dvr/GetRecordedList?startindex=%2&count=%3&Descending=%4")
            .arg(gSettings->masterBackend()).arg(startIndex).arg(count).arg(descending);

    if (!m_title.isEmpty())
        sUrl.append(QString("&TitleRegEx=%1").arg(m_title));

    if (!m_recGroup.isEmpty())
        sUrl.append(QString("&RecGroup=%1").arg(m_recGroup));

    if (!m_storageGroup.isEmpty())
        sUrl.append(QString("&StorageGroup=%1").arg(m_storageGroup));

    if (!m_category.isEmpty())
        sUrl.append(QString("&Category=%1").arg(m_category));

    if (!m_sort.isEmpty())
        sUrl.append(QString("&Sort=%1").arg(m_sort));

    QUrl url(sUrl);
    m_downloadManager->append(url);
}

// process the XML extracting the data we need for the model
void RecordingsModel::processDownload(QByteArray buffer)
{
    if (buffer.isEmpty())
    {
        qWarning() << "RecordingsModel: got an empty buffer!";
        return;
    }

    // parse the xml
    QDomDocument domDoc;

    if (!domDoc.setContent(buffer))
    {
        qWarning() << "Failed to parse xml";
        qDebug() << buffer;
        return;
    }

    //Check the type of the feed
    QString rootName = domDoc.documentElement().nodeName();
    if (rootName == "ProgramList")
    {
        // get the total available recordings
        QDomNode totalNode = domDoc.documentElement().namedItem("TotalAvailable");
        if (!totalNode.isNull())
        {
            int totalAvailable = totalNode.toElement().text().simplified().toInt();
            if (m_totalAvailable < totalAvailable)
            {
                beginResetModel();
                for (int x = 0; x < totalAvailable - m_totalAvailable; x++)
                {
                    m_data.append(nullptr);
                }

                m_totalAvailable = m_data.count();
                emit totalAvailableChanged();
                endResetModel();
            }
        }

        // get the StartIndex
        int startIndex = 0;
        QDomNode startIndexNode = domDoc.documentElement().namedItem("StartIndex");

        if (!startIndexNode.isNull())
            startIndex = startIndexNode.toElement().text().simplified().toInt();

        QDomNodeList programs = domDoc.elementsByTagName("Program");

        for (int x = 0; x < programs.count(); x++)
        {
            QDomNode programNode = programs.item(x);
            QDomNode recordingNode = programNode.toElement().namedItem("Recording");
            QDomNode channelNode = programNode.toElement().namedItem("Channel");
            QDomNode artworkNode = programNode.toElement().namedItem("Artwork");

            RowData *data = m_data.at(startIndex + x);
            if (m_pendingDownloads.contains(startIndex + x))
                m_pendingDownloads.removeAll(startIndex + x);

            if (data)
            {
                // we already have it so just update it?
                qDebug() << "RecordingsModel: recording found in recordings at: " << startIndex + x;
            }
            else
            {
                // not found so add it to the model
                qDebug() << "RecordingsModel: adding new recording: " << startIndex + x;
                data = addNewRow();
                m_data[startIndex + x] = data;

                // program
                addStringData(data, programNode, "Title");
                addStringData(data, programNode, "SubTitle");
                addStringData(data, programNode, "Description");
                addDateTimeData(data, programNode, "StartTime");
                addDateTimeData(data, programNode, "EndTime");
                addStringData(data, programNode, "Category");
                addStringData(data, programNode, "CatType");
                addBoolData(data, programNode, "Repeat");
                addIntData(data, programNode, "VideoProps");
                addIntData(data, programNode, "AudioProps");
                addIntData(data, programNode, "SubProps");
                addStringData(data, programNode, "SeriesId");
                addStringData(data, programNode, "ProgramId");
                addDoubleData(data, programNode, "Stars");
                addDateTimeData(data, programNode, "LastModified");
                addIntData(data, programNode, "ProgramFlags");
                addDateData(data, programNode, "Airdate");
                addStringData(data, programNode, "Inetref");
                addIntData(data, programNode, "Season");
                addIntData(data, programNode, "Episode");
                addIntData(data, programNode, "TotalEpisodes");
                addLongData(data, programNode, "FileSize");
                addStringData(data, programNode, "FileName");
                addStringData(data, programNode, "HostName");

                // recording
                addStringData(data, recordingNode, "RecordingId");
                addStringData(data, recordingNode, "RecGroup");
                addStringData(data, recordingNode, "Status");

                //channel
                addStringData(data, channelNode, "ChanNum");
                addStringData(data, channelNode, "ChannelName");
                addStringData(data, channelNode, "CallSign");
                addStringData(data, channelNode, "IconURL");

                // artwork
                QDomNodeList artworkNodes = artworkNode.toElement().elementsByTagName("ArtworkInfo");
                for (int y = 0; y < artworkNodes.count(); y++)
                {
                    QDomNode artworkNode = artworkNodes.item(y);
                    QString type = artworkNode.toElement().namedItem("Type").toElement().text();
                    QString url = artworkNode.toElement().namedItem("URL").toElement().text();
                    if (type == "coverart")
                    {
                        (*data)[m_roleMap["Coverart"]].setValue(url);
                    }
                    else if (type == "fanart")
                    {
                        (*data)[m_roleMap["Fanart"]].setValue(url);
                    }
                    else if (type == "banner")
                    {
                        (*data)[m_roleMap["Banner"]].setValue(url);
                    }
                }
            }
        }
        QModelIndex topLeft = createIndex(startIndex, 0);
        QModelIndex bottomRight = createIndex(startIndex + m_count - 1, 0);
        QVector<int> roles;

        for (QHash<int, QByteArray>::const_iterator it = m_roleNames.begin(); it != m_roleNames.end(); ++it)
            roles.append(it.key());

        emit dataChanged(topLeft, bottomRight, roles);
    }
    else
    {
        qWarning() << "RecordingsModel: Doesn't look like valid recording list XML!";
        return;
    }
}
