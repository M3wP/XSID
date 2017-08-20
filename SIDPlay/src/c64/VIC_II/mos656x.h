/*
 * This file is part of libsidplayfp, a SID player engine.
 *
 * Copyright 2011-2014 Leandro Nini <drfiemost@users.sourceforge.net>
 * Copyright 2009-2014 VICE Project
 * Copyright 2007-2010 Antti Lankila
 * Copyright 2001 Simon White
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

#ifndef MOS656X_H
#define MOS656X_H

#include <stdint.h>

#include "lightpen.h"
#include "sprites.h"
#include "event.h"
#include "c64/component.h"
#include "EventScheduler.h"


class MOS656X: public component, private Event
{
public:
    typedef enum
    {
        MOS6567R56A = 0  ///< OLD NTSC CHIP
        ,MOS6567R8       ///< NTSC-M
        ,MOS6569         ///< PAL-B
        ,MOS6572         ///< PAL-N
    } model_t;

private:
    typedef event_clock_t (MOS656X::*ClockFunc)();

    typedef struct
    {
        unsigned int rasterLines;
        unsigned int cyclesPerLine;
        ClockFunc clock;
    } model_data_t;

private:
    static const char *credit;

    static const model_data_t modelData[];

    /// raster IRQ flag
    static const int IRQ_RASTER = 1 << 0;

    /// Light-Pen IRQ flag
    static const int IRQ_LIGHTPEN = 1 << 3;

    /// First line when we check for bad lines
    static const unsigned int FIRST_DMA_LINE = 0x30;

    /// Last line when we check for bad lines
    static const unsigned int LAST_DMA_LINE = 0xf7;

private:
    ClockFunc clock;

    event_clock_t rasterClk;

    /// CPU's event context.
    EventContext &event_context;

    /// Number of cycles per line.
    unsigned int cyclesPerLine;

    /// Number of raster lines.
    unsigned int maxRasters;

    /// Current visible line
    unsigned int lineCycle;

    /// current raster line
    unsigned int rasterY;

    /// vertical scrolling value
    unsigned int yscroll;

    /// are bad lines enabled for this frame?
    bool areBadLinesEnabled;

    /// is the current line a bad line
    bool isBadLine;

    /// Is rasterYIRQ condition true?
    bool rasterYIRQCondition;

    /// Set when new frame starts.
    bool vblanking;

    /// Is CIA asserting lightpen?
    bool lpAsserted;

    /// internal IRQ flags
    uint8_t irqFlags;

    /// masks for the IRQ flags
    uint8_t irqMask;

    /// Light pen coordinates
    Lightpen lp;

    /// the 8 sprites data
    Sprites sprites;

    /// memory for chip registers
    uint8_t regs[0x40];

private:
    event_clock_t clockPAL();
    event_clock_t clockNTSC();
    event_clock_t clockOldNTSC();

    /**
     * Signal CPU interrupt if requested by VIC.
     */
    void handleIrqState();

    EventCallback<MOS656X> badLineStateChangeEvent;

    /**
     * AEC state was updated.
     */
    void badLineStateChange() { setBA(!isBadLine); }

    EventCallback<MOS656X> rasterYIRQEdgeDetectorEvent;

    /**
     * RasterY IRQ edge detector.
     */
    void rasterYIRQEdgeDetector()
    {
        const bool oldRasterYIRQCondition = rasterYIRQCondition;
        rasterYIRQCondition = rasterY == readRasterLineIRQ();
        if (!oldRasterYIRQCondition && rasterYIRQCondition)
            activateIRQFlag(IRQ_RASTER);
    }

    /**
     * Set an IRQ flag and trigger an IRQ if the corresponding IRQ mask is set.
     * The IRQ only gets activated, i.e. flag 0x80 gets set, if it was not active before.
     */
    void activateIRQFlag(int flag)
    {
        irqFlags |= flag;
        handleIrqState();
    }

    /**
     * Read the value of the raster line IRQ
     *
     * @return raster line when to trigger an IRQ
     */
    unsigned int readRasterLineIRQ() const
    {
        return (regs[0x12] & 0xff) + ((regs[0x11] & 0x80) << 1);
    }

    /**
     * Read the DEN flag which tells whether the display is enabled
     *
     * @return true if DEN is set, otherwise false
     */
    bool readDEN() const { return (regs[0x11] & 0x10) != 0; }

    bool evaluateIsBadLine() const
    {
        return areBadLinesEnabled
            && rasterY >= FIRST_DMA_LINE
            && rasterY <= LAST_DMA_LINE
            && (rasterY & 7) == yscroll;
    }

    /**
     * Get previous value of Y raster
     */
    inline unsigned int oldRasterY() const
    {
        return rasterY > 0 ? rasterY - 1 : maxRasters - 1;
    }

    inline void sync()
    {
        event_context.cancel(*this);
        event();
    }

    /**
     * Check for vertical blanking.
     */
    inline void checkVblank()
    {
        // IRQ occurred (xraster != 0)
        if (rasterY == (maxRasters - 1))
        {
            vblanking = true;
        }

        // Check DEN bit on first cycle of the line following the first DMA line
        if (rasterY == FIRST_DMA_LINE
            && !areBadLinesEnabled
            && readDEN())
        {
            areBadLinesEnabled = true;
        }

        // Disallow bad lines after the last possible one has passed
        if (rasterY == LAST_DMA_LINE)
        {
            areBadLinesEnabled = false;
        }

        isBadLine = false;

        if (!vblanking)
        {
            rasterY++;
            rasterYIRQEdgeDetector();
        }

        if (evaluateIsBadLine())
            isBadLine = true;
    }

    inline void vblank()
    {
        // Vertical blank (line 0)
        if (vblanking)
        {
            vblanking = false;
            rasterY = 0;
            rasterYIRQEdgeDetector();
            lp.untrigger();
            if (lpAsserted && lp.retrigger(lineCycle, rasterY))
            {
                activateIRQFlag(IRQ_LIGHTPEN);
            }
        }
    }

    /**
     * Start DMA for sprite n.
     */
    template<int n>
    inline void startDma()
    {
        if (sprites.isDma(0x01 << n))
            setBA(false);
    }

    /**
     * End DMA for sprite n.
     */
    template<int n>
    inline void endDma()
    {
        if (!sprites.isDma(0x06 << n))
            setBA(true);
    }

    /**
     * Start bad line.
     */
    inline void startBadline()
    {
        if (isBadLine)
            setBA(false);
    }

protected:
    MOS656X(EventContext *context);
    ~MOS656X() {}

    // Environment Interface
    virtual void interrupt (bool state) = 0;
    virtual void setBA     (bool state) = 0;

    /**
     * Read VIC register.
     *
     * @param addr
     *            Register to read.
     */
    uint8_t read(uint_least8_t addr);

    /**
     * Write to VIC register.
     *
     * @param addr
     *            Register to write to.
     * @param data
     *            Data byte to write.
     */
    void write(uint_least8_t addr, uint8_t data);

public:
    void event();

    void chip(model_t model);

    /**
     * Trigger the lightpen. Sets the lightpen usage flag.
     */
    void triggerLightpen();

    /**
     * Clears the lightpen usage flag.
     */
    void clearLightpen();

    // Component Standard Calls
    void reset();

    static const char *credits() { return credit; }
};

// Template specializations

/**
 * Start DMA for sprite 0.
 */
template<>
inline void MOS656X::startDma<0>()
{
    setBA(!sprites.isDma(0x01));
}

/**
 * End DMA for sprite 7.
 */
template<>
inline void MOS656X::endDma<7>()
{
    setBA(true);
}

#endif // MOS656X_H
