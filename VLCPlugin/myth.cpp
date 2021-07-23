#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

// vlc
#include <vlc_common.h>
#include <vlc_plugin.h>
#include <vlc_playlist.h>
#include <vlc_input.h>

#include <vlc_access.h>
#include <vlc_dialog.h>
#include <vlc_demux.h>

#include <vlc_network.h>
#include <vlc_services_discovery.h>
#include <vlc_url.h>

// mythcpp
#include <mythtypes.h>
#include <mythlivetvplayback.h>
#include <mythfileplayback.h>
#include <mythwsapi.h>
#include <mythdebug.h>

// system
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <map>
#include <string>
#include <sstream>
#include <algorithm>
#include <iterator>
#include <iostream>

// myth protocol port
#define IPPORT_MYTH 6543u
// services API port
#define IPPORT_API  6544u

#ifdef MODULE_STRING
#undef MODULE_STRING
#endif

#define MODULE_STRING "myth"

#define N_(str) (str)
#define _(str) (str)

using namespace std;

/*****************************************************************************
 * Module descriptor
 *****************************************************************************/
static int  InOpen(vlc_object_t *);
static void InClose(vlc_object_t *);
//static int  SDOpen(vlc_object_t *);
//static void SDClose(vlc_object_t *);

#define CACHING_TEXT N_("Caching value in ms")
#define CACHING_LONGTEXT N_( \
    "Caching value for MythTV streams. This " \
    "value should be set in milliseconds." )

#define SERVER_URL_TEXT N_("MythTV Backend Server URL")
#define SERVER_URL_LONGTEXT N_("Enter the URL of myth backend starting with eg. myth://localhost/")

#define SERVER_VERSION_TEXT N_("MythTV Backend Server Version")
#define SERVER_VERSION_LONGTEXT N_("Suggested version of the backend server")

VLC_SD_PROBE_HELPER("myth", "MythTV Library", SD_CAT_LAN)

vlc_module_begin()
    set_shortname("MythTV")
    set_description(N_("MythTV VLC Plugin"))
    set_capability("access", 0)
    set_category(CAT_INPUT)
    set_subcategory(SUBCAT_INPUT_ACCESS)
    add_integer("myth-caching", 2 * DEFAULT_PTS_DELAY / 1000,
                CACHING_TEXT, CACHING_LONGTEXT, true)
    add_shortcut("myth")
    set_callbacks(InOpen, InClose)

    //add_submodule()
    //    set_shortname("MythTV Library")
    //    set_description(N_("MythTV Library"))
    //    set_category(CAT_PLAYLIST)
    //    set_subcategory(SUBCAT_PLAYLIST_SD)

    //    add_string("mythbackend-url", NULL, SERVER_URL_TEXT, SERVER_URL_LONGTEXT, false)

    //    set_capability("services_discovery", 0)
    //    set_callbacks(SDOpen, SDClose)

    //    VLC_SD_PROBE_SUBMODULE

vlc_module_end()

/*****************************************************************************
 * Local prototypes
 *****************************************************************************/
static ssize_t Read(stream_t *, void *, size_t);
static int     Seek(stream_t *, unsigned long);
static int     Control(stream_t *, int, va_list);

//static void *SDRun(void *data);

template <class Container>
void split(const string& str, Container& cont, char delim = ':')
{
    stringstream ss(str);
    string token;
    while (getline(ss, token, delim))
    {
        cont.push_back(token);
    }
}

typedef std::multimap<string, Myth::ChannelPtr> channelMap_t;

struct myth_sys_t
{
    string m_server;
    uint   m_portProto;
    uint   m_portAPI;

    string m_pin;

    string location;

    string m_type;
    string m_filename;
    string m_sgroup;

    uint   m_encoder;
    string m_chanNum;
    int    m_chanId;

    Myth::WSAPI *m_wsapi;

    channelMap_t m_channelMap;

    Myth::LiveTVPlayback *m_lp;
    Myth::FilePlayback *m_fp;

    Myth::VideoSourceListPtr m_sourceList;
    Myth::ChannelListPtr m_chanList;
};


// Load visible channels into the channelMap
bool loadChannels(stream_t *p_stream)
{
    myth_sys_t *p_sys = static_cast<myth_sys_t*>(p_stream->p_sys);

    if (p_sys->m_wsapi->CheckService())
    {
        p_sys->m_sourceList = p_sys->m_wsapi->GetVideoSourceList();

        // Loop from MythTV sources
        for (Myth::VideoSourceList::const_iterator sourceIt = p_sys->m_sourceList->begin(); sourceIt != p_sys->m_sourceList->end(); ++sourceIt )
        {
            // Loop from MythTV channels from a source
            p_sys->m_chanList = p_sys->m_wsapi->GetChannelList((*sourceIt)->sourceId, true); // true for visible

            for (Myth::ChannelList::const_iterator chanIt = p_sys->m_chanList->begin(); chanIt != p_sys->m_chanList->end(); ++chanIt)
            {
                p_sys->m_channelMap.insert(channelMap_t::value_type((*chanIt)->chanNum, *chanIt));
            }
        }

        msg_Info(p_stream,  "INFO: found %u channels", p_sys->m_channelMap.size());

        return true;
    }

    return false;
}

// file playback
bool filePlayback(stream_t *p_stream, const string &filename, const string &sgroup)
{
    myth_sys_t *p_sys = static_cast<myth_sys_t*>(p_stream->p_sys);

    if (!p_sys->m_fp)
        p_sys->m_fp = new Myth::FilePlayback(p_sys->m_server, p_sys->m_portProto);

    msg_Info(p_stream, "INFO: starting file playback");

    if (p_sys->m_fp->OpenTransfer(filename, sgroup))
    {
        msg_Info(p_stream, "INFO: file length is: %u", p_sys->m_fp->GetSize());
        return true;
    }

    return false;
}

// live TV playback
bool liveTVSpawn(stream_t *p_stream, const string &server, int chanId, const string &chanNum)
{
    myth_sys_t *p_sys = static_cast<myth_sys_t*>(p_stream->p_sys);

    if (!p_sys->m_lp)
        p_sys->m_lp = new Myth::LiveTVPlayback(server, IPPORT_MYTH);

    if (!loadChannels(p_stream))
    {
        msg_Err(p_stream,  "ERROR: failed to load channels");
        return false;
    }

    // if we have a chanId try that channel only
    if (chanId != -1)
    {
        msg_Info(p_stream, "INFO: spawning live TV for chanId: %u", chanId);

        // get the channel from the chanID
        Myth::ChannelPtr chan = p_sys->m_wsapi->GetChannel(chanId);

        // try to play this channel
        if (p_sys->m_lp->SpawnLiveTV(chan))
        {
            const Myth::ProgramPtr prog = p_sys->m_lp->GetPlayedProgram();
            msg_Info(p_stream,  "INFO: live TV is playing channel id %u from source id %u",
                     prog->channel.chanId, prog->channel.sourceId);
            msg_Info(p_stream, "INFO: program title is: %s", prog->title.c_str());

            return true;
        }
    }

    msg_Info(p_stream, "INFO: spawning live TV for chanNum: %s", chanNum.c_str());

    // find all channels with this chanNum
    Myth::ChannelList chanList;

    channelMap_t::const_iterator it = p_sys->m_channelMap.find(chanNum);

    while (it != p_sys->m_channelMap.end())
    {
        chanList.push_back(it->second);
        ++it;
    }

    // try to play one of these channels
    if (p_sys->m_lp->SpawnLiveTV(chanNum, chanList))
    {
        const Myth::ProgramPtr prog = p_sys->m_lp->GetPlayedProgram();
        msg_Info(p_stream,  "INFO: live TV is playing channel id %u from source id %u",
                 prog->channel.chanId, prog->channel.sourceId);
        msg_Info(p_stream, "INFO: program title is: %s", prog->title.c_str());

        return true;
    }

    msg_Err(p_stream, "ERROR: failed to start LiveTV on channel: %s", chanNum.c_str());

    return false;
}

static bool getOptionString(const string &token, const string &key, string &value)
{
    if (token.rfind(key, 0) == 0)
    {
        value = token.substr(key.length());
        return true;
    }

    return false;
}

static bool getOptionUInt(const string &token, const string &key, uint &value)
{
    if (token.rfind(key, 0) == 0)
    {
        string svalue = token.substr(key.length());
        value = static_cast<uint>(stoul(token.substr(key.length()).c_str()));
        return true;
    }

    return false;
}

static bool getOptionInt(const string &token, const string &key, int &value)
{
    if (token.rfind(key, 0) == 0)
    {
        string svalue = token.substr(key.length());
        value = static_cast<int>(stoul(token.substr(key.length()).c_str()));
        return true;
    }

    return false;
}

/*****************************************************************************
 * VarInit/ParseMRL:
 *****************************************************************************/
static void VarInit(stream_t *p_stream)
{
    var_Create(p_stream, "myth-caching", VLC_VAR_INTEGER | VLC_VAR_DOINHERIT);
}

static bool ParseMRL(stream_t *p_stream)
{
    myth_sys_t *p_sys = static_cast<myth_sys_t*>(p_stream->p_sys);

    p_sys->location = p_stream->psz_location;

    vector<string> tokens;
    split(p_sys->location, tokens);

    for (vector<string>::iterator it = tokens.begin(); it != tokens.end(); ++it)
    {
        string token = *it;
        bool found = false;

        found |= getOptionString(token, "type=",     p_sys->m_type);
        found |= getOptionString(token, "server=",   p_sys->m_server);
        found |= getOptionString(token, "pin=",      p_sys->m_pin);
        found |= getOptionUInt(token,   "port=",     p_sys->m_portProto);
        found |= getOptionUInt(token,   "portapi=",  p_sys->m_portAPI);
        found |= getOptionString(token, "filename=", p_sys->m_filename);
        found |= getOptionString(token, "sgroup=",   p_sys->m_sgroup);
        found |= getOptionUInt(token,   "encoder=",  p_sys->m_encoder);
        found |= getOptionString(token, "channum=",  p_sys->m_chanNum);
        found |= getOptionInt(token, "chanid=",   p_sys->m_chanId);

        if (!found)
        {
            msg_Err(p_stream, "unknown option (%s)", token.c_str());
        }
    }

    // sanity check type
    if (!p_sys->m_type.length())
    {
        p_sys->m_type = "recording";
    }
    else if (p_sys->m_type != "recording" && p_sys->m_type != "video" && p_sys->m_type != "livetv")
    {
        msg_Err(p_stream, "unknown type (%s)", p_sys->m_type.c_str());
        return VLC_EGENERIC;
    }

    // sanity check server
    if (!p_sys->m_server.length())
        p_sys->m_server = "localhost";

    // sanity check pin
    if (!p_sys->m_pin.length())
        p_sys->m_pin = "0000";

    // sanity check port for the MythTV Protocol
    if (p_sys->m_portProto == 0)
        p_sys->m_portProto = IPPORT_MYTH;

    // sanity check port for the MythTV Services API
    if (p_sys->m_portAPI == 0)
        p_sys->m_portAPI = IPPORT_API;

    // sanity check storage group
    if (!p_sys->m_sgroup.length())
        p_sys->m_sgroup = "default";

    return true;
}

/****************************************************************************
 * Open: connect to mythbackend
 ****************************************************************************/
static int InOpen(vlc_object_t *p_obj)
{
    Myth::DBGLevel(MYTH_DBG_WARN);

    stream_t *p_stream = reinterpret_cast<stream_t*>(p_obj);

    myth_sys_t *p_sys = new myth_sys_t;

    p_sys->m_portProto = 0;
    p_sys->m_portAPI = 0;
    p_sys->m_encoder = 0;
    p_sys->m_chanId = -1;

    p_sys->m_lp = nullptr;
    p_sys->m_fp = nullptr;
    p_sys->m_wsapi = nullptr;

    if (unlikely(p_sys == NULL))
        return VLC_ENOMEM;

    p_stream->p_sys = p_sys;

    /* Create all variables */
    VarInit(p_stream);

    /* Parse the command line */
    if (!ParseMRL(p_stream))
    {
        free(p_sys);
        return VLC_EGENERIC;
    }

    p_sys->m_wsapi = new Myth::WSAPI(p_sys->m_server, p_sys->m_portAPI, p_sys->m_pin);
    if (p_sys->m_wsapi->CheckService())
    {
        // Print the version of our backend
        Myth::VersionPtr versionPtr = p_sys->m_wsapi->GetVersion();
        msg_Info(p_stream,  "MythTV backend version: %s", versionPtr->version.c_str());
    }
    else
    {
        msg_Info(p_stream,  "MythTV backend check service failed");
        goto exit_error;
    }

    msg_Info(p_stream, "type: %s, server: %s, proto port: %d, api port: %d, filename: %s",
             p_sys->m_type.c_str(),
             p_sys->m_server.c_str(),
             p_sys->m_portProto,
             p_sys->m_portAPI,
             p_sys->m_filename.c_str());

    if (p_sys->m_type == "recording")
    {
        msg_Info(p_stream, "playing a recording");
        if (!filePlayback(p_stream, p_sys->m_filename, p_sys->m_sgroup))
             goto exit_error;
    }
    else if (p_sys->m_type == "video")
    {
         msg_Info(p_stream, "playing a video");

         if (!filePlayback(p_stream, p_sys->m_filename, p_sys->m_sgroup))
              goto exit_error;
    }
    else if (p_sys->m_type == "livetv")
    {
        msg_Info(p_stream, "playing LiveTV");
        msg_Info(p_stream, "encoder: %d, channum: %s, chanid: %d", p_sys->m_encoder,  p_sys->m_chanNum.c_str(), p_sys->m_chanId);

        // start LiveTV
        if (!liveTVSpawn(p_stream, p_sys->m_server, p_sys->m_chanId, p_sys->m_chanNum))
             goto exit_error;
    }
    else
    {
        msg_Info(p_stream, "Don't know how to play type: %s", p_sys->m_type.c_str());

        goto exit_error;
    }

    p_stream->pf_read = Read;
    p_stream->pf_block = NULL;
    p_stream->pf_seek = Seek;
    p_stream->pf_control = Control;

    msg_Info(p_stream, "InOpen exiting with VLC_SUCCESS");

    return VLC_SUCCESS;

exit_error:

    InClose(p_obj);

    return VLC_EGENERIC;
}

/*****************************************************************************
 * Close: free now unused data structures
 *****************************************************************************/
static void Close(stream_t *p_stream)
{
    myth_sys_t *p_sys = static_cast<myth_sys_t*>(p_stream->p_sys);

    msg_Info(p_stream, "stopping stream");

    // are we playing LiveTV?
    if (p_sys->m_lp)
    {
        // TODO check if we need to do this
        p_sys->m_lp->StopLiveTV();
        delete p_sys->m_lp;
    }

    // are we playing a file?
    if (p_sys->m_fp)
    {
        if (p_sys->m_fp->TransferIsOpen())
            p_sys->m_fp->CloseTransfer();

        delete p_sys->m_fp;
    }

    if (p_sys->m_wsapi)
        delete p_sys->m_wsapi;

    free(p_sys);
    p_stream->p_sys = nullptr;
}

static void InClose(vlc_object_t *p_this)
{
    Close(reinterpret_cast<stream_t *>(p_this));
}


/*****************************************************************************
 * Seek: try to go to the right place
 *****************************************************************************/
static int Seek(stream_t *p_stream, unsigned long i_pos)
{
    myth_sys_t *p_sys = static_cast<myth_sys_t *>(p_stream->p_sys);

    msg_Info(p_stream, "Seek to: %ld, position: %ld, size: %ld", i_pos, p_sys->m_fp->GetPosition(), p_sys->m_fp->GetSize());

    if (!p_sys->m_lp && !p_sys->m_fp)
        return VLC_EGENERIC;

    if (p_sys->m_lp)
        p_sys->m_lp->Seek(static_cast<int64_t>(i_pos), Myth::WHENCE_SET);
    else if (p_sys->m_fp)
        p_sys->m_fp->Seek(static_cast<int64_t>(i_pos), Myth::WHENCE_SET);
    else
        return VLC_EGENERIC;

    return VLC_SUCCESS;
}


/*****************************************************************************
 * Read:
 *****************************************************************************/
static ssize_t Read(stream_t *p_stream, void *p_buffer, size_t i_len)
{
    myth_sys_t *p_sys = static_cast<myth_sys_t *>(p_stream->p_sys);

    // LiveTV
    if (p_sys->m_lp)
    {
        return p_sys->m_lp->Read(p_buffer, static_cast<unsigned int>(i_len));
    }
    else if (p_sys->m_fp)
    {
        //msg_Info(p_stream, "Read: position: %d, size: %d", p_sys->m_fp->GetPosition(), p_sys->m_fp->GetSize());
        if (p_sys->m_fp->GetPosition() == p_sys->m_fp->GetSize())
        {
            msg_Info(p_stream, "Can't read already at EOF");
            return 0;
        }

        return p_sys->m_fp->Read(p_buffer, static_cast<unsigned int>(i_len));
    }

    return 0;
}

/*****************************************************************************
 * Control:
 *****************************************************************************/
static int Control(stream_t *p_stream, int i_query, va_list args)
{
    myth_sys_t  *p_sys = static_cast<myth_sys_t *>(p_stream->p_sys);
    bool        *pb_bool;
    int64_t     *pi_64;
    vlc_value_t  val;
    int          i_idx;

    //msg_Info(p_access, "Control query %d", i_query);
    
    switch(i_query)
    {
        /* */
        case STREAM_CAN_SEEK:
            pb_bool = (bool*)va_arg(args, bool*);
            *pb_bool = true;
            break;
        case STREAM_CAN_FASTSEEK:
            pb_bool = (bool*)va_arg(args, bool*);
            *pb_bool = false;
            break;
        case STREAM_CAN_PAUSE:
            pb_bool = (bool*)va_arg(args, bool*);
            *pb_bool = true;    /* FIXME */
            break;
        case STREAM_CAN_CONTROL_PACE:
            pb_bool = (bool*)va_arg(args, bool*);
            *pb_bool = true;    /* FIXME */
            break;
        case STREAM_IS_DIRECTORY:
            pb_bool = (bool*)va_arg(args, bool*);
            *pb_bool = false;
            break;
        case STREAM_GET_PTS_DELAY:
            pi_64 = (int64_t*)va_arg(args, int64_t *);
            var_Get(p_stream, "myth-caching", &val);
            *pi_64 = (int64_t)var_GetInteger(p_stream, "myth-caching") * INT64_C(1000);
            //*va_arg(args, int64_t *) = DEFAULT_PTS_DELAY;
            break;

        case STREAM_GET_SIZE:
            if (p_sys->m_lp)
            {
                msg_Info(p_stream, "STREAM_GET_SIZE: %ld B", p_sys->m_lp->GetSize());
                *va_arg(args, uint64_t *) = static_cast<uint64_t>(p_sys->m_lp->GetSize());
                return VLC_SUCCESS;
            }
            else if (p_sys->m_fp)
            {
                msg_Info(p_stream, "STREAM_GET_SIZE: %ld B", p_sys->m_fp->GetSize());
                *va_arg(args, uint64_t *) = static_cast<uint64_t>(p_sys->m_fp->GetSize());
                return VLC_SUCCESS;
            }

            return VLC_EGENERIC;

        case STREAM_SET_PAUSE_STATE:
            /* nothing to do */
            break;

        case STREAM_SET_PRIVATE_ID_STATE:
        case STREAM_GET_META:
        case STREAM_GET_SIGNAL:
        case STREAM_GET_TAGS:
            return VLC_EGENERIC;

        case STREAM_GET_TITLE_INFO:
        {
               msg_Dbg(p_stream, "STREAM_GET_TITLE_INFO");
               return VLC_EGENERIC;

//                access_sys_t *p_sys = p_access->p_sys;

//                input_title_t ***ppp_title;
//                int          *pi_int;
//                int i;

//                ppp_title = (input_title_t***)va_arg( args, input_title_t*** );
//                pi_int    = (int*)va_arg( args, int* );
//                *((int*)va_arg( args, int* )) = 0; /* Title offset */
//                *((int*)va_arg( args, int* )) = 1; /* Chapter offset */

                //* Duplicate title infos
//                *pi_int = p_sys->i_titles;
//                *ppp_title = malloc( sizeof( input_title_t ** ) * p_sys->i_titles );
//                if ( !*ppp_title )
//                    return VLC_ENOMEM;

//                for( i = 0; i < p_sys->i_titles; i++ )
//                {
//                    (*ppp_title)[i] = vlc_input_title_Duplicate( p_sys->titles[i] );
//                }

//                return VLC_SUCCESS;
        }

        case STREAM_GET_TITLE:
            msg_Dbg(p_stream, "ACCESS_GET_TITLE");
            //*va_arg(args, uint64_t *) = p_sys->m_lp->GetPlayedProgram()->title; // FIXME
            return VLC_SUCCESS;


//        case STREAM_GET_SEEKPOINT:
//            *va_arg(args, uint64_t *) = p_access->p_sys->i_seekpoint;
//            return VLC_SUCCESS;

        case STREAM_SET_TITLE:
            /* TODO handle editions as titles */
            i_idx = (int)va_arg(args, int);
            //p_sys->i_title = i_idx;
            msg_Info( p_stream, "STREAM_SET_TITLE %d", i_idx);
            //if (i_idx < p_sys->used_segments.size())
            //{
            //    p_sys->JumpTo(*p_sys->used_segments[i_idx], NULL);
            //    return VLC_SUCCESS;
            //}
            return VLC_EGENERIC;

        case STREAM_GET_SEEKPOINT:
#if 0
            i_skp = (int)va_arg(args, int);
            p_sys->i_seekpoint = i_skp;

            msg_Err(p_stream, "STREAM_SET_SEEKPOINT %d", i_skp);


            // TODO change the way it works with the << & >> buttons on the UI (+1/-1 instead of a number)
            if ( p_sys->i_titles && i_skp < p_sys->titles[0]->i_seekpoint)
            {
                //Seek( p_access, (int64_t)p_sys->titles[0]->seekpoint[i_skp]->i_byte_offset);

                /* do the seeking */
                input_thread_t *p_input = p_stream->p_input;
                // FIXME:
                //input_Control(p_input, INPUT_SET_POSITION, (double)p_sys->titles[0]->seekpoint[i_skp]->i_byte_offset / p_sys->i_size);
                vlc_object_release(p_input);

                //p_access->info.i_update = 0;
                //p_access->info.i_size = 0;
                //p_sys->realpos = p_access->info.i_pos;
                //p_access->info.i_pos = 0;
                //p_access->info.b_eof = false;
                //p_access->i_title = 0;
                //p_access->info.i_seekpoint = 0;

                //p_access->info.i_update |= INPUT_UPDATE_SEEKPOINT;
                //p_access->info.i_seekpoint = i_skp;
                return VLC_SUCCESS;
            }
#endif

            return VLC_EGENERIC;

        case STREAM_SET_PRIVATE_ID_CA:
            return VLC_EGENERIC;

        case STREAM_GET_CONTENT_TYPE:
            msg_Warn(p_stream, "DONT KNOW THE CONTENT TYPE");
            return VLC_EGENERIC;
            //*va_arg( args, char ** ) = strdup( false ? "video/MP2T" : "video/MP2P" );
            //return VLC_SUCCESS;

        default:
            msg_Warn(p_stream, "unimplemented query in control: %d", i_query);
            return VLC_EGENERIC;

    }

    return VLC_SUCCESS;
}
