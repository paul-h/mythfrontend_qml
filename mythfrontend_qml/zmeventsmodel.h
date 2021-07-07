#ifndef ZMEVENTSMODEL_H
#define ZMEVENTSMODEL_H

#include <QAbstractListModel>
#include <QStringList>
#include <QDateTime>
#include <QList>

#include "mythincrementalmodel.h"

class ZMEventsModel : public MythIncrementalModel
{
    Q_OBJECT
public:
    ZMEventsModel(void);
    ~ZMEventsModel(void) {}

    enum Cause
    {
        CauseAll,
        CauseContinuous,
        CauseMotion,
        CauseForced
    };
    Q_ENUM(Cause)

    enum Archived
    {
        ArchivedAll,
        ArchivedYes,
        ArchivedNo
    };
    Q_ENUM(Archived)

    Q_PROPERTY(QString token READ token WRITE setToken NOTIFY tokenChanged)
    Q_PROPERTY(QString monitorID READ monitorID WRITE setMonitorID NOTIFY monitorIDChanged)
    Q_PROPERTY(QDate date READ date WRITE setDate NOTIFY dateChanged)
    Q_PROPERTY(bool descending READ descending WRITE setDescending NOTIFY descendingChanged)
    Q_PROPERTY(QString sort READ getSort WRITE setSort NOTIFY sortChanged)
    Q_PROPERTY(Cause cause READ getCause WRITE setCause NOTIFY causeChanged)
    Q_PROPERTY(Archived archived READ getArchived WRITE setArchived NOTIFY archivedChanged)

    Q_PROPERTY(QVariantList dateList READ getDateList)
    Q_PROPERTY(QList<int> monitorList READ getMonitorList)

    QString token(void) { return m_token; }
    void setToken(const QString &token);

    QString monitorID(void) { return m_monitorID; }
    void setMonitorID(const QString &monitorID);

    QDate date(void) { return m_date; }
    void setDate(const QDate &date);

    bool descending(void) { return m_descending; }
    void setDescending(bool descending);

    QString getSort(void) { return m_sort; }
    void setSort(const QString &sort);

    Cause getCause(void) { return m_cause; }
    void setCause(Cause cause);

    Archived getArchived(void) { return m_archived; }
    void setArchived(Archived archived);

    QVariantList getDateList(void) { return m_dateList; }
    QList<int> getMonitorList(void) { return m_monitorList; }

 signals:
    void tokenChanged(void);
    void monitorIDChanged(void);
    void dateChanged(void);
    void descendingChanged(void);
    void sortChanged(void);
    void causeChanged(void);
    void archivedChanged(void);

  protected slots:
    virtual void startDownload(void);
    virtual void processDownload(QByteArray buffer);

  private:
    QString m_token;
    QString m_monitorID;
    QDate   m_date;
    bool    m_descending;
    QString m_sort;
    Cause   m_cause;
    Archived m_archived;
    QVariantList m_dateList;
    QList<int>  m_monitorList;
};

#endif // ZMEVENTSMODEL_H
