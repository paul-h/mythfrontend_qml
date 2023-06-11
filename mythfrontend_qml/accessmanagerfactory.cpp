#include "context.h"
#include "accessmanagerfactory.h"

MythQmlNetworkAccessManagerFactory::MythQmlNetworkAccessManagerFactory()
{
    // disregard this for now...
    QList<QSslCertificate> cert = QSslCertificate::fromPath(":/public.crt");
    QSslError self_signed_error(QSslError::SelfSignedCertificate, cert.at(0));
    m_expectedSslErrors.append(self_signed_error);
}

MythQmlNetworkAccessManagerFactory::~MythQmlNetworkAccessManagerFactory()
{
    //delete nam;
}

QNetworkAccessManager* MythQmlNetworkAccessManagerFactory::create(QObject* parent)
{
    QNetworkAccessManager* m_nam = new QNetworkAccessManager(parent);
    QObject::connect(m_nam, SIGNAL(authenticationRequired(QNetworkReply*, QAuthenticator*)),
                     this, SLOT(onAuthenticationRequired(QNetworkReply*, QAuthenticator*))
                     );

    QObject::connect(m_nam, SIGNAL(sslErrors(QNetworkReply*, QList<QSslError>)),
                     this, SLOT(onIgnoreSslErrors(QNetworkReply*,QList<QSslError>))
                     );
    return m_nam;
}


void MythQmlNetworkAccessManagerFactory::onIgnoreSslErrors(QNetworkReply *reply, QList<QSslError> errors)
{
    gContext->m_logger->debug(Verbose::NETWORK, QString("MythQmlNetworkAccessManagerFactory::onIgnoreSslErrors: url is %1").arg(reply->url().toString()));

    for (int i = 0; i < errors.size(); i++)
    {
        gContext->m_logger->debug(Verbose::NETWORK, QString("        error: %1 - %2").arg(i + 1).arg(errors.at(i).errorString()));
    }

    reply->ignoreSslErrors(errors);
}

void MythQmlNetworkAccessManagerFactory::onAuthenticationRequired(QNetworkReply* reply, QAuthenticator* authenticator)
{
    gContext->m_logger->debug(Verbose::NETWORK, QString("MythQmlNetworkAccessManagerFactory::onAuthenticationRequired: url is %1").arg(reply->url().toString()));

    if (reply->url().host() == gContext->m_settings->tivoIP())
    {
        gContext->m_logger->debug(Verbose::NETWORK, QString("MythQmlNetworkAccessManagerFactory::onAuthenticationRequired: setting username to %1 and password to %2")
                                  .arg(gContext->m_settings->tivoUserName()).arg(gContext->m_settings->tivoPassword()));

        authenticator->setUser(gContext->m_settings->tivoUserName());
        authenticator->setPassword(gContext->m_settings->tivoPassword());
    }
}
