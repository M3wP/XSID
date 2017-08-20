unit XSIDFiles;

{$INCLUDE XSID.inc}

interface

uses
	Classes,
	C64Types;

type
	TXSIDFileConfig = class
//		System settings
		System: TC64SystemType;
		UpdateRate: TC64UpdateRate;

//		SID settings
//TODO  Need these for each SID used.
		Model: TC64SIDModel;
		Filter6581,
		Filter8580: Double;
		FilterEnable: Boolean;
		DigiBoostEnable: Boolean;
		SIDParams: TStringList;

		MetaData: TStringList;

		Title,
		Artist,
		Album,
		TrackNumber,
		Date: AnsiString;

		constructor Create;
		destructor  Destroy; override;

		procedure ParseSIDParams;
		procedure ParseMetaData;
	end;


	TXSIDFileStage = (rfsPrepare, rfsLoad, rfsInitialise);

	TXSIDFileCallback = procedure(const AStage: TXSIDFileStage;
			const APosition, ASize: Int64) of object;


function XSIDLoadFileXSID(const AFileName: string; const AEvents: TList;
		const ACallback: TXSIDFileCallback; out AXSIDFileConfig: TXSIDFileConfig): Cardinal;


implementation

uses
	SysUtils, XSIDTypes, SyncObjs,
{$IFDEF DCC}
	zlib,
{$ELSE}
	zstream,
{$ENDIF}
	ULZBinTree, URangeEncoder, ULZMADecoder;

type
	TXSIDHeaderRec = packed record
		tag: array[0..3] of AnsiChar;
		size: Byte;
		version: Byte;
		format: Byte;
		sidCnt: Byte;
		system: Byte;
		updateRate: Byte;
	end;

	TXSIDSIDDescRec = packed record
		tag: array[0..3] of AnsiChar;
		size: Cardinal;
		sid: Byte;
		sidType: Byte;
	end;

	TXSIDTrackRec = packed record
		tag: array[0..3] of AnsiChar;
		size: Cardinal;
		compType: Byte;
	end;

	TXSIDMetaDataRec = packed record
		tag: array[0..3] of AnsiChar;
		size: Cardinal;
	end;

	TLZMADecodeThread = class(TThread)
	protected
		FEvent: TEvent;
		FInput,
		FOutput: TStream;

		procedure Execute; override;
	public
		constructor Create(AEvent: TEvent; AInput, AOutput: TStream);
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
		AResult:= AResult + Cardinal(d and $7F);

//		Last byte?
		if not ((d and $80) = $80) then
			Break;
		end;
	end;

function XSIDLoadFileXSID(const AFileName: string; const AEvents: TList;
		const ACallback: TXSIDFileCallback; out AXSIDFileConfig: TXSIDFileConfig): Cardinal;
	var
	ts: array[0..3] of TMemoryStream;
	fs: TFileStream;
	ds: array[0..3] of TDecompressionStream;
	de: array[0..3] of TSimpleEvent;
//	ld: array[0..3] of TLZMADecoder;
	ls: array[0..3] of TMemoryStream;
	ev: PXSIDEvent;
	o: array[0..3] of cycle_count;
	r,
	v: array[0..3] of reg8;
	ov: array[0..3,0..3] of Byte;
	d: Boolean;
	p: Integer;
	fh: TXSIDHeaderRec;
	sd: TXSIDSIDDescRec;
	th: TXSIDTrackRec;
	md: TXSIDMetaDataRec;
	i: Integer;
	si: array[0..3] of TStream;
	sz: Int64;
	ht: array[0..3] of Boolean;
	rz: Int64;
	mo: cycle_count;
	s: AnsiString;

	function ReadOffset(AIdx: Integer): Boolean;
		var
		b: Byte;
		l: Integer;
		c: Cardinal;

		begin
//		Result:= False;
		l:= -1;
		b:= 0;

		while (si[AIdx].Read(b, 1) = 1) and (l < 4) do
			begin
			Inc(rz);

			Inc(l);
			ov[AIdx, l]:= b;
			if  (b and $80) = 0 then
				Break;
			end;

		Result:= (l > -1) and (l < 4) and ((b and $80) = 0);
		if  Result then
			begin
			VarLenToCard(ov[AIdx], c);
			o[AIdx]:= c;
			end;
		end;

	procedure ReadRegister(AIdx: Integer);
		var
		b: Byte;

		begin
		if  si[AIdx].Read(b, 1) <> 1 then
			Exception.Create('No register data for event');
		Inc(rz);

		if  b > 24 then
			Exception.Create('Invalid register number');

		r[AIdx]:= b;
		end;

	procedure ReadValue(AIdx: Integer);
		var
		b: Byte;

		begin
		if  si[AIdx].Read(b, 1) <> 1 then
			Exception.Create('No value data for event');
		Inc(rz);

		v[AIdx]:= b;
		end;

	function ReadTracks: Boolean;
		var
		i: Integer;
		r: Boolean;

		begin
		Result:= False;

		for i:= 0 to 3 do
			begin
			r:= ht[i] and (o[i] <> 0);

			if  ht[i]
			and (o[i] = 0) then
				begin
				r:= ReadOffset(i);

				if  r then
					begin
					ReadRegister(i);
					ReadValue(i);
					end
				else
					ht[i]:= False;
				end;

			Result:= Result or r;
			end;
		end;

	begin
	Result:= 0;

	AXSIDFileConfig:= TXSIDFileConfig.Create;

//dengland	If not using the threads, need this somewhere
//	ULZBinTree.InitCRC;
//	URangeEncoder.RangeEncoder:= TRangeEncoder.Create;

	d:= False;
	p:= 0;
	fs:= TFileStream.Create(AFileName, fmOpenRead);
	try
		fs.Seek(0, soFromBeginning);

		fs.Read(fh, SizeOf(TXSIDHeaderRec));

		if  fh.system = 2 then
			AXSIDFileConfig.System:= cstNTSC
		else
			AXSIDFileConfig.System:= cstPAL;
		AXSIDFileConfig.UpdateRate:= TC64UpdateRate(fh.updateRate);

		fs.Read(sd, SizeOf(TXSIDSIDDescRec));
		if  sd.size > (SizeOf(TXSIDSIDDescRec) - 8) then
			begin
			SetLength(s, sd.size - SizeOf(TXSIDSIDDescRec) + 8);
			fs.Read(s[1], Length(s));
			end
		else
			SetLength(s, 0);

		if  sd.sidType = 2 then
			AXSIDFileConfig.Model:= csmMOS8580
		else
			AXSIDFileConfig.Model:= csmMOS6581;
		AXSIDFileConfig.SIDParams.Text:= string(s);

//TODO  Need to be able to handle multiple SIDs in file.
//FIXME	Should allow meta data to be before tracks.

		for i:= 0 to 3 do
			begin
			ts[i]:= nil;
			ds[i]:= nil;
			si[i]:= nil;
			de[i]:= nil;
//			ld[i]:= nil;
			ls[i]:= nil;
			end;

		sz:= 0;
		rz:= 0;
		i:= 0;
		repeat
			if  fs.Read(th, SizeOf(TXSIDTrackRec)) <> SizeOf(TXSIDTrackRec) then
				Break;

			if  CompareText(string(th.tag), 'XSTK') <> 0 then
				Break;

			ts[i]:= TMemoryStream.Create;
			ts[i].CopyFrom(fs, th.size - 1);
			ts[i].Position:= 0;

			Inc(sz, th.size - 1);

			if  th.compType = 2 then
				begin
				de[i]:= TSimpleEvent.Create;
				de[i].ResetEvent;

				ls[i]:= TMemoryStream.Create;
				si[i]:= ls[i];

				TLZMADecodeThread.Create(de[i], ts[i], ls[i]);

//				ld[i]:= TLZMADecoder.Create;
//				ld[i].SetDictionarySize(1 shl 23);
//				ld[i].SetLcLpPb(3, 0, 2);
//
//				ld[i].Code(ts[i], ls[i], -1);
//
//				ls[i].Position:= 0;
				end
			else if th.compType = 1 then
				begin
				ds[i]:= TDecompressionStream.Create(ts[i]);
				ds[i].Seek(0, soFromBeginning);
				si[i]:= ds[i];
				end
			else
				si[i]:= ts[i];

			Inc(i);
			until (fh.format = 0) or (i = 4);

		if  Assigned(de[0]) then
			de[0].WaitFor(INFINITE);
		if  Assigned(de[1]) then
			de[1].WaitFor(INFINITE);
		if  Assigned(de[2]) then
			de[2].WaitFor(INFINITE);
		if  Assigned(de[3]) then
			de[3].WaitFor(INFINITE);

		for i:= 0 to 3 do
			begin
			ht[i]:= Assigned(si[i]) and (si[i].Size > 0);
			o[i]:= 0;
			end;

		try
			if  Assigned(ACallback) then
				ACallback(rfsPrepare, 0, sz);

			while ReadTracks do
				try
					mo:= High(cycle_count);
					for i:= 3 downto 0 do
						if  ht[i] then
							if  o[i] < mo then
								mo:= o[i];

					for i:= 3 downto 0 do
						if  ht[i] then
							Dec(o[i], mo);

					for i:= 3 downto 0 do
						if  ht[i]
						and (o[i] = 0) then
							begin
							ev:= CreateEvent(mo, r[i], v[i]);
							AEvents.Add(ev);
							end;

					Inc(Result, mo);

//					If the tracks are compressed then there is no way to tell exactly
//					how large they are.  Just switch to the initialising mode to give
//					the user some form of feedback.
					if  not d then
						if  rz >= sz then
							begin
							if Assigned(ACallback) then
								ACallback(rfsInitialise, fs.Position,
										fs.Size);
							d:= True;
							end
						else
							begin
							Inc(p);

							if  ((p mod 1024) = 0) then
								begin
								if  Assigned(ACallback) then
									ACallback(rfsLoad, rz, sz);

								p:= 0;
								end;
							end;

					except
					Break;
					end;

			if  fs.Read(md, SizeOf(TXSIDMetaDataRec)) = SizeOf(TXSIDMetaDataRec) then
				if  md.tag = 'XSMD' then
					if  md.size > (SizeOf(TXSIDMetaDataRec) - 8) then
						begin
						SetLength(s, md.size - SizeOf(TXSIDMetaDataRec) + 8);
						fs.Read(s[1], Length(s));

						AXSIDFileConfig.MetaData.Text:= string(s);
						end;

			if Assigned(ACallback) then
				ACallback(rfsInitialise, -1, sz);

			AXSIDFileConfig.ParseSIDParams;
			AXSIDFileConfig.ParseMetaData;

			finally
			for i:= 3 downto 0 do
				if  Assigned(ds[i]) then
					ds[i].Free;

			for i:= 3 downto 0 do
				if  Assigned(ts[i]) then
					ts[i].Free;

			for i:= 3 downto 0 do
				if  Assigned(de[i]) then
					de[i].Free;

//			for i:= 3 downto 0 do
//				if  Assigned(ld[i]) then
//					ld[i].Free;

			for i:= 3 downto 0 do
				if  Assigned(ls[i]) then
					ls[i].Free;
			end;
		finally
		fs.Free;
		end;

//dengland	If not using the threads, need this somewhere
//	URangeEncoder.RangeEncoder.Free;
	end;

{ TXSIDConfig }

constructor TXSIDFileConfig.Create;
	begin
	inherited Create;

	SIDParams:= TStringList.Create;
	MetaData:= TStringList.Create;
	end;

destructor TXSIDFileConfig.Destroy;
	begin
	MetaData.Free;
	SIDParams.Free;

	inherited;
	end;

procedure TXSIDFileConfig.ParseMetaData;
	var
	i: Integer;

	procedure SetMetaData(AIndex: Integer; AValue: AnsiString);
		begin
		case i of
			0:
				Title:= AValue;
			1:
				Artist:= AValue;
			2:
				Album:= AValue;
			3:
				TrackNumber:= AValue;
			4:
				Date:= AValue;
			end;
		end;
	begin
	for i:= 0 to MetaData.Count - 1 do
		if  Pos('=', MetaData.Strings[i]) = 0 then
			SetMetaData(i, AnsiString(MetaData.Strings[i]));

	for i:= MetaData.Count - 1 downto 0 do
		if  Pos('=', MetaData.Strings[i]) = 0 then
			MetaData.Delete(i);
	end;

procedure TXSIDFileConfig.ParseSIDParams;
	var
	i: Integer;
	d: Double;
	v: Integer;

	begin
	d:= GlobalConfig.Filter6581;
	i:= SIDParams.IndexOfName('Filter6581');
	if  i > -1 then
		TryStrToFloat(SIDParams.ValueFromIndex[i], d);

	Filter6581:= d;

	d:= GlobalConfig.Filter8580;
	i:= SIDParams.IndexOfName('Filter8580');
	if  i > -1 then
		TryStrToFloat(SIDParams.ValueFromIndex[i], d);

	Filter8580:= d;

	if  GlobalConfig.FilterEnable then
		v:= 1
	else
		v:= 0;

	i:= SIDParams.IndexOfName('FilterEnable');
	if  i > -1 then
		TryStrToInt(SIDParams.ValueFromIndex[i], v);

	FilterEnable:= v <> 0;

	if  GlobalConfig.DigiBoostEnable then
		v:= 1
	else
		v:= 0;

	i:= SIDParams.IndexOfName('DigiBoostEnable');
	if  i > -1 then
		TryStrToInt(SIDParams.ValueFromIndex[i], v);

	DigiBoostEnable:= v <> 0;
	end;

{ TLZMADecodeThread }

constructor TLZMADecodeThread.Create(AEvent: TEvent; AInput, AOutput: TStream);
	begin
	FEvent:= AEvent;
	FInput:= AInput;
	FOutput:= AOutput;

	FreeOnTerminate:= True;
	inherited Create(False);
	end;

procedure TLZMADecodeThread.Execute;
	var
	d: TLZMADecoder;

	begin
	ULZBinTree.InitCRC;
	URangeEncoder.RangeEncoder:= TRangeEncoder.Create;

	d:= TLZMADecoder.Create;
	try
		d.SetDictionarySize(1 shl 23);
		d.SetLcLpPb(3, 0, 2);

		d.Code(FInput, FOutput, -1);

		finally
		d.Free;
		URangeEncoder.RangeEncoder.Free;
		end;

	FOutput.Position:= 0;
	FEvent.SetEvent;
	end;

end.

