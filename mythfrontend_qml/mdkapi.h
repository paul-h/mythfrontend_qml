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

private:
    QLibrary m_library;

    // Global function pointers
    int (*m_MDK_version)(void) = 0;

    // Player function pointers
    const mdkPlayerAPI* (*m_mdkPlayerAPI_new)(void) = 0;
    void * (*m_mdkPlayerAPI_delete)(const mdkPlayerAPI**) = 0;
};

extern MDKAPI* gMDKAPI;

#endif // MDKAPI_H
