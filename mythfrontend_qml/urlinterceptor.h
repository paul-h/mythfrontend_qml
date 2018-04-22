#pragma once
#include <QQmlAbstractUrlInterceptor>
#include <QQmlApplicationEngine>

#include "settings.h"

class MythQmlAbstractUrlInterceptor : public QQmlAbstractUrlInterceptor
{
  public:
    MythQmlAbstractUrlInterceptor(QQmlApplicationEngine *engine) { m_qmlEngine = engine; }

    QUrl intercept(const QUrl &url, DataType type);

    void setTheme(const QString &theme);

  private:
    QQmlApplicationEngine *m_qmlEngine;
    QString m_theme;
    QString m_activeThemePath;
    QString m_defaultThemePath;

    QMap<QString, QString> m_fileMap;
};
