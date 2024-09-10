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
    void cleanUp();

public:
    bool init(void);

    QString getOSVersion();
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
};

extern Context *gContext;

#endif // CONTEXT_H
