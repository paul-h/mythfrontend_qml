#pragma once

// qt
#include <QObject>
#include <QDateTime>
#include <QQmlApplicationEngine>
#include <QPoint>
#include <QImage>
#include <QQuickItem>

class MythUtils : public QObject
{
    Q_OBJECT
  public:
    MythUtils(QQmlApplicationEngine* engine) {m_engine = engine;}

    Q_INVOKABLE QString findThemeFile(const QString &fileName);
    Q_INVOKABLE bool grabScreen(const QString &fileName);
    Q_INVOKABLE bool fileExists(const QString &fileName);
    Q_INVOKABLE bool removeFile(const QString &fileName);
    Q_INVOKABLE QString calcFileHash(const QString &filename);
    Q_INVOKABLE void clearDir(const QString &path);
    Q_INVOKABLE bool mkPath(const QString &path);
    Q_INVOKABLE QDateTime addMinutes(const QDateTime &dateTime, int minutes);
    Q_INVOKABLE QString formatDateTime(const QDateTime &dateTime);
    Q_INVOKABLE QString formatDate(const QDateTime &dateTime);
    Q_INVOKABLE QString replaceHtmlChar(const QString &orig);
    Q_INVOKABLE bool sendKeyEvent(QObject *obj, int keyCode);
    Q_INVOKABLE void moveMouse(int x, int y);
    Q_INVOKABLE bool clickMouse(QObject *obj, int x, int y);
    Q_INVOKABLE bool doubleClickMouse(QObject *obj, int x, int y);
    Q_INVOKABLE QPoint getMousePos(void);
    Q_INVOKABLE QImage cropRailcamImage(QImage image);
    Q_INVOKABLE QString properties(QObject *item, bool linebreak);
    Q_INVOKABLE QString compressStr(const QString &str);
    Q_INVOKABLE QString unCompressStr(const QString &str);
    Q_INVOKABLE bool writeMetadataXML(const QString &mxmlFile, QObject *metadata);

  private:
    QQmlApplicationEngine *m_engine;
};
