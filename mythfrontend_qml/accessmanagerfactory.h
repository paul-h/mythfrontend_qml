#ifndef ACCESSMANAGERFACTORY_H
#define ACCESSMANAGERFACTORY_H

#include <QQmlNetworkAccessManagerFactory>
#include <QObject>
#include <QNetworkReply>
#include <QList>
#include <QSslError>
#include <QNetworkAccessManager>
#include <QDebug>
#include <QSslCertificate>
#include <QAuthenticator>

class MythQmlNetworkAccessManagerFactory : public QObject,
                                           public QQmlNetworkAccessManagerFactory
{
  Q_OBJECT

public:
    explicit MythQmlNetworkAccessManagerFactory();
    ~MythQmlNetworkAccessManagerFactory();
    virtual QNetworkAccessManager* create(QObject* parent);

  public slots:
    void onIgnoreSslErrors(QNetworkReply* reply, QList<QSslError> errors);
    void onAuthenticationRequired(QNetworkReply* reply, QAuthenticator* authenticator);
  private:
    QNetworkAccessManager* m_nam;
    QList<QSslError>       m_expectedSslErrors;
};

#endif // ACCESSMANAGERFACTORY_H
