unit XSIDToMIDITypes;

interface

uses
	Classes, C64Types;

type
	TMIDINote = -1..127;
	TMIDICents = -99..99;
	TMIDIDataLong = 0..16383;
	TMIDIPitchBend = -8192..8191;

	TSIDNybble = 0..15;
	TSIDWord = 0..65535;
	TSIDPulseWidth = 0..4095;

	TSIDVoice = 0..2;
	TSIDWaveformType = (swtTest, swtTriangle, swtSawtooth, swtPulse, swtNoise);
	TSIDWaveformTypes = set of TSIDWaveformType;
	TSIDEffectType = (setSync, setRing);
	TSIDEffectTypes = set of TSIDEffectType;
	TSIDRegType = (srtFreqLo, srtFreqHi, srtPWLo, srtPWHi, srtControl, srtEnvAD,
			srtEnvSR);
	TSIDMessageType = (smtNext, smtGateOff, smtPitch, smtWaveform, smtPWidth,
			smtEffect, smtFiltMix);

	TSIDVoiceState = record
	private
		HasGated: Boolean;

		procedure DoUpdateGated;
//		procedure DoUpdateTesting;
		procedure DoUpdateEnvelope;
		procedure DoUpdateWaveform;
		procedure DoUpdateEffect;
		procedure DoUpdatePWidth;
		procedure DoUpdatePitch;
		procedure Update;

	public
		Regs: array[0..6] of Byte;
		UseFreqAfterGate: Boolean;
		LastRegType: TSIDRegType;
		AppliedEffect: TSIDEffectTypes;

		Gated: Boolean;
//		Testing: Boolean;
		Attack,
		Decay,
		Sustain,
		Release: TSIDNybble;
		Waveform: TSIDWaveFormTypes;
		Effect: TSIDEffectTypes;
		PWidth: TSIDPulseWidth;
		Pitch: TSIDWord;

		Frequency: Double;
		Note: TMIDINote;
		Cents: TMIDICents;

		procedure Initialise;
		procedure UpdateRegister(const AReg, AValue: Byte);
	end;

	TSIDFiltMixState = record
	public
		FCLo,
		FCHi,
		ResFilt,
		ModeVol: Byte;

		procedure Initialise;
		procedure UpdateRegister(const AReg, AValue: Byte);
	end;

	TSIDState = record
	private
		procedure DoUpdateVoice(const AReg, AValue: Byte);
		procedure DoUpdateEffects;

	public
		Voices: array [0..2] of TSIDVoiceState;

		procedure Initialise;
		function  IsVoiceReg(const AReg: Byte): Boolean; inline;
		function  VoiceForReg(const AReg: Byte): Integer; inline;
		function  RegisterType(const AReg: Byte): TSIDRegType; inline;
		function  IsGateChanged(const AReg, AValue: Byte): Boolean;
		procedure UpdateRegister(const AReg, AValue: Byte);
	end;

	TSIDWaveformMapping = record
		Offset: Cardinal;
		Waveform: TSIDWaveformTypes;
	end;

	TSIDPitchMapping = record
		Offset: Cardinal;
		Frequency: Double;
		Note: TMIDINote;
		Cents: TMIDICents;
	end;

	TSIDPWidthMapping = record
		Offset: Cardinal;
		Width: TSIDPulseWidth;
	end;

	TSIDEffectMapping = record
		Offset: Cardinal;
		Effect: TSIDEffectTypes;
	end;

	TSIDFiltMixMapping = record
		Offset: Cardinal;
		Reg,
		Value: Byte;
	end;

	TSIDNoteModulation = record
		NoteStart: Cardinal;
		NoteOff: Cardinal;
		NoteEnd: Cardinal;
		PitchMap: array of TSIDPitchMapping;
		PWidthMap: array of TSIDPWidthMapping;
		Sustain: TSIDNybble;

		procedure Initialise;
	end;

	TSIDInstrument = record
		Voice: TSIDVoice;
		Valid: Boolean;

		Attack,
		Decay,
		Release: TSIDNybble;

		WaveformMap: array of TSIDWaveformMapping;
		EffectMap: array of TSIDEffectMapping;

		HardSync: Boolean;

		MinNote,
		MaxNote: TMIDINote;
		UsedNotes: array[0..127] of Boolean;
		NotesCount: Byte;

		ResidualPitch: TSIDPitchMapping;

		MaxDuration: Cardinal;
		HitCount: Cardinal;

		BendRangeNotes: TMIDINote;
		BendRangeCents: TMIDICents;
        BendRange: Integer;

		procedure Initialise;
	end;

	TSIDInstrumentMap = array of TSIDInstrument;
	TSIDNoteModulationMap = array of TSIDNoteModulation;
	TSIDFiltMixMap = array of TSIDFiltMixMapping;

	TMIDIEvFamily = (mefNoteOff, mefNoteOn, mefAftertouch, mefController,
			mefPatchChange, mefChanPressure, mefPitchWheel, mefSystem,
			mefRunningStatus);
	TMIDIEvChannel = 0..15;
	TMIDIEvDataLen = (melUnknown, melSingle, melDouble, melTriple, melVaries);

	TMIDINoteMap = array[0..127] of TMIDINote;
	TMIDIPWidthStyle = (mpwNone, mpwSingle, mpwDouble);

	PMIDIInsMapping = ^TMIDIInsMapping;
	TMIDIInsMapping = record
        Name: AnsiString;
		Suppress: Boolean;
		DrumMode: Boolean;
		Channel: TMIDIEvChannel;
		ExtendForBend: Boolean;
		NoteMap: TMIDINoteMap;
		ChordMode: Boolean;
		PWidthStyle: TMIDIPWidthStyle;
        EffectOutput: Boolean;
	end;

	TMIDIInsMap = array of TMIDIInsMapping;


const
	LIT_TOK_SMFHEADR = 'MThd';
	LIT_TOK_SMFTRACK = 'MTrk';

type
	PSMFMThd = ^TSMFMThd;
	TSMFMThd = packed record
		ID: array[0..3] of AnsiChar;  		// 'MThd'
		Len: Cardinal;
		Format: Word;						//0, 1, 2
		NumTrks: Word;
		case SMPTE: Boolean of
			False: (Division: Word);		//+ = PPQN,
			True:  (FPS: ShortInt;			//- = SMPTE (-24, -25, -29, -30)
					Res: Byte);
	end;

	PSMFMTev = ^TSMFMTev;
	TSMFMTev = packed record
		Delta: Cardinal;					//Variable length
		DVLen: Byte;						//1, 2, 3, 4
		DVari: array[0..3] of Byte;
		Family: TMIDIEvFamily;
		Chan: TMIDIEvChannel;
		Data: array of Byte;

		Next,
		Prev: PSMFMTev;
	end;

	PSMFMTrk = ^TSMFMTrk;
	TSMFMTrk = packed record
		ID: array[0..3] of AnsiChar; 		// 'MTrk'
		Len: Cardinal;

		First,
		Last: PSMFMTev;

		Next,
		Prev: PSMFMTrk;
	end;

	TSMFFile = record
		HeaderChunk: PSMFMThd;
		TrackChunks: PSMFMTrk;
	end;

const
	ARR_TBL_SMFEVENTS: array[TMIDIEvFamily] of TMIDIEvDataLen = (
		melUnknown, melDouble, melDouble, melDouble, melDouble, melSingle, melSingle,
		melDouble, melVaries);

	VAL_SET_SMFCHANEV: set of TMIDIEvFamily = [mefNoteOff..mefPitchWheel];

	ARR_LBL_STDDRMNTN: array[0..127] of string = (
			'0',
			'1',
			'2',
			'3',
			'4',
			'5',
			'6',
			'7',
			'8',
			'9',
			'10',
			'11',
			'12',
			'13',
			'14',
			'15',
			'16',
			'17',
			'18',
			'19',
			'20',
			'21',
			'22',
			'23',
			'24',
			'25',
			'26',
			'High Q',
			'Slap',
			'Scratch Push',
			'Scratch Pull',
			'Sticks',
			'Square Click',
			'Metron Click',
			'Metron Bell',
			'Kick Drum 2',
			'Kick Drum 1',
			'Side Stick',
			'Aco.Snare',
			'Hand Clap',
			'Elec.Snare',
			'Low Tom 2',
			'ClosedHi-hat',
			'Low Tom 1',
			'Pedal Hi-hat',
			'Mid Tom 2',
			'Open Hi-hat',
			'Mid Tom 1',
			'High Tom 2',
			'CrashCymbal1',
			'High Tom 1',
			'Ride Cymbal1',
			'China Cymbal',
			'Ride Bell',
			'Tambourine',
			'SplashCymbal',
			'Cowbell',
			'CrashCymbal2',
			'Vibra-slap',
			'Ride Cymbal2',
			'High Bongo',
			'Low Bongo',
			'MuteHi Conga',
			'OpenHi Conga',
			'Low Conga',
			'High Timbale',
			'Low Timbale',
			'High Agogo',
			'Low Agogo',
			'Cabasa',
			'Maracas',
			'ShortWhistle',
			'Long Whistle',
			'Short Guiro',
			'Long Guiro',
			'Claves',
			'Hi WoodBlock',
			'LowWoodBlock',
			'Mute Cuica',
			'Open Cuica',
			'MuteTriangle',
			'OpenTriangle',
			'Shaker',
			'Jingle Bell',
			'Bell Tree',
			'Castanets',
			'Mute Surdo',
			'Open Surdo',
			'88',
			'89',
			'80',
			'91',
			'92',
			'93',
			'94',
			'95',
			'96',
			'97',
			'98',
			'99',
			'100',
			'101',
			'102',
			'103',
			'104',
			'105',
			'106',
			'107',
			'108',
			'109',
			'110',
			'111',
			'112',
			'113',
			'114',
			'115',
			'116',
			'117',
			'118',
			'119',
			'120',
			'121',
			'122',
			'123',
			'124',
			'125',
			'126',
			'127');


procedure CardToVarLen(const AValue: Cardinal; var ALen: Byte;
		var AResult: array of Byte; const AMaxLen: Byte = 4);
procedure VarLenToCard(const AValue: array of Byte; var AResult: Cardinal);
procedure WriteNCard(AStream: TStream; AValue: Cardinal);
procedure WriteNWord(AStream: TStream; AValue: Cardinal);

procedure InitialiseSMFFile(var ASMFFile: TSMFFile);
procedure FinaliseSMFFile(var ASMFFile: TSMFFile);
procedure WriteSMFFile(const ASMFFile: TSMFFile; const AStream: TStream);


var
	XSIDSystem: TC64SystemType = cstPAL;


implementation

uses
	SysUtils,
	Math,
	XSIDTypes;


//Should make it a function and return false if value can not fit in AResult
procedure CardToVarLen(const AValue: Cardinal; var ALen: Byte;
		var AResult: array of Byte; const AMaxLen: Byte = 4);
	var
	i: Byte;
	data: Cardinal;
	buffer: Integer;

	begin
//	These must be true
	Assert(AMaxLen > 0);
	Assert(Length(AResult) >= AMaxLen);

	ALen:= 0;
	buffer:= AValue and $7F;

	data:= AValue shr 7;
	while (ALen < AMaxLen) and (data > 0) do
		begin
//		Data bytes
		buffer:= buffer shl 8;
		buffer:= buffer or $80;
		buffer:= buffer + Byte(data and $7F);

		data:= data shr 7;
		Inc(ALen);
		end;

//	First/Last byte
	Inc(ALen);

//	Byte swap for big endian!
	for i:= 0 to ALen - 1 do
		begin
		AResult[i]:= buffer and $FF;

//		Shouldn't need this if test for break since the length is known
		if (buffer and $80) > 0 then
			buffer:= buffer shr 8
		else
//			???
			Break;
		end;
	end;

procedure VarLenToCard(const AValue: array of Byte; var AResult: Cardinal);
	var
	i: Byte;
	d: Byte;

	begin
	AResult:= 0;

	for i:= 0 to High(AValue) do
		begin
//		Byte swap for little endian
		AResult:= AResult shl 7;

//		Next data byte
		d:= AValue[i];
		AResult:= AResult + (d and $7F);

//		Last byte?
		if not ((d and $80) = $80) then
			Break;
		end;
	end;

procedure WriteNCard(AStream: TStream; AValue: Cardinal);
	var
	buf: array[0..3] of Byte;

	begin
	buf[0]:= Byte((AValue and $FF000000) shr 24);
	buf[1]:= Byte((AValue and $00FF0000) shr 16);
	buf[2]:= Byte((AValue and $0000FF00) shr 8);
	buf[3]:= Byte(AValue and $000000FF);

	AStream.WriteBuffer(buf, 4);
	end;

procedure WriteNWord(AStream: TStream; AValue: Cardinal);
	var
	buf: array[0..1] of Byte;

	begin
	buf[0]:= Byte((AValue and $FF00) shr 8);
	buf[1]:= Byte(AValue and $00FF);

	AStream.WriteBuffer(buf, 2);
	end;


procedure InitialiseSMFFile(var ASMFFile: TSMFFile);
	begin
	New(ASMFFile.HeaderChunk);
	ASMFFile.HeaderChunk^.ID:= LIT_TOK_SMFHEADR;
	ASMFFile.HeaderChunk^.Len:= 6;
	ASMFFile.HeaderChunk^.Format:= 1;
	ASMFFile.HeaderChunk^.NumTrks:= 1;
	ASMFFile.HeaderChunk^.SMPTE:= False;
	ASMFFile.HeaderChunk^.Division:= 96;

	New(ASMFFile.TrackChunks);
	ASMFFile.TrackChunks^.ID:= LIT_TOK_SMFTRACK;
	ASMFFile.TrackChunks^.Len:= 0;
	ASMFFile.TrackChunks^.First:= nil;
	ASMFFile.TrackChunks^.Last:= nil;
	ASMFFile.TrackChunks^.Next:= nil;
	ASMFFile.TrackChunks^.Prev:= nil;
	end;

procedure FinaliseSMFFile(var ASMFFile: TSMFFile);
	var
	t,
	n: PSMFMTrk;

	procedure DisposeTrack(var ATrack: PSMFMTrk);
		var
		t,
		n: PSMFMTev;

		begin
		t:= ATrack^.First;
		while Assigned(t) do
			begin
			n:= t^.Next;
			Dispose(t);
			t:= n;
			end;

		Dispose(ATrack);
		end;

	begin
	Dispose(ASMFFile.HeaderChunk);
	ASMFFile.HeaderChunk:= nil;

	t:= ASMFFile.TrackChunks;
	while Assigned(t) do
		begin
		n:= t^.Next;
		DisposeTrack(t);
		t:= n;
		end;

	ASMFFile.TrackChunks:= nil;
	end;

procedure WriteSMFFile(const ASMFFile: TSMFFile; const AStream: TStream);
	var
	i: Integer;
	ev: PSMFMTev;
	trk: PSMFMTrk;
//	lasts: TMIDIEvFamily;
	data: Byte;
//	len: TMIDIEvDataLen;

	begin
	AStream.Write(ASMFFile.HeaderChunk^.ID, 4);
	WriteNCard(AStream, ASMFFile.HeaderChunk^.Len);
	WriteNWord(AStream, ASMFFile.HeaderChunk^.Format);
	WriteNWord(AStream, ASMFFile.HeaderChunk^.NumTrks);

	if  ASMFFile.HeaderChunk^.SMPTE then
		begin
		AStream.Write(ASMFFile.HeaderChunk^.FPS, 1);
		AStream.Write(ASMFFile.HeaderChunk^.Res, 1);
		end
	else
		WriteNWord(AStream, ASMFFile.HeaderChunk^.Division);

	trk:= ASMFFile.TrackChunks;
	while  Assigned(trk) do
		begin
		AStream.Write(trk^.ID, 4);
		WriteNCard(AStream, trk^.Len);

		ev:= trk^.First;
//		lasts:= mefRunningStatus;
		while  Assigned(ev) do
			begin
			AStream.Write(ev^.DVari[0], ev^.DVLen);

			if  ev^.Family <> mefRunningStatus then
				begin
//				lasts:= ev^.Family;
				data:= (($8 or Ord(ev^.Family)) shl 4) or ev^.Chan;
				AStream.Write(data, 1);
				end;

			for i:= 0 to High(ev^.Data) do
				AStream.Write(ev^.Data[i], 1);

			ev:= ev^.Next;
			end;

		trk:= trk^.Next;
		end;
	end;


{ TSIDVoiceState }

procedure TSIDVoiceState.DoUpdateEffect;
	begin
	Effect:= [];
	if  (Regs[4] and $04) <> 0 then
		Include(Effect, setRing);
	if  (Regs[4] and $02) <> 0 then
		Include(Effect, setSync);
	end;

procedure TSIDVoiceState.DoUpdateEnvelope;
	begin
	Attack:= Regs[5] shr 4;
	Decay:= Regs[5] and $0F;
    Sustain:= Regs[6] shr 4;
	Release:= Regs[6] and $0F;
	end;

procedure TSIDVoiceState.DoUpdateGated;
	begin
	Gated:= (Regs[4] and $01) <> 0;
	end;

procedure TSIDVoiceState.DoUpdatePitch;
	var
	fnot,
	mfac: Double;
	mnot: Integer;

	begin
	Note:= -1;
	Cents:= 0;

	Pitch:= (Regs[1] shl 8) or Regs[0];
	Frequency:= Pitch * ARR_VAL_SYSSIDFRQF[XSIDSystem];

	if  Pitch > 0 then
		begin
		mnot:= Round(12 * Log2(Frequency / 440)) + 69;
		if  mnot >= 0 then
			begin
			Note:= mnot;
			fnot:= 440 * Power(2, (Note - 69) / 12);

			mfac:= Frequency / fnot;
			if  mfac <> 0 then
				Cents:= Round(1200 * Log2(mfac));
			end;
		end;
	end;

procedure TSIDVoiceState.DoUpdatePWidth;
	begin
	PWidth:= ((Regs[3] and $0F) shl 8) or Regs[2];
	end;

//procedure TSIDVoiceState.DoUpdateTesting;
//	begin
//	Testing:= (Regs[4] and $08) <> 0;
//	end;

procedure TSIDVoiceState.DoUpdateWaveform;
	begin
	Waveform:= [];

	if  (Regs[4] and $08) <> 0 then
		Include(Waveform, swtTest);

	if  (Regs[4] and $80) <> 0 then
		Include(Waveform, swtNoise);
	if  (Regs[4] and $40) <> 0 then
		Include(Waveform, swtPulse);
	if  (Regs[4] and $20) <> 0 then
		Include(Waveform, swtSawtooth);
	if  (Regs[4] and $10) <> 0 then
		Include(Waveform, swtTriangle);
	end;

procedure TSIDVoiceState.Initialise;
	var
	i: Integer;

	begin
	HasGated:= False;
	UseFreqAfterGate:= False;

	for i:= 0 to 6 do
		Regs[i]:= 0;

	Update;
	end;

procedure TSIDVoiceState.Update;
	begin
	DoUpdateGated;
//	DoUpdateTesting;
	DoUpdateEnvelope;
	DoUpdateWaveform;
	DoUpdateEffect;
    DoUpdatePWidth;
	DoUpdatePitch;

	if  Gated
	and not HasGated then
		begin
		if  Note = -1 then
			UseFreqAfterGate:= True;

		HasGated:= True;
		end;
	end;

procedure TSIDVoiceState.UpdateRegister(const AReg, AValue: Byte);
	begin
	Assert((AReg < 7), 'Register must be in correct range (0 <= r < 7)');

	Regs[AReg]:= AValue;
	Update;
	end;

{ TSIDState }

procedure TSIDState.DoUpdateEffects;
	begin
	Voices[0].AppliedEffect:= Voices[2].Effect;
	Voices[1].AppliedEffect:= Voices[0].Effect;
	Voices[2].AppliedEffect:= Voices[1].Effect;
	end;

procedure TSIDState.DoUpdateVoice(const AReg, AValue: Byte);
	var
	v: Byte;
	r: TSIDRegType;

	begin
	v:= VoiceForReg(AReg);
	r:= RegisterType(AReg);

	Voices[v].UpdateRegister(Ord(r), AValue);
	Voices[v].LastRegType:= r;
	end;

procedure TSIDState.Initialise;
	begin
	Voices[0].Initialise;
	Voices[1].Initialise;
	Voices[2].Initialise;

	DoUpdateEffects;
	end;

function TSIDState.IsGateChanged(const AReg, AValue: Byte): Boolean;
	var
	r: TSIDRegType;

	begin
	Result:= False;

	if  IsVoiceReg(AReg) then
		begin
		r:= RegisterType(AReg);

		if  r = srtControl then
			begin
			Result:= (AValue and $01) <> 0;
			Result:= Result <> Voices[VoiceForReg(AReg)].Gated;
			end;
		end;
	end;

function TSIDState.IsVoiceReg(const AReg: Byte): Boolean;
	begin
	Result:= AReg < 21;
	end;

function TSIDState.RegisterType(const AReg: Byte): TSIDRegType;
	begin
	Result:= TSIDRegType(AReg mod 7);
	end;

procedure TSIDState.UpdateRegister(const AReg, AValue: Byte);
	begin
	if  IsVoiceReg(AReg) then
		begin
		DoUpdateVoice(AReg, AValue);
		DoUpdateEffects;
		end;
	end;

function TSIDState.VoiceForReg(const AReg: Byte): Integer;
	begin
	if  AReg > 20 then
		Result:= -1
	else
		Result:= AReg div 7;
	end;

{ TSIDInstrument }

procedure TSIDInstrument.Initialise;
	var
	i: Integer;

	begin
	Voice:= 0;
	Valid:= False;

	Attack:= 0;
	Decay:= 0;
	Release:= 0;

	SetLength(WaveformMap, 0);
	SetLength(EffectMap, 0);

	HardSync:= False;

	MinNote:= -1;
	MaxNote:= -1;

	for i:= 0 to High(UsedNotes) do
		UsedNotes[i]:= False;

	NotesCount:= 0;

	MaxDuration:= 0;
	HitCount:= 0;

	BendRangeNotes:= -1;
	BendRangeCents:= 0;
	end;

{ TSIDNoteModulation }

procedure TSIDNoteModulation.Initialise;
	begin
	NoteStart:= 0;
    NoteOff:= 0;
	NoteEnd:= 0;

	SetLength(PitchMap, 0);
	SetLength(PWidthMap, 0);

//	SetLength(EffectMap, 0);
	end;

{ TSIDFiltMixState }

procedure TSIDFiltMixState.Initialise;
	begin
	FCLo:= 0;
	FCHi:= 0;
	ResFilt:= 0;
	ModeVol:= 0;
	end;

procedure TSIDFiltMixState.UpdateRegister(const AReg, AValue: Byte);
	begin
	case AReg of
		21:
			FCLo:= AValue;
		22:
			FCHi:= AValue;
		23:
			ResFilt:= AValue;
		24:
			ModeVol:= AValue;
		end;
	end;

end.
