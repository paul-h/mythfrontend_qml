#ifndef CONTEXT_H
#define CONTEXT_H

#include <QObject>
#include <QSqlDatabase>
#include <QQmlApplicationEngine>

#include "settings.h"
#include "databaseutils.h"
#include "mythutils.h"
#include "eventlistener.h"
#include "urlinterceptor.h"
#include "logger.h"

class Context : public QObject
{
    Q_OBJECT


public:
    Context(const QString &appName, const QString &logLevel, const QString &verbose, QObject *parent = nullptr);
    ~Context(void);

signals:

public slots:

public:
    void init(void);
    bool initMythQMLDB(void);
    bool loadMythDBSettings(void);
    QString systemID(void);

    QString m_appName;

    QQmlApplicationEngine *m_engine;
    Logger *m_logger;
    Settings *m_settings;
    DatabaseUtils *m_databaseUtils;
    MythUtils *m_mythUtils;
    EventListener *m_eventListener;
    MythQmlAbstractUrlInterceptor *m_urlInterceptor;

    QString m_systemID;

    // local DB
    QSqlDatabase m_mythQMLDB;

    // MythTV DB
    QSqlDatabase m_mythDB;
    QString m_mythDBHost;
    QString m_mythDBPort;
    QString m_mythDBUser;
    QString m_mythDBPassword;
    QString m_mythDBName;
};

extern Context *gContext;

#endif // CONTEXT_H
