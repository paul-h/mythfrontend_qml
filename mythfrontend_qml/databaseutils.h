#pragma once
#include <QObject>
#include <QSqlQuery>

class DatabaseUtils : public QObject
{
    Q_OBJECT
  public:
    DatabaseUtils() { }

    Q_INVOKABLE void updateChannel(int chanid, QString chanName, QString chanNo, QString xmltvid, QString callsign);

    Q_INVOKABLE QString getSetting(const QString &settingName, const QString &hostName, const QString &defaultValue = "");
    Q_INVOKABLE bool    setSetting(QString settingName, QString hostName, QString value);
};
