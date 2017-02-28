//------------------------------------------------------------------------------
//C64Types
//========
//Type and constant declarations for handling C64 system information.
//
//
//Copyright (C) 2017, Daniel England.
//All Rights Reserved.  Released under the GPL.
//
//This program is free software: you can redistribute it and/or modify it under
//the terms of the GNU General Public License as published by the Free Software
//Foundation, either version 3 of the License, or (at your option) any later
//version.
//
//This program is distributed in the hope that it will be useful, but WITHOUT
//ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//details.
//
//You should have received a copy of the GNU General Public License along with
//this program.  If not, see <http://www.gnu.org/licenses/>.
//
//------------------------------------------------------------------------------
unit C64Types;

{$IFDEF FPC}
	{$MODE DELPHI}
{$ENDIF}

{$H+}

interface

type
//	reg4 = Byte;
	reg8 = Byte;
//	reg11 = Word;
//	reg12 = Word;
//	reg16 = Word;
//	reg24 = Cardinal;
//	reg32 = Cardinal;

//dengland This was Integer
	cycle_count = Cardinal;

	TC64UpdateRate = (cur1X, cur2X, cur4X, cur8X, cur16X);
	TC64SystemType = (cstAny, cstPAL, cstNTSC, cstNTSCOLD, cstPALN, cstNominal);
	TC64SIDModel = (csmAny, csmMOS6581, csmMOS8580);

//	TC64Float = Single;
	TC64Float = Double;


const
//	(1 shl 24) - 24 is the number of bits in the SID oscillator accumulators
	VAL_SIZ_SIDFREQGEN = $01000000;

//	PAL System
	VAL_CNT_PALCYCPLIN = 63;
	VAL_CNT_PALSCRNLNS = 312;
	VAL_CNT_PALCPFRESH = VAL_CNT_PALCYCPLIN * VAL_CNT_PALSCRNLNS;

	VAL_CNT_PALCYCPSEC = 985248;
//	50.124542124542124542124542124542
	VAL_FRQ_PALRFRSHPS = 1.0 / (VAL_CNT_PALCPFRESH / VAL_CNT_PALCYCPSEC);
//	0.0587253570556640625
	VAL_FAC_PALSIDFREQ = VAL_CNT_PALCYCPSEC / VAL_SIZ_SIDFREQGEN;

//	NTSC System
	VAL_CNT_NTSCYCPLIN = 65;
	VAL_CNT_NTSSCRNLNS = 263;
	VAL_CNT_NTSCPFRESH = VAL_CNT_NTSCYCPLIN * VAL_CNT_NTSSCRNLNS;

	VAL_CNT_NTSCYCPSEC = 1022730;
//  59.826264989763088622404211757824
	VAL_FRQ_NTSRFRSHPS = 1.0 / (VAL_CNT_NTSCPFRESH / VAL_CNT_NTSCYCPSEC);
//  0.06095945835113525390625
	VAL_FAC_NTSSIDFREQ = VAL_CNT_NTSCYCPSEC / VAL_SIZ_SIDFREQGEN;

//	Old NTSC System
	VAL_CNT_NTOCYCPLIN = 64;
	VAL_CNT_NTOSCRNLNS = 262;
	VAL_CNT_NTOCPFRESH = VAL_CNT_NTOCYCPLIN * VAL_CNT_NTOSCRNLNS;

	VAL_CNT_NTOCYCPSEC = 1022730;
	VAL_FRQ_NTORFRSHPS = 1.0 / (VAL_CNT_NTOCPFRESH / VAL_CNT_NTOCYCPSEC);
	VAL_FAC_NTOSIDFREQ = VAL_CNT_NTOCYCPSEC / VAL_SIZ_SIDFREQGEN;

//	PAL-N System
	VAL_CNT_PLNCYCPLIN = 65;
	VAL_CNT_PLNSCRNLNS = 312;
	VAL_CNT_PLNCPFRESH = VAL_CNT_PLNCYCPLIN * VAL_CNT_PLNSCRNLNS;

	VAL_CNT_PLNCYCPSEC = 1023440;
	VAL_FRQ_PLNRFRSHPS = 1.0 / (VAL_CNT_PLNCPFRESH / VAL_CNT_PLNCYCPSEC);
	VAL_FAC_PLNSIDFREQ = VAL_CNT_PLNCYCPSEC / VAL_SIZ_SIDFREQGEN;

//	Nominal System
	VAL_CNT_NOMCYCPLIN = 50;
	VAL_CNT_NOMSCRNLNS = 400;
	VAL_CNT_NOMCPFRESH = VAL_CNT_NOMCYCPLIN * VAL_CNT_NOMSCRNLNS;

	VAL_CNT_NOMCYCPSEC = 1000000;
	VAL_FRQ_NOMRFRSHPS = 1.0 / (VAL_CNT_NOMCPFRESH / VAL_CNT_NOMCYCPSEC);
	VAL_FAC_NOMSIDFREQ = VAL_CNT_NOMCYCPSEC / VAL_SIZ_SIDFREQGEN;

	ARR_VAL_SYSCYCPSEC: array[TC64SystemType] of Cardinal = (
			VAL_CNT_NOMCYCPSEC,
			VAL_CNT_PALCYCPSEC, VAL_CNT_NTSCYCPSEC, VAL_CNT_NTOCYCPSEC,
			VAL_CNT_PLNCYCPSEC, VAL_CNT_NOMCYCPSEC);
	ARR_VAL_SYSRFRSHPS: array[TC64SystemType] of TC64Float = (
			VAL_FRQ_NOMRFRSHPS,
			VAL_FRQ_PALRFRSHPS, VAL_FRQ_NTSRFRSHPS, VAL_FRQ_NTORFRSHPS,
			VAL_FRQ_PLNRFRSHPS, VAL_FRQ_NOMRFRSHPS);
	ARR_VAL_SYSSIDFRQF: array[TC64SystemType] of TC64Float = (
			VAL_FAC_NOMSIDFREQ,
			VAL_FAC_PALSIDFREQ, VAL_FAC_NTSSIDFREQ, VAL_FAC_NTOSIDFREQ,
			VAL_FAC_PLNSIDFREQ, VAL_FAC_NOMSIDFREQ);
	ARR_VAL_SYSCYCPRFS: array[TC64SystemType] of TC64Float = (
    		VAL_CNT_NOMCPFRESH,
			VAL_CNT_PALCPFRESH, VAL_CNT_NTSCPFRESH, VAL_CNT_NTOCPFRESH,
			VAL_CNT_PLNCPFRESH, VAL_CNT_NOMCPFRESH);

	VAL_DEF_C64SYSTYPE = cstPAL;
	VAL_DEF_C64SIDMODL = csmMOS6581;
	VAL_DEF_C64UPDRATE = cur16X;

	ARR_LIT_LBL_SIDREGS: array[0..24] of string = (
			'00:  Voice 1 FREQ LO',
			'01:  Voice 1 FREQ HI',
			'02:  Voice 1 PW LO',
			'03:  Voice 1 PW HI',
			'04:  Voice 1 CNTRL',
			'05:  Voice 1 ATK/DEC',
			'06:  Voice 1 SUS/REL',
			'07:  Voice 2 FREQ LO',
			'08:  Voice 2 FREQ HI',
			'09:  Voice 2 PW LO',
			'0A:  Voice 2 PW HI',
			'0B:  Voice 2 CNTRL',
			'0C:  Voice 2 ATK/DEC',
			'0D:  Voice 2 SUS/REL',
			'0E:  Voice 3 FREQ LO',
			'0F:  Voice 3 FREQ HI',
			'10:  Voice 3 PW LO',
			'11:  Voice 3 PW HI',
			'12:  Voice 3 CNTRL',
			'13:  Voice 3 ATK/DEC',
			'14:  Voice 3 SUS/REL',
			'15:  Filter  FC LO',
			'16:  Filter  FC HI',
			'17:  Filter  RES/FILT',
			'18:  Filter  MODE/VOL');

	ARR_LIT_LBL_VOCCNTRL: array[0..7] of string = (
			'Gate',
			'Sync',
			'Ring',
			'Test',
			'Triangle',
			'Saw',
			'Pulse',
			'Noise');

	ARR_LIT_LBL_FLTRES: array[0..3] of string = (
			'Filt V1',
			'Filt V2',
			'Filt V3',
			'Filt Ex');

	ARR_LIT_LBL_FLTCNTRL: array[0..3] of string = (
			'Low Pass',
			'Band Pass',
			'High Pass',
			'V3 Off');


function  C64TimerGetTime: Double;
procedure C64Wait(ASec: Double);

implementation

uses
{$IFDEF MSWINDOWS}
	Windows;
{$ENDIF}
{$IFDEF LINUX}
	Unix;
{$ENDIF}
{$IFDEF DARWIN}
	MacOSAll;
{$ENDIF}

{$IFDEF MSWINDOWS}
var
	FTickFreq: Int64;
	FUSecPTick: Double;
{$ENDIF}

function C64TimerGetTime: Double;
	var
{$IFDEF MSWINDOWS}
	T: Int64;
{$ENDIF}
{$IFDEF LINUX}
	T: TimeVal;
{$ENDIF}
{$IFDEF DARWIN}
	T: UnsignedWide;
{$ENDIF}

	begin
{$IFDEF MSWINDOWS}
	QueryPerformanceCounter(T);
	Result:= T * FUSecPTick;
{$ENDIF}
{$IFDEF LINUX}
	FPGetTimeOfDay(@T, nil);
	Result:= ((T.tv_sec * 1000000) + T.tv_usec) / 1000000;
{$ENDIF}
{$IFDEF DARWIN}
	Microseconds(T);
	Result:= T / 1000000;
{$ENDIF}
	end;

procedure C64Wait(ASec: Double);
	var
	p,
	t,
	d: Double;

	begin
	p:= -1;
	while p < 0 do
		p:= C64TimerGetTime;
	repeat
		t:= -1;
		while t < 0 do
			t:= C64TimerGetTime;

		d:= t - p;
		until d >= ASec;
	end;

{$IFDEF MSWINDOWS}
initialization
	QueryPerformanceFrequency(FTickFreq);
	FUSecPTick:= 1 / FTickFreq;
{$ENDIF}

end.

