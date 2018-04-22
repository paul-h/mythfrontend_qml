#include "downloadmanager.h"

#include <cstdio>

DownloadManager::DownloadManager(QObject *parent)
    : QObject(parent)
{
    m_currentDownload = nullptr;
}

void DownloadManager::append(const QUrl &url)
{
    qInfo() << "DownloadManager::append: " << url.toString();
    DownloadInfo *dl = new DownloadInfo(url);

    m_downloadQueue.enqueue(dl);

    if (m_downloadQueue.size() == 1)
        QTimer::singleShot(0, this, SLOT(startNextDownload()));
}

void DownloadManager::startNextDownload()
{
    if (m_downloadQueue.isEmpty() || m_currentDownload)
    {
        return;
    }

    m_currentDownload = m_downloadQueue.dequeue();
    QUrl url = m_currentDownload->getUrl();

    QNetworkRequest request(url);
    m_currentDownload->setReply(m_manager.get(request));
    connect(m_currentDownload->getReply(), SIGNAL(finished()), SLOT(downloadFinished()));
    connect(m_currentDownload->getReply(), SIGNAL(readyRead()), SLOT(downloadReadyRead()));

    qInfo() << "DownloadManager: Downloading: " << url.toEncoded();
}

void DownloadManager::downloadFinished()
{
    if (m_currentDownload->getReply()->error())
    {
        // download failed
        qWarning() << "DownloadManager: download failed: " << m_currentDownload->getReply()->errorString();
        m_currentDownload->getBuffer()->clear();
    }
    else
    {
        // let's check if it was actually a redirect
        if (isHttpRedirect())
        {
            reportRedirect();
            m_currentDownload->getBuffer()->clear();
        }
        else
        {
            qDebug() << "DownloadManager: download finished OK.";
        }
    }

    emit finished(*m_currentDownload->getBuffer());
    m_currentDownload->deleteLater();
    m_currentDownload = NULL;

    startNextDownload();
}

void DownloadManager::downloadReadyRead()
{
    m_currentDownload->getBuffer()->append(m_currentDownload->getReply()->readAll());
}

bool DownloadManager::isHttpRedirect() const
{
    int statusCode = m_currentDownload->getReply()->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    return statusCode == 301 || statusCode == 302 || statusCode == 303
           || statusCode == 305 || statusCode == 307 || statusCode == 308;
}

void DownloadManager::reportRedirect()
{
    int statusCode = m_currentDownload->getReply()->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QUrl requestUrl = m_currentDownload->getReply()->request().url();

    qInfo() << "Request: " << requestUrl.toDisplayString() << " was redirected with code: " << statusCode;

    QVariant target = m_currentDownload->getReply()->attribute(QNetworkRequest::RedirectionTargetAttribute);

    if (!target.isValid())
        return;

    QUrl redirectUrl = target.toUrl();
    if (redirectUrl.isRelative())
        redirectUrl = requestUrl.resolved(redirectUrl);

    qInfo() << "Redirected to: " << redirectUrl.toDisplayString();
}
