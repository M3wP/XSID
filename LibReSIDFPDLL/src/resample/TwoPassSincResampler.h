/*
 * This file is part of libsidplayfp, a SID player engine.
 *
 * Copyright 2011-2013 Leandro Nini <drfiemost@users.sourceforge.net>
 * Copyright 2007-2010 Antti Lankila
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

#ifndef TWOPASSSINCRESAMPLER_H
#define TWOPASSSINCRESAMPLER_H

#include <cmath>

#include "Resampler.h"
#include "SincResampler.h"

namespace reSIDfp
{

/**
 * Compose a more efficient SINC from chaining two other SINCs.
 */
class TwoPassSincResampler : public Resampler
{
private:
    SincResampler* s1;
    SincResampler* s2;

public:
    TwoPassSincResampler(double clockFrequency, double samplingFrequency,
                         double highestAccurateFrequency)
    {
        // Calculation according to Laurent Ganier. It evaluates to about 120 kHz at typical settings.
        // Some testing around the chosen value seems to confirm that this does work.
        const double intermediateFrequency = 2. * highestAccurateFrequency
                                             + sqrt(2. * highestAccurateFrequency * clockFrequency
                                                     * (samplingFrequency - 2. * highestAccurateFrequency) / samplingFrequency);
        s1 = new SincResampler(clockFrequency, intermediateFrequency, highestAccurateFrequency);
        s2 = new SincResampler(intermediateFrequency, samplingFrequency, highestAccurateFrequency);
    }

    ~TwoPassSincResampler()
    {
        delete s1;
        delete s2;
    }

    bool input(int sample)
    {
        return s1->input(sample) && s2->input(s1->output());
    }

    int output() const
    {
        return s2->output();
    }

    void reset()
    {
        s1->reset();
        s2->reset();
    }
};

} // namespace reSIDfp

#endif
