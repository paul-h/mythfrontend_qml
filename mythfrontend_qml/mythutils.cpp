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

 bool MythUtils::writeMetadataXML(const QString &mxmlFile, QObject *metadata)
 {
    QDomDocument doc("MythMetadataXML");

    QDomElement root = doc.createElement("metadata");
    doc.appendChild(root);

    QDomElement item = doc.createElement("item");
    root.appendChild(item);

    QString RFC822("ddd, d MMMM yyyy hh:mm:ss");

    // add each metadata items
    QDomElement title = doc.createElement("title");
    item.appendChild(title);
    title.appendChild(doc.createTextNode(metadata->property("title").toString()));

    QDomElement subtitle = doc.createElement("subtitle");
    item.appendChild(subtitle);
    subtitle.appendChild(doc.createTextNode(metadata->property("subtitle").toString()));

    QDomElement desc = doc.createElement("description");
    item.appendChild(desc);
    desc.appendChild(doc.createTextNode(metadata->property("description").toString()));

    QDomElement episode = doc.createElement("episode");
    item.appendChild(episode);
    episode.appendChild(doc.createTextNode(metadata->property("episode").toString()));

    QDomElement season = doc.createElement("season");
    item.appendChild(season);
    season.appendChild(doc.createTextNode(metadata->property("season").toString()));

    QDomElement tagline = doc.createElement("tagline");
    item.appendChild(tagline);
    tagline.appendChild(doc.createTextNode(metadata->property("tagline").toString()));

    QStringList cats = metadata->property("categories").toString().split(",", Qt::SkipEmptyParts);
    QDomElement categories = doc.createElement("categories");
    item.appendChild(categories);

    for (const auto & str : qAsConst(cats))
    {
        QString trimmedStr = str.trimmed();
        QDomElement cat = doc.createElement("category");
        categories.appendChild(cat);
        cat.setAttribute("type", "genre");
        cat.setAttribute("name", trimmedStr);
    }

    QDomElement contenttype = doc.createElement("contenttype");
    item.appendChild(contenttype);
    contenttype.appendChild(doc.createTextNode(metadata->property("contentType").toString()));

    QDomElement nsfw = doc.createElement("nsfw");
    item.appendChild(nsfw);
    nsfw.appendChild(doc.createTextNode(metadata->property("nsfw").toString()));

    QDomElement inetref = doc.createElement("inetref");
    item.appendChild(inetref);
    inetref.appendChild(doc.createTextNode(metadata->property("inetref").toString()));

    QDomElement website = doc.createElement("website");
    item.appendChild(website);
    website.appendChild(doc.createTextNode(metadata->property("website").toString()));

    QDomElement studio = doc.createElement("studio");
    item.appendChild(studio);
    studio.appendChild(doc.createTextNode(metadata->property("studio").toString()));

    QDomElement coverart = doc.createElement("coverart");
    item.appendChild(coverart);
    coverart.appendChild(doc.createTextNode(metadata->property("coverart").toString()));

    QDomElement fanart = doc.createElement("fanart");
    item.appendChild(fanart);
    fanart.appendChild(doc.createTextNode(metadata->property("fanart").toString()));

    QDomElement banner = doc.createElement("banner");
    item.appendChild(banner);
    banner.appendChild(doc.createTextNode(metadata->property("banner").toString()));

    QDomElement front = doc.createElement("front");
    item.appendChild(front);
    front.appendChild(doc.createTextNode(metadata->property("front").toString()));

    QDomElement back = doc.createElement("back");
    item.appendChild(back);
    back.appendChild(doc.createTextNode(metadata->property("back").toString()));

    QDomElement screenshot = doc.createElement("screenshot");
    item.appendChild(screenshot);
    screenshot.appendChild(doc.createTextNode(metadata->property("screenshot").toString()));

    QDomElement channum = doc.createElement("channum");
    item.appendChild(channum);
    channum.appendChild(doc.createTextNode(metadata->property("channum").toString()));

    QDomElement callsign = doc.createElement("callsign");
    item.appendChild(callsign);
    callsign.appendChild(doc.createTextNode(metadata->property("callsign").toString()));

    QDomElement startts = doc.createElement("startts");
    item.appendChild(startts);
    startts.appendChild(doc.createTextNode(metadata->property("startts").toString()));

    QDomElement releasedate = doc.createElement("releasedate");
    item.appendChild(releasedate);
    releasedate.appendChild(doc.createTextNode(metadata->property("releasedate").toString()));

    QDomElement runtime = doc.createElement("runtime");
    item.appendChild(runtime);
    runtime.appendChild(doc.createTextNode(metadata->property("runtime").toString()));

    QDomElement runtimesecs = doc.createElement("runtimesecs");
    item.appendChild(runtimesecs);
    runtimesecs.appendChild(doc.createTextNode(metadata->property("runtimesecs").toString()));

    QDomElement status = doc.createElement("status");
    item.appendChild(status);
    status.appendChild(doc.createTextNode(metadata->property("status").toString()));

    QDomElement extras = doc.createElement("extras");
    item.appendChild(extras);
    qDebug() << "extras: " << metadata->property("extras").toString();
    QByteArray jsonStr = metadata->property("extras").toByteArray();

    if (!jsonStr.isEmpty())
    {
        QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonStr);

        if (jsonDoc.isNull())
            gContext->m_logger->error(Verbose::GENERAL, QString("Failed to parse JSON for extras"));
        else
        {
            QJsonObject jsonObj = jsonDoc.object();
            QJsonArray jsonArr = jsonObj["extras"].toArray();

            foreach (const QJsonValue &value, jsonArr)
            {
                QJsonObject obj = value.toObject();
                QString name = obj["name"].toString();
                QString url = obj["url"].toString();

                QDomElement extra = doc.createElement("extra");
                extras.appendChild(extra);
                extra.setAttribute("name", name);
                extra.setAttribute("url", url);
            }
        }
    }

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

