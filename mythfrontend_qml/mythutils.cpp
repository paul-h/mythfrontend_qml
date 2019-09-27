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

// common
#include "mythutils.h"
#include "context.h"

QString MythUtils::findThemeFile(const QString &fileName)
{
    // do we have a http file
    if (fileName.startsWith("http"))
        return fileName;

    // do we have a full path
    QString f = fileName;
    if (QFile::exists(f.remove("file://")))
        return fileName;

    // look in the active theme
    if (QFile::exists(gContext->m_settings->qmlPath().remove("file://") + fileName))
        return gContext->m_settings->qmlPath() + fileName;

    // look in the default theme
    if (QFile::exists(gContext->m_settings->sharePath().remove("file://") + "qml/Themes/Default/" + fileName))
        return gContext->m_settings->sharePath() + "qml/Themes/Default/" + fileName;

    // not found
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
    s.replace(QRegExp("<a href=.*/a>"), "");

    // images
    s.replace(QRegExp("<img src=.*/>"), "");

    return s;
}

bool MythUtils::sendKeyEvent(QObject *obj, int keyCode)
{
    if (!obj)
        return false;

    Qt::Key key = Qt::Key(keyCode);
    QKeyEvent* event = new QKeyEvent(QKeyEvent::KeyPress, key, Qt::NoModifier, QKeySequence(key).toString());
    QCoreApplication::postEvent(obj, event);

    return true;
}

QPoint MythUtils::getMousePos(void)
{
    return QCursor::pos();
}

void MythUtils::moveMouse(int x, int y)
{
    QPoint globalPoint = QPoint(x, y);
    QCursor::setPos(globalPoint);
}

bool MythUtils::clickMouse(QObject *obj, int x, int y)
{
    if (!obj)
        return false;

    QMouseEvent * event1 = new QMouseEvent ((QEvent::MouseButtonPress), QPoint(x, y),
        Qt::LeftButton,
        Qt::NoButton,
        Qt::NoModifier   );

    QCoreApplication::postEvent(obj, event1);

    usleep(1000);

    QMouseEvent * event2 = new QMouseEvent ((QEvent::MouseButtonRelease), QPoint(x, y),
        Qt::LeftButton,
        Qt::NoButton,
        Qt::NoModifier   );

    QCoreApplication::postEvent(obj, event2);

    return true;
}

bool MythUtils::doubleClickMouse(QObject *obj, int x, int y)
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
