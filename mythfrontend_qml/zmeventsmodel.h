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

    Q_PROPERTY(QString auth READ auth WRITE setAuth NOTIFY authChanged)
    Q_PROPERTY(QString monitorID READ monitorID WRITE setMonitorID NOTIFY monitorIDChanged)
    Q_PROPERTY(QDate date READ date WRITE setDate NOTIFY dateChanged)
    Q_PROPERTY(bool descending READ descending WRITE setDescending NOTIFY descendingChanged)
    Q_PROPERTY(QString sort READ getSort WRITE setSort NOTIFY sortChanged)

    Q_PROPERTY(QVariantList dateList READ getDateList)
    Q_PROPERTY(QList<int> monitorList READ getMonitorList)

    QString auth(void) { return m_auth; }
    void setAuth(const QString &auth);

    QString monitorID(void) { return m_monitorID; }
    void setMonitorID(const QString &monitorID);

    QDate date(void) { return m_date; }
    void setDate(const QDate &date);

    bool descending(void) { return m_descending; }
    void setDescending(bool descending);

    QString getSort(void) { return m_sort; }
    void setSort(const QString &sort);

    QVariantList getDateList(void) { return m_dateList; }
    QList<int> getMonitorList(void) { return m_monitorList; }

 signals:
    void authChanged(void);
    void monitorIDChanged(void);
    void dateChanged(void);
    void descendingChanged(void);
    void sortChanged(void);

  protected slots:
    virtual void startDownload(void);
    virtual void processDownload(QByteArray buffer);

  private:
    QString m_auth;
    QString m_monitorID;
    QDate   m_date;
    bool    m_descending;
    QString m_sort;

    QVariantList m_dateList;
    QList<int>  m_monitorList;

};

#endif // ZMEVENTSMODEL_H