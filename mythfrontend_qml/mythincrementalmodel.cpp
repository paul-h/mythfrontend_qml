#include <QDomDocument>
#include <QDomNode>

#include "mythincrementalmodel.h"

MythIncrementalModel::MythIncrementalModel(void)
    : QAbstractListModel(nullptr)
{
    m_count = 10;
    m_totalAvailable = 0;
    m_lastRole = Qt::UserRole + 1;
    m_downloadManager = new DownloadManager;
    connect(m_downloadManager, SIGNAL(finished(QByteArray)), this, SLOT(processDownload(QByteArray)));

    // get the first item which will also give use the total available
    m_pendingDownloads.append(0);
}

MythIncrementalModel::~MythIncrementalModel()
{
    delete m_downloadManager;

    clearData();
}

void MythIncrementalModel::setTotalAvailable(int available)
{
    m_totalAvailable = available;
    emit totalAvailableChanged();
}

int MythIncrementalModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_totalAvailable;
}

QVariantMap MythIncrementalModel::get(int row) const
{
    QVariantMap map;
    QModelIndex modelIndex = index(row, 0);
    QHash<int, QByteArray> roles = roleNames();

    for (QHash<int, QByteArray>::const_iterator it = roles.begin(); it != roles.end(); ++it)
        map.insert(it.value(), data(modelIndex, it.key()));

    return map;
}

QVariant MythIncrementalModel::getData(int row, int role) const
{
    if (row < 0 || row >= m_data.count())
        return QVariant();

    RowData *rowData = m_data[row];

    if (!rowData)
    {
        if (m_pendingDownloads.contains(row))
        {
            // we're still waiting for the download to complete
            return QVariant();
        }

        for (int x = 0; x < m_count; x++)
            m_pendingDownloads.append(row + x);

        QTimer::singleShot(0, this, SLOT(startDownload()));
        return QVariant();
    }
    else
    {
        if (role > Qt::UserRole && role < m_lastRole)
            return rowData->at(role - 1 - Qt::UserRole);
    }

   return QVariant();
}

QVariant MythIncrementalModel::data(const QModelIndex &index, int role) const
{
    return getData(index.row(), role);
}

void MythIncrementalModel::addRole(const QByteArray &roleName)
{
    qDebug() << "add role: " << roleName << ", at: " << m_lastRole;
    m_roleNames[m_lastRole] = roleName;
    m_roleMap[roleName] = m_lastRole - 1 - Qt::UserRole;
    m_lastRole++;
}

RowData *MythIncrementalModel::addNewRow(void)
{
    RowData *row = new RowData;

    for (int x = 0; x < m_roleNames.size(); x++)
    {
        row->append(QVariant());
    }

    return row;
}

QHash<int, QByteArray> MythIncrementalModel::roleNames() const
{
    return m_roleNames;
}

void MythIncrementalModel::reload(void)
{
    clearData();

    m_pendingDownloads.clear();
    m_pendingDownloads.append(0);
    startDownload();
}

void MythIncrementalModel::clearData()
{
    beginRemoveRows(QModelIndex(), 0, m_data.count() - 1);

    for (int x = 0; x < m_data.count(); x++)
        delete m_data.at(x);

    m_data.clear();

    m_totalAvailable = 0;

    endRemoveRows();
}

void MythIncrementalModel::addStringData(RowData* row, const QDomNode &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        qWarning() << "MythIncrementalModel::addStringData roleName not found: " << roleName;
        return;
    }

    QString data = node.toElement().namedItem(roleName).toElement().text();
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addIntData(RowData* row, const QDomNode &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        qWarning() << "MythIncrementalModel::addIntData roleName not found: " << roleName;
        return;
    }

    int data = node.toElement().namedItem(roleName).toElement().text().toInt();
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addLongData(RowData* row, const QDomNode &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        qWarning() << "MythIncrementalModel::addLongData roleName not found: " << roleName;
        return;
    }

    long data = node.toElement().namedItem(roleName).toElement().text().toLong();
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addDoubleData(RowData* row, const QDomNode &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        qWarning() << "MythIncrementalModel::addDoubleData roleName not found: " << roleName;
        return;
    }

    double data = node.toElement().namedItem(roleName).toElement().text().toDouble();
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addDateTimeData(RowData* row, const QDomNode &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        qWarning() << "MythIncrementalModel::addDatTimeData roleName not found: " << roleName;
        return;
    }

    QDateTime data = QDateTime::fromString(node.toElement().namedItem(roleName).toElement().text(),  Qt::ISODate);
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addDateData(RowData* row, const QDomNode &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        qWarning() << "MythIncrementalModel::addDateData roleName not found: " << roleName;
        return;
    }

    QDate data = QDate::fromString(node.toElement().namedItem(roleName).toElement().text(), Qt::ISODate);
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addBoolData(RowData* row, const QDomNode &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        qWarning() << "MythIncrementalModel::addBoolData roleName not found: " << roleName;
        return;
    }

    bool data = (node.toElement().namedItem(roleName).toElement().text() == "true");
    (*row)[m_roleMap[roleName]].setValue(data);
}
