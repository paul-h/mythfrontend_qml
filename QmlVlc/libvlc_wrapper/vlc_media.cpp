/*******************************************************************************
* Copyright © 2014, Sergey Radionov <rsatom_gmail.com>
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*   1. Redistributions of source code must retain the above copyright notice,
*      this list of conditions and the following disclaimer.
*   2. Redistributions in binary form must reproduce the above copyright notice,
*      this list of conditions and the following disclaimer in the documentation
*      and/or other materials provided with the distribution.

* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
* THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
* ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
* BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
* OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
* OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*******************************************************************************/

#include "vlc_media.h"

using namespace vlc;

media media::create_media( libvlc_instance_t* inst,
                           const char* mrl_or_path,
                           unsigned optc, const char** optv,
                           unsigned trusted_optc, const char** trusted_optv,
                           bool is_path )
{
    ::libvlc_media_t* libvlc_media =
        is_path ?
            libvlc_media_new_path( inst, mrl_or_path ) :
            libvlc_media_new_location( inst, mrl_or_path );

    if( libvlc_media ) {
        unsigned i;
        for( i = 0; i < optc; ++i )
            libvlc_media_add_option_flag( libvlc_media, optv[i], libvlc_media_option_unique );

        for( i = 0; i < trusted_optc; ++i )
            libvlc_media_add_option_flag( libvlc_media, trusted_optv[i],
                                          libvlc_media_option_unique | libvlc_media_option_trusted );

        return media( libvlc_media, false );
    }

    return media();
}

media::media()
    : m_media( nullptr )
{
}

media::media( ::libvlc_media_t* m, bool needs_retain )
    : m_media( m )
{
    if( m_media && needs_retain )
        libvlc_media_retain( m_media );
}

media::media( const media& other )
    : m_media( other.m_media )
{
    if( m_media )
        libvlc_media_retain( m_media );
}

media::~media()
{
    release_media();
}

void media::release_media()
{
    if( m_media ) {
        libvlc_media_release( m_media );
        m_media = 0;
    }
}

media& media::operator= ( const media& m )
{
    release_media();

    m_media = m.m_media;
    if( m_media )
        libvlc_media_retain( m_media );

    return *this;
}

std::string media::mrl() const
{
    std::string ret;

    if( !m_media )
        return ret;

    if( char* mrl = libvlc_media_get_mrl( m_media ) ) {
        ret = mrl;
        libvlc_free( mrl );
    }

    return ret;
}

std::string media::meta( libvlc_meta_t meta_id ) const
{
    std::string ret;

    if( m_media ) {
        if( char* meta = libvlc_media_get_meta( m_media, meta_id ) ) {
            ret = meta;
            libvlc_free( meta );
        }
    }

    return ret;
}

void media::set_meta( ::libvlc_meta_t meta_id, const std::string& meta )
{
    if( m_media )
        libvlc_media_set_meta( m_media, meta_id, meta.c_str() );
}

bool media::is_parsed() const
{
    if( m_media )
       return libvlc_media_is_parsed( m_media ) != 0;

    return false;
}

void media::parse( bool async /*= false*/ )
{
    if( !m_media )
        return;

    if( async )
        libvlc_media_parse_async( m_media );
    else
        libvlc_media_parse( m_media );
}

libvlc_time_t media::duration() const
{
    if( !m_media )
        return 0;

    return libvlc_media_get_duration( m_media );
}
