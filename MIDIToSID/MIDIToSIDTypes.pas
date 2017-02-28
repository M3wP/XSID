//------------------------------------------------------------------------------
//MIDIToSIDTypes
//==============
//Type declarations for the MIDI To SID application.
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
unit MIDIToSIDTypes;

interface

type
	TNybble = 0..15;
	TMIDISmall = 0..127;
	TMIDILarge = 0..16383;
	TMIDIWheel = -8192..8191;
	TMIDIChannel = 1..16;

	TSIDPWidth = 0..4095;
	TSIDFreq = 0..65535;
	TSIDWaveform = (swvTriangle, swvSaw, swvPulse, swvNoise);
	TSIDWaveforms = set of TSIDWaveform;
	TSIDEffect = (sefSync, sefRing, sefTest);
	TSIDEffects = set of TSIDEffect;
	TSIDByteOrder = (sboLoHi, sboHiLo);

	TSIDVoice = (svsNone, svsVoice1, svsVoice2, svsVoice3);

	TSIDChannelMap = array[TMIDIChannel] of TSIDVoice;

	TMIDIChannelInfo = record
	private
		FLastNote: TMIDISmall;
		FNotesOn: array[TMIDISmall] of Boolean;
		FNotesOnCount: TMIDISmall;

	public
		Patch: TMIDISmall;
		DataEntryLo,
		DataEntryHi: TMIDISmall;

		PitchBendRange: TMIDISmall;
		PitchWheel: TMIDIWheel;

		procedure Initialise;

		procedure NoteOn(const ANote: TMIDISmall); inline;
		procedure NoteOff(const ANote: TMIDISmall); inline;
		function  NotesOnCount: TMIDISmall; inline;
		function  IsNoteOn(const ANote: TMIDISmall): Boolean; inline;
		function  LastNote: TMIDISmall; inline;
	end;

	TMIDIChannelInfos = array[TMIDIChannel] of TMIDIChannelInfo;


	TMusNoteName = (mnnC, mnnCs, mnnD, mnnDs, mnnE, mnnF, mnnFs, mnnG, mnnGs,
			mnnA, mnnAs, mnnB);

	PMusNoteDetail = ^TMusNoteDetail;
	TMusNoteDetail = packed record
		Name: TMusNoteName;
		Octave: Integer;
		Freq: Double;
		MidiNote: Integer;
	end;

const
	ARR_LIT_MUSNOTENAM: array[TMusNoteName] of string = (
			'C ', 'C#', 'D ', 'D#', 'E ', 'F ', 'F#', 'G ', 'G#', 'A ', 'A#', 'B ');

//	The SID can go another four ocatves lower
	ARR_REC_MUSNOTEDET: array[0..108] of TMusNoteDetail = (
		(Name: mnnC;  Octave: -1; Freq:    8.176; MidiNote:   0),
		(Name: mnnCs; Octave: -1; Freq:    8.662; MidiNote:   1),
		(Name: mnnD;  Octave: -1; Freq:    9.177; MidiNote:   2),
		(Name: mnnDs; Octave: -1; Freq:    9.723; MidiNote:   3),
		(Name: mnnE;  Octave: -1; Freq:   10.301; MidiNote:   4),
		(Name: mnnF;  Octave: -1; Freq:   10.913; MidiNote:   5),
		(Name: mnnFs; Octave: -1; Freq:   11.562; MidiNote:   6),
		(Name: mnnG;  Octave: -1; Freq:   12.250; MidiNote:   7),
		(Name: mnnGs; Octave: -1; Freq:   12.978; MidiNote:   8),
		(Name: mnnA;  Octave: -1; Freq:   13.750; MidiNote:   9),
		(Name: mnnAs; Octave: -1; Freq:   14.568; MidiNote:  10),
		(Name: mnnB;  Octave: -1; Freq:   15.434; MidiNote:  11),
		(Name: mnnC;  Octave:  0; Freq:   16.352; MidiNote:  12),
		(Name: mnnCs; Octave:  0; Freq:   17.324; MidiNote:  13),
		(Name: mnnD;  Octave:  0; Freq:   18.354; MidiNote:  14),
		(Name: mnnDs; Octave:  0; Freq:   19.445; MidiNote:  15),
		(Name: mnnE;  Octave:  0; Freq:   20.602; MidiNote:  16),
		(Name: mnnF;  Octave:  0; Freq:   21.827; MidiNote:  17),
		(Name: mnnFs; Octave:  0; Freq:   23.125; MidiNote:  18),
		(Name: mnnG;  Octave:  0; Freq:   24.500; MidiNote:  19),
		(Name: mnnGs; Octave:  0; Freq:   25.957; MidiNote:  20),
		(Name: mnnA;  Octave:  0; Freq:   27.500; MidiNote:  21),
		(Name: mnnAs; Octave:  0; Freq:   29.135; MidiNote:  22),
		(Name: mnnB;  Octave:  0; Freq:   30.868; MidiNote:  23),
		(Name: mnnC;  Octave:  1; Freq:   32.703; MidiNote:  24),
		(Name: mnnCs; Octave:  1; Freq:   34.648; MidiNote:  25),
		(Name: mnnD;  Octave:  1; Freq:   36.708; MidiNote:  26),
		(Name: mnnDs; Octave:  1; Freq:   38.891; MidiNote:  27),
		(Name: mnnE;  Octave:  1; Freq:   41.203; MidiNote:  28),
		(Name: mnnF;  Octave:  1; Freq:   43.654; MidiNote:  29),
		(Name: mnnFs; Octave:  1; Freq:   46.249; MidiNote:  30),
		(Name: mnnG;  Octave:  1; Freq:   48.999; MidiNote:  31),
		(Name: mnnGs; Octave:  1; Freq:   51.913; MidiNote:  32),
		(Name: mnnA;  Octave:  1; Freq:   55.000; MidiNote:  33),
		(Name: mnnAs; Octave:  1; Freq:   58.270; MidiNote:  34),
		(Name: mnnB;  Octave:  1; Freq:   61.735; MidiNote:  35),
		(Name: mnnC;  Octave:  2; Freq:   65.406; MidiNote:  36),
		(Name: mnnCs; Octave:  2; Freq:   69.296; MidiNote:  37),
		(Name: mnnD;  Octave:  2; Freq:   73.416; MidiNote:  38),
		(Name: mnnDs; Octave:  2; Freq:   77.782; MidiNote:  39),
		(Name: mnnE;  Octave:  2; Freq:   82.407; MidiNote:  40),
		(Name: mnnF;  Octave:  2; Freq:   87.307; MidiNote:  41),
		(Name: mnnFs; Octave:  2; Freq:   92.499; MidiNote:  42),
		(Name: mnnG;  Octave:  2; Freq:   97.999; MidiNote:  43),
		(Name: mnnGs; Octave:  2; Freq:  103.826; MidiNote:  44),
		(Name: mnnA;  Octave:  2; Freq:  110.000; MidiNote:  45),
		(Name: mnnAs; Octave:  2; Freq:  116.541; MidiNote:  46),
		(Name: mnnB;  Octave:  2; Freq:  123.471; MidiNote:  47),
		(Name: mnnC;  Octave:  3; Freq:  130.813; MidiNote:  48),
		(Name: mnnCs; Octave:  3; Freq:  138.591; MidiNote:  49),
		(Name: mnnD;  Octave:  3; Freq:  146.832; MidiNote:  50),
		(Name: mnnDs; Octave:  3; Freq:  155.563; MidiNote:  51),
		(Name: mnnE;  Octave:  3; Freq:  164.814; MidiNote:  52),
		(Name: mnnF;  Octave:  3; Freq:  174.614; MidiNote:  53),
		(Name: mnnFs; Octave:  3; Freq:  184.997; MidiNote:  54),
		(Name: mnnG;  Octave:  3; Freq:  195.998; MidiNote:  55),
		(Name: mnnGs; Octave:  3; Freq:  207.652; MidiNote:  56),
		(Name: mnnA;  Octave:  3; Freq:  220.000; MidiNote:  57),
		(Name: mnnAs; Octave:  3; Freq:  233.082; MidiNote:  58),
		(Name: mnnB;  Octave:  3; Freq:  246.942; MidiNote:  59),
		(Name: mnnC;  Octave:  4; Freq:  261.626; MidiNote:  60),
		(Name: mnnCs; Octave:  4; Freq:  277.183; MidiNote:  61),
		(Name: mnnD;  Octave:  4; Freq:  293.665; MidiNote:  62),
		(Name: mnnDs; Octave:  4; Freq:  311.127; MidiNote:  63),
		(Name: mnnE;  Octave:  4; Freq:  329.628; MidiNote:  64),
		(Name: mnnF;  Octave:  4; Freq:  349.228; MidiNote:  65),
		(Name: mnnFs; Octave:  4; Freq:  369.994; MidiNote:  66),
		(Name: mnnG;  Octave:  4; Freq:  391.995; MidiNote:  67),
		(Name: mnnGs; Octave:  4; Freq:  415.305; MidiNote:  68),
		(Name: mnnA;  Octave:  4; Freq:  440.000; MidiNote:  69),
		(Name: mnnAs; Octave:  4; Freq:  466.164; MidiNote:  70),
		(Name: mnnB;  Octave:  4; Freq:  493.883; MidiNote:  71),
		(Name: mnnC;  Octave:  5; Freq:  523.251; MidiNote:  72),
		(Name: mnnCs; Octave:  5; Freq:  554.365; MidiNote:  73),
		(Name: mnnD;  Octave:  5; Freq:  587.330; MidiNote:  74),
		(Name: mnnDs; Octave:  5; Freq:  622.254; MidiNote:  75),
		(Name: mnnE;  Octave:  5; Freq:  659.255; MidiNote:  76),
		(Name: mnnF;  Octave:  5; Freq:  698.456; MidiNote:  77),
		(Name: mnnFs; Octave:  5; Freq:  739.989; MidiNote:  78),
		(Name: mnnG;  Octave:  5; Freq:  783.991; MidiNote:  79),
		(Name: mnnGs; Octave:  5; Freq:  830.609; MidiNote:  80),
		(Name: mnnA;  Octave:  5; Freq:  880.000; MidiNote:  81),
		(Name: mnnAs; Octave:  5; Freq:  932.328; MidiNote:  82),
		(Name: mnnB;  Octave:  5; Freq:  987.767; MidiNote:  83),
		(Name: mnnC;  Octave:  6; Freq: 1046.502; MidiNote:  84),
		(Name: mnnCs; Octave:  6; Freq: 1108.731; MidiNote:  85),
		(Name: mnnD;  Octave:  6; Freq: 1174.659; MidiNote:  86),
		(Name: mnnDs; Octave:  6; Freq: 1244.508; MidiNote:  87),
		(Name: mnnE;  Octave:  6; Freq: 1318.510; MidiNote:  88),
		(Name: mnnF;  Octave:  6; Freq: 1396.913; MidiNote:  89),
		(Name: mnnFs; Octave:  6; Freq: 1479.978; MidiNote:  90),
		(Name: mnnG;  Octave:  6; Freq: 1567.982; MidiNote:  91),
		(Name: mnnGs; Octave:  6; Freq: 1661.219; MidiNote:  92),
		(Name: mnnA;  Octave:  6; Freq: 1760.000; MidiNote:  93),
		(Name: mnnAs; Octave:  6; Freq: 1864.655; MidiNote:  94),
		(Name: mnnB;  Octave:  6; Freq: 1975.533; MidiNote:  95),
		(Name: mnnC;  Octave:  7; Freq: 2093.005; MidiNote:  96),
		(Name: mnnCs; Octave:  7; Freq: 2217.461; MidiNote:  97),
		(Name: mnnD;  Octave:  7; Freq: 2349.318; MidiNote:  98),
		(Name: mnnDs; Octave:  7; Freq: 2489.016; MidiNote:  99),
		(Name: mnnE;  Octave:  7; Freq: 2637.020; MidiNote: 100),
		(Name: mnnF;  Octave:  7; Freq: 2793.826; MidiNote: 101),
		(Name: mnnFs; Octave:  7; Freq: 2959.955; MidiNote: 102),
		(Name: mnnG;  Octave:  7; Freq: 3135.963; MidiNote: 103),
		(Name: mnnGs; Octave:  7; Freq: 3322.438; MidiNote: 104),
		(Name: mnnA;  Octave:  7; Freq: 3520.000; MidiNote: 105),
		(Name: mnnAs; Octave:  7; Freq: 3729.310; MidiNote: 106),
		(Name: mnnB;  Octave:  7; Freq: 3951.066; MidiNote: 107),
		(Name: mnnC;  Octave:  8; Freq: 4186.009; MidiNote: 108));


	function  TempoDivisionToC64Cycles(const ATempo: Cardinal; const ADivision: Word;
			const ATicks, ACyclesPSec: Cardinal): Double;

	function  MIDIHiLoToLarge(const AHi, ALo: TMIDISmall): TMIDILarge;


implementation


uses
	SysUtils;


function  TempoDivisionToC64Cycles(const ATempo: Cardinal; const ADivision: Word;
		const ATicks, ACyclesPSec: Cardinal): Double;
	begin
	if  ATicks = 0 then
		Result:= 0
	else
		Result:= (ATicks * (ATempo / ADivision) / 1000000) * ACyclesPSec;
	end;

function  MIDIHiLoToLarge(const AHi, ALo: TMIDISmall): TMIDILarge;
	begin
	Result:= (AHi shl 7) or ALo;
	end;

{ TMIDIChannelInfo }

procedure TMIDIChannelInfo.Initialise;
	var
	i: Integer;

	begin
	Patch:= 0;
	DataEntryLo:= $7F;
	DataEntryHi:= $7F;

	PitchBendRange:= 2;

	for i:= Low(TMIDISmall) to High(TMIDISmall) do
		FNotesOn[i]:= False;
	FNotesOnCount:= 0;
	FLastNote:= 0;
	end;

function TMIDIChannelInfo.IsNoteOn(const ANote: TMIDISmall): Boolean;
	begin
	Result:= FNotesOn[ANote];
	end;

function TMIDIChannelInfo.LastNote: TMIDISmall;
	begin
	Result:= FLastNote;
	end;

procedure TMIDIChannelInfo.NoteOff(const ANote: TMIDISmall);
	begin
	if  FNotesOn[ANote] then
		Dec(FNotesOnCount);

	FNotesOn[ANote]:= False;
	end;

procedure TMIDIChannelInfo.NoteOn(const ANote: TMIDISmall);
	begin
	if  not FNotesOn[ANote] then
		Inc(FNotesOnCount);

	FNotesOn[ANote]:= True;
	FLastNote:= ANote;
	end;

function TMIDIChannelInfo.NotesOnCount: TMIDISmall;
	begin
	Result:= FNotesOnCount;
	end;


initialization

end.
