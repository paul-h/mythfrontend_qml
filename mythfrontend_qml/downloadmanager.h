#ifndef DOWNLOADMANAGER_H
#define DOWNLOADMANAGER_H

#include <QtNetwork>
#include <QtCore>

class DownloadInfo: public QObject
{
    Q_OBJECT
  public:
    explicit DownloadInfo(QUrl url) { m_url = url; }
    ~DownloadInfo() { if (m_reply) m_reply->deleteLater(); }

    QUrl getUrl(void) { return m_url; }
    void setUrl(QUrl url) { m_url = url; }

    QNetworkReply *getReply(void) { return m_reply; }
    void setReply(QNetworkReply *reply) { m_reply = reply; }

    QByteArray *getBuffer(void) { return &m_buffer; }

  private:
    QUrl m_url;
    QNetworkReply *m_reply = nullptr;
    QByteArray     m_buffer;
};

class DownloadManager: public QObject
{
    Q_OBJECT
public:
    explicit DownloadManager(QObject *parent = nullptr);

    void append(const QUrl &url);

signals:
    void finished(QByteArray buffer);

private slots:
    void startNextDownload();
    void downloadFinished();
    void downloadReadyRead();

private:
    bool isHttpRedirect() const;
    void reportRedirect();

    QNetworkAccessManager m_manager;
    QQueue<DownloadInfo*> m_downloadQueue;
    DownloadInfo *m_currentDownload;
};

#endif
