// qt
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QDebug>
#include <QHostInfo>
#include <QDomDocument>
#include <QFile>
#include <QDir>
#include <QtWebEngine>
#include <QUrl>

// mythfrontend_qml
#include "recordingsmodel.h"
#include "zmeventsmodel.h"
#include "sqlquerymodel.h"

// shared
#include "context.h"

//#undef QT_NO_DEBUG_OUTPUT

Context *gContext = nullptr;

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // create the context
    gContext = new Context("MythFrontendQML");

    // attempt to connect to the database
    if (!gContext->loadDBSettings())
        return 1;

    gContext->init();

    // these are frontend only

    // recordings model
    qmlRegisterType<RecordingsModel>("RecordingsModel", 1, 0, "RecordingsModel");

    //ZoneMinder Events model
    qmlRegisterType<ZMEventsModel>("ZMEventsModel", 1, 0, "ZMEventsModel");

    // create the radio streams model
    SqlQueryModel *radioStreamsModel = new SqlQueryModel(gContext->m_engine);
    radioStreamsModel->setQuery("SELECT intid, broadcaster, channel, description, "
                                "url1, url2, url3, url4, url5, logourl, country, "
                                "language, genre, metaformat, format "
                                "FROM music_radios ORDER BY broadcaster, channel", gContext->m_db);
    gContext->m_engine->rootContext()->setContextProperty("radioStreamsModel", radioStreamsModel);

    // create the radio streams database model
    SqlQueryModel *radioStreamsDBModel = new SqlQueryModel(gContext->m_engine);
    radioStreamsDBModel->setQuery("SELECT intid, broadcaster, channel, description, "
                                "url1, url2, url3, url4, url5, logourl, country, "
                                "language, genre, metaformat "
                                "FROM music_streams ORDER BY broadcaster, channel", gContext->m_db);
    gContext->m_engine->rootContext()->setContextProperty("radioStreamsDBModel", radioStreamsDBModel);

    // create the news feed model
    SqlQueryModel *rssFeedsModel = new SqlQueryModel(gContext->m_engine);
    rssFeedsModel->setQuery("SELECT name, url, ico, updated, podcast FROM newssites ORDER BY name", gContext->m_db);
    gContext->m_engine->rootContext()->setContextProperty("rssFeedsModel", rssFeedsModel);

    // create the tv channels model
    SqlQueryModel *dbChannelsModel = new SqlQueryModel(gContext->m_engine);
    dbChannelsModel->setQuery("SELECT chanid, channum, callsign, name, icon, xmltvid FROM channel ORDER BY cast(channum as unsigned);", gContext->m_db);
    gContext->m_engine->rootContext()->setContextProperty("dbChannelsModel", dbChannelsModel);

    // load the main screen
    gContext->m_engine->load(QUrl(QString(SHAREPATH) + "qml/main.qml"));

    return app.exec();
}
