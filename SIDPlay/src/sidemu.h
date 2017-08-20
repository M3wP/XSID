/*
 * This file is part of libsidplayfp, a SID player engine.
 *
 * Copyright 2011-2014 Leandro Nini <drfiemost@users.sourceforge.net>
 * Copyright 2007-2010 Antti Lankila
 * Copyright 2000-2001 Simon White
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef SIDEMU_H
#define SIDEMU_H

#include <string>

#include "SidConfig.h"
#include "siddefs.h"
#include "event.h"
#include "c64/c64sid.h"

class sidbuilder;
class EventContext;

/**
 * Inherit this class to create a new SID emulation.
 */
class sidemu : public c64sid
{
public:
    /**
     * Buffer size. 5000 is roughly 5 ms at 96 kHz
     */
    enum
    {
        OUTPUTBUFFERSIZE = 5000
    };

private:
    sidbuilder *m_builder;

protected:
    static std::string m_credit;

protected:
    static const char ERR_UNSUPPORTED_FREQ[];
    static const char ERR_INVALID_SAMPLING[];
    static const char ERR_INVALID_CHIP[];

protected:
    EventContext *m_context;

    event_clock_t m_accessClk;

    /// The sample buffer
    short *m_buffer;

    /// Current position in buffer
    int m_bufferpos;

    bool m_status;
    bool m_locked;

    std::string m_error;

public:
    sidemu(sidbuilder *builder) :
        m_builder (builder),
        m_context(0),
        m_buffer(0),
        m_bufferpos(0),
        m_status(true),
        m_locked(false),
        m_error("N/A") {}
    virtual ~sidemu() {}

    /**
     * Clock the SID chip.
     */
    virtual void clock() = 0;

    /**
     * Set execution environment and lock sid to it.
     */
    virtual bool lock(EventContext *env);

    /**
     * Unlock sid.
     */
    virtual void unlock();

    // Standard SID functions
    
    /**
     * Mute/unmute voice.
     */
    virtual void voice(unsigned int num, bool mute) = 0;

    /**
     * Set SID model.
     */
    virtual void model(SidConfig::sid_model_t model) = 0;

    /**
     * Set the sampling method.
     *
     * @param systemfreq
     * @param outputfreq
     * @param method
     * @param fast
     */
    virtual void sampling(float systemfreq SID_UNUSED, float outputfreq SID_UNUSED,
        SidConfig::sampling_method_t method SID_UNUSED, bool fast SID_UNUSED) {}

    /**
     * Get a detailed error message.
     */
    const char *error() const { return m_error.c_str(); }

    sidbuilder *builder() const { return m_builder; }

    /**
     * Get the current position in buffer.
     */
    int bufferpos() const { return m_bufferpos; }

    /**
     * Set the position in buffer.
     */
    void bufferpos(int pos) { m_bufferpos = pos; }

    /**
     * Get the buffer.
     */
    short *buffer() const { return m_buffer; }

    void poke(uint_least16_t address, uint8_t value) { write(address & 0x1f, value); }
    uint8_t peek(uint_least16_t address) { return read(address & 0x1f); }
};

#endif // SIDEMU_H
