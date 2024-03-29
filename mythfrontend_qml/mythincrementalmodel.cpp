#include <unistd.h>

#include <QDomDocument>
#include <QDomNode>

#include "context.h"
#include "mythincrementalmodel.h"

MythIncrementalModel::MythIncrementalModel(void)
    : QAbstractListModel(nullptr)
{
    m_count = 10;
    m_totalAvailable = 0;
    m_loadAll = false;
    m_lastRole = Qt::UserRole + 1;
    m_downloadManager = new DownloadManager;
    connect(m_downloadManager, SIGNAL(finished(QByteArray)), this, SLOT(processDownload(QByteArray)));

    // get the first item which will also give use the total available
    //m_pendingDownloads.append(0);
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

        int count = m_loadAll ? m_totalAvailable - row : qMin(m_count, m_totalAvailable - row);
        for (int x = 0; x < count; x++)
        {
            m_pendingDownloads.append(row + x);
        }

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
    m_roleNames[m_lastRole] = roleName;
    m_roleMap[roleName] = m_lastRole - 1 - Qt::UserRole;
    m_lastRole++;
}

void MythIncrementalModel::set(int row, const QByteArray &roleName, QVariant value)
{
    if (row < 0 || row >= m_data.count())
        return;

    RowData *rowData = m_data[row];

    if (!rowData)
        return;

    (*rowData)[m_roleMap[roleName]].setValue(value);

    QModelIndex topLeft = createIndex(row, 0);
    QModelIndex bottomRight = createIndex(row, 0);
    QVector<int> roles;

    for (QHash<int, QByteArray>::const_iterator it = m_roleNames.begin(); it != m_roleNames.end(); ++it)
    {
        if (it.value() == roleName)
            roles.append(it.key());
    }

    emit dataChanged(topLeft, bottomRight, roles);
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

bool MythIncrementalModel::remove(int row)
{
    return removeRows(row, 1, QModelIndex());
}

bool MythIncrementalModel::removeRows(int row, int count, const QModelIndex &parent)
{
    // sanity check
    if (row < 0 || row > m_data.count() - 1 || count < 0 || row + count > m_data.count() - 1)
        return false;

    beginRemoveRows(parent, row, row + count - 1);

    for (int x = row; x < row + count; x++)
    {
        delete m_data.at(x);
        m_data.removeAt(x);
    }
    endRemoveRows();

    setTotalAvailable(m_totalAvailable - count);

    return true;
}

void MythIncrementalModel::addStringData(RowData* row, const QDomNode &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        gContext->m_logger->warning(Verbose::MODEL, "MythIncrementalModel: addStringData - roleName not found: " + roleName);
        return;
    }

    QString data = node.toElement().namedItem(roleName).toElement().text();
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addIntData(RowData* row, const QDomNode &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        gContext->m_logger->warning(Verbose::MODEL, "MythIncrementalModel: addIntData - roleName not found: " + roleName);
        return;
    }

    int data = node.toElement().namedItem(roleName).toElement().text().toInt();
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addLongData(RowData* row, const QDomNode &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        gContext->m_logger->warning(Verbose::MODEL, "MythIncrementalModel: addLongData - roleName not found: " + roleName);
        return;
    }

    long data = node.toElement().namedItem(roleName).toElement().text().toLong();
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addDoubleData(RowData* row, const QDomNode &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        gContext->m_logger->warning(Verbose::MODEL, "MythIncrementalModel: addDoubleData - roleName not found: " + roleName);
        return;
    }

    double data = node.toElement().namedItem(roleName).toElement().text().toDouble();
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addDateTimeData(RowData* row, const QDomNode &node, const QByteArray &roleName, const QString &format)
{
    if (!m_roleMap.contains(roleName))
    {
        gContext->m_logger->warning(Verbose::MODEL, "MythIncrementalModel: addDateTimeData - roleName not found: " + roleName);
        return;
    }

    QDateTime data = QDateTime::fromString(node.toElement().namedItem(roleName).toElement().text(),  format);
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addDateTimeData(RowData* row, const QDomNode &node, const QByteArray &roleName, Qt::DateFormat format)
{
    if (!m_roleMap.contains(roleName))
    {
        gContext->m_logger->warning(Verbose::MODEL, "MythIncrementalModel: addDateTimeData - roleName not found: " + roleName);
        return;
    }

    QDateTime data = QDateTime::fromString(node.toElement().namedItem(roleName).toElement().text(),  format);
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addDateData(RowData* row, const QDomNode &node, const QByteArray &roleName, const QString &format)
{
    if (!m_roleMap.contains(roleName))
    {
        gContext->m_logger->warning(Verbose::MODEL, "MythIncrementalModel: addDateData - roleName not found: " + roleName);
        return;
    }

    QDate data = QDate::fromString(node.toElement().namedItem(roleName).toElement().text(), format);
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addBoolData(RowData* row, const QDomNode &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        gContext->m_logger->warning(Verbose::MODEL, "MythIncrementalModel: addBoolData - roleName not found: " + roleName);
        return;
    }

    bool data = (node.toElement().namedItem(roleName).toElement().text() == "true");
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addStringData(RowData* row, const QJsonValue &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        gContext->m_logger->warning(Verbose::MODEL, "MythIncrementalModel: addStringData - roleName not found: " + roleName);
        return;
    }

    QString data = node.toObject()[roleName].toString();
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addIntData(RowData* row, const QJsonValue &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        gContext->m_logger->warning(Verbose::MODEL, "MythIncrementalModel: addIntData - roleName not found: " + roleName);
        return;
    }

    int data = node.toObject()[roleName].toInt();
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addLongData(RowData* row, const QJsonValue &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        gContext->m_logger->warning(Verbose::MODEL, "MythIncrementalModel: addLongData - roleName not found: " + roleName);
        return;
    }

    long data = node.toObject()[roleName].toInt();
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addDoubleData(RowData* row, const QJsonValue &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        gContext->m_logger->warning(Verbose::MODEL, "MythIncrementalModel: addDoubleData - roleName not found: " + roleName);
        return;
    }

    double data = node.toObject()[roleName].toDouble();
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addDateTimeData(RowData* row, const QJsonValue &node, const QByteArray &roleName, const QString &format)
{
    if (!m_roleMap.contains(roleName))
    {
        gContext->m_logger->warning(Verbose::MODEL, "MythIncrementalModel: addDateTimeData - roleName not found: " + roleName);
        return;
    }

    QDateTime data = QDateTime::fromString(node.toObject()[roleName].toString(), format);
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addDateTimeData(RowData* row, const QJsonValue &node, const QByteArray &roleName, Qt::DateFormat format)
{
    if (!m_roleMap.contains(roleName))
    {
        gContext->m_logger->warning(Verbose::MODEL, "MythIncrementalModel: addDateTimeData - roleName not found: " + roleName);
        return;
    }

    QDateTime data = QDateTime::fromString(node.toObject()[roleName].toString(), format);
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addDateData(RowData* row, const QJsonValue&node, const QByteArray &roleName, const QString &format)
{
    if (!m_roleMap.contains(roleName))
    {
        gContext->m_logger->warning(Verbose::MODEL, "MythIncrementalModel: addDateData - roleName not found: " + roleName);
        return;
    }

    QDate data = QDate::fromString(node.toObject()[roleName].toString(), format);
    (*row)[m_roleMap[roleName]].setValue(data);
}

void MythIncrementalModel::addBoolData(RowData* row, const QJsonValue &node, const QByteArray &roleName)
{
    if (!m_roleMap.contains(roleName))
    {
        gContext->m_logger->warning(Verbose::MODEL, "MythIncrementalModel: addBoolData - roleName not found: " + roleName);
        return;
    }

    bool data = (node.toObject()[roleName].toString() == "true");
    (*row)[m_roleMap[roleName]].setValue(data);
}
