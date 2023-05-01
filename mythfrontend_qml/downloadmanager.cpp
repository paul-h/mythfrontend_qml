
#include "downloadmanager.h"
#include "context.h"
#include "logger.h"

DownloadManager::DownloadManager(QObject *parent)
    : QObject(parent)
{
    m_currentDownload = nullptr;
}

void DownloadManager::append(const QUrl &url)
{
    gContext->m_logger->debug(Verbose::NETWORK, "DownloadManager: append - " + url.toString());
    DownloadInfo *dl = new DownloadInfo(url);

    // check for duplicate downloads
    for (int x = 0; x < m_downloadQueue.count(); x++)
    {
        if (m_downloadQueue.at(x)->getUrl().toString() == url.toString())
        {
            gContext->m_logger->info(Verbose::NETWORK, QString("DownloadManager: got duplicate url - %1").arg(url.toString()));
            return;
        }
    }

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

    gContext->m_logger->debug(Verbose::NETWORK, "DownloadManager: Downloading - " + url.toEncoded());
}

void DownloadManager::downloadFinished()
{
    if (m_currentDownload->getReply()->error())
    {
        // download failed
        gContext->m_logger->warning(Verbose::NETWORK, "DownloadManager: download failed - " + m_currentDownload->getReply()->errorString());
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
            gContext->m_logger->debug(Verbose::NETWORK, "DownloadManager: download finished OK - " + m_currentDownload->getUrl().toEncoded());
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

    gContext->m_logger->debug(Verbose::NETWORK, "Request: " + requestUrl.toDisplayString() + " was redirected with code: " + statusCode);

    QVariant target = m_currentDownload->getReply()->attribute(QNetworkRequest::RedirectionTargetAttribute);

    if (!target.isValid())
        return;

    QUrl redirectUrl = target.toUrl();
    if (redirectUrl.isRelative())
        redirectUrl = requestUrl.resolved(redirectUrl);

    gContext->m_logger->debug(Verbose::NETWORK, "Redirected to: " + redirectUrl.toDisplayString());
}
