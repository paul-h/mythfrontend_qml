#ifndef MYTHINCREMENTALMODEL_H
#define MYTHINCREMENTALMODEL_H

#include <QAbstractListModel>
#include <QHash>
#include <QMap>
#include <QList>
#include <QDomNode>

#include "downloadmanager.h"
#include "settings.h"

using RowData = QList<QVariant>;

class MythIncrementalModel : public QAbstractListModel
{
    Q_OBJECT
public:
    MythIncrementalModel(void);
    ~MythIncrementalModel(void) override;

    Q_PROPERTY(int totalAvailable READ totalAvailable NOTIFY totalAvailableChanged)
    Q_PROPERTY(int loadAll READ loadAll WRITE setLoadAll NOTIFY loadAllChanged)

    Q_INVOKABLE void reload(void);
    Q_INVOKABLE QVariant getData(int row, int role = Qt::DisplayRole) const;
    Q_INVOKABLE QVariantMap get(int row) const;
    Q_INVOKABLE bool remove(int row);

    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;

    void addRole(const QByteArray &roleName);

    void setCount(int count) { m_count = count; }

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    int totalAvailable(void) { return m_totalAvailable; }

    bool loadAll(void) { return m_loadAll; }
    void setLoadAll(bool loadAll) { m_loadAll = loadAll; }

  signals:
     void totalAvailableChanged(void);
     void loadAllChanged(bool loadall);
     void loaded(void);

protected:
    QHash<int, QByteArray> roleNames() const override;

protected slots:
    virtual void startDownload(void) = 0;
    virtual void processDownload(QByteArray buffer) = 0;

protected:
    void setTotalAvailable(int available);

    void clearData(void);
    RowData *addNewRow(void);

    // for XML data
    void addStringData(RowData *row, const QDomNode &node, const QByteArray &roleName);
    void addIntData(RowData *row, const QDomNode &node, const QByteArray &roleName);
    void addLongData(RowData* row, const QDomNode &node, const QByteArray &roleName);
    void addDateTimeData(RowData *row, const QDomNode &node, const QByteArray &roleName, const QString &format = "");
    void addDoubleData(RowData *row, const QDomNode &node, const QByteArray &roleName);
    void addDateData(RowData *row, const QDomNode &node, const QByteArray &roleName, const QString &format = "");
    void addBoolData(RowData *row, const QDomNode &node, const QByteArray &roleName);

    // for Json data
    void addStringData(RowData *row, const QJsonValue &node, const QByteArray &roleName);
    void addIntData(RowData *row, const QJsonValue &node, const QByteArray &roleName);
    void addLongData(RowData* row, const QJsonValue &node, const QByteArray &roleName);
    void addDateTimeData(RowData *row, const QJsonValue &node, const QByteArray &roleName, const QString &format = "");
    void addDoubleData(RowData *row, const QJsonValue &node, const QByteArray &roleName);
    void addDateData(RowData *row, const QJsonValue &node, const QByteArray &roleName, const QString &format = "");
    void addBoolData(RowData *row, const QJsonValue &node, const QByteArray &roleName);

    DownloadManager *m_downloadManager;

    int m_lastRole;
    QHash<int, QByteArray> m_roleNames;
    QMap<QByteArray, int> m_roleMap;

    mutable int m_count;
    int m_totalAvailable;
    bool m_loadAll;

    QList<RowData*> m_data;
    mutable QList<int> m_pendingDownloads;
};

#endif // MYTHINCREMENTALMODEL_H
