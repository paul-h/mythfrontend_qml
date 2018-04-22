#include <iostream>

#include <QVariant>

#include "databaseutils.h"

void DatabaseUtils::updateChannel(int chanid, QString chanName, QString chanNo, QString xmltvid, QString callsign)
{
    std::cout << "DatabaseUtils::updateChannel: " << "chanid is: " << chanid
    << ", chanName is: " << qPrintable(chanName)
    << ", chanNo is: " << qPrintable(chanNo)
    << ", xmltv is: " << qPrintable(xmltvid)
    << ", callsign is: " << qPrintable(callsign) << std::endl;

    QSqlQuery query(m_db);
    query.prepare("UPDATE channel SET channum = :CHANNUM, name = :NAME, xmltvid = :XMLTVID, callsign = :CALLSIGN "
                  "WHERE chanid = :CHANID;"
    "VALUES (:id, :forename, :surname)");
    query.bindValue(":CHANID",   QString("%1").arg(chanid));
    query.bindValue(":CHANNUM",  chanNo);
    query.bindValue(":NAME",     chanName);
    query.bindValue(":XMLTVID",  xmltvid);
    query.bindValue(":CALLSIGN", callsign);
    query.exec();
}

QString DatabaseUtils::getSetting(const QString &settingName, const QString &hostName, const QString &defaultValue)
{
    QString value;
    QSqlQuery query(m_db);

    query.prepare(
        "SELECT data "
        "FROM settings "
        "WHERE value = :VALUE AND hostname = :HOSTNAME");

    query.bindValue(":VALUE", settingName);
    query.bindValue(":HOSTNAME", hostName);

    if (query.exec() && query.next())
    {
        value = query.value(0).toString();
        return value;
    }

    return defaultValue;
}

bool DatabaseUtils::setSetting(QString settingName, QString hostName, QString value)
{
    QSqlQuery query(m_db);
    bool success = false;

    if (!hostName.isEmpty())
        query.prepare("DELETE FROM settings WHERE value = :KEY "
                      "AND hostname = :HOSTNAME ;");
    else
        query.prepare("DELETE FROM settings WHERE value = :KEY "
                      "AND hostname is NULL;");

    query.bindValue(":KEY", settingName);
    if (!hostName.isEmpty())
        query.bindValue(":HOSTNAME", hostName);

    if (!query.exec())
    {
        std::cout << "DatabaseUtils::setSetting delete failed" << std::endl;
        return false;
    }
    else
    {
        success = true;
    }

    if (success)
    {
        if (!hostName.isEmpty())
            query.prepare("INSERT INTO settings (value,data,hostname) "
                          "VALUES ( :VALUE, :DATA, :HOSTNAME );");
        else
            query.prepare("INSERT INTO settings (value,data ) "
                          "VALUES ( :VALUE, :DATA );");

        query.bindValue(":VALUE", settingName);
        query.bindValue(":DATA", value);
        if (!hostName.isEmpty())
            query.bindValue(":HOSTNAME", hostName);

        if (!query.exec())
        {
            success = false;
            std::cout << "DatabaseUtils::setSetting insert failed" << std::endl;
        }
    }

    return success;
}
