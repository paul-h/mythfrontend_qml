#pragma once
#include <QObject>
#include <QSqlQuery>

class DatabaseUtils : public QObject
{
    Q_OBJECT
  public:
    DatabaseUtils() { }

    // these use the MythTV database
    Q_INVOKABLE void updateChannel(int chanid, QString chanName, QString chanNo, QString xmltvid, QString callsign);

    Q_INVOKABLE QString getMythSetting(const QString &settingName, const QString &hostName, const QString &defaultValue = "");
    Q_INVOKABLE bool    setMythSetting(QString settingName, QString hostName, QString value);

    // these use the MythQML database
    Q_INVOKABLE QString getSetting(const QString &settingName, const QString &hostName, const QString &defaultValue = "");
    Q_INVOKABLE bool    setSetting(QString settingName, QString hostName, QString value);
};
