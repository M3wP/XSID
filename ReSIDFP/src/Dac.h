/*
 * This file is part of libsidplayfp, a SID player engine.
 *
 * Copyright 2011-2013 Leandro Nini <drfiemost@users.sourceforge.net>
 * Copyright 2007-2010 Antti Lankila
 * Copyright 2004,2010 Dag Lem <resid@nimrod.no>
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

#ifndef DAC_H
#define DAC_H

namespace reSIDfp
{

/**
 * Estimate DAC nonlinearity.
 * The SID DACs are built up as R-2R ladder as follows:
 *
 *         n  n-1      2   1   0    VGND
 *         |   |       |   |   |      |   Termination
 *        2R  2R      2R  2R  2R     2R   only for
 *         |   |       |   |   |      |   MOS 8580
 *     Vo  --R---R--...--R---R--    ---
 *
 *
 * All MOS 6581 DACs are missing a termination resistor at bit 0. This causes
 * pronounced errors for the lower 4 - 5 bits (e.g. the output for bit 0 is
 * actually equal to the output for bit 1), resulting in DAC discontinuities
 * for the lower bits.
 * In addition to this, the 6581 DACs exhibit further severe discontinuities
 * for higher bits, which may be explained by a less than perfect match between
 * the R and 2R resistors, or by output impedance in the NMOS transistors
 * providing the bit voltages. A good approximation of the actual DAC output is
 * achieved for 2R/R ~ 2.20.
 *
 * The MOS 8580 DACs, on the other hand, do not exhibit any discontinuities.
 * These DACs include the correct termination resistor, and also seem to have
 * very accurately matched R and 2R resistors (2R/R = 2.00).
 */
namespace Dac
{
    /**
     * @param dac an array to be filled with the resulting analog values
     * @param dacLength the dac array length
     * @param _2R_div_R nonlinearity parameter, 1.0 for perfect linearity.
     * @param term is the dac terminated by a 2R resistor? (6581 DACs are not)
     */
    void kinkedDac(double* dac, int dacLength, double _2R_div_R, bool term);
}

} // namespace reSIDfp

#endif
