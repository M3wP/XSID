XSID
====

A suite of tools for the XSID format.  Includes tools for converting SID files 
and playing them back.


Copyright (C) 2016, Daniel England.
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

I initially developed the XSID format as part of another project but I realised
that the format had potential for greater use and so developed the format 
further.

XSID is a MIDI (SMF) a-like format for SID tunes.  It's benefits over usual RSID
or PSID formats is that it allows for seeking without ugly hacks, contains all
of the related meta-data, allows for embedded play-back hints about filters and
required capabilities and no longer requires 6510 CPU and 6526 CIA emulation so
the player can use less CPU for playback (which can then be dedicated to the
SID emulation, instead).  It also allows for playback of songs that were 
originally spooled from disk (instead of having to have the entire track in 
memory as per the requirements of the RSID and PSID formats).

The XSID format does require "much" more disk space for the tunes than the SID 
formats but given today's near unlimited bulk storage, the trade-offs of less
CPU requirements are problably worth it, especially if the play-back is on a
low-end, portable-type device.

To begin with, the project used a Pascal conversion of ReSID that I wrote but I
abandoned the conversion (it was complete and functional) once ReSID-FP was 
released because I didn't want to re-write the conversion.  Instead, I wrote a 
C DLL wrapper for ReSID-FP and now use it via this wrapper.  The problem is that 
my C programming skills are currently not up to the task of writing a DLL/SO 
wrapper with GCC that will  work on Linux, Mac OSX and Windows and so the 
project has become Windows bound.  Writing a stand-along XSID player that uses
ReSID would be a doddle, however.

The tool set includes a player (XSIDPlay) and two conversion tools - DumpConvert
and SIDConvert.  SIDConvert uses a C wrapped DLL for a special version of 
SIDPlay that I developed that allows dumping of the playback similarly to how
VICE can be made to dump the SID output to a file.  

With SIDConvert, you can drag and drop SID files to the conversion list and then 
run the conversion.  It will automatically set-up the meta data and perform the
conversion to your specifications.

DumpConvert converts previously dumped SID files which you can use with VICE 
dumps to convert tunes that can't be played via SID files.


Usage
-----

Under development.


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

Please include the word "XSID" in the subject line.

Thanks for using XSID!



Daniel England.
