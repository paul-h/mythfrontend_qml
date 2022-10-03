// qt
#include <QDir>
#include <QFile>
#include <QUrl>

//common
#include "settings.h"
#include "context.h"

Settings::Settings(const QString &hostName, const QString &theme)
{
    setDefaultSettings(hostName);
    initSettings(hostName, theme);
}

void Settings::initSettings(const QString &hostName, const QString &theme)
{
    setThemeName(theme);
    setHostName(hostName);

    // mysql database
    setMysqlIP(gContext->m_databaseUtils->getSetting("MysqlIP", hostName));
    setMysqlPort(gContext->m_databaseUtils->getSetting("MysqlPort", hostName).toInt());
    setMysqlUser(gContext->m_databaseUtils->getSetting("MysqlUser", hostName));
    setMysqlPassword(gContext->m_databaseUtils->getSetting("MysqlPassword", hostName));
    setMysqlDBName(gContext->m_databaseUtils->getSetting("MysqlDBName", hostName));

    // master backend
    setMasterIP(gContext->m_databaseUtils->getSetting("MasterIP", hostName));
    setMasterPort(gContext->m_databaseUtils->getSetting("MasterPort", hostName).toInt());
    setSecurityPin(gContext->m_databaseUtils->getSetting("SecurityPin", hostName));

    // system paths
    setConfigPath(QDir::homePath() + "/.mythqml/");
    setSharePath(QString(SHAREPATH));
    setQmlPath(QString(SHAREPATH) + "qml/Themes/" + theme + "/");

    // feed source paths
    setVideoPath(gContext->m_databaseUtils->getSetting("VideoPath", hostName));
    setPicturePath(gContext->m_databaseUtils->getSetting("PicturePath", hostName));
    setSdChannels(gContext->m_databaseUtils->getSetting("SdChannels", hostName));
    setWebcamListFile(gContext->m_databaseUtils->getSetting("WebcamListFile", hostName));
    setWebvideoListFile(gContext->m_databaseUtils->getSetting("WebvideoListFile", hostName));
    setYoutubeSubListFile(gContext->m_databaseUtils->getSetting("YoutubeSubListFile", hostName));
    setYoutubeAPIKey(gContext->m_databaseUtils->getSetting("YoutubeAPIKey", hostName));

    // default the websocket port to the master backend port
    setWebsocketPort(masterPort());

    // start fullscreen
    setStartFullscreen((gContext->m_databaseUtils->getSetting("StartFullScreen", hostName) == "true"));

    // use alternate menu layout
    setMythQLayout((gContext->m_databaseUtils->getSetting("MythQLayout", hostName) == "true"));

    // vbox
    setVboxFreeviewIP(gContext->m_databaseUtils->getSetting("VboxFreeviewIP", hostName));
    setVboxFreesatIP(gContext->m_databaseUtils->getSetting("VboxFreesatIP", hostName));

    // hdmiEncoder
    setHdmiEncoder(gContext->m_databaseUtils->getSetting("HdmiEncoder", hostName));

    // menu theme
    QString menuTheme = "classic"; // just use this for now
    setMenuPath(QString(SHAREPATH) + "qml/MenuThemes/" + menuTheme + "/");

    // show text borders debug flag
    setShowTextBorder(false);

    // default OSD timeouts TODO add user settings for these?
    setOsdTimeoutShort(5000);
    setOsdTimeoutMedium(8000);
    setOsdTimeoutLong(30000);

    // zoneminder settings
    setZMIP(gContext->m_databaseUtils->getSetting("ZmIP", hostName));
    setZMUserName(gContext->m_databaseUtils->getSetting("ZmUserName", hostName));
    setZMPassword(gContext->m_databaseUtils->getSetting("ZmPassword", hostName));

    // shutdown settings
    setFrontendIdleTime(gContext->m_databaseUtils->getSetting("FrontendIdleTime", hostName).toInt());
    setLauncherIdleTime(gContext->m_databaseUtils->getSetting("LauncherIdleTime", hostName).toInt());
    setRebootCommand(gContext->m_databaseUtils->getSetting("RebootCommand", hostName));
    setShutdownCommand(gContext->m_databaseUtils->getSetting("ShutdownCommand", hostName));
    setSuspendCommand(gContext->m_databaseUtils->getSetting("SuspendCommand", hostName));

    // auto start
    setAutoStartFrontend(gContext->m_databaseUtils->getSetting("AutoStartFrontend", hostName));

    // tivo
    setTivoIP(gContext->m_databaseUtils->getSetting("TivoIP", hostName));
    setTivoControlPort(gContext->m_databaseUtils->getSetting("TivoControlPort", hostName));
    setTivoVideoURL(gContext->m_databaseUtils->getSetting("TivoVideoURL", hostName));

    //schedules direct
    setSDUserName(gContext->m_databaseUtils->getSetting("SdUserName", hostName));
    setSDPassword(gContext->m_databaseUtils->getSetting("SdPassword", hostName));

    // weather
    setWeatherCurrentConditions(gContext->m_databaseUtils->getSetting("WeatherCurrentConditions", hostName));
    setWeatherBBCForecast(gContext->m_databaseUtils->getSetting("WeatherBBCForecast", hostName));
    setWeatherMetOfficeForecast(gContext->m_databaseUtils->getSetting("WeatherMetOfficeForecast", hostName));
    setWeatherLightningMap(gContext->m_databaseUtils->getSetting("WeatherLightningMap", hostName));
    setWeatherRainRadar(gContext->m_databaseUtils->getSetting("WeatherRainRadar", hostName));
    setWeatherVideoForecast(gContext->m_databaseUtils->getSetting("WeatherVideoForecast", hostName));
}

void Settings::setDefaultSettings(const QString &hostName)
{
    // mysql
    if (gContext->m_databaseUtils->getSetting("MysqlIP", hostName) == "")
    {
        setMysqlIP("127.0.0.1");
        gContext->m_databaseUtils->setSetting("MysqlIP", hostName, "127.0.0.1");
    }

    if (gContext->m_databaseUtils->getSetting("MysqlPort", hostName) == "")
    {
        setMysqlPort(3306);
        gContext->m_databaseUtils->setSetting("MysqlPort", hostName, "3306");
    }

    if (gContext->m_databaseUtils->getSetting("MysqlUser", hostName) == "")
    {
        setMysqlUser("mythtv");
        gContext->m_databaseUtils->setSetting("MysqlUser", hostName, "mythtv");
    }

    if (gContext->m_databaseUtils->getSetting("MysqlPassword", hostName) == "")
    {
        setMysqlPassword("mythtv");
        gContext->m_databaseUtils->setSetting("MysqlPassword", hostName, "mythtv");
    }

    if (gContext->m_databaseUtils->getSetting("MysqlDBName", hostName) == "")
    {
        setMysqlDBName("mythconverg");
        gContext->m_databaseUtils->setSetting("MysqlDBName", hostName, "mythconverg");
    }

    // master backend
    if (gContext->m_databaseUtils->getSetting("MasterIP", hostName) == "")
    {
        setMasterIP("127.0.0.1");
        gContext->m_databaseUtils->setSetting("MasterIP", hostName, "127.0.0.1");
    }

    if (gContext->m_databaseUtils->getSetting("MasterPort", hostName) == "")
    {
        setMasterPort(6544);
        gContext->m_databaseUtils->setSetting("MasterPort", hostName, "6544");
    }

    if (gContext->m_databaseUtils->getSetting("SecurityPin", hostName) == "")
    {
        setSecurityPin("0000"); // TODO check this is the default
        gContext->m_databaseUtils->setSetting("SecurityPin", hostName, "0000");
    }

    // feed source paths
    if (gContext->m_databaseUtils->getSetting("WebcamListFile", hostName) == "")
    {
        setWebcamListFile("https://mythqml.net/download.php?f=webcams_list.xml");
        gContext->m_databaseUtils->setSetting("WebcamListFile", hostName, "https://mythqml.net/download.php?f=webcams_list.xml");
    }

    if (gContext->m_databaseUtils->getSetting("WebvideoListFile", hostName) == "")
    {
        setWebvideoListFile("https://mythqml.net/download.php?f=webvideos_list.xml");
        gContext->m_databaseUtils->setSetting("WebvideoListFile", hostName, "https://mythqml.net/download.php?f=webvideos_list.xml");
    }

    if (gContext->m_databaseUtils->getSetting("YoutubeSubListFile", hostName) == "")
    {
        setYoutubeSubListFile("https://mythqml.net/download.php?f=youtube_subs_list.xml");
        gContext->m_databaseUtils->setSetting("YoutubeSubListFile", hostName, "https://mythqml.net/download.php?f=youtube_subs_list.xml");
    }

    // start fullscreen
    if (gContext->m_databaseUtils->getSetting("StartFullScreen", hostName) == "")
    {
        setStartFullscreen(true);
        gContext->m_databaseUtils->setSetting("StartFullScreen", hostName, "true");
    }

    // use alternate menu layout
    if (gContext->m_databaseUtils->getSetting("MythQLayout", hostName) == "")
    {
        setMythQLayout(false);
        gContext->m_databaseUtils->setSetting("MythQLayout", hostName, "false");
    }

    // shutdown settings
    if (gContext->m_databaseUtils->getSetting("FrontendIdleTime", hostName) == "")
    {
        setFrontendIdleTime(90);
        gContext->m_databaseUtils->setSetting("FrontendIdleTime", hostName, "90");
    }

    if (gContext->m_databaseUtils->getSetting("LauncherIdleTime", hostName) == "")
    {
        setLauncherIdleTime(10);
        gContext->m_databaseUtils->setSetting("LauncherIdleTime", hostName, "10");
    }

    if (gContext->m_databaseUtils->getSetting("RebootCommand", hostName) == "")
    {
        setRebootCommand("sudo /sbin/reboot");
        gContext->m_databaseUtils->setSetting("RebootCommand", hostName, "sudo /sbin/reboot");
    }

    if (gContext->m_databaseUtils->getSetting("ShutdownCommand", hostName) == "")
    {
        setShutdownCommand("sudo /sbin/poweroff");
        gContext->m_databaseUtils->setSetting("ShutdownCommand", hostName, "sudo /sbin/poweroff");
    }

    if (gContext->m_databaseUtils->getSetting("SuspendCommand", hostName) == "")
    {
        setShutdownCommand("systemctl suspend");
        gContext->m_databaseUtils->setSetting("SuspendCommand", hostName, "systemctl suspend");
    }

    // auto start
    if (gContext->m_databaseUtils->getSetting("AutoStartFrontend", hostName) == "")
    {
        setAutoStartFrontend("QML_Frontend");
        gContext->m_databaseUtils->setSetting("AutoStartFrontend", hostName, "QML_Frontend");
    }

    // tivo
    if (gContext->m_databaseUtils->getSetting("TivoControlPort", hostName) == "")
    {
        setTivoControlPort("31339");
        gContext->m_databaseUtils->setSetting("TivoControlPort", hostName, "31339");
    }

    // weather
    if (gContext->m_databaseUtils->getSetting("WeatherCurrentConditions", hostName) == "")
    {
        setWeatherCurrentConditions("http://192.168.1.33/weewx/ss/index.html");
        gContext->m_databaseUtils->setSetting("WeatherCurrentConditions", hostName, "http://192.168.1.33/weewx/ss/index.html");
    }

    if (gContext->m_databaseUtils->getSetting("WeatherBBCForecast", hostName) == "")
    {
        setWeatherCurrentConditions("https://www.bbc.co.uk/weather/0/2644547");
        gContext->m_databaseUtils->setSetting("WeatherBBCForecast", hostName, "https://www.bbc.co.uk/weather/0/2644547");
    }

    if (gContext->m_databaseUtils->getSetting("WeatherMetOfficeForecast", hostName) == "")
    {
        setWeatherCurrentConditions("https://www.metoffice.gov.uk/public/weather/forecast/gcw16xq5y");
        gContext->m_databaseUtils->setSetting("WeatherMetOfficeForecast", hostName, "https://www.metoffice.gov.uk/public/weather/forecast/gcw16xq5y");
    }

    if (gContext->m_databaseUtils->getSetting("WeatherLightningMap", hostName) == "")
    {
        setWeatherCurrentConditions("https://www.lightningmaps.org/blitzortung/europe/index.php?bo_page=archive&bo_map=uk&bo_animation=now");
        gContext->m_databaseUtils->setSetting("WeatherLightningMap", hostName, "https://www.lightningmaps.org/blitzortung/europe/index.php?bo_page=archive&bo_map=uk&bo_animation=now");
    }

    if (gContext->m_databaseUtils->getSetting("WeatherRainRadar", hostName) == "")
    {
        setWeatherCurrentConditions("https://embed.windy.com/embed2.html?lat=53.6953&lon=-2.69348&zoom=7&level=surface&overlay=radar&menu=&message=&marker=&calendar=&pressure=&type=map&location=coordinates&detail=&detailLat=37.2747&detailLon=-122.02298&metricWind=mph&metricTemp=%C2%B0F&radarRange=-1");
        gContext->m_databaseUtils->setSetting("WeatherRainRadar", hostName, "https://embed.windy.com/embed2.html?lat=53.6953&lon=-2.69348&zoom=7&level=surface&overlay=radar&menu=&message=&marker=&calendar=&pressure=&type=map&location=coordinates&detail=&detailLat=37.2747&detailLon=-122.02298&metricWind=mph&metricTemp=%C2%B0F&radarRange=-1");
    }

    if (gContext->m_databaseUtils->getSetting("WeatherVideoForecast", hostName) == "")
    {
        setWeatherCurrentConditions("https://players.brightcove.net/2310970326001/rkbBbpMdNx_default/index.html?playlistId=2320300299001&autoplay");
        gContext->m_databaseUtils->setSetting("WeatherVideoForecast", hostName, "https://players.brightcove.net/2310970326001/rkbBbpMdNx_default/index.html?playlistId=2320300299001&autoplay");
    }
}

// general get/set methods

QString Settings::getSetting(const QString &setting)
{
    return gContext->m_databaseUtils->getSetting(setting, m_hostName);
}

void Settings::setSetting(const QString &setting, const QString &value)
{
    gContext->m_databaseUtils->setSetting(setting, m_hostName, value);
}

// Mysql Database
QString Settings::mysqlIP(void)
{
    return m_mysqlIP;
}

void Settings::setMysqlIP(const QString &mysqlIP)
{
    m_mysqlIP = mysqlIP;
    emit mysqlIPChanged();
}

int Settings::mysqlPort(void)
{
    return m_mysqlPort;
}

void Settings::setMysqlPort(int mysqlPort)
{
    m_mysqlPort = mysqlPort;
    emit mysqlPortChanged();
}

QString Settings::mysqlUser(void)
{
    return m_mysqlUser;
}

void Settings::setMysqlUser(const QString &mysqlUser)
{
    m_mysqlUser = mysqlUser;
    emit mysqlUserChanged();
}

QString Settings::mysqlPassword(void)
{
    return m_mysqlPassword;
}

void Settings::setMysqlPassword(const QString &mysqlPassword)
{
    m_mysqlPassword = mysqlPassword;
    emit mysqlPasswordChanged();
}
QString Settings::mysqlDBName(void)
{
    return m_mysqlDBName;
}

void Settings::setMysqlDBName(const QString &mysqlDBName)
{
    m_mysqlDBName = mysqlDBName;
    emit mysqlDBNameChanged();
}

// MythTV backend
QString Settings::themeName(void)
{
    return m_themeName;
}

void Settings::setThemeName(const QString &themeName)
{
    m_themeName = themeName;

    if (gContext->m_urlInterceptor)
        gContext->m_urlInterceptor->setTheme(themeName);

    emit themeNameChanged();
}

QString Settings::hostName(void)
{
    return m_hostName;
}

void Settings::setHostName(const QString &hostName)
{
    m_hostName = hostName;
    emit hostNameChanged();
}

QString Settings::masterIP(void)
{
    return m_masterIP;
}

void Settings::setMasterIP(const QString &masterIP)
{
    m_masterIP = masterIP;
    emit masterIPChanged();
    emit masterBackendChanged();
}

int Settings::masterPort(void)
{
    return m_masterPort;
}

void Settings::setMasterPort(int masterPort)
{
    m_masterPort = masterPort;
    emit masterPortChanged();
    emit masterBackendChanged();
}

QString Settings::masterBackend()
{
    return QString("http://%1:%2/").arg(m_masterIP).arg(m_masterPort);
}


QString Settings::securityPin(void)
{
    return m_securityPin;
}

void Settings::setSecurityPin(const QString &securityPin)
{
    m_securityPin = securityPin;
    emit securityPinChanged();
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

QString Settings::menuPath(void)
{
    return m_menuPath;
}

void Settings::setMenuPath(const QString &menuPath)
{
    m_menuPath = menuPath;
    emit menuPathChanged();
}

int Settings::websocketPort(void)
{
    return m_websocketPort;
}

void Settings::setWebsocketPort(int websocketPort)
{
    m_websocketPort = websocketPort;
    emit websocketPortChanged();
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

bool Settings::mythQLayout(void)
{
    return m_mythQLayout;
}

void Settings::setMythQLayout(const bool mythQLayout)
{
    m_mythQLayout = mythQLayout;
    emit mythQLayoutChanged();
}

QString Settings::webcamListFile(void)
{
    return m_webcamListFile;
}

void Settings::setWebcamListFile(const QString &webcamListFile)
{
    m_webcamListFile = webcamListFile;
    emit webcamListFileChanged();
}

QString Settings::webvideoListFile(void)
{
    return m_webvideoListFile;
}

void Settings::setWebvideoListFile(const QString &webvideoListFile)
{
    m_webvideoListFile = webvideoListFile;
    emit webvideoListFileChanged();
}

QString Settings::youtubeSubListFile(void)
{
    return m_youtubeSubListFile;
}

void Settings::setYoutubeSubListFile(const QString &youtubeSubListFile)
{
    m_youtubeSubListFile = youtubeSubListFile;
    emit youtubeSubListFileChanged();
}

QString Settings::youtubeAPIKey(void)
{
    return m_youtubeAPIKey;
}

void Settings::setYoutubeAPIKey(const QString &youtubeAPIKey)
{
    m_youtubeAPIKey = youtubeAPIKey;
    emit youtubeAPIKeyChanged();
}

int Settings::osdTimeoutShort(void)
{
    return m_osdTimeoutShort;
}

void Settings::setOsdTimeoutShort(const int osdTimeoutShort)
{
    m_osdTimeoutShort = osdTimeoutShort;
    emit osdTimeoutShortChanged();
}

int Settings::osdTimeoutMedium(void)
{
    return m_osdTimeoutMedium;
}

void  Settings::setOsdTimeoutMedium(const int osdTimeoutMedium)
{
    m_osdTimeoutMedium = osdTimeoutMedium;
    emit osdTimeoutMediumChanged();
}

int Settings::osdTimeoutLong(void)
{
    return m_osdTimeoutLong;
}

void Settings::setOsdTimeoutLong(const int osdTimeoutLong)
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

int Settings::frontendIdleTime(void)
{
    return m_frontendIdleTime;
}

void Settings::setFrontendIdleTime(const int idleTime)
{
    m_frontendIdleTime = idleTime;
    emit frontendIdleTimeChanged();
}

int Settings::launcherIdleTime(void)
{
    return m_launcherIdleTime;
}

void Settings::setLauncherIdleTime(const int idleTime)
{
    m_launcherIdleTime = idleTime;
    emit launcherIdleTimeChanged();
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

QString Settings::suspendCommand(void)
{
    return m_suspendCommand;
}

void    Settings::setSuspendCommand(const QString &suspendCommand)
{
    m_suspendCommand = suspendCommand;
    emit suspendCommandChanged();
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

QString Settings::tivoIP(void)
{
    return m_tivoIP;
}

void Settings::setTivoIP(const QString &tivoIP)
{
    m_tivoIP = tivoIP;
    emit tivoIPChanged();
}

QString Settings::tivoControlPort(void)
{
    return m_tivoControlPort;
}

void Settings::setTivoControlPort(const QString &tivoControlPort)
{
    m_tivoControlPort = tivoControlPort;
    emit tivoControlPortChanged();
}

QString Settings::tivoVideoURL(void)
{
    return m_tivoVideoURL;
}

void Settings::setTivoVideoURL(const QString &tivoVideoURL)
{
    m_tivoVideoURL = tivoVideoURL;
    emit tivoVideoURLChanged();
}

QString Settings::sdUserName(void)
{
    return m_sdUserName;
}

void Settings::setSDUserName(const QString &sdUserName)
{
    m_sdUserName = sdUserName;
    emit sdUserNameChanged();
}

QString Settings::sdPassword(void)
{
    return m_sdPassword;
}
void Settings::setSDPassword(const QString &sdPassword)
{
    m_sdPassword = sdPassword;
    emit sdPasswordChanged();
}

QString Settings::weatherCurrentConditions(void)
{
    return m_weatherCurrentConditions;
}

void    Settings::setWeatherCurrentConditions(const QString &currentConditions)
{
     m_weatherCurrentConditions = currentConditions;
     emit weatherCurrentConditionsChanged();
}

QString Settings::weatherBBCForecast(void)
{
    return m_weatherBBCForecast;
}

void    Settings::setWeatherBBCForecast(const QString &BBCForecast)
{
    m_weatherBBCForecast = BBCForecast;
    emit weatherBBCForecastChanged();
}

QString Settings::weatherMetOfficeForecast(void)
{
    return m_weatherMetOfficeForecast;
}

void    Settings::setWeatherMetOfficeForecast(const QString &metOfficeForecast)
{
    m_weatherMetOfficeForecast = metOfficeForecast;
    emit weatherMetOfficeForecastChanged();
}

QString Settings::weatherLightningMap(void)
{
    return m_weatherLightningMap;
}

void    Settings::setWeatherLightningMap(const QString &lightningMap)
{
    m_weatherLightningMap = lightningMap;
    emit weatherLightningMapChanged();
}

QString Settings::weatherRainRadar(void)
{
    return m_weatherRainRadar;
}

void    Settings::setWeatherRainRadar(const QString &rainRadar)
{
    m_weatherRainRadar = rainRadar;
    emit weatherRainRadarChanged();
}

QString Settings::weatherVideoForecast(void)
{
    return m_weatherVideoForecast;
}

void    Settings::setWeatherVideoForecast(const QString &videoForecast)
{
    m_weatherVideoForecast = videoForecast;
    emit weatherVideoForecastChanged();
}

