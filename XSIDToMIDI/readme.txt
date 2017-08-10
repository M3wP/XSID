XSID To MIDI
============

A tool for converting XSID files to MIDI files.


Copyright (C) 2017, Daniel England.
All Rights Reserved.  Released under the GPL.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.


Introduction
------------

The XSID format was developed to ease the use of SID files outside of the C64
emulation environment where only the SID was to be used/emulated.

Since then, a number of tools have been developed that use the XSID format.  
This is another tool in that suite.

This tool allows you to convert XSID files into MIDI (SMF) files.  It does this
by analysing the way in which the SID is used.  Specifically, the "patches" or
"instruments" are discovered and the notes that are played with them recorded.
The way in which the filter/mixer is used is also recorded.

Once you have the analysis, you are able to "map" the way in which these patches
or instruments are converted to MIDI.

You can output individual instruments or the whole song in a number of ways.


Usage
-----

Open the XSID file or Load an existing XSID To MIDI project and you will be 
presented with a list of instruments (patches) that were found after some 
analysis.

Enter a BPM and Division if you know what these should be.  Recommended values
for Division are 96, 168, 240, 480 or 960.  Higher values will give more
accurate results but may also cause problems for the playback.  The BPM can 
actually be any value (120 is the default) but the MIDI file will be easier to 
use if the value matches the source file.

You should set the project output directory before you continue.

You are able to "dump" the instruments to a LOG or WAV file.  This reconstructs
the instruments as detected back on the SID.  Use LOG files to see how the SID 
registers are used or WAV files to get an idea of how the instrument sounds.
You can also dump the filter/mixer sounds here (by themselves for manual
processing and you can optionally include filter/mixer handling with the 
instruments if the accuracy in reproduction is required).  

An important value here is the Parameter Latency.  Since the instrument playback 
is a reconstruction, the latency value is required for determining the minimum 
number of cycles required between certain changes.  Values that are too large or
too small will cause notes to drop due to not enough time for the change or SID
lock ups.  Some experimentation may be required.

You can now map each of these instruments to MIDI.  Use Note Mode when the 
instrument is a regular melodic instrument type or where many notes are used and
pitch bends/legato are important.  A MIDI Channel must be assigned when using
Note Mode.  Use Drum Mode when the instrument is a percussion type instrument 
with few notes.  In Drum Mode, each used note should be mapped to the 
appropriate percussion instrument.  MIDI Channel 10 will be used for Drum Mode
mapping.  With Note Mode, there is the option to use Chord Mode instead.  This
will cause pitch bends to output individual notes instead of bends/legato.  I
have used this on individual patches after outputting the whole song to "repair"
bass lines and drum beats where extreme bends are used to "dither" multiple 
instruments but also for handling lead lines where multiple notes have been 
layed down together and quickly toggled.

You can elect to output Pulse Width change data to one or two controllers.  When
single controller is selected, data is output only on controller 16.  For the 
double controller selection, data is output on controller 16 (coarse) and 17 
(fine).

You can also elect to output Effect information.  Controller 18 is used.  Value
0 means no effects, 32 for just Oscillator Sync., 64 for just Ring Modulation
and 96 for both.

As a note, when using Chord Mode, controller 19 is used to indicate where a 
pitch bend would have occurred.

You can name an instrument and that name will be output as the track name in the
MIDI file.  If you elect to "suppress" an instrument, it will not be output with
a dump all to MIDI.

Once you have determined the mapping, you can perform the conversion on
individual instruments or the whole song.  Each instrument will be output to its
own track in the MIDI file.

Import the output MIDI files into your favourite DAW to assign patches to each
channel and playback your MIDI file!

You can save your project to file, if you desire.


Known Limitations
-----------------

There can be dropped notes in the instrument LOG or WAV dumps.  These notes 
should still be included in the MIDI file conversions.  Notes can be dropped due
to a number of issues.  Experimenting with the Parameter Latency may help.

MIDI Channel patch information is currently not output on the tracks.  This 
feature may be implemented in the future (supporting GM2 patch listings).

There is no automatic BPM detection.  I'm not sure if I will include this in 
the future or not since its almost moot.  Even when the BPM is manually 
detected and determined, most SID songs will use some kind of "funk tempo"
causing notes to be off the beats anyway.

There is no automatic mapping determination.  Other than a relatively arbitrary
channel assignment, there is no automatic mapping.  Other tools do this for you
but I feel that this is a more advanced tool and understanding the mapping and
allowing you to do it manually, gives much better results.

You can't actually play the instrument in XSID To MIDI.  You can however, dump
WAVs or LOGs which can be converted into XSID files using the DumpConvert tool.
There is a forth-coming tool, XSID List, which can help you view XSID files.

Effects such as Ring Modulation and Osciallator Synchronisation are detected 
and used in the instrument/patch determinations but are not used in the 
reproductions (since these require multiple voices).


Compiling
---------

You will need Delphi (XE8 is currently used) and Visual Studio to compile all of
the project binaries.  Visual Studio is only required for the DLLs.

Lazarus and FPC are presently unsupported.


Contact
-------

I can be contacted for further information regarding this tool at the following
address:

        mewpokemon {you know what goes here} hotmail {and here} com

Please include the word "XSID To MIDI" in the subject line.

Thanks for using XSID To MIDI!



Daniel England.
