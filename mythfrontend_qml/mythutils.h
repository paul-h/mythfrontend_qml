#pragma once

// qt
#include <QObject>
#include <QDateTime>
#include <QQmlApplicationEngine>

// mythfrontend_qml
#include "settings.h"

class MythUtils : public QObject
{
    Q_OBJECT
  public:
      MythUtils(QQmlApplicationEngine* engine) {m_engine = engine;}

    Q_INVOKABLE QString findThemeFile(const QString &fileName);
    Q_INVOKABLE bool grabScreen(const QString &fileName);
    Q_INVOKABLE bool fileExists(const QString &fileName);
    Q_INVOKABLE QDateTime addMinutes(const QDateTime &dateTime, int minutes);

  private:
    QQmlApplicationEngine *m_engine;
};
