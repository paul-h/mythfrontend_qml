// qt
#include <QDir>
#include <QFile>
#include <QUrl>

//common
#include "settings.h"
#include "context.h"

Settings::Settings(const QString &hostName, const QString &theme)
{
    initSettings(hostName, theme);
}

void Settings::initSettings(const QString &hostName, const QString &theme)
{
    setThemeName(theme);
    setHostName(hostName);
    setConfigPath(QDir::homePath() + "/.mythtv/");
    setSharePath(QString(SHAREPATH));
    setQmlPath(QString(SHAREPATH) + "qml/Themes/" + theme + "/");
    setMasterBackend(gContext->m_databaseUtils->getSetting("Qml_masterBackend", hostName));
    setVideoPath(gContext->m_databaseUtils->getSetting("Qml_videoPath", hostName));
    setPicturePath(gContext->m_databaseUtils->getSetting("Qml_picturePath", hostName));
    setSdChannels(gContext->m_databaseUtils->getSetting("Qml_sdChannels", hostName));
    setWebcamPath(gContext->m_databaseUtils->getSetting("Qml_webcamPath", hostName));

    // set the websocket url using the master backend as a starting point
    QUrl url(masterBackend());
    url.setScheme("ws");
    url.setPort(url.port() + 5);
    setWebSocketUrl(url.toString());

    // start fullscreen
    setStartFullscreen((gContext->m_databaseUtils->getSetting("Qml_startFullScreen", hostName) == "true"));

    // vbox
    setVboxFreeviewIP(gContext->m_databaseUtils->getSetting("Qml_vboxFreeviewIP", hostName));
    setVboxFreesatIP(gContext->m_databaseUtils->getSetting("Qml_vboxFreesatIP", hostName));

    // hdmiEncoder
    setHdmiEncoder(gContext->m_databaseUtils->getSetting("Qml_hdmiEncoder", hostName));

    // look for the theme in ~/.mythtv/themes
    if (QFile::exists(QString(QDir::homePath() + "/.mythtv/themes/") + theme + "/themeinfo.xml"))
        setThemePath(QString(QDir::homePath() + "/.mythtv/themes/") + theme + "/");
    else
        setThemePath(QString(SHAREPATH) + "themes/" + theme + "/");

    // menu theme
    QString menuTheme = "classic"; // just use this for now
    setMenuPath(QString(SHAREPATH) + "qml/MenuThemes/" + menuTheme + "/");

    // show text borders debug flag
    setShowTextBorder(false);

    // default OSD timeouts TODO add user settings for these?
    setOsdTimeoutShort(4000);
    setOsdTimeoutMedium(8000);
    setOsdTimeoutLong(30000);

    // zoneminder settings
    setZMIP(gContext->m_databaseUtils->getSetting("Qml_zmIP", hostName));
    setZMUserName(gContext->m_databaseUtils->getSetting("Qml_zmUserName", hostName));
    setZMPassword(gContext->m_databaseUtils->getSetting("Qml_zmPassword", hostName));

    // shutdown settings
    setIdleTime(gContext->m_databaseUtils->getSetting("Qml_idleTime", hostName).toInt());
    setRebootCommand(gContext->m_databaseUtils->getSetting("Qml_rebootCommand", hostName));
    setShutdownCommand(gContext->m_databaseUtils->getSetting("Qml_shutdownCommand", hostName));

    // auto start
    setAutoStartFrontend(gContext->m_databaseUtils->getSetting("Qml_autoStartFrontend", hostName, "QML_Frontend"));
}

QString Settings::themeName(void)
{
    return m_themeName;
}

void Settings::setThemeName(const QString &themeName)
{
    m_themeName = themeName; emit themeNameChanged();
}

QString Settings::hostName(void)
{
    return m_hostName;
}

void Settings:: setHostName(const QString &hostName)
{
    m_hostName = hostName;
    emit hostNameChanged();
}

QString Settings::configPath(void)
{
    return m_configPath;
}

void Settings::setConfigPath(const QString &configPath)
{
    m_configPath = configPath;
    emit configPathChanged();
}

QString Settings::sharePath(void)
{
    return m_sharePath;
}

void Settings::setSharePath(const QString &sharePath)
{
    m_sharePath = sharePath;
    emit sharePathChanged();
}

QString Settings::qmlPath(void)
{
    return m_qmlPath;
}

void Settings::setQmlPath(const QString &qmlPath)
{
    m_qmlPath = qmlPath;
    emit qmlPathChanged();
}

QString Settings::themePath(void)
{
    return m_themePath;
}

void Settings::setThemePath(const QString &themePath)
{
    m_themePath = themePath;
    emit themePathChanged();
}

QString Settings::menuPath(void)
{
    return m_menuPath;
}

void Settings::setMenuPath(const QString &menuPath)
{
    m_menuPath = menuPath;
    emit menuPathChanged();
}

QString Settings::masterBackend(void)
{
    return m_masterBackend;
}

void Settings:: setMasterBackend(const QString &masterBackend)
{
    m_masterBackend = masterBackend;
    emit masterBackendChanged();
}

QString Settings::webSocketUrl(void)
{
    return m_webSocketUrl;
}

void Settings::setWebSocketUrl(const QString &webSocketUrl)
{
    m_webSocketUrl = webSocketUrl;
    emit webSocketUrlChanged();
}

QString Settings::videoPath(void)
{
    return m_videoPath;
}

void Settings::setVideoPath(const QString &videoPath)
{
    m_videoPath = videoPath;
    emit videoPathChanged();
}

QString Settings::picturePath(void)
{
    return m_picturePath;
}

void Settings::setPicturePath(const QString &picturePath)
{
    m_picturePath = picturePath;
    emit picturePathChanged();
}

QString Settings::sdChannels(void)
{
    return m_sdChannels;
}

void Settings::setSdChannels(const QString &sdChannels)
{
    m_sdChannels = sdChannels;
    emit sdChannelsChanged();
}

QString Settings::vboxFreeviewIP(void)
{
    return m_vboxFreeviewIP;
}

void Settings::setVboxFreeviewIP(const QString &vboxFreeviewIP)
{
    m_vboxFreeviewIP = vboxFreeviewIP;
    emit vboxFreeviewIPChanged();
}

QString Settings::vboxFreesatIP(void)
{
    return m_vboxFreesatIP;
}

void Settings::setVboxFreesatIP(const QString &vboxFreesatIP)
{
    m_vboxFreesatIP = vboxFreesatIP;
    emit vboxFreesatIPChanged();
}

QString Settings::hdmiEncoder(void)
{
    return m_hdmiEncoder;
}

void Settings::setHdmiEncoder(const QString &hdmiEncoder)
{
    m_hdmiEncoder = hdmiEncoder;
    emit hdmiEncoderChanged();
}

bool Settings::showTextBorder(void)
{
    return m_showTextBorder;
}

void Settings:: setShowTextBorder(const bool showTextBorder)
{
    m_showTextBorder = showTextBorder;
    emit showTextBorderChanged();
}

bool Settings::startFullscreen(void)
{
    return m_startFullscreen;
}

void Settings::setStartFullscreen(const bool startFullscreen)
{
    m_startFullscreen = startFullscreen;
    emit startFullscreenChanged();
}

QString Settings::webcamPath(void)
{
    return m_webcamPath;
}

void Settings::setWebcamPath(const QString &webcamPath)
{
    m_webcamPath = webcamPath;
    emit webcamPathChanged();
}

int Settings::osdTimeoutShort(void)
{
    return m_osdTimeoutShort;
}

void Settings::setOsdTimeoutShort(const int &osdTimeoutShort)
{
    m_osdTimeoutShort = osdTimeoutShort;
    emit osdTimeoutShortChanged();
}

int Settings::osdTimeoutMedium(void)
{
    return m_osdTimeoutMedium;
}

void  Settings::setOsdTimeoutMedium(const int &osdTimeoutMedium)
{
    m_osdTimeoutMedium = osdTimeoutMedium;
    emit osdTimeoutMediumChanged();
}

int Settings::osdTimeoutLong(void)
{
    return m_osdTimeoutLong;
}

void Settings::setOsdTimeoutLong(const int &osdTimeoutLong)
{
    m_osdTimeoutLong = osdTimeoutLong;
    emit osdTimeoutLongChanged();
}

QString Settings::zmIP(void)
{
    return m_zmIP;
}

void Settings::setZMIP(const QString &zmIP)
{
    m_zmIP = zmIP;
    emit zmIPChanged();
}

QString Settings::zmUserName(void)
{
    return m_zmUserName;
}

void Settings::setZMUserName(const QString &zmUserName)
{
    m_zmUserName = zmUserName;
    emit zmUserNameChanged();
}

QString Settings::zmPassword(void)
{
    return m_zmPassword;
}
void Settings::setZMPassword(const QString &zmPassword)
{
    m_zmPassword = zmPassword;
    emit zmPasswordChanged();
}

int Settings::idleTime(void)
{
    return m_idleTime;
}

void Settings::setIdleTime(const int &idleTime)
{
    m_idleTime = idleTime;
    emit idleTimeChanged();
}

QString Settings::rebootCommand(void)
{
    return m_rebootCommand;
}

void Settings::setRebootCommand(const QString &rebootCommand)
{
    m_rebootCommand = rebootCommand;
    emit rebootCommandChanged();
}

QString Settings::shutdownCommand(void)
{
    return m_shutdownCommand;
}

void    Settings::setShutdownCommand(const QString &shutdownCommand)
{
    m_shutdownCommand = shutdownCommand;
    emit shutdownCommandChanged();
}

QString Settings::autoStartFrontend(void)
{
    return m_autoStartFrontend;
}

void Settings::setAutoStartFrontend(const QString &autoStartFrontend)
{
    m_autoStartFrontend = autoStartFrontend;
    emit autoStartFrontendChanged();
}

