// qt
#include <QDir>

// mythqml
#include "logger.h"
#include "mdkapi.h"
#include "context.h"

#define MDK_LIBRARY_PATH "/usr/lib/mythqml/libmdk.so"

MDKAPI::MDKAPI()
{
    load(MDK_LIBRARY_PATH);
}

MDKAPI::~MDKAPI()
{
    unload();
}

bool MDKAPI::isAvailable(void)
{
    return m_MDK_version && m_mdkGetGlobalOptionString && m_mdkGetGlobalOptionInt32 &&
           m_mdkSetGlobalOptionString && *m_mdkPlayerAPI_new && m_mdkPlayerAPI_delete;
}

bool MDKAPI::load(const QString &path)
{
    if (path.isEmpty())
    {
        gContext->m_logger->error(Verbose::GENERAL, "MDKAPI: Failed to load MDK: empty library path");
        return false;
    }

    if (isLoaded())
    {
        gContext->m_logger->warning(Verbose::GENERAL, "MDKAPI: MDK already loaded. Unloading ...");

        if (!unload())
            return false;
    }

    m_library.setFileName(path);

    gContext->m_logger->info(Verbose::GENERAL, QString("MDKAPI: Start loading MDK from: %1").arg(QDir::toNativeSeparators(path)));

    if (m_library.load())
        gContext->m_logger->info(Verbose::GENERAL, "MDKAPI: MDK has been loaded successfully");
    else
    {
        gContext->m_logger->error(Verbose::GENERAL, QString("MDKAPI: Failed to load MDK: %1").arg(m_library.errorString()));
        return false;
    }

    m_MDK_version = (int (*) (void))m_library.resolve("MDK_version");
    if (!m_MDK_version)
    {
        gContext->m_logger->error(Verbose::GENERAL, "MDKAPI: Failed to find m_MDK_version");
        return false;
    }

    m_mdkPlayerAPI_new = (const mdkPlayerAPI* (*)(void))m_library.resolve("mdkPlayerAPI_new");
    if (!m_mdkPlayerAPI_new)
    {
        gContext->m_logger->error(Verbose::GENERAL, "MDKAPI: Failed to find m_mdkPlayerAPI_new");
        return false;
    }

    m_mdkPlayerAPI_delete = (void * (*)(const mdkPlayerAPI**))m_library.resolve("mdkPlayerAPI_delete");
    if (!m_mdkPlayerAPI_delete)
    {
        gContext->m_logger->error(Verbose::GENERAL, "MDKAPI: Failed to find m_mdkPlayerAPI_delete");
        return false;
    }

    m_mdkGetGlobalOptionString = (bool (*)(const char* key, const char** value))m_library.resolve("MDK_getGlobalOptionString");
    if (!m_mdkGetGlobalOptionString)
    {
        gContext->m_logger->error(Verbose::GENERAL, "MDKAPI: Failed to find MDK_getGlobalOptionString");
        return false;
    }

    m_mdkGetGlobalOptionInt32 = (bool (*)(const char* key, int* value))m_library.resolve("MDK_getGlobalOptionInt32");
    if (!m_mdkGetGlobalOptionInt32)
    {
        gContext->m_logger->error(Verbose::GENERAL, "MDKAPI: Failed to find MDK_getGlobalOptionInt32");
        return false;
    }

    m_mdkSetGlobalOptionString = (void (*)(const char* key, const char* value))m_library.resolve("MDK_setGlobalOptionString");
    if (!m_mdkGetGlobalOptionString)
    {
        gContext->m_logger->error(Verbose::GENERAL, "MDKAPI: Failed to find MDK_setGlobalOptionString");
        return false;
    }

    int mdkVersion = m_MDK_version();
    int major = (mdkVersion & 0xff0000) >> 16;
    int minor = (mdkVersion & 0x00ff00) >> 8;
    int patch = (mdkVersion & 0x0000ff);
    gContext->m_logger->info(Verbose::GENERAL, QString("MDKAPI: MDK Versions is: v%1.%2.%3").arg(major).arg(minor).arg(patch));

    return true;
}

bool MDKAPI::unload(void)
{
    // Player.h
    m_mdkPlayerAPI_new = nullptr;
    m_mdkPlayerAPI_delete = nullptr;
    m_MDK_version = nullptr;

    if (m_library.isLoaded())
    {
        if (!m_library.unload())
        {
            gContext->m_logger->error(Verbose::GENERAL, QString("MDKAPI: Failed to unload MDK: %1").arg(m_library.errorString()));
            return false;
        }
    }

    gContext->m_logger->error(Verbose::GENERAL, "MDKAPI: MDK unloaded successfully");
    return true;
}

bool MDKAPI::isLoaded() const
{
    const bool result = m_mdkPlayerAPI_new && m_mdkPlayerAPI_delete && m_MDK_version;
    return result;
}

const mdkPlayerAPI *MDKAPI::createPlayer(void)
{
    if (m_mdkPlayerAPI_new)
        return m_mdkPlayerAPI_new();

    return nullptr;
}

void MDKAPI::destroyPlayer(const mdkPlayerAPI **player)
{
    if (m_mdkPlayerAPI_delete)
        m_mdkPlayerAPI_delete(player);
}

QString MDKAPI::getFFMPEGVersion(void)
{
    int ffmpegVersion;
    if (m_mdkGetGlobalOptionInt32("ffmpeg.version", &ffmpegVersion))
    {
        gContext->m_logger->info(Verbose::GENERAL, QString("MDKAPI: MDK ffmpeg version: %1").arg(ffmpegVersion));
        return QString::number(ffmpegVersion);
    }

    return QString();
}

QString MDKAPI::getFFMPEGConfig(void)
{
    const char* ffmpegConfig;
    if (m_mdkGetGlobalOptionString("ffmpeg.configuration", &ffmpegConfig))
    {
        QString config = QString::fromLocal8Bit(ffmpegConfig);
        gContext->m_logger->info(Verbose::GENERAL, QString("MDKAPI: MDK ffmpeg config: %1").arg(config));
        return QString(ffmpegConfig);
    }

    return QString();
}

