//------------------------------------------------------------------------------
//XSIDConvertor
//=============
//XSID convertor classes for the MIDI To SID application.
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
unit XSIDConvertor;

interface

uses
	Classes, XML.XMLIntf, XML.XMLDoc, SMFTypes, C64Types, MIDIToSIDTypes,
	MIDIToSIDClasses, FramePatchBandBase;


type
	TXSIDEventData = record
		reg,
		val: reg8;
	end;

	TXSIDEvent = record
		offs: Cardinal;
		data: TXSIDEventData;
	end;

	TXSIDEvents = array of TXSIDEvent;

	TXSIDNtOnPatchBand = class(TSIDPatchBand)
	public
		NtOnAlwaysEnv: Boolean;
		NtOnAlwaysPW: Boolean;
		NtOnPWAfterGate,
		NtOnFreqAfterGate: Boolean;
		NtOnSusBeforeAtk: Boolean;
		NtOnAtkDecDelay,
		NtOnSusRelDelay: Byte;
		NtOnPWOrder: TSIDByteOrder;
		NtOnPWHiDelay,
		NtOnPWLoDelay: Byte;
		NtOnFreqOrder: TSIDByteOrder;
		NtOnFreqLoDelay,
		NtOnFreqHiDelay: Byte;
		NtOnHardSyncDelay,
		NtOnGateDelay: Byte;

		class function  GetName: string; override;
		class function  GetFrame: TFrameClass; override;

		procedure Initialise(const APatch: TSIDPatch); override;
		procedure Finalise(const APatch: TSIDPatch); override;
		procedure Assign(const APatch: TSIDPatch); override;

		procedure SaveToXML(const ADoc: IXMLDocument; const ANode: IXMLNode); override;
		procedure LoadFromXML(const ANode: IXMLNode); override;
	end;

	TXSIDCtrlPatchBand = class(TSIDPatchBand)
	public
		CtrlPWHiDelay,
		CtrlPWLoDelay: Byte;
		CtrlFreqLoDelay,
		CtrlFreqHiDelay: Byte;
		CtrlPWOrder,
		CtrlFreqOrder: TSIDByteOrder;

		class function  GetName: string; override;
		class function  GetFrame: TFrameClass; override;

		procedure Initialise(const APatch: TSIDPatch); override;
		procedure Finalise(const APatch: TSIDPatch); override;
		procedure Assign(const APatch: TSIDPatch); override;

		procedure SaveToXML(const ADoc: IXMLDocument; const ANode: IXMLNode); override;
		procedure LoadFromXML(const ANode: IXMLNode); override;
	end;

	TXSIDConvertor = class(TMIDIToSIDConvertor)
	private
		FSystem: TC64SystemType;

		FFileName: string;
		FProject: TMIDIToSIDProject;
		FStream: TStringStream;
//		FSMF: PSMF;
		FDivision: Word;
		FCyclesPSec: Cardinal;
		FVoiceLstPatch: array[TSIDVoice] of Byte;

		FOffset,
		FResidual: Double;

		procedure WriteEvent(const AEvent: TXSIDEvent);
		procedure PatchToControlReg(const APatch: TMIDISmall; var AData: Byte;
				const AGate: Boolean = False; const ATest: Boolean = False);
		function  PreparePatchNoteOnEvents(const AChannel: TMIDIChannel;
				const APatch: TMIDISmall; const ANote: TMIDISmall;
				var AEvents: TXSIDEvents): Cardinal;
		function  GetFrequencyForNote(const AChannel: TMIDIChannel;
				const ANote: TMIDISmall): Word;

	protected
		procedure ExtractChannelData1(const AEvent: PSMFMTev;
				var AChannel: TMIDIChannel; var AData1: TMIDISmall);
		procedure ExtractChannelData2(const AEvent: PSMFMTev;
				var AChannel: TMIDIChannel; var AData1, AData2: TMIDISmall);
		procedure OutputNoteOffEvent(const AChannel: TMIDIChannel;
				var AOffs, AResidual: Double);
		procedure OutputNoteOnEvents(const AChannel: TMIDIChannel;
				const ANote: TMIDISmall; var AOffs, AResidual: Double);
		procedure OutputWheelEvents(const AChannel: TMIDIChannel;
				var AOffs, AResidual: Double);
		procedure OutputPWidthEvents(const AChannel: TMIDIChannel;
				const AData: TMIDISmall; var AOffs, AResidual: Double);

	public
		constructor Create;

		class function  GetName: string; override;

		procedure Configure; override;

		procedure Initialise(const AProject: TMIDIToSIDProject); override;
		procedure Finalise; override;

		procedure ProcessEvent(const AEvent: PSMFMTev); override;
	end;


implementation

uses
	SysUtils, Math, FrameXSIDNtOnPatchBand, FrameXSIDCtrlPatchBand;


{ TXSIDConvertor }

procedure TXSIDConvertor.Configure;
	begin

	end;

constructor TXSIDConvertor.Create;
	begin
	inherited;

	FSystem:= cstPAL;
	end;

procedure TXSIDConvertor.ExtractChannelData1(const AEvent: PSMFMTev;
		var AChannel: TMIDIChannel; var AData1: TMIDISmall);
	begin
	AChannel:= (AEvent^.Data[0] and $0F) + 1;
	AData1:= AEvent^.Data[1];
	end;

procedure TXSIDConvertor.ExtractChannelData2(const AEvent: PSMFMTev;
		var AChannel: TMIDIChannel; var AData1, AData2: TMIDISmall);
	begin
	AChannel:= (AEvent^.Data[0] and $0F) + 1;
	AData1:= AEvent^.Data[1];
	AData2:= AEvent^.Data[2];
	end;

procedure TXSIDConvertor.Finalise;
	var
	f: TFileStream;

	begin
	f:= TFileStream.Create(FFileName, fmCreate);
	try
		FStream.Position:= 0;

		f.CopyFrom(FStream, FStream.Size);

		finally
		f.Free;
		end;

	FStream.Free;
	end;

function TXSIDConvertor.GetFrequencyForNote(const AChannel: TMIDIChannel;
		const ANote: TMIDISmall): Word;
	var
	f,
//	fu,
//	fl,
	c: Double;
	i: Integer;
	r: Byte;

	begin
//	i:= ANote + MIDIChannelInfo[AChannel].PitchBendRange;
//	if  i <= 108 then
//		fu:= ARR_REC_MUSNOTEDET[i].Freq
//	else
//		begin
//		r:= 1;
//		while i > 108 do
//			begin
//			Dec(i, 12);
//			r:= r * 2;
//			end;
//
//		fu:= ARR_REC_MUSNOTEDET[i].Freq * r;
//		end;
//
//	i:= ANote - MIDIChannelInfo[AChannel].PitchBendRange;
//	if  i >= 0 then
//		fl:= ARR_REC_MUSNOTEDET[i].Freq
//	else
//		begin
//		r:= 1;
//		while i < 0 do
//			begin
//			Inc(i, 12);
//			r:= r * 2;
//			end;
//
//		fl:= ARR_REC_MUSNOTEDET[i].Freq / r;
//		end;

	i:= ANote;
	if  i <= 108 then
		f:= ARR_REC_MUSNOTEDET[i].Freq
	else
		begin
		r:= 1;
		while i > 108 do
			begin
			Dec(i, 12);
			r:= r * 2;
			end;

		f:= ARR_REC_MUSNOTEDET[i].Freq * r;
		end;

	if  FProject.MIDIChannelInfo[AChannel].PitchWheel > 0 then
		begin
		c:= FProject.MIDIChannelInfo[AChannel].PitchWheel / 8191 *
				FProject.MIDIChannelInfo[AChannel].PitchBendRange * 100;
		f:= f * Power(2, c / 1200);
		end
	else if FProject.MIDIChannelInfo[AChannel].PitchWheel < 0 then
		begin
		c:= FProject.MIDIChannelInfo[AChannel].PitchWheel / 8192 *
				FProject.MIDIChannelInfo[AChannel].PitchBendRange * 100;
		f:= f * Power(2, c / 1200);
		end;

	if  f > ARR_REC_MUSNOTEDET[108].Freq then
		f:= ARR_REC_MUSNOTEDET[108].Freq
	else if f < 0 then
		f:= 0;

	Result:= Round(f / ARR_VAL_SYSSIDFRQF[FSystem]);
	end;

class function TXSIDConvertor.GetName: string;
	begin
	Result:= 'XSID Convertor';
	end;

procedure TXSIDConvertor.Initialise(const AProject: TMIDIToSIDProject);
	begin
	FProject:= AProject;
	FFileName:= ChangeFileExt(AProject.SMFFileName, '.log');
//	FSMF:= AProject.SMF;

	FDivision:= PSMFMThd(FProject.SMF^.First^.Data)^.Division;
	FCyclesPSec:= ARR_VAL_SYSCYCPSEC[FSystem];

	AProject.InitialiseMIDIChannelInfo;
	FVoiceLstPatch[svsVoice1]:= $FF;
	FVoiceLstPatch[svsVoice2]:= $FF;
	FVoiceLstPatch[svsVoice3]:= $FF;

	FResidual:= 0;

	FStream:= TStringStream.Create;
	end;

procedure TXSIDConvertor.OutputNoteOffEvent(const AChannel: TMIDIChannel;
		var AOffs, AResidual: Double);
	var
	ev: TXSIDEvent;
	p: TMIDISmall;
	b: TXSIDNtOnPatchBand;

	begin
	p:= FProject.MIDIChannelInfo[AChannel].Patch;

	if  AOffs < 0 then
		ev.offs:= 0
	else
		ev.offs:= Round(AOffs);

	case FProject.SIDChannelMap[AChannel] of
		svsVoice1:
			ev.data.reg:= $04;
		svsVoice2:
			ev.data.reg:= $0B;
		svsVoice3:
			ev.data.reg:= $12;
		end;

	PatchToControlReg(p, ev.data.val);

	AResidual:= AOffs - ev.offs;
	AOffs:= 0;

	b:= FProject.SIDPatches[p].BandByName('XSID NoteOn') as TXSIDNtOnPatchBand;

	if  ev.offs < b.NtOnGateDelay then
		begin
		AResidual:= AResidual + ev.offs - b.NtOnGateDelay;
		ev.offs:= b.NtOnGateDelay;
		end;

	WriteEvent(ev);
	end;

procedure TXSIDConvertor.OutputNoteOnEvents(const AChannel: TMIDIChannel;
		const ANote: TMIDISmall; var AOffs, AResidual: Double);
	var
	p: TMIDISmall;
	evs: TXSIDEvents;
	t: Cardinal;
	i: Integer;

	begin
	p:= FProject.MIDIChannelInfo[AChannel].Patch;

	t:= PreparePatchNoteOnEvents(AChannel, p, ANote, evs);
	if  (t > Round(AOffs))
	and (evs[0].offs < (Round(AOffs) - t)) then
		evs[0].offs:= evs[0].offs + Round(AOffs) - t;

	AResidual:= AOffs - t;
	AOffs:= 0;

	for i:= 0 to High(evs) do
		WriteEvent(evs[i]);
	end;

procedure TXSIDConvertor.OutputPWidthEvents(const AChannel: TMIDIChannel;
		const AData: TMIDISmall; var AOffs, AResidual: Double);
	var
	p: TMIDISmall;
	v: TSIDVoice;
	pw: TSIDPWidth;
	evs: TXSIDEvents;
	i: Integer;
	t: Cardinal;
	b: TXSIDCtrlPatchBand;


	begin
	p:= FProject.MIDIChannelInfo[AChannel].Patch;
	v:= FProject.SIDChannelMap[AChannel];

	pw:= Round(AData / High(TMIDISmall) * High(TSIDPWidth));

	SetLength(evs, 2);

	b:= FProject.SIDPatches[p].BandByName('XSID Controller') as TXSIDCtrlPatchBand;

	if  b.CtrlFreqOrder = sboLoHi then
		begin
		evs[0].offs:= b.CtrlFreqLoDelay;
		evs[0].data.reg:= $02;
		evs[0].data.val:= pw and $FF;

		evs[1].offs:= b.CtrlFreqHiDelay;
		evs[1].data.reg:= $03;
		evs[1].data.val:= (pw and $FF00) shr 8;
		end
	else
		begin
		evs[0].offs:= b.CtrlFreqHiDelay;
		evs[0].data.reg:= $03;
		evs[0].data.val:= (pw and $FF00) shr 8;

		evs[1].offs:= b.CtrlFreqLoDelay;
		evs[1].data.reg:= $02;
		evs[1].data.val:= pw and $FF;
		end;

//  Update the regs for required voice
	if  v > svsVoice1 then
		for i:= 0 to High(evs) do
			evs[i].data.reg:= evs[i].data.reg + (Ord(v) - 1) * 7;

	t:= evs[0].offs + evs[1].offs;

	if  (t > Round(AOffs))
	and (evs[0].offs < (Round(AOffs) - t)) then
		evs[0].offs:= evs[0].offs + Round(AOffs) - t;

	AResidual:= AOffs - t;
	AOffs:= 0;

	for i:= 0 to High(evs) do
		WriteEvent(evs[i]);
	end;

procedure TXSIDConvertor.OutputWheelEvents(const AChannel: TMIDIChannel; var AOffs,
		AResidual: Double);
	var
	p: TMIDISmall;
	v: TSIDVoice;
	freq: Word;
	evs: TXSIDEvents;
	i: Integer;
	t: Cardinal;
	b: TXSIDCtrlPatchBand;

	begin
	p:= FProject.MIDIChannelInfo[AChannel].Patch;
	v:= FProject.SIDChannelMap[AChannel];

//  Get the frequency
	freq:= GetFrequencyForNote(AChannel, FProject.MIDIChannelInfo[AChannel].LastNote);

	SetLength(evs, 2);

	b:= FProject.SIDPatches[p].BandByName('XSID Controller') as TXSIDCtrlPatchBand;

	if  b.CtrlFreqOrder = sboLoHi then
		begin
		evs[0].offs:= b.CtrlFreqLoDelay;
		evs[0].data.reg:= $00;
		evs[0].data.val:= freq and $FF;

		evs[1].offs:= b.CtrlFreqHiDelay;
		evs[1].data.reg:= $01;
		evs[1].data.val:= (freq and $FF00) shr 8;
		end
	else
		begin
		evs[0].offs:= b.CtrlFreqHiDelay;
		evs[0].data.reg:= $01;
		evs[0].data.val:= (freq and $FF00) shr 8;

		evs[1].offs:= b.CtrlFreqLoDelay;
		evs[1].data.reg:= $00;
		evs[1].data.val:= freq and $FF;
		end;

//  Update the regs for required voice
	if  v > svsVoice1 then
		for i:= 0 to High(evs) do
			evs[i].data.reg:= evs[i].data.reg + (Ord(v) - 1) * 7;

	t:= evs[0].offs + evs[1].offs;

	if  (t > Round(AOffs))
	and (evs[0].offs < (Round(AOffs) - t)) then
		evs[0].offs:= evs[0].offs + Round(AOffs) - t;

	AResidual:= AOffs - t;
	AOffs:= 0;

	for i:= 0 to High(evs) do
		WriteEvent(evs[i]);
	end;

procedure TXSIDConvertor.PatchToControlReg(const APatch: TMIDISmall;
		var AData: Byte; const AGate, ATest: Boolean);
	var
	w: TSIDWaveforms;
	e: TSIDEffects;

	begin
	w:= FProject.SIDPatches[APatch].Waveforms;
	e:= FProject.SIDPatches[APatch].Effects;

	AData:= 0;
	if  AGate then
		AData:= AData or 1;

	if  sefSync in e then
		AData:= AData or 2;
	if  sefRing in e then
		AData:= AData or 4;

	if  ATest then
		AData:= AData or 8;

	if  swvTriangle in w then
		AData:= AData or 16;
	if  swvSaw in w then
		AData:= AData or 32;
	if  swvPulse in w then
		AData:= AData or 64;
	if  swvNoise in w then
		AData:= AData or 128;
	end;

function TXSIDConvertor.PreparePatchNoteOnEvents(const AChannel: TMIDIChannel;
		const APatch, ANote: TMIDISmall; var AEvents: TXSIDEvents): Cardinal;
	var
	n,
	i: Integer;
	freq: Word;
	v: TSIDVoice;
	b: TXSIDNtOnPatchBand;

	begin
//  Get the voice required
	v:= FProject.SIDChannelMap[AChannel];

	b:= FProject.SIDPatches[APatch].BandByName('XSID NoteOn') as TXSIDNtOnPatchBand;

//  Count the number required
	n:= 0;
//  - Need for envelope?
	if  b.NtOnAlwaysEnv
	or  (FVoiceLstPatch[FProject.SIDChannelMap[AChannel]] <> APatch) then
		Inc(n, 2);

//  - Need for pw?
	if  b.NtOnAlwaysPW
	or  (FVoiceLstPatch[v] <> APatch) then
		Inc(n, 2);

//  - Need for freq
	Inc(n, 2);

//  - Need for hard sync?
	if  FProject.SIDPatches[APatch].NtOnHardSync then
		Inc(n);

//  - Need for gate
	Inc(n);

//  Set-up the array
	SetLength(AEvents, n);

//  Get the frequency
	freq:= GetFrequencyForNote(AChannel, ANote);

//  Fill in the array (default voice 1)
	i:= 0;
//  - Need for envelope?
	if  b.NtOnAlwaysEnv
	or  (FVoiceLstPatch[v] <> APatch) then
		begin
//      - Sus/Rel first or last?
		if  b.NtOnSusBeforeAtk then
			begin
			AEvents[i].offs:= b.NtOnSusRelDelay;
			AEvents[i].data.reg:= $06;
			AEvents[i].data.val:= (FProject.SIDPatches[APatch].Sustain shl 4) or
					FProject.SIDPatches[APatch].Release;
			Inc(i);

			AEvents[i].offs:= b.NtOnAtkDecDelay;
			AEvents[i].data.reg:= $05;
			AEvents[i].data.val:= (FProject.SIDPatches[APatch].Attack shl 4) or
					FProject.SIDPatches[APatch].Decay;
			Inc(i);
			end
		else
			begin
			AEvents[i].offs:= b.NtOnAtkDecDelay;
			AEvents[i].data.reg:= $05;
			AEvents[i].data.val:= (FProject.SIDPatches[APatch].Attack shl 4) or
					FProject.SIDPatches[APatch].Decay;
			Inc(i);

			AEvents[i].offs:= b.NtOnSusRelDelay;
			AEvents[i].data.reg:= $06;
			AEvents[i].data.val:= (FProject.SIDPatches[APatch].Sustain shl 4) or
					FProject.SIDPatches[APatch].Release;
			Inc(i);
			end;
		end;

//  - Need for pw before gate?
	if  b.NtOnAlwaysPW
	or  (FVoiceLstPatch[v] <> APatch) then
		if  not b.NtOnPWAfterGate then
			if  b.NtOnPWOrder = sboLoHi then
				begin
				AEvents[i].offs:= b.NtOnPWLoDelay;
				AEvents[i].data.reg:= $02;
				AEvents[i].data.val:= FProject.SIDPatches[APatch].PulseWidth and $FF;
				Inc(i);

				AEvents[i].offs:= b.NtOnPWHiDelay;
				AEvents[i].data.reg:= $03;
				AEvents[i].data.val:=
						(FProject.SIDPatches[APatch].PulseWidth and $FF00) shr 8;
				Inc(i);
				end
			else
				begin
				AEvents[i].offs:= b.NtOnPWHiDelay;
				AEvents[i].data.reg:= $03;
				AEvents[i].data.val:=
						(FProject.SIDPatches[APatch].PulseWidth and $FF00) shr 8;
				Inc(i);

				AEvents[i].offs:= b.NtOnPWLoDelay;
				AEvents[i].data.reg:= $02;
				AEvents[i].data.val:= FProject.SIDPatches[APatch].PulseWidth and $FF;
				Inc(i);
				end;

//  - Need for freq before gate?
	if  not b.NtOnFreqAfterGate then
		if  b.NtOnFreqOrder = sboLoHi then
			begin
			AEvents[i].offs:= b.NtOnFreqLoDelay;
			AEvents[i].data.reg:= $00;
			AEvents[i].data.val:= freq and $FF;
			Inc(i);

			AEvents[i].offs:= b.NtOnFreqHiDelay;
			AEvents[i].data.reg:= $01;
			AEvents[i].data.val:= (freq and $FF00) shr 8;
			Inc(i);
			end
		else
			begin
			AEvents[i].offs:= b.NtOnFreqHiDelay;
			AEvents[i].data.reg:= $01;
			AEvents[i].data.val:= (freq and $FF00) shr 8;
			Inc(i);

			AEvents[i].offs:= b.NtOnFreqLoDelay;
			AEvents[i].data.reg:= $00;
			AEvents[i].data.val:= freq and $FF;
			Inc(i);
			end;

//  - Need for hard sync
	if  FProject.SIDPatches[APatch].NtOnHardSync then
		begin
		AEvents[i].offs:= b.NtOnHardSyncDelay;
		AEvents[i].data.reg:= $04;
		PatchToControlReg(APatch, AEvents[i].data.val, True, True);
		Inc(i);
		end;

//  - Need for gate
	AEvents[i].offs:= b.NtOnGateDelay;
	AEvents[i].data.reg:= $04;
	PatchToControlReg(APatch, AEvents[i].data.val, True, False);
	Inc(i);

//  - Need for pw after gate?
	if  b.NtOnAlwaysPW
	or  (FVoiceLstPatch[v] <> APatch) then
		if  b.NtOnPWAfterGate then
			if  b.NtOnPWOrder = sboLoHi then
				begin
				AEvents[i].offs:= b.NtOnPWLoDelay;
				AEvents[i].data.reg:= $02;
				AEvents[i].data.val:= FProject.SIDPatches[APatch].PulseWidth and $FF;
				Inc(i);

				AEvents[i].offs:= b.NtOnPWHiDelay;
				AEvents[i].data.reg:= $03;
				AEvents[i].data.val:=
						(FProject.SIDPatches[APatch].PulseWidth and $FF00) shr 8;
				Inc(i);
				end
			else
				begin
				AEvents[i].offs:= b.NtOnPWHiDelay;
				AEvents[i].data.reg:= $03;
				AEvents[i].data.val:=
						(FProject.SIDPatches[APatch].PulseWidth and $FF00) shr 8;
				Inc(i);

				AEvents[i].offs:= b.NtOnPWLoDelay;
				AEvents[i].data.reg:= $02;
				AEvents[i].data.val:= FProject.SIDPatches[APatch].PulseWidth and $FF;
				Inc(i);
				end;

//  - Need for freq after gate?
	if  b.NtOnFreqAfterGate then
		if  b.NtOnFreqOrder = sboLoHi then
			begin
			AEvents[i].offs:= b.NtOnFreqLoDelay;
			AEvents[i].data.reg:= $00;
			AEvents[i].data.val:= freq and $FF;
			Inc(i);

			AEvents[i].offs:= b.NtOnFreqHiDelay;
			AEvents[i].data.reg:= $01;
			AEvents[i].data.val:= (freq and $FF00) shr 8;
//			Inc(i);
			end
		else
			begin
			AEvents[i].offs:= b.NtOnFreqHiDelay;
			AEvents[i].data.reg:= $01;
			AEvents[i].data.val:= (freq and $FF00) shr 8;
			Inc(i);

			AEvents[i].offs:= b.NtOnFreqLoDelay;
			AEvents[i].data.reg:= $00;
			AEvents[i].data.val:= freq and $FF;
//			Inc(i);
			end;

//  Update the regs for required voice
	if  v > svsVoice1 then
		for i:= 0 to High(AEvents) do
			AEvents[i].data.reg:= AEvents[i].data.reg + (Ord(v) - 1) * 7;

//  Set the last used patch for the voice
	FVoiceLstPatch[FProject.SIDChannelMap[AChannel]]:= APatch;

//  Return the number of cycles required for events
	Result:= 0;
	for i:= 0 to High(AEvents) do
		Inc(Result, AEvents[i].offs);
	end;

procedure TXSIDConvertor.ProcessEvent(const AEvent: PSMFMTev);
	var
	offs: Double;
	ch: TMIDIChannel;
	d1,
	d2: TMIDISmall;
	l1: TMIDILarge;

	begin
	offs:= TempoDivisionToC64Cycles(FProject.MIDICurrentTempo, FDivision,
			AEvent^.Delta, FCyclesPSec) + FResidual;

	FOffset:= FOffset + offs;
	FResidual:= 0;

	case AEvent^.Family of
		sefNoteOff:
			begin
			ExtractChannelData2(AEvent, ch, d1, d2);

			if  FProject.SIDChannelMap[ch] > svsNone then
				if  FProject.MIDIChannelInfo[ch].IsNoteOn(d1) then
					begin
					OutputNoteOffEvent(ch, FOffset, FResidual);
					FProject.MIDIChannelInfo[ch].NoteOff(d1);
					end;
			end;
		sefNoteOn:
			begin
			ExtractChannelData2(AEvent, ch, d1, d2);

			if  FProject.SIDChannelMap[ch] > svsNone then
				if  d2 = 0 then
					begin
					if  FProject.MIDIChannelInfo[ch].IsNoteOn(d1) then
						begin
						OutputNoteOffEvent(ch, FOffset, FResidual);
						FProject.MIDIChannelInfo[ch].NoteOff(d1);
						end;
					end
				else
					begin
					if  FProject.MIDIChannelInfo[ch].NotesOnCount = 0 then
						begin
						OutputNoteOnEvents(ch, d1, FOffset, FResidual);
						FProject.MIDIChannelInfo[ch].NoteOn(d1);
						end;
					end;
			end;
		sefAftertouch:
			;
		sefController:
			begin
			ExtractChannelData2(AEvent, ch, d1, d2);

			if  FProject.SIDChannelMap[ch] > svsNone then
				if  d1 = $65 then
					FProject.MIDIChannelInfo[ch].DataEntryHi:= d2
				else if d1 = $64 then
					FProject.MIDIChannelInfo[ch].DataEntryLo:= d2
				else if d1 = $06 then
					begin
					l1:= MIDIHiLoToLarge(FProject.MIDIChannelInfo[ch].DataEntryHi,
							FProject.MIDIChannelInfo[ch].DataEntryLo);
					if  l1 = 0 then
						FProject.MIDIChannelInfo[ch].PitchBendRange:= d2 + 1;
					end
				else if d1 = $6E then
					OutputPWidthEvents(ch, d2, FOffset, FResidual);
			end;
		sefPatchChange:
			begin
			ExtractChannelData1(AEvent, ch, d1);

			if  FProject.SIDChannelMap[ch] > svsNone then
				FProject.MIDIChannelInfo[ch].Patch:= d1;
			end;
		sefChanPressure:
			;
		sefPitchWheel:
			begin
			ExtractChannelData2(AEvent, ch, d1, d2);

			if  FProject.SIDChannelMap[ch] > svsNone then
				begin
				l1:= MIDIHiLoToLarge(d2, d1);
				FProject.MIDIChannelInfo[ch].PitchWheel:= l1 - 8192;

				if  FProject.MIDIChannelInfo[ch].NotesOnCount > 0 then
					OutputWheelEvents(ch, FOffset, FResidual);
				end;
			end;
		sefSystem:
			;
		end;
	end;

procedure TXSIDConvertor.WriteEvent(const AEvent: TXSIDEvent);
	begin
	FStream.WriteString(IntToStr(AEvent.offs) + ' ' + IntToStr(AEvent.data.reg) +
			' ' + IntToStr(AEvent.data.val) + sLineBreak);
	end;


{ TXSIDNtOnPatchBand }

procedure TXSIDNtOnPatchBand.Assign(const APatch: TSIDPatch);
	var
	sb: TXSIDNtOnPatchBand;

	begin
	sb:= APatch.BandByName('XSID NoteOn') as TXSIDNtOnPatchBand;

	NtOnFreqAfterGate:= sb.NtOnFreqAfterGate;
	NtOnPWAfterGate:= sb.NtOnPWAfterGate;
	NtOnAlwaysEnv:= sb.NtOnAlwaysEnv;
	NtOnAtkDecDelay:= sb.NtOnAtkDecDelay;
	NtOnSusRelDelay:= sb.NtOnSusRelDelay;
	NtOnSusBeforeAtk:= sb.NtOnSusBeforeAtk;
	NtOnAlwaysPW:= sb.NtOnAlwaysPW;
	NtOnPWOrder:= sb.NtOnPWOrder;
	NtOnPWHiDelay:= sb.NtOnPWHiDelay;
	NtOnPWLoDelay:= sb.NtOnPWLoDelay;
	NtOnFreqOrder:= sb.NtOnFreqOrder;
	NtOnFreqLoDelay:= sb.NtOnFreqLoDelay;
	NtOnFreqHiDelay:= sb.NtOnFreqHiDelay;
	NtOnHardSyncDelay:= sb.NtOnHardSyncDelay;
	NtOnGateDelay:= sb.NtOnGateDelay;
	end;

procedure TXSIDNtOnPatchBand.Finalise(const APatch: TSIDPatch);
	begin
	end;

class function TXSIDNtOnPatchBand.GetFrame: TFrameClass;
	begin
	Result:= TXSIDNtOnPatchBandFrame;
	end;

class function TXSIDNtOnPatchBand.GetName: string;
	begin
	Result:= 'XSID NoteOn';
	end;

procedure TXSIDNtOnPatchBand.Initialise(const APatch: TSIDPatch);
	begin
	NtOnFreqAfterGate:= True;
	NtOnPWAfterGate:= True;
	NtOnAlwaysEnv:= True;
	NtOnAtkDecDelay:= 19;
	NtOnSusRelDelay:= 33;
	NtOnSusBeforeAtk:= True;
	NtOnAlwaysPW:= True;
	NtOnPWOrder:= sboHiLo;
	NtOnPWHiDelay:= 19;
	NtOnPWLoDelay:= 19;
	NtOnFreqOrder:= sboLoHi;
	NtOnFreqLoDelay:= 33;
	NtOnFreqHiDelay:= 4;
	NtOnHardSyncDelay:= 19;
	NtOnGateDelay:= 7;
	end;

procedure TXSIDNtOnPatchBand.LoadFromXML(const ANode: IXMLNode);
	begin
	NtOnFreqAfterGate:= ANode.ChildNodes.FindNode('ntonfreqaftergate').NodeValue;
	NtOnPWAfterGate:= ANode.ChildNodes.FindNode('ntonpwaftergate').NodeValue;
	NtOnAlwaysEnv:= ANode.ChildNodes.FindNode('ntonalwaysenv').NodeValue;
	NtOnAtkDecDelay:= ANode.ChildNodes.FindNode('ntonatkdecdelay').NodeValue;
	NtOnSusRelDelay:= ANode.ChildNodes.FindNode('ntonsusreldelay').NodeValue;
	NtOnSusBeforeAtk:= ANode.ChildNodes.FindNode('ntonsusbeforeatk').NodeValue;
	NtOnAlwaysPW:= ANode.ChildNodes.FindNode('ntonalwayspw').NodeValue;
	NtOnPWOrder:= ANode.ChildNodes.FindNode('ntonpworder').NodeValue;
	NtOnPWHiDelay:= ANode.ChildNodes.FindNode('ntonpwhidelay').NodeValue;
	NtOnPWLoDelay:= ANode.ChildNodes.FindNode('ntonpwlodelay').NodeValue;
	NtOnFreqOrder:= ANode.ChildNodes.FindNode('ntonfreqorder').NodeValue;
	NtOnFreqLoDelay:= ANode.ChildNodes.FindNode('ntonfreqlodelay').NodeValue;
	NtOnFreqHiDelay:= ANode.ChildNodes.FindNode('ntonfreqhidelay').NodeValue;
	NtOnHardSyncDelay:= ANode.ChildNodes.FindNode('ntonhardsyncdelay').NodeValue;
	NtOnGateDelay:= ANode.ChildNodes.FindNode('ntongatedelay').NodeValue;
	end;

procedure TXSIDNtOnPatchBand.SaveToXML(const ADoc: IXMLDocument;
		const ANode: IXMLNode);

	procedure DoAddNode(const ANodeName: string; const ANodeValue: OLEVariant);
		var
		en: IXMLNode;

		begin
		en:= ADoc.CreateElement(ANodeName, '');
		en.NodeValue:= ANodeValue;
		ANode.ChildNodes.Add(en);
		end;

	begin
	DoAddNode('ntonfreqaftergate', NtOnFreqAfterGate);
	DoAddNode('ntonpwaftergate', NtOnPWAfterGate);
	DoAddNode('ntonalwaysenv', NtOnAlwaysEnv);
	DoAddNode('ntonatkdecdelay', NtOnAtkDecDelay);
	DoAddNode('ntonsusreldelay', NtOnSusRelDelay);
	DoAddNode('ntonsusbeforeatk', NtOnSusBeforeAtk);
	DoAddNode('ntonalwayspw', NtOnAlwaysPW);
	DoAddNode('ntonpworder', NtOnPWOrder);
	DoAddNode('ntonpwhidelay', NtOnPWHiDelay);
	DoAddNode('ntonpwlodelay', NtOnPWLoDelay);
	DoAddNode('ntonfreqorder', NtOnFreqOrder);
	DoAddNode('ntonfreqlodelay', NtOnFreqLoDelay);
	DoAddNode('ntonfreqhidelay', NtOnFreqHiDelay);
	DoAddNode('ntonhardsyncdelay', NtOnHardSyncDelay);
	DoAddNode('ntongatedelay', NtOnGateDelay);
	end;

{ TXSIDCtrlPatchBand }

procedure TXSIDCtrlPatchBand.Assign(const APatch: TSIDPatch);
	var
	sb: TXSIDCtrlPatchBand;

	begin
	sb:= APatch.BandByName('XSID Controller') as TXSIDCtrlPatchBand;

	CtrlPWHiDelay:= sb.CtrlPWHiDelay;
	CtrlPWLoDelay:= sb.CtrlPWLoDelay;
	CtrlFreqLoDelay:= sb.CtrlFreqLoDelay;
	CtrlFreqHiDelay:= sb.CtrlFreqHiDelay;
	CtrlPWOrder:= sb.CtrlPWOrder;
	CtrlFreqOrder:= sb.CtrlFreqOrder;
	end;

procedure TXSIDCtrlPatchBand.Finalise(const APatch: TSIDPatch);
	begin
	end;

class function TXSIDCtrlPatchBand.GetFrame: TFrameClass;
	begin
	Result:= TXSIDCtrlPatchBandFrame;
	end;

class function TXSIDCtrlPatchBand.GetName: string;
	begin
	Result:= 'XSID Controller';
	end;

procedure TXSIDCtrlPatchBand.Initialise(const APatch: TSIDPatch);
	begin
	CtrlPWHiDelay:= 4;
	CtrlPWLoDelay:= 4;
	CtrlFreqLoDelay:= 19;
	CtrlFreqHiDelay:= 4;
	CtrlPWOrder:= sboLoHi;
	CtrlFreqOrder:= sboLoHi;
	end;

procedure TXSIDCtrlPatchBand.LoadFromXML(const ANode: IXMLNode);
	begin
	CtrlPWHiDelay:= ANode.ChildNodes.FindNode('ctrlpwhidelay').NodeValue;
	CtrlPWLoDelay:= ANode.ChildNodes.FindNode('ctrlpwlodelay').NodeValue;
	CtrlFreqLoDelay:= ANode.ChildNodes.FindNode('ctrlfreqlodelay').NodeValue;
	CtrlFreqHiDelay:= ANode.ChildNodes.FindNode('ctrlfreqhidelay').NodeValue;
	CtrlPWOrder:= ANode.ChildNodes.FindNode('ctrlpworder').NodeValue;
	CtrlFreqOrder:= ANode.ChildNodes.FindNode('ctrlfreqorder').NodeValue;
	end;

procedure TXSIDCtrlPatchBand.SaveToXML(const ADoc: IXMLDocument;
		const ANode: IXMLNode);
	procedure DoAddNode(const ANodeName: string; const ANodeValue: OLEVariant);
		var
		en: IXMLNode;

		begin
		en:= ADoc.CreateElement(ANodeName, '');
		en.NodeValue:= ANodeValue;
		ANode.ChildNodes.Add(en);
		end;

	begin
	DoAddNode('ctrlpwhidelay', CtrlPWHiDelay);
	DoAddNode('ctrlpwlodelay', CtrlPWLoDelay);
	DoAddNode('ctrlfreqlodelay', CtrlFreqLoDelay);
	DoAddNode('ctrlfreqhidelay', CtrlFreqHiDelay);
	DoAddNode('ctrlpworder', CtrlPWOrder);
	DoAddNode('ctrlfreqorder', CtrlFreqOrder);
	end;


initialization
	RegisterPatchBandClass(TXSIDNtOnPatchBand);
	RegisterPatchBandClass(TXSIDCtrlPatchBand);

	RegisterConvertorClass(TXSIDConvertor);

end.
