unit C64Types;

{$IFDEF FPC}
	{$MODE DELPHI}
{$ENDIF}
//todo Need checks for DCC to define WINDOWS so we can change the $IFDEF WIN32
//		checks below to just $IFDEF WINDOWS checks.

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

//dengland This should be Cardinal
	cycle_count = Integer;

	TC64UpdateRate = (cur1X, cur2X, cur4X, cur8X, cur16X);
//dengland cstUnknown is for compatibility only.
	TC64SystemType = (cstUnknown, cstPAL, cstNTSC, cstNTSCOLD, cstPALN, cstNominal);
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
			' 0 $00:  Voice 1 FREQ LO',
			' 1 $01:  Voice 1 FREQ HI',
			' 2 $02:  Voice 1 PW LO',
			' 3 $03:  Voice 1 PW HI',
			' 4 $04:  Voice 1 CNTRL',
			' 5 $05:  Voice 1 ATK/DEC',
			' 6 $06:  Voice 1 SUS/REL',
			' 7 $07:  Voice 2 FREQ LO',
			' 8 $08:  Voice 2 FREQ HI',
			' 9 $09:  Voice 2 PW LO',
			'10 $0A:  Voice 2 PW HI',
			'11 $0B:  Voice 2 CNTRL',
			'12 $0C:  Voice 2 ATK/DEC',
			'13 $0D:  Voice 2 SUS/REL',
			'14 $0E:  Voice 3 FREQ LO',
			'15 $0F:  Voice 3 FREQ HI',
			'16 $10:  Voice 3 PW LO',
			'17 $11:  Voice 3 PW HI',
			'18 $12:  Voice 3 CNTRL',
			'19 $13:  Voice 3 ATK/DEC',
			'20 $14:  Voice 3 SUS/REL',
			'21 $15:  Filter  FC LO',
			'22 $16:  Filter  FC HI',
			'23 $17:  Filter  RES/FILT',
			'24 $18:  Filter  MODE/VOL');

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


//                                                         Voice 1       TYPE
//   0 00   F7    F6    F5    F4    F3    F2    F1    F0   FREQ LO         WO
//   1 01   F15   F14   F13   F12   F11   F10   F9    F8   FREQ HI         WO
//   2 02   PW7   PW6   PW5   PW4   PW3   PW2   PW1   PW0  PW LO           WO
//   3 03    -     -     -     -   PW11  PW10   PW9   PW8  PW HI           WO
//   4 04  NOISE PULSE  SAW TRIANG TEST  RING  SYNC  GATE  CONTROL REG     WO
//   5 05  ATK3  ATK2  ATK1  ATK0  DCY3  DCY2  DCY1  DCY0  ATTACK/DECAY    WO
//   6 06  STN3  STN2  STN1  STN0  RLS3  RLS2  RLS1  RLS0  SUSTAIN/RELEASE WO

//														 Voice 2
//   7 07   F7    F6    F5    F4    F3    F2    F1    F0   FREQ LO         WO
//   8 08   F15   F14   F13   F12   F11   F10   F9    F8   FREQ HI         WO
//   9 09   PW7   PW6   PW5   PW4   PW3   PW2   PW1   PW0  PW LO           WO
//  10 0A    -     -     -     -   PW11  PW10   PW9   PW8  PW HI           WO
//  11 0B  NOISE PULSE  SAW TRIANG TEST  RING  SYNC  GATE  CONTROL REG     WO
//  12 0C  ATK3  ATK2  ATK1  ATK0  DCY3  DCY2  DCY1  DCY0  ATTACK/DECAY    WO
//  13 0D  STN3  STN2  STN1  STN0  RLS3  RLS2  RLS1  RLS0  SUSTAIN/RELEASE WO

//                                                         Voice 3
//  14 0E   F7    F6    F5    F4    F3    F2    F2    F1   FREQ LO         WO
//  15 0F   F15   F14   F13   F12   F11   F10   F9    F8   FREQ HI         WO
//  16 10   PW7   PW6   PW5   PW4   PW3   PW2   PW1   PW0  PW LO           WO
//  17 11    -     -     -     -   PW11  PW10   PW9   PW8  PW HI           WO
//  18 12  NOISE PULSE  SAW TRIANG TEST  RING  SYNC  GATE  CONTROL REG     WO
//  19 13  ATK3  ATK2  ATK1  ATK0  DCY3  DCY2  DCY1  DCY0  ATTACK/DECAY    WO
//  20 14  STN3  STN2  STN1  STN0  RLS3  RLS2  RLS1  RLS0  SUSTAIN/RELEASE WO

//                                                         Filter
//  21 15    -     -     -     -     -    FC2   FC1   FC0  FC LO           WO
//  22 16  FC10   FC9   FC8   FC7   FC6   FC5   FC4   FC3  FC HI           WO
//  23 17  RES3  RES2  RES1  RES0 FILTEX FILT3 FILT2 FILT1 RES/FILT        WO
//  24 18  3OFF   HP    BP    LP   VOL3  VOL2  VOL1  VOL0  MODE/VOL        WO

//														 Misc.
//  25 19   PX7   PX6   PX5   PX4   PX3   PX2   PX1   PX0  POT X           RO
//  26 1A   PY7   PY6   PY5   PY4   PY3   PY2   PY1   PY0  POT Y           RO
//  27 1B   O7    O6    O5    O4    O3    O2    O1    O0   OSC3/RANDOM     RO
//  28 1C   E7    E6    E5    E4    E3    E2    E1    E0   ENV3            RO


function  C64TimerGetTime: Double;
procedure C64Wait(ASec: Double);

implementation

uses
{$IFDEF MSWINDOWS}
	Windows
{$IFDEF FPC}
	, LCLIntf, LCLType, LMessages
{$ENDIF}
	;
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
	Result:= T.int / 1000000;
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

