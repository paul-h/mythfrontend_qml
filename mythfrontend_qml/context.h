#ifndef CONTEXT_H
#define CONTEXT_H

#include <QObject>
#include <QSqlDatabase>
#include <QQmlApplicationEngine>

#include "settings.h"
#include "databaseutils.h"
#include "mythutils.h"
#include "keypresslistener.h"
#include "urlinterceptor.h"

class Context : public QObject
{
    Q_OBJECT


public:
    Context(const QString &appName, QObject *parent = nullptr);
    ~Context(void);

signals:

public slots:

public:
    void init(void);
    bool loadDBSettings(void);

    QString m_appName;

    QQmlApplicationEngine *m_engine;
    QSqlDatabase m_db;
    Settings *m_settings;
    DatabaseUtils *m_databaseUtils;
    MythUtils *m_mythUtils;
    KeyPressListener *m_kpl;
    MythQmlAbstractUrlInterceptor *m_urlInterceptor;

    QString m_dbHost;
    QString m_dbPort;
    QString m_dbUser;
    QString m_dbPassword;
    QString m_dbName;

    QString m_securityPin;
};

extern Context *gContext;

#endif // CONTEXT_H
