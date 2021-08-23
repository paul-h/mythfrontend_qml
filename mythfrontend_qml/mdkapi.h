#ifndef MDKAPI_H
#define MDKAPI_H

// qt
#include <QLibrary>

// mdk
#include "mdk/c/Player.h"


class MDKAPI
{
public:
    MDKAPI();
    ~MDKAPI();

    bool load(const QString &path);
    bool unload(void);
    bool isLoaded(void) const;

    const mdkPlayerAPI *createPlayer(void);
    void destroyPlayer(const mdkPlayerAPI **);

    QString getFFMPEGVersion(void);
    QString getFFMPEGConfig(void);

    bool isAvailable(void);

private:
    QLibrary m_library;

    // Global function pointers
    int (*m_MDK_version)(void) = nullptr;
    bool(*m_mdkGetGlobalOptionString)(const char* key, const char** value) = nullptr;
    bool(*m_mdkGetGlobalOptionInt32)(const char* key, int* value) = nullptr;

    void (*m_mdkSetGlobalOptionString)(const char* key, const char* value) = nullptr;

    // Player function pointers
    const mdkPlayerAPI* (*m_mdkPlayerAPI_new)(void) = nullptr;
    void * (*m_mdkPlayerAPI_delete)(const mdkPlayerAPI**) = nullptr;
};

extern MDKAPI* gMDKAPI;

#endif // MDKAPI_H
