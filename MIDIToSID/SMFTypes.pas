//------------------------------------------------------------------------------
//SMFTypes
//========
//Type and constant delcarations for handling Standard MIDI Files.
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
unit SMFTypes;

interface

uses
	Classes;

type
//	Write all Cardinal/Word as big endian (need swap)
	PSMFChunk = ^TSMFChunk;
	TSMFChunk = packed record
		ID: AnsiString;					// 'MThd' or 'MTrk'
		Len: Cardinal;
		Data: Pointer;

		Prev,
		Next: PSMFChunk;
	end;

	PSMF = ^TSMF;
	TSMF = packed record
		First,
		Last: PSMFChunk;
	end;

const
	LIT_TOK_SMFHEADR: AnsiString = 'MThd';
	LIT_TOK_SMFTRACK: AnsiString = 'MTrk';

type
//	'MThd', Len 06
	PSMFMThd = ^TSMFMThd;
	TSMFMThd = packed record
		Format: Word;						//0, 1, 2
		NumTrks: Word;
		case Boolean of
			False: (Division: Word);		//+ = PPQN,
			True:  (FPS: ShortInt;			//- = SMPTE (-24, -25, -29, -30)
					Res: Byte);
	end;

	TSMFEvFamily = (sefNoteOff, sefNoteOn, sefAftertouch, sefController,
			sefPatchChange, sefChanPressure, sefPitchWheel, sefSystem);

	PSMFMTev = ^TSMFMTev;
	TSMFMTev = packed record
		Delta: Cardinal;					//Variable length
		DVLen: Byte;						//1, 2, 3, 4
		DVari: array[0..3] of Byte;

		Family: TSMFEvFamily;
		Data: array of Byte;
		Buf: PByte;
		BufLen: Integer;

		Prev,
		Next: PSMFMTev;
	end;

//	'MTrk', Len ??
	PSMFMTrk = ^TSMFMTrk;
	TSMFMTrk = packed record
		First,
		Last: PSMFMTev;
	end;

	TSMFEvDataLen = (selNone, selSingle, selDouble, selTriple, selVaries);

const
	ARR_TBL_SMFEVENTS: array[TSMFEvFamily] of TSMFEvDataLen = (
			selDouble, selDouble, selDouble, selDouble, selSingle, selSingle,
			selDouble, selVaries);

	ARR_LIT_LBL_SMFFAMILY: array[TSMFEvFamily] of string = (
			'Note Off', 'Note On', 'Aftertouch', 'Controller', 'Patch Change',
			'Channel Pressure', 'Pitch Wheel', 'System');

	VAL_SET_SMFCHANEV: set of TSMFEvFamily = [sefNoteOff..sefPitchWheel];


procedure SMFEvSetDelta(ASMFEv: PSMFMTev; const AValue: Cardinal);
procedure SMFTkCalcChunkLen(ASMFTk: PSMFMTrk; const AChunk: PSMFChunk);

procedure CardToVarLen(const AValue: Cardinal; var ALen: Byte;
		var AResult: array of Byte; const AMaxLen: Byte = 4);
procedure VarLenToCard(const AValue: array of Byte; var AResult: Cardinal);
procedure WriteNCard(AStream: TStream; AValue: Cardinal);
procedure ReadNCard(AStream: TStream; var AValue: Cardinal);
procedure WriteNWord(AStream: TStream; AValue: Cardinal);
procedure ReadNWord(AStream: TStream; var AValue: Word);

procedure InitialiseSMF(var ASMF: PSMF);
procedure DisposeSMF(var ASMF: PSMF);
procedure WriteSMF(const ASMF: PSMF; const AFile: TStream);
procedure ReadSMF(var ASMF: PSMF; const AFile: TStream);


implementation

uses
	SysUtils;

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
		buffer:= buffer or Byte((data and $7F) or $80);

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

procedure ReadNCard(AStream: TStream; var AValue: Cardinal);
	var
	buf: array[0..3] of Byte;

	begin
	AValue:= 0;
	AStream.ReadBuffer(buf[0], 4);

	AValue:= (buf[0] shl 24) + (buf[1] shl 16) + (buf[2] shl 8) + buf[3];
	end;

procedure WriteNWord(AStream: TStream; AValue: Cardinal);
	var
	buf: array[0..1] of Byte;

	begin
	buf[0]:= Byte((AValue and $FF00) shr 8);
	buf[1]:= Byte(AValue and $00FF);

	AStream.WriteBuffer(buf, 2);
	end;

procedure ReadNWord(AStream: TStream; var AValue: Word);
	var
	buf: array[0..1] of Byte;

	begin
	AValue:= 0;
	AStream.ReadBuffer(buf[0], 2);

	AValue:= (buf[0] shl 8) +  buf[1];
	end;

procedure InitialiseSMF(var ASMF: PSMF);
	var
	hdrCh: PSMFChunk;
	hdrDt: PSMFMThd;

	begin
	if not Assigned(ASMF) then
		New(ASMF);

	New(hdrDt);
	hdrDt^.Format:= 0;
	hdrDt^.NumTrks:= 0;
	hdrDt^.Division:= 0;

	New(hdrCh);

	ASMF^.First:= hdrCh;
	hdrCh^.ID:= LIT_TOK_SMFHEADR;

	hdrCh^.Len:= 6;
	hdrCh^.Data:= hdrDt;
	hdrCh^.Prev:= nil;
	hdrCh^.Next:= nil;
	end;

procedure DisposeSMF(var ASMF: PSMF);
	var
	pch,
	chk: PSMFChunk;

	trk: PSMFMTrk;

	pev,
	evt: PSMFMTev;

	begin
	chk:= ASMF^.Last;
	while Assigned(chk) do
		begin
		pch:= chk^.Prev;

		if  AnsiCompareStr(string(chk^.ID), string(LIT_TOK_SMFHEADR)) = 0 then
			Dispose(PSMFMTHd(chk^.Data))
		else
			begin
			trk:= PSMFMTrk(chk^.Data);

			evt:= trk^.Last;
			while Assigned(evt) do
				begin
				pev:= evt^.Prev;

				SetLength(evt^.Data, 0);
				if evt^.BufLen > 0 then
					FreeMem(evt^.Buf, evt^.BufLen);

				Dispose(evt);

				evt:= pev;
				end;

			Dispose(trk);
			end;

		Dispose(chk);

		chk:= pch;
		end;

	Dispose(ASMF);
	ASMF:= nil;
	end;

procedure WriteSMF(const ASMF: PSMF; const AFile: TStream);
	var
	chk: PSMFChunk;

	procedure WriteChunkHdr(AHdr: PSMFChunk);
		begin
		AFile.WriteBuffer(AHdr^.Id[1], 4);
		WriteNCard(AFile, AHdr^.Len);
		end;

	procedure WriteHeaderChk(AHdr: PSMFMThd);
		begin
		WriteNWord(AFile, AHdr^.Format);
		WriteNWord(AFile, AHdr^.NumTrks);
//		Fixme
		WriteNWord(AFile, AHdr^.Division);
		end;

	procedure WriteTrackChk(ATrk: PSMFMTrk);
		var
		evt: PSMFMTev;

		begin
		evt:= ATrk^.First;
		while Assigned(evt) do
			begin
			AFile.WriteBuffer(evt^.DVari[0], evt^.DVLen);
			AFile.WriteBuffer(evt^.Data[0], Length(evt^.Data));

			evt:= evt^.Next;
			end;
		end;

	begin
	chk:= ASMF^.First;
	while Assigned(chk) do
		begin
		WriteChunkHdr(chk);

		if  CompareStr(string(chk^.ID), string(LIT_TOK_SMFHEADR)) = 0 then
			WriteHeaderChk(PSMFMThd(chk^.Data))
		else
			WriteTrackChk(PSMFMTrk(chk^.Data));

		chk:= chk^.Next;
		end;
	end;

procedure ReadSMF(var ASMF: PSMF; const AFile: TStream);
	const
	ARR_VAL_SMFEVLEN: array[TSMFEvDataLen] of Integer = (
		0, 1, 2, 3, -1);

	var
	curId: array[0..3] of AnsiChar;
	curLen: Cardinal;
	curData: TMemoryStream;
	lstChk,
	thsChk: PSMFChunk;
	thsTrk: PSMFMTrk;

	procedure ReadChunkHdr;
		begin
		AFile.ReadBuffer(curId[0], 4);
		ReadNCard(AFile, curLen);
		end;

	procedure ReadChunkData;
		begin
		curData.Clear;
		curData.CopyFrom(AFile, curLen);
		curData.Seek(0, soFromBeginning);
		end;

	procedure CopyHeaderChunk(AHdr: PSMFMThd);
		begin
		ReadNWord(curData, AHdr^.Format);
		ReadNWord(curData, AHdr^.NumTrks);
//		Fixme
		ReadNWord(curData, AHdr^.Division);
		end;

	function PeekNextByte: Byte;
		begin
		curData.Read(Result, 1);
		curData.Seek(-1, soFromCurrent);
		end;

	procedure ReadVarLen(var AValue: array of Byte; var ALen: Integer);
		var
		byt: Byte;

		begin
		ALen:= 0;
		repeat
			curData.Read(byt, 1);
			AValue[ALen]:= byt;
			Inc(ALen);
			until ((byt and $80) = 0) or (ALen > 3);
		end;

	procedure CopyTrackChunk(ATrk: PSMFMTrk);
		var
		lstStat,
		thsStat: Byte;
		lstEv,
		thsEv: PSMFMTev;
		thsFm: TSMFEvFamily;
		ofs,
		len: Integer;
		byt: Byte;
		buf: array[0..3] of Byte;
		vlen: Cardinal;
		run: Boolean;

		begin
		ofs:= 0;
		vlen:= 0;
		lstStat:= 0;
		lstEv:= nil;

		while curData.Position < curData.Size do
			begin
			New(thsEv);
//			FillChar(thsEv^, SizeOf(TSMFMTev), 0);

//			Read variable size delta time
			ReadVarLen(thsEv^.DVari, ofs);
			thsEv^.DVLen:= ofs;
			VarLenToCard(thsEv^.DVari, thsEv^.Delta);

//			Check status byte or last status
			len:= 0;
			byt:= PeekNextByte;
			if  (byt and $80) = 0 then
				begin
				thsStat:= lstStat;
				run:= True;
				end
			else
				begin
				len:= 1;
				thsStat:= byt;
				run:= False;
				end;

			if thsStat < $80 then
				raise Exception.Create('Invalid status byte.  Invalid MIDI file.');

//			get data length
			thsFm:= TSMFEvFamily((thsStat and $70) shr 4);
			if  thsFm = sefSystem then
				begin
				ofs:= 0;
				lstStat:= 0;
				FillChar(buf[0], Length(buf), 0);
//				F0 - SysEx		:	F0 <vlen> <data> F7			(vlen includes data and F7)
//				F1 - MTC		:	F1 <val>
//				F2 - Song Pos	:	F2 <lo> <hi>
//				F3 - Song Sel	:	F3 <val>
//				F4 -
//				F5 -
//				F6 - Tune Req	:	F6
//				F7 - SysEx Cont :	F7 <unknown>
//				F8 - Clock		:	F8
//				F9 - Tick		:	F9
//				FA - Start		:	FA
//				FB - Continue	:	FB
//				FC - Stop		:	FC
//				FD -
//				FE - Act. Sense	:	FE
//				FF - Reset/Meta	:	FF <type> <vlen> <data>
//										00		Sequence Number
//										01		Text
//										02		Copyright
//										03		Track Name
//										04		Instrument Name
//										05		Lyric
//										06		Marker
//										07		Cue Point
//										09		Port Name
//										20		Meta Channel deprecated
//										21		MIDI Port deprecated
//										2F		End of Track
//										51		Tempo
//										54		SMPTE Offset
//										58		Time Signature
//										59		Key Signature
//										7F		Proprietary
				case thsStat of
					$F0:
						begin
						curData.Read(byt, 1);
						ReadVarLen(buf, len);
						VarLenToCard(buf, vlen);
						ofs:= len + 1;
						len:= len + Integer(vlen) + 1;
						end;
					$F1, $F3:
						len:= 2;
					$F2:
						len:= 3;
					$F6, $F8..$FC, $FE:
						len:= 1;
					$FF:
						begin
						curData.Read(byt, 1);
						curData.Read(byt, 1);
						ReadVarLen(buf, len);
						VarLenToCard(buf, vlen);
						ofs:= len + 2;
						len:= len + Integer(vlen) + 2;
						end;
					else
						raise Exception.Create('Unhandled condition; System event: ' +
							Format('$%4.4x', [curData.Position]))
					end;

				curData.Seek(-1 * ofs, soFromCurrent);
				end
			else
				begin
				lstStat:= thsStat;
				Inc(len, ARR_VAL_SMFEVLEN[ARR_TBL_SMFEVENTS[thsFm]]);
				end;

			thsEv^.Family:= thsFm;

			if  not run then
				begin
//			Read data bytes
				SetLength(thsEv^.Data, len);
//				thsEv^.Buf:= GetMem(len);
//				thsEv^.BufLen:= len;
				curData.Read(thsEv^.Data[0], len);
//				curData.Read(thsEv^.Buf^, len);
				end
			else
				begin
				SetLength(thsEv^.Data, len + 1);
				thsEv^.Data[0]:= thsStat;
				curData.Read(thsEv^.Data[1], len);
				end;

//			Next event
			if not Assigned(lstEv) then
				ATrk^.First:= thsEv
			else
				lstEv^.Next:= thsEv;

			thsEv^.Prev:= lstEv;
			lstEv:= thsEv;
			end;

		if  Assigned(lstEv) then
			ATrk^.Last:= lstEv;
		end;

	begin
	if Assigned(ASMF) then
		DisposeSMF(ASMF);

	curData:= TMemoryStream.Create;
	try
//		Read chunk header
		ReadChunkHdr;

//		if not header chunk,
		if  (CompareStr(string(LIT_TOK_SMFHEADR), string(curId)) <> 0)
		or  (curLen <> 6) then
//			abort
			raise Exception.Create('Header chunk not found.  Invalid MIDI file.')
		else
			begin
//			read chunk data
			ReadChunkData;
//			initialise smf;
			InitialiseSMF(ASMF);
//			copy data into chunk rec
			CopyHeaderChunk(PSMFMThd(ASMF^.First^.Data));
			end;

//		first chunk
		lstChk:= ASMF^.First;
		thsChk:= nil;

//		while not end of stream
		while AFile.Position < AFile.Size do
			begin
//			read chunk
			ReadChunkHdr;
			ReadChunkData;

			if CompareStr(string(LIT_TOK_SMFTRACK), string(curId)) = 0 then
				begin
//				new chunk
				New(thsChk);
				thsChk^.Prev:= lstChk;
//				contains a track
				New(thsTrk);
				thsChk^.Data:= thsTrk;

//				copy event data
				CopyTrackChunk(thsTrk);

//				next chunk
				lstChk^.Next:= thsChk;
				lstChk:= thsChk;
				end;
			end;

//		Tidy up
		ASMF^.Last:= thsChk;
		finally
		curData.Free;
		end;
	end;

{ TSMFMTev }

procedure SMFEvSetDelta(ASMFEv: PSMFMTev; const AValue: Cardinal);
	begin
	ASMFEv^.Delta:= AValue;
	CardToVarLen(ASMFEv^.Delta, ASMFEv^.DVLen, ASMFEv^.DVari, 4);
	end;

{ TSMFMTrk }

procedure SMFTkCalcChunkLen(ASMFTk: PSMFMTrk; const AChunk: PSMFChunk);
	var
	z: Cardinal;
	e: PSMFMTev;

	begin
	if  Assigned(AChunk) then
		begin
		z:= 0;

		e:= ASMFTk^.First;
		while Assigned(e) do
			begin
			Inc(z, e^.DVLen);
			Inc(z, Length(e^.Data));

			e:= e^.Next;
			end;

		AChunk^.Len:= z;
		end;
	end;

end.
