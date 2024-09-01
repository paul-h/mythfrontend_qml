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

    Q_INVOKABLE void updateRecording(int recordid, const QString &title, const QString &subtitle, const QString &description, const QString &category,
                                     const QString &chanid, const QString &channum, const QString &callsign, const QString &channelname,
                                     const QString &recgroup, const QString &starttime, const QString & airdate, const QString &filename, const QString &hostname);

    Q_INVOKABLE int  addBrowserBookmark(const QString &website, const QString &title, const QString &category, const QString &url, const QString &iconUrl);
    Q_INVOKABLE void updateBrowserBookmark(int bookmarkid, const QString &website, const QString &title, const QString &category, const QString &url, const QString &iconUrl);
    Q_INVOKABLE void deleteBrowserBookmark(int bookmarkid);

    Q_INVOKABLE int  addTivoChannel(int channo, const QString &name, int plus1, const QString &category, const QString &definition, int sdid, const QString &icon);
    Q_INVOKABLE void updateTivoChannel(int chanid,int channo, const QString &name, int plus1, const QString &category, const QString &definition, int sdid, const QString &icon);
    Q_INVOKABLE void deleteTivoChannel(int chanid);

    Q_INVOKABLE int  addMenuItem(const QString &menu, int position, const QString &menuText, const QString &loaderSource, const QString &waterMark, const QString &url,
                                 double zoom, bool fullscreen, int layout, const QString &exec);
    Q_INVOKABLE void updateMenuItem(int itemid,const QString &menu, int position, const QString &menuText, const QString &loaderSource, const QString &waterMark, const QString &url,
                                    double zoom, bool fullscreen, int layout, const QString &exec);
    Q_INVOKABLE void deleteMenuItem(int itemid);

    Q_INVOKABLE bool updateMediaItem(QObject *metadata);
};
