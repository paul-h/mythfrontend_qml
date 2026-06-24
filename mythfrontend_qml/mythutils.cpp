// c++
#include <unistd.h>

// qt
#include <QFile>
#include <QString>
#include <QGuiApplication>
#include <QQmlContext>
#include <QQuickWindow>
#include <QPixmap>
#include <QImage>
#include <QDomDocument>
#include <QJsonDocument>
#include <QRegularExpression>

// common
#include "mythutils.h"
#include "context.h"

QString MythUtils::findThemeFile(const QString &fileName)
{
    gContext->m_logger->debug(Verbose::FILE, QString("MythUtils::findThemeFile: looking for '%1'").arg(fileName));

    // do we have a http file
    if (fileName.startsWith("http"))
    {
        gContext->m_logger->debug(Verbose::FILE, QString("MythUtils::findThemeFile: is http file - Result is: '%1'").arg(fileName));
        return fileName;
    }

    // do we have a full path
    QString f = fileName;
    if (QFile::exists(f.remove("file://")))
    {
        gContext->m_logger->debug(Verbose::FILE, QString("MythUtils::findThemeFile: have full path - Result is: '%1'").arg(fileName));
        return fileName;
    }

    // look in the active theme
    if (QFile::exists(gContext->m_settings->qmlPath().remove("file://") + fileName))
    {
        gContext->m_logger->debug(Verbose::FILE, QString("MythUtils::findThemeFile: is in active theme - Result is: '%1'").arg(gContext->m_settings->qmlPath() + fileName));
        return gContext->m_settings->qmlPath() + fileName;
    }

    // look in the default theme
    if (QFile::exists(gContext->m_settings->sharePath().remove("file://") + "qml/Themes/Default/" + fileName))
    {
        gContext->m_logger->debug(Verbose::FILE, QString("MythUtils::findThemeFile: is in default theme - Result is: '%1'").arg(gContext->m_settings->sharePath() + "qml/Themes/Default/" + fileName));
        return gContext->m_settings->sharePath() + "qml/Themes/Default/" + fileName;
    }

    // not found
    gContext->m_logger->debug(Verbose::FILE, QString("MythUtils::findThemeFile: file not found!"));
    return QString();
}

bool MythUtils::grabScreen(const QString& fileName)
{
    QQuickWindow *qw = dynamic_cast<QQuickWindow*>(m_engine->rootObjects().first());

    if (!qw)
    {
        return false;
    }

    QImage image = qw->grabWindow();

    if (image.isNull())
        return false;

    return image.save(fileName, "PNG");
}

bool MythUtils::fileExists(const QString& fileName)
{
    return QFile::exists(fileName);
}

bool MythUtils::removeFile(const QString& fileName)
{
    return QFile::remove(fileName);
}

QString MythUtils::calcFileHash(const QString& filename)
{
    QFile file(filename);
    QFileInfo fileinfo(file);
    qint64 initialsize = fileinfo.size();
    quint64 hash = 0;

    if (initialsize == 0)
        return {"NULL"};

    if (file.open(QIODevice::ReadOnly))
        hash = initialsize;
    else
    {
        gContext->m_logger->error(Verbose::FILE, "CalcFileHash - Error: Unable to open selected file, missing read permissions?");
        return {"NULL"};
    }

    file.seek(0);
    QDataStream stream(&file);
    stream.setByteOrder(QDataStream::LittleEndian);
    for (quint64 tmp = 0, i = 0; i < 65536/sizeof(tmp); i++)
    {
        stream >> tmp;
        hash += tmp;
    }

    file.seek(initialsize - 65536);
    for (quint64 tmp = 0, i = 0; i < 65536/sizeof(tmp); i++)
    {
        stream >> tmp;
        hash += tmp;
    }

    file.close();

    QString output = QString("%1").arg(hash, 0, 16);
    return output;
}

void MythUtils::clearDir(const QString &path)
{
    // for security only allow paths in the config directory
    if (!path.startsWith((gContext->m_settings->configPath())))
    {
        gContext->m_logger->warning(Verbose::FILE, QString("MythUtils::clearDir: not allowed to clear this directory: '%1'").arg(path));
        return;
    }

    QDir dir( path );

    dir.setFilter(QDir::NoDotAndDotDot | QDir::Files);
    foreach(QString dirItem, dir.entryList())
        dir.remove(dirItem);

    dir.setFilter(QDir::NoDotAndDotDot | QDir::Dirs);
    foreach(QString dirItem, dir.entryList())
    {
        QDir subDir(dir.absoluteFilePath(dirItem));
        subDir.removeRecursively();
    }
}

bool MythUtils::mkPath(const QString &path)
{
    QDir d;

    return d.mkpath(path);
}

QDateTime MythUtils::addMinutes(const QDateTime& dateTime, int minutes)
{
    return dateTime.addSecs(minutes * 60);
}

Q_INVOKABLE QString MythUtils::formatDateTime(const QDateTime &dateTime)
{
    QDate now = QDate::currentDate();
    if (now == dateTime.date())
        return "Today, " + dateTime.toString("hh:mm:ss");
    else if (now.addDays(-1) == dateTime.date())
        return "Yesterday, " + dateTime.toString("hh:mm:ss");
    else if (now.addDays(1) == dateTime.date())
        return "Tomorrow, " + dateTime.toString("hh:mm:ss");

    return dateTime.toString("ddd dd MMM yyyy hh:mm:ss");
}

Q_INVOKABLE QString MythUtils::formatDate(const QDateTime &dateTime)
{
    QDate now = QDate::currentDate();
    if (now == dateTime.date())
        return "Today";
    else if (now.addDays(-1) == dateTime.date())
        return "Yesterday";
    else if (now.addDays(1) == dateTime.date())
        return "Tomorrow";

    return dateTime.toString("ddd dd MMM yyyy");
}

// from MythNews newssite.cpp
QString MythUtils::replaceHtmlChar(const QString &orig)
{
    if (orig.isEmpty())
        return orig;

    QString s = orig;
    s.replace("&amp;", "&");
    s.replace("&lt;", "<");
    s.replace("&gt;", ">");
    s.replace("&quot;", "\"");
    s.replace("&apos;", "\'");
    s.replace("&#8220;",QChar(8220));
    s.replace("&#8221;",QChar(8221));
    s.replace("&#8230;",QChar(8230));
    s.replace("&#233;",QChar(233));
    s.replace("&mdash;", QChar(8212));
    s.replace("&nbsp;", " ");
    s.replace("&#160;", QChar(160));
    s.replace("&#225;", QChar(225));
    s.replace("&#8216;", QChar(8216));
    s.replace("&#8217;", QChar(8217));
    s.replace("&#039;", "\'");
    s.replace("&#39;", "\'");
    s.replace("&#173;", "-");
    s.replace("&ndash;", QChar(8211));

    // german umlauts
    s.replace("&auml;", QChar(0x00e4));
    s.replace("&ouml;", QChar(0x00f6));
    s.replace("&uuml;", QChar(0x00fc));
    s.replace("&Auml;", QChar(0x00c4));
    s.replace("&Ouml;", QChar(0x00d6));
    s.replace("&Uuml;", QChar(0x00dc));
    s.replace("&szlig;", QChar(0x00df));

    // links
    s.replace(QRegularExpression("<a href=.*/a>"), "");

    // images
    s.replace(QRegularExpression("<img src=.*/>"), "");

    return s;
}

bool MythUtils::sendKeyEvent(QObject *obj, int keyCode, Qt::KeyboardModifiers modifiers)
{
    if (!obj)
        return false;

    Qt::Key key = Qt::Key(keyCode);
    QKeyEvent* pressEvent = new QKeyEvent(QKeyEvent::KeyPress, key, modifiers, QKeySequence(key).toString());
    QKeyEvent* releaseEvent = new QKeyEvent(QKeyEvent::KeyRelease, key, modifiers, QKeySequence(key).toString());
    QCoreApplication::postEvent(obj, pressEvent);
    QCoreApplication::postEvent(obj, releaseEvent);

    return true;
}

QPoint MythUtils::getMousePos(void)
{
    return QCursor::pos();
}

void MythUtils::mouseMove(int x, int y)
{
    QPoint globalPoint = QPoint(x, y);
    QCursor::setPos(globalPoint);
}

bool MythUtils::mouseLeftClick(QObject *obj, int x, int y)
{
    if (!obj)
        return false;

    QMouseEvent * event1 = new QMouseEvent ((QEvent::MouseButtonPress), QPoint(x, y),
        Qt::LeftButton,
        Qt::LeftButton,
        Qt::NoModifier   );

    QCoreApplication::postEvent(obj, event1);

    QMouseEvent * event2 = new QMouseEvent ((QEvent::MouseButtonRelease), QPoint(x, y),
        Qt::LeftButton,
        Qt::LeftButton,
        Qt::NoModifier   );

    QCoreApplication::postEvent(obj, event2);

    return true;
}

bool MythUtils::mouseLeftDoubleClick(QObject *obj, int x, int y)
{
    if (!obj)
        return false;

    QMouseEvent * event1 = new QMouseEvent ((QEvent::MouseButtonDblClick), QPoint(x, y),
        Qt::LeftButton,
        Qt::LeftButton,
        Qt::NoModifier   );

    QCoreApplication::postEvent(obj, event1);

    return true;
}

QImage MythUtils::cropRailcamImage(QImage image)
{
    QColor bgColor = image.pixelColor(QPoint(0,0));
    QColor altBgColor = QColor(0x11, 0x11, 0x11);

    int x = 0, y = 0, width = 0, height = 0;

    // find left edge
    for (int i = 0; i < image.width(); i++)
    {
        if (image.pixelColor(QPoint(i, 100)) != bgColor)
        {
            x = i;
            break;
        }
    }

    // find right edge
    for (int i = image.width() - 1; i > 0; i--)
    {
        if (image.pixelColor(QPoint(i, 100)) != bgColor && image.pixelColor(QPoint(i, 100)) != altBgColor)
        {
            width = i - x;
            break;
        }
    }

    // find top edge
    for (int i = 0; i < image.height(); i++)
    {
        if (image.pixelColor(QPoint(image.width() / 2, i)) != bgColor)
        {
            y = i;
            break;
        }
    }

    // find bottom edge
    for (int i = image.height() - 1; i > 0; i--)
    {
        if (image.pixelColor(QPoint(image.width() / 2, i)) != bgColor && image.pixelColor(QPoint(image.width() / 2, i)) != altBgColor)
        {
            height = i - y;
            break;
        }
    }

    QImage res = image.copy(x, y, width, height);
    res.save(gContext->m_settings->configPath() + "Snapshots/railcam.png");
    return res;
}

QString MythUtils::properties(QObject *item, bool linebreak)
{
    const QMetaObject *meta = item->metaObject();

    QHash<QString, QVariant> list;
    for (int i = 0; i < meta->propertyCount(); i++)
    {
        QMetaProperty property = meta->property(i);
        const char* name = property.name();
        QVariant value = item->property(name);
        list[name] = value;
    }

    QString out;
    QHashIterator<QString, QVariant> i(list);
    while (i.hasNext()) {
        i.next();
        if (!out.isEmpty())
        {
            out += ", ";
            if (linebreak) out += "\n";
        }
        out.append(i.key());
        out.append(": ");
        out.append(i.value().toString());
    }
    return out;
}

QString MythUtils::compressStr(const QString &str)
{
    return qCompress(str.toUtf8(), 5);
}

QString MythUtils::unCompressStr(const QString &str)
{
    return QString::fromUtf8(qUncompress(str.toUtf8()));
}

bool MythUtils::writeMetadataXML(const QString &mxmlFile, const QString &metadata)
{
    QJsonParseError parseError;
    QJsonDocument jsonDoc;
    jsonDoc = QJsonDocument::fromJson(metadata.toUtf8(), &parseError);
    if (parseError.error != QJsonParseError::NoError){
        qWarning() << "Parse error at " << parseError.offset << ":" << parseError.errorString();
        return false;
    }

    QJsonObject jsonObj;
    jsonObj = jsonDoc.object();

    QDomDocument doc("MythMetadataXML");

    QDomElement root = doc.createElement("metadata");
    doc.appendChild(root);

    QDomElement item = doc.createElement("item");
    root.appendChild(item);

    QString RFC822("ddd, d MMMM yyyy hh:mm:ss");

    // add each metadata items
    QDomElement title = doc.createElement("title");
    item.appendChild(title);
    title.appendChild(doc.createTextNode(jsonObj["title"].toString()));

    QDomElement subtitle = doc.createElement("subtitle");
    item.appendChild(subtitle);
    subtitle.appendChild(doc.createTextNode(jsonObj["subtitle"].toString()));

    QDomElement desc = doc.createElement("description");
    item.appendChild(desc);
    desc.appendChild(doc.createTextNode(jsonObj["description"].toString()));

    QDomElement episode = doc.createElement("episode");
    item.appendChild(episode);
    episode.appendChild(doc.createTextNode(jsonObj["episode"].toString()));

    QDomElement season = doc.createElement("season");
    item.appendChild(season);
    season.appendChild(doc.createTextNode(jsonObj["season"].toString()));

    QDomElement tagline = doc.createElement("tagline");
    item.appendChild(tagline);
    tagline.appendChild(doc.createTextNode(jsonObj["tagline"].toString()));

    QDomElement categories = doc.createElement("categories");
    item.appendChild(categories);
    QJsonArray jsonArr = jsonObj["categories"].toArray();

    foreach (const QJsonValue &value, jsonArr)
    {
        QString category = value.toString().trimmed();
        QDomElement cat = doc.createElement("category");
        categories.appendChild(cat);
        cat.setAttribute("type", "genre");
        cat.setAttribute("name", category);
    }

    QDomElement contenttype = doc.createElement("contenttype");
    item.appendChild(contenttype);
    contenttype.appendChild(doc.createTextNode(jsonObj["contentType"].toString()));

    QDomElement nsfw = doc.createElement("nsfw");
    item.appendChild(nsfw);
    nsfw.appendChild(doc.createTextNode(jsonObj["nsfw"].toString()));

    QJsonObject inetrefObj = jsonObj["inetref"].toObject();
    QJsonObject seriesObj = inetrefObj["series"].toObject();
    QJsonObject episodeObj = inetrefObj["episode"].toObject();

    QDomElement inetref = doc.createElement("inetref");
    item.appendChild(inetref);

    QDomElement series = doc.createElement("series");
    inetref.appendChild(series);

    QDomElement imdbID = doc.createElement("imdbid");
    imdbID.appendChild(doc.createTextNode(seriesObj["imdbID"].toString()));
    series.appendChild(imdbID);

    QDomElement tmdbID = doc.createElement("tmdbid");
    tmdbID.appendChild(doc.createTextNode(seriesObj["tmdbID"].toString()));
    series.appendChild(tmdbID);

    QDomElement thetvdbID = doc.createElement("thtvdbid");
    thetvdbID.appendChild(doc.createTextNode(seriesObj["thetvdbID"].toString()));
    series.appendChild(thetvdbID);

    QDomElement tvmazeID = doc.createElement("tvmazeid");
    tvmazeID.appendChild(doc.createTextNode(seriesObj["tvmazeID"].toString()));
    series.appendChild(tvmazeID);

    QDomElement fanartID = doc.createElement("fanartid");
    fanartID.appendChild(doc.createTextNode(seriesObj["fanartID"].toString()));
    series.appendChild(fanartID);

    QDomElement episodeIDs = doc.createElement("episode");
    inetref.appendChild(episodeIDs);

    QDomElement episodeImdbID = doc.createElement("imdbid");
    episodeImdbID.appendChild(doc.createTextNode(episodeObj["imdbID"].toString()));
    episodeIDs.appendChild(episodeImdbID);

    QDomElement episodeTmdbID = doc.createElement("tmdbid");
    episodeTmdbID.appendChild(doc.createTextNode(episodeObj["tmdbID"].toString()));
    episodeIDs.appendChild(episodeTmdbID);

    QDomElement episodeThetvdbID = doc.createElement("thtvdbid");
    episodeThetvdbID.appendChild(doc.createTextNode(episodeObj["thetvdbID"].toString()));
    episodeIDs.appendChild(episodeThetvdbID);

    QDomElement episodeTvmazeID = doc.createElement("tvmazeid");
    episodeTvmazeID.appendChild(doc.createTextNode(episodeObj["tvmazeID"].toString()));
    episodeIDs.appendChild(episodeTvmazeID);

    QDomElement episodeFanartID = doc.createElement("fanartid");
    episodeFanartID.appendChild(doc.createTextNode(episodeObj["fanartID"].toString()));
    episodeIDs.appendChild(episodeFanartID);

    QDomElement website = doc.createElement("website");
    item.appendChild(website);
    website.appendChild(doc.createTextNode(jsonObj["website"].toString()));

    QDomElement studio = doc.createElement("studio");
    item.appendChild(studio);
    studio.appendChild(doc.createTextNode(jsonObj["studio"].toString()));

    QDomElement coverart = doc.createElement("coverart");
    item.appendChild(coverart);
    coverart.appendChild(doc.createTextNode(jsonObj["coverart"].toString()));

    QDomElement fanart = doc.createElement("fanart");
    item.appendChild(fanart);
    fanart.appendChild(doc.createTextNode(jsonObj["fanart"].toString()));

    QDomElement banner = doc.createElement("banner");
    item.appendChild(banner);
    banner.appendChild(doc.createTextNode(jsonObj["banner"].toString()));

    QDomElement front = doc.createElement("front");
    item.appendChild(front);
    front.appendChild(doc.createTextNode(jsonObj["front"].toString()));

    QDomElement back = doc.createElement("back");
    item.appendChild(back);
    back.appendChild(doc.createTextNode(jsonObj["back"].toString()));

    QDomElement screenshot = doc.createElement("screenshot");
    item.appendChild(screenshot);
    screenshot.appendChild(doc.createTextNode(jsonObj["screenshot"].toString()));

    QDomElement channum = doc.createElement("channum");
    item.appendChild(channum);
    channum.appendChild(doc.createTextNode(jsonObj["channum"].toString()));

    QDomElement callsign = doc.createElement("callsign");
    item.appendChild(callsign);
    callsign.appendChild(doc.createTextNode(jsonObj["callsign"].toString()));

    QDomElement startts = doc.createElement("startts");
    item.appendChild(startts);
    startts.appendChild(doc.createTextNode(jsonObj["startts"].toString()));

    QDomElement releasedate = doc.createElement("releasedate");
    item.appendChild(releasedate);
    releasedate.appendChild(doc.createTextNode(jsonObj["releasedate"].toString()));

    QDomElement runtime = doc.createElement("runtime");
    item.appendChild(runtime);
    runtime.appendChild(doc.createTextNode(jsonObj["runtime"].toString()));

    QDomElement runtimesecs = doc.createElement("runtimesecs");
    item.appendChild(runtimesecs);
    runtimesecs.appendChild(doc.createTextNode(jsonObj["runtimesecs"].toString()));

    QDomElement status = doc.createElement("status");
    item.appendChild(status);
    status.appendChild(doc.createTextNode(jsonObj["status"].toString()));

    QDomElement extras = doc.createElement("extras");
    item.appendChild(extras);

    QJsonObject extraObj = jsonObj["extras"].toObject();

    // add videos
    if (extraObj.contains("video"))
    {
        QDomElement videos = doc.createElement("videos");
        extras.appendChild(videos);

        QJsonArray videoArr = extraObj["video"].toArray();

        foreach (const QJsonValue &value, videoArr)
        {
            QJsonObject obj = value.toObject();
            QString name = obj["name"].toString();
            QString url = obj["url"].toString();

            QDomElement video = doc.createElement("video");
            videos.appendChild(video);
            video.setAttribute("name", name);
            video.setAttribute("url", url);
        }
    }

    // add audio
    if (extraObj.contains("audio"))
    {
        QDomElement audios = doc.createElement("audios");
        extras.appendChild(audios);

        QJsonArray audioArr = extraObj["audio"].toArray();

        foreach (const QJsonValue &value, audioArr)
        {
            QJsonObject obj = value.toObject();
            QString name = obj["name"].toString();
            QString url = obj["url"].toString();

            QDomElement audio = doc.createElement("audio");
            audios.appendChild(audio);
            audio.setAttribute("name", name);
            audio.setAttribute("url", url);
        }
    }

    // add subtitles
    if (extraObj.contains("subtitles"))
    {
        QDomElement subtitles = doc.createElement("subtitles");
        extras.appendChild(subtitles);

        QJsonArray subtitlesArr = extraObj["subtitles"].toArray();

        foreach (const QJsonValue &value, subtitlesArr)
        {
            QJsonObject obj = value.toObject();
            QString name = obj["name"].toString();
            QString url = obj["url"].toString();

            QDomElement subtitle = doc.createElement("subtitle");
            subtitles.appendChild(subtitle);
            subtitle.setAttribute("name", name);
            subtitle.setAttribute("url", url);
        }
    }
    // add screeshots
    if (extraObj.contains("screenshots"))
    {
        QDomElement screeshots = doc.createElement("screenshots");
        extras.appendChild(screeshots);

        QJsonArray screeshotsArr = extraObj["screenshots"].toArray();

        foreach (const QJsonValue &value, screeshotsArr)
        {
            QJsonObject obj = value.toObject();
            QString name = obj["name"].toString();
            QString url = obj["url"].toString();

            QDomElement screeshot = doc.createElement("screeshot");
            screeshots.appendChild(screeshot);
            screeshot.setAttribute("name", name);
            screeshot.setAttribute("url", url);
        }
    }

    //qDebug().noquote() << "write XML: " <<doc.toString(4);

    // save the mxml to the file
    QFile f(mxmlFile);
    if (!f.open(QIODevice::WriteOnly))
    {
        gContext->m_logger->info(Verbose::GENERAL, QString("Failed to open mxml file for writing - %1").arg(mxmlFile));
        return false;
    }

    QTextStream t(&f);
    t << doc.toString(4);
    f.close();

    return true;
 }

 bool MythUtils::writeMetadataJSON(const QString &jsonFile, const QString &metadata)
 {
     // make sure the Metadata and Artwork folders have been created
     QFileInfo fi(jsonFile);
     QDir dir(fi.absolutePath());

     dir.cdUp();

     if (!dir.exists("Metadata"))
         dir.mkdir("Metadata");

     if (!dir.exists("Artwork"))
         dir.mkdir("Artwork");

     // save the json to the file
     QFile f(jsonFile);
     if (!f.open(QIODevice::WriteOnly))
     {
         gContext->m_logger->info(Verbose::GENERAL, QString("Failed to open json file for writing - %1").arg(jsonFile));
         return false;
     }

     QTextStream t(&f);
     t << metadata;
     f.close();

     return true;
 }

 int MythUtils::countFiles(const QString &path)
 {
     int count = 0;
     QDir dir(path);
     dir.setFilter(QDir::AllEntries | QDir::NoDotAndDotDot);
     if(!dir.exists())
        return 0;

     QFileInfoList sList = dir.entryInfoList(QDir::AllEntries | QDir::NoDotAndDotDot);

     foreach(QFileInfo finfo, sList)
     {
         if (finfo.isDir())
             count += countFiles(finfo.path() + "/" + finfo.completeBaseName() + "/");

         count++;
     }
     return count;
 }

 QString MythUtils::readTextFile(const QString &textFile)
 {
     QFile file(textFile);
     if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
         return "";

     QString result(file.readAll());

     return result;
 }
