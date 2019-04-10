/*******************************************************************************
* Copyright © 2013-2015, Sergey Radionov <rsatom_gmail.com>
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

#pragma once

#include "callbacks_holder.h"

#include "vlc_basic_player.h"

namespace vlc
{
    enum class audio_event_e
    {
        mute_changed,
        volume_changed,
    };

    struct audio_events_callback
    {
        virtual void audio_event( audio_event_e e ) = 0;
    };

    class audio
        : public callbacks_holder<audio_events_callback>
    {
    public:
        audio( vlc::basic_player& player )
            : _player( player ) {};

        bool is_muted();
        void toggle_mute();
        void set_mute( bool );

        unsigned get_volume();
        void set_volume( unsigned );

        unsigned track_count();
        //can return -1 if there is no active audio track
        int get_track();
        void set_track( unsigned );

        libvlc_audio_output_channel_t get_channel();
        void set_channel( libvlc_audio_output_channel_t );

        //in milliseconds
        int64_t get_delay();
        void set_delay( int64_t );

    private:
        void notify( audio_event_e );

    private:
        vlc::basic_player& _player;
    };
};
