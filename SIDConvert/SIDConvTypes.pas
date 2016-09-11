unit SIDConvTypes;

interface

uses
	Classes, System.Generics.Collections, SysUtils, SyncObjs;

type
	TSIDConvCompFmt = (scfFormat0, scfFormat1, scfDetermine, scfDumpOnly);
	TSIDConvCompType = (sctNone, sctDeflate, sctLZMA);

	TSIDPlayEndType = (speLoop, speOverlap, speFadeOut);
	TSIDPlayLenType = (splUnknown, splDefault, splEstimated, splClosestSeconds,
			splAccurate);

	PSIDPlayDetailRec = ^TSIDPlayDetailRec;
	TSIDPlayDetailRec = record
		time: TTime;
		endType: TSIDPlayEndType;
		lenType: TSIDPlayLenType;
	end;

	TSIDPlayMD5 = array[0..15] of Byte;

	TSIDPlayDetails = TList<PSIDPlayDetailRec>;
	TSIDPlayLengths = TDictionary<TSIDPlayMD5, TSIDPlayDetails>;

	TSIDPlayHeaderRec = packed record
		tag: array[0..3] of AnsiChar;
		version: Word;
		dataOffset: Word;
		loadAddress,
		initAddress,
		playAddress: Word;
		songs: Word;
		startSong: Word;
		speedFlags: Cardinal;
		name: array[0..31] of AnsiChar;
		author: array[0..31] of AnsiChar;
		released: array[0..31] of AnsiChar;
		flags: Word;
	end;

	TSIDPlaySubSong = 0..63;
	TSIDPlaySubSongs = set of TSIDPlaySubSong;

	PNodeData = ^TNodeData;
	TNodeData = record
		fileIndex: Integer;
		caption: string;
		header: TSIDPlayHeaderRec;
		updateRate: Byte;
		sidType: Byte;
		md5: TSIDPlayMD5;
		details: TSIDPlayDetails;
		lengths: array of TTime;
		selected: TSIDPlaySubSongs;
		sidParams,
		metaData: array of string;
	end;

	PSIDConvConfig = ^TSIDConvConfig;
	TSIDConvConfig = record
		songLengths,
		viceVSID,
		outputPath: string;
		startDelay: TTime;

		procedure LoadFromIniFile(const AFile: string);
		procedure SaveToIniFile(const AFile: string);
	end;

	TSIDConvCompCntrl = class;

	TSIDConvCompress = class(TThread)
	protected
		FCntrl: TSIDConvCompCntrl;
		FFormat: TSIDConvCompFmt;
		FStream: TMemoryStream;
		FDone: TLightweightEvent;

		procedure Execute; override;

		procedure DoWriteHeader;
		procedure DoWriteSIDDesc;
		procedure DoConvertTracks;
		procedure DoWriteMetaData;

	public
		constructor Create(const AController: TSIDConvCompCntrl;
				const AFormat: TSIDConvCompFmt; const AStream: TMemoryStream;
				const ADone: TLightweightEvent);
	end;

	TSIDConvCompCntrl = class(TThread)
	protected
		FNode: PNodeData;
		FSong: Integer;
		FFormat: TSIDConvCompFmt;
		FCompType: TSIDConvCompType;
		FDumpFile: string;
		FStream0,
		FStream1: TMemoryStream;
		FDone0,
		FDone1: TLightweightEvent;

		procedure Execute; override;

	public
		constructor Create(const ANode: PNodeData; const ASong: Integer;
				const AFormat: TSIDConvCompFmt; const ACompType: TSIDConvCompType;
				const ADumpFile: string);
	end;


function  SIDPlayComputeStreamMD5(AStream: TStream; const AHeader: TSIDPlayHeaderRec;
		var AMD5: TSIDPlayMD5): Boolean;

function  SIDPlayMD5ToString(const AMD5: TSIDPlayMD5): AnsiString;
function  SIDPlayStringToMD5(const AString: AnsiString): TSIDPlayMD5;

var
	ConvCountLock: TMultiReadExclusiveWriteSynchronizer;
	ConvCount: Integer;


implementation

uses
	IOUtils, AnsiStrings, IniFiles, ULZBinTree, URangeEncoder, ULZMAEncoder, Zip, ZLib;

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

	TSIDPlayMD5Context = record
	private
		FTotal: array[0..1] of Cardinal;
		FState: array[0..3] of Cardinal;
		FBuffer: array[0..63] of Byte;

		procedure Process(ABuf: PByte);

	public
		procedure Start;
		procedure Update(ABuf: PByte; ACount: Cardinal);
		procedure Finish(var AMD5: TSIDPlayMD5);
	end;

{ TSIDPlayMD5Context }

const
	ARR_VAL_RSIDMD5_PADDING: array[0..63] of Byte = (
			$80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);


function  READ_LE_UINT32(ptr: Pointer): Cardinal; inline;
	begin
	Result:= PCardinal(ptr)^;
	end;

procedure WRITE_LE_UINT32(ptr: Pointer; value: Cardinal); inline;
	begin
	PCardinal(ptr)^:= value;
	end;

procedure GET_UINT32(var val: Cardinal; base: PByte; offs: Integer); inline;
	begin
	val:= READ_LE_UINT32(base + offs);
	end;

procedure PUT_UINT32(val: Cardinal; base: PByte; offs: Integer); inline;
	begin
	WRITE_LE_UINT32(base + offs, val);
	end;


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
	Assert(AValue < ($01 shl (AMaxLen * 7)));

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


procedure TSIDPlayMD5Context.Finish(var AMD5: TSIDPlayMD5);
	var
	last,
	padn: Cardinal;
	high,
	low: Cardinal;
	msglen: array[0..7] of Byte;

	begin
	high:= (FTotal[0] shr 29) or (FTotal[1] shl 3);
	low:= FTotal[0] shl  3;

	PUT_UINT32(low,  @msglen[0], 0);
	PUT_UINT32(high, @msglen[0], 4);

	last:= FTotal[0] and $3F;
	if  last < 56 then
		padn:= 56 - last
	else
		padn:= 120 - last;

	Update(@ARR_VAL_RSIDMD5_PADDING[0], padn);
	Update(@msglen[0], 8);

	PUT_UINT32(FState[0], @AMD5[0],  0);
	PUT_UINT32(FState[1], @AMD5[0],  4);
	PUT_UINT32(FState[2], @AMD5[0],  8);
	PUT_UINT32(FState[3], @AMD5[0], 12);
	end;

//This is pretty nasty.  I hope there are no artefacts from the conversion and
//		that I haven't otherwise broken the logic.  For some reason the F
//		routines don't match my pascal reference.  I guess someone has
//		determined that these versions are likely to be better??
procedure TSIDPlayMD5Context.Process(ABuf: PByte);
//define S(x, n) ((x << n) | ((x & 0xFFFFFFFF) >> (32 - n)))
	function S(AX: Cardinal; AN: Byte): Cardinal; inline;
		begin
		Result:= ((AX shl AN) or ((AX and $FFFFFFFF) shr (32 - AN)));
		end;

//define P(a, b, c, d, k, s, t)
//	{
//		a += F(b,c,d) + X[k] + t; a = S(a,s) + b;
//	}

//define F(x, y, z) (z ^ (x & (y ^ z)))
	procedure P1(var AA: Cardinal; AB, AC, AD: Cardinal; AX: Cardinal; AN: Byte;
			AT: Cardinal); inline;
		begin
		Inc(AA, (AD xor (AB and (AC xor AD))) + AX + AT);
		AA:= S(AA, AN) + AB;
		end;

//define F(x, y, z) (y ^ (z & (x ^ y)))
	procedure P2(var AA: Cardinal; AB, AC, AD: Cardinal; AX: Cardinal; AN: Byte;
			AT: Cardinal); inline;
		begin
		Inc(AA, (AC xor (AD and (AB xor AC))) + AX + AT);
		AA:= S(AA, AN) + AB;
		end;

//define F(x, y, z) (x ^ y ^ z)
	procedure P3(var AA: Cardinal; AB, AC, AD: Cardinal; AX: Cardinal; AN: Byte;
			AT: Cardinal); inline;
		begin
		Inc(AA, (AB xor AC xor AD) + AX + AT);
		AA:= S(AA, AN) + AB;
		end;

//define F(x, y, z) (y ^ (x | ~z))
	procedure P4(var AA: Cardinal; AB, AC, AD: Cardinal; AX: Cardinal; AN: Byte;
			AT: Cardinal); inline;
		begin
		Inc(AA, (AC xor (AB or (not AD))) + AX + AT);
		AA:= S(AA, AN) + AB;
		end;

	var
	X: array[0..15] of Cardinal;
	A,
	B,
	C,
	D: Cardinal;

	begin
	GET_UINT32(X[0],  ABuf,  0);
	GET_UINT32(X[1],  ABuf,  4);
	GET_UINT32(X[2],  ABuf,  8);
	GET_UINT32(X[3],  ABuf, 12);
	GET_UINT32(X[4],  ABuf, 16);
	GET_UINT32(X[5],  ABuf, 20);
	GET_UINT32(X[6],  ABuf, 24);
	GET_UINT32(X[7],  ABuf, 28);
	GET_UINT32(X[8],  ABuf, 32);
	GET_UINT32(X[9],  ABuf, 36);
	GET_UINT32(X[10], ABuf, 40);
	GET_UINT32(X[11], ABuf, 44);
	GET_UINT32(X[12], ABuf, 48);
	GET_UINT32(X[13], ABuf, 52);
	GET_UINT32(X[14], ABuf, 56);
	GET_UINT32(X[15], ABuf, 60);

	A:= FState[0];
	B:= FState[1];
	C:= FState[2];
	D:= FState[3];

	P1(A, B, C, D, X[  0],  7, $D76AA478);
	P1(D, A, B, C, X[  1], 12, $E8C7B756);
	P1(C, D, A, B, X[  2], 17, $242070DB);
	P1(B, C, D, A, X[  3], 22, $C1BDCEEE);
	P1(A, B, C, D, X[  4],  7, $F57C0FAF);
	P1(D, A, B, C, X[  5], 12, $4787C62A);
	P1(C, D, A, B, X[  6], 17, $A8304613);
	P1(B, C, D, A, X[  7], 22, $FD469501);
	P1(A, B, C, D, X[  8],  7, $698098D8);
	P1(D, A, B, C, X[  9], 12, $8B44F7AF);
	P1(C, D, A, B, X[ 10], 17, $FFFF5BB1);
	P1(B, C, D, A, X[ 11], 22, $895CD7BE);
	P1(A, B, C, D, X[ 12],  7, $6B901122);
	P1(D, A, B, C, X[ 13], 12, $FD987193);
	P1(C, D, A, B, X[ 14], 17, $A679438E);
	P1(B, C, D, A, X[ 15], 22, $49B40821);

	P2(A, B, C, D, X[  1],  5, $F61E2562);
	P2(D, A, B, C, X[  6],  9, $C040B340);
	P2(C, D, A, B, X[ 11], 14, $265E5A51);
	P2(B, C, D, A, X[  0], 20, $E9B6C7AA);
	P2(A, B, C, D, X[  5],  5, $D62F105D);
	P2(D, A, B, C, X[ 10],  9, $02441453);
	P2(C, D, A, B, X[ 15], 14, $D8A1E681);
	P2(B, C, D, A, X[  4], 20, $E7D3FBC8);
	P2(A, B, C, D, X[  9],  5, $21E1CDE6);
	P2(D, A, B, C, X[ 14],  9, $C33707D6);
	P2(C, D, A, B, X[  3], 14, $F4D50D87);
	P2(B, C, D, A, X[  8], 20, $455A14ED);
	P2(A, B, C, D, X[ 13],  5, $A9E3E905);
	P2(D, A, B, C, X[  2],  9, $FCEFA3F8);
	P2(C, D, A, B, X[  7], 14, $676F02D9);
	P2(B, C, D, A, X[ 12], 20, $8D2A4C8A);

	P3(A, B, C, D, X[  5],  4, $FFFA3942);
	P3(D, A, B, C, X[  8], 11, $8771F681);
	P3(C, D, A, B, X[ 11], 16, $6D9D6122);
	P3(B, C, D, A, X[ 14], 23, $FDE5380C);
	P3(A, B, C, D, X[  1],  4, $A4BEEA44);
	P3(D, A, B, C, X[  4], 11, $4BDECFA9);
	P3(C, D, A, B, X[  7], 16, $F6BB4B60);
	P3(B, C, D, A, X[ 10], 23, $BEBFBC70);
	P3(A, B, C, D, X[ 13],  4, $289B7EC6);
	P3(D, A, B, C, X[  0], 11, $EAA127FA);
	P3(C, D, A, B, X[  3], 16, $D4EF3085);
	P3(B, C, D, A, X[  6], 23, $04881D05);
	P3(A, B, C, D, X[  9],  4, $D9D4D039);
	P3(D, A, B, C, X[ 12], 11, $E6DB99E5);
	P3(C, D, A, B, X[ 15], 16, $1FA27CF8);
	P3(B, C, D, A, X[  2], 23, $C4AC5665);

	P4(A, B, C, D, X[  0],  6, $F4292244);
	P4(D, A, B, C, X[  7], 10, $432AFF97);
	P4(C, D, A, B, X[ 14], 15, $AB9423A7);
	P4(B, C, D, A, X[  5], 21, $FC93A039);
	P4(A, B, C, D, X[ 12],  6, $655B59C3);
	P4(D, A, B, C, X[  3], 10, $8F0CCC92);
	P4(C, D, A, B, X[ 10], 15, $FFEFF47D);
	P4(B, C, D, A, X[  1], 21, $85845DD1);
	P4(A, B, C, D, X[  8],  6, $6FA87E4F);
	P4(D, A, B, C, X[ 15], 10, $FE2CE6E0);
	P4(C, D, A, B, X[  6], 15, $A3014314);
	P4(B, C, D, A, X[ 13], 21, $4E0811A1);
	P4(A, B, C, D, X[  4],  6, $F7537E82);
	P4(D, A, B, C, X[ 11], 10, $BD3AF235);
	P4(C, D, A, B, X[  2], 15, $2AD7D2BB);
	P4(B, C, D, A, X[  9], 21, $EB86D391);

	Inc(FState[0], A);
	Inc(FState[1], B);
	Inc(FState[2], C);
	Inc(FState[3], D);
	end;

procedure TSIDPlayMD5Context.Start;
	begin
	FTotal[0]:= 0;
	FTotal[1]:= 0;

	FState[0]:= $67452301;
	FState[1]:= $EFCDAB89;
	FState[2]:= $98BADCFE;
	FState[3]:= $10325476;
	end;

procedure TSIDPlayMD5Context.Update(ABuf: PByte; ACount: Cardinal);
	var
	left,
	fill: Cardinal;
	len: Cardinal;
	input: PByte;

	begin
	len:= ACount;
	input:= ABuf;

	if  len = 0 then
		Exit;

	left:= FTotal[0] and $3F;
	fill:= 64 - left;

	Inc(FTotal[0], len);
	FTotal[0]:= FTotal[0] and $FFFFFFFF;

	if  FTotal[0] < len then
		Inc(FTotal[1]);

	if  (left <> 0) and (len >= fill) then
		begin
//		memcpy((void *)(ctx->buffer + left), (const void *)input, fill);
		Move(input^, FBuffer[left], fill);

		Process(@FBuffer[0]);
		Dec(len, fill);
		Inc(input, fill);
		left:= 0;
		end;

	while len >= 64 do
		begin
		Process(input);
		Dec(len, 64);
		Inc(input, 64);
		end;

	if  len > 0 then
//		memcpy((void *)(ctx->buffer + left), (const void *)input, length);
		Move(input^, FBuffer[left], len);
	end;

function  SIDPlayComputeStreamMD5(AStream: TStream; const AHeader: TSIDPlayHeaderRec;
		var AMD5: TSIDPlayMD5): Boolean;
	var
	ctx: TSIDPlayMD5Context;
	i: Integer;
	buf: array[0..999] of Byte;
//	restricted: Boolean;
//	readlen: Cardinal;
//	len: Cardinal;

	function Min(AValue1, AValue2: Integer): Integer; inline;
		begin
		if  AValue1 < AValue2 then
			Result:= AValue1
		else
			Result:= AValue2;
        end;

	begin
//	len:= AMaxLen;
	FillChar(AMD5, SizeOf(AMD5), 0);

//	restricted:= (len <> 0);

//	if  (not restricted) or (SizeOf(buf) <= len) then
//		readlen:= SizeOf(buf)
//	else
//		readlen:= len;

	ctx.Start;

//	i:= AStream.Read(buf, readlen);
	i:= AStream.Read(buf, SizeOf(buf));
	while i > 0 do
		begin
		ctx.Update(@buf[0], i);

//		if  restricted then
//			begin
//			Dec(len, i);
//			if  len = 0 then
//				Break;
//
//			if  SizeOf(buf) > len then
//				readlen:= len;
//			end;

//		i:= AStream.Read(buf, readlen);
		i:= AStream.Read(buf, SizeOf(buf));
		end;

	buf[1]:= (AHeader.initAddress and $FF00) shr 8;
	buf[0]:= (AHeader.initAddress and $00FF);
	ctx.Update(@buf[0], 2);

	buf[1]:= (AHeader.playAddress and $FF00) shr 8;
	buf[0]:= (AHeader.playAddress and $00FF);
	ctx.Update(@buf[0], 2);

	buf[1]:= (AHeader.songs and $FF00) shr 8;
	buf[0]:= (AHeader.songs and $00FF);
	ctx.Update(@buf[0], 2);

	buf[0]:= Byte(#60);
	buf[1]:= Byte(#0);

	for i:= 0 to AHeader.songs - 1 do
		begin
		if  CompareText(AHeader.tag, AnsiString('RSID')) = 0 then
			ctx.update(@buf[0], 1)
		else if (AHeader.speedFlags and (1 shl Min(i, 31))) <> 0 then
			ctx.update(@buf[0], 1)
		else
			ctx.update(@buf[1], 1);
		end;

	if  AHeader.version >= 2 then
		if (AHeader.flags and $0C) = $08 then
			begin
			buf[0]:= Byte(#2);
			ctx.update(@buf[0], 1);
			end;

	ctx.Finish(AMD5);
	Result:= True;
	end;

function  SIDPlayMD5ToString(const AMD5: TSIDPlayMD5): AnsiString;
	var
	i: Integer;

	begin
	Result:= '';
	for i:= 0 to 15 do
		Result:= Result + AnsiStrings.Format('%2.2x', [AMD5[i]]);
	end;

function  SIDPlayStringToMD5(const AString: AnsiString): TSIDPlayMD5;
	const
	SET_VAL_ANSI_DIGIT = [#$30..#$39];
	SET_VAL_ANSI_UPPER = [#$41..#$46];
	SET_VAL_ANSI_LOWER = [#$61..#$66];

	var
	i: Integer;
	c: AnsiChar;
	h, l: Byte;

	begin
	Assert(Length(AString) >= 32, 'MD5 string length must be 32');

	h:= $00;
	for i:= 1 to 32 do
		begin
		c:= AString[i];
		if  c in SET_VAL_ANSI_LOWER then
			c:= AnsiChar(Byte(c) - $20);

		Assert((c in SET_VAL_ANSI_DIGIT) or (c in SET_VAL_ANSI_UPPER),
				'MD5 string must contain only characters 0..9 and A..F');

		if  c in SET_VAL_ANSI_DIGIT then
			l:= Byte(c) - $30
		else
			l:= Byte(c) - $37;

		if  (i mod 2) = 0 then
			Result[i shr 1 - 1]:= h + l
		else
			h:= l shl 4;
		end;
	end;


{ TSIDConvConfig }

procedure TSIDConvConfig.LoadFromIniFile(const AFile: string);
	var
	ini: TIniFile;
	s: string;

	begin
	ini:= TIniFile.Create(AFile);
	try
		songLengths:= ini.ReadString('Paths', 'SongLengths', '');
		viceVSID:= ini.ReadString('Paths', 'VICEVSID', '');
		outputPath:= ini.ReadString('Paths', 'OutputPath', '');

		s:= ini.ReadString('Settings', 'StartDelay', '00:00:00');
		startDelay:= StrToDateTime(s);

		finally
		ini.Free;
		end;
	end;

procedure TSIDConvConfig.SaveToIniFile(const AFile: string);
	var
	ini: TIniFile;
	s: string;

	begin
	ini:= TIniFile.Create(AFile);
	try
		ini.WriteString('Paths', 'SongLengths', songLengths);
		ini.WriteString('Paths', 'VICEVSID', viceVSID);
		ini.WriteString('Paths', 'OutputPath', outputPath);

		s:= FormatDateTime('hh:nn:ss', startDelay);
		ini.WriteString('Settings', 'StartDelay', s);

		finally
		ini.Free;
		end;
	end;

{ TSIDConvCompress }

constructor TSIDConvCompress.Create(const AController: TSIDConvCompCntrl;
		const AFormat: TSIDConvCompFmt; const AStream: TMemoryStream;
		const ADone: TLightweightEvent);
	begin
	Assert(AFormat in [scfFormat0, scfFormat1]);

	FCntrl:= AController;
	FFormat:= AFormat;
	FStream:= AStream;
	FDone:= ADone;

	FDone.ResetEvent;

	FreeOnTerminate:= True;
	inherited Create(False);
	end;

procedure TSIDConvCompress.DoConvertTracks;
	var
	h: TXSIDTrackRec;
	mtk: Boolean;
	enb: array[0..3] of Boolean;
	os: Integer;
	mos: array[0..3] of TMemoryStream;
	mts: TMemoryStream;

	cd: TCompressionStream;
	cl: TLZMAEncoder;

	ofs: array[0..3] of Cardinal;
	fis: TFileStream;
	o: Cardinal;
	r,
	v: Byte;
	ov: array[0..3] of Byte;
	vl: Byte;
	w: Boolean;
	i: Integer;

	procedure ReadOffset;
		var
		b: AnsiChar;
		s: AnsiString;

		begin
		s:= '';
		fis.Read(b, 1);
		while b <> #32 do
			begin
			s:= s + b;
			fis.Read(b, 1);
			end;

		o:= StrToInt64(string(s));
		end;

	procedure ReadRegister;
		var
		b: AnsiChar;
		s: AnsiString;
		n: Byte;

		begin
		s:= '';
		fis.Read(b, 1);
		while b <> #32 do
			begin
			s:= s + b;
			fis.Read(b, 1);
			end;

		n:= StrToInt(string(s));
		if n > 24 then
			Exception.Create('Invalid register number');

		r:= Byte(n);
		end;

	procedure ReadValue;
		var
		b: AnsiChar;
		s: AnsiString;

		begin
		s:= '';
		fis.Read(b, 1);
		while not (b in [#32, #13, #10]) do
			begin
			s:= s + b;
			fis.Read(b, 1);
			end;

		v:= StrToInt(string(s));

		while (fis.Position < fis.Size) and (b in [#32, #13, #10]) do
			fis.Read(b, 1);

		if fis.Position < fis.Size then
			fis.Seek(-1, soCurrent);
		end;

	begin
	mtk:= FFormat = scfFormat1;

	enb[0]:= True;
	enb[1]:= True;
	enb[2]:= True;
	enb[3]:= True;

	ofs[0]:= 0;
	ofs[1]:= 0;
	ofs[2]:= 0;
	ofs[3]:= 0;

	mos[0]:= TMemoryStream.Create;
	mos[1]:= TMemoryStream.Create;
	mos[2]:= TMemoryStream.Create;
	mos[3]:= TMemoryStream.Create;
	try
		fis:= TFileStream.Create(FCntrl.FDumpFile, fmOpenRead or fmShareDenyWrite);
		try
			fis.Seek(0, soFromBeginning);
			while fis.Position < fis.Size do
				try
					ReadOffset;
					ReadRegister;
					ReadValue;

					w:= ((r in [0..6]) and enb[0]) or
							((r in [7..13]) and enb[1]) or
							((r in [14..20]) and enb[2]) or
							((r in [21..24]) and enb[3]);

					if  w then
						if  (not mtk)
						or  (r in [0..6]) then
							os:= 0
						else if r in [7..13] then
							os:= 1
						else if r in [14..20] then
							os:= 2
						else
							os:= 3
					else
						os:= -1;

					for i:= 0 to 3 do
						Inc(ofs[i], o);

					if  w then
						begin
						CardToVarLen(ofs[os], vl, ov);
						mos[os].Write(ov[0], vl);
						mos[os].Write(r, 1);
						mos[os].Write(v, 1);

						ofs[os]:= 0;
						end;

					except
					Break;
					end;
			finally
			fis.Free;
			end;

		for i:= 0 to 3 do
			begin
			mos[i].Position:= 0;

			if  mos[i].Size > 0 then
				begin
				h.tag:= 'XSTK';

				if  FCntrl.FCompType = sctDeflate then
					begin
					h.compType:= 1;

					mts:= TMemoryStream.Create;

					cd:= TCompressionStream.Create(clMax, mts);
					try
						cd.CopyFrom(mos[i], mos[i].Size);
						finally
						cd.Free;
						end;

					mts.Position:= 0;
					end
				else if  FCntrl.FCompType = sctLZMA then
					begin
					h.compType:= 2;

					mts:= TMemoryStream.Create;

					ULZBinTree.InitCRC;
					URangeEncoder.RangeEncoder:= TRangeEncoder.Create;
					cl:= TLZMAEncoder.Create;
					try
						cl.SetAlgorithm(2);
						cl.SetDictionarySize(1 shl 23);
						cl.SeNumFastBytes(128);
						cl.SetMatchFinder(1);
						cl.SetLcLpPb(3, 0, 2);
						cl.SetEndMarkerMode(True);
//						cl.WriteCoderProperties(mts);
						cl.Code(mos[i], mts, -1, -1);

						finally
						cl.Free;
						URangeEncoder.RangeEncoder.Free;
						end;

					mts.Position:= 0;
					end
				else
					begin
					h.compType:= 0;

					mts:= mos[i];
					end;

				h.size:= 1 + mts.Size;
				FStream.Write(h, SizeOf(TXSIDTrackRec));
				FStream.CopyFrom(mts, mts.Size);

				if  FCntrl.FCompType <> sctNone then
					mts.Free;
				end;
			end;

		finally
		mos[3].Free;
		mos[2].Free;
		mos[1].Free;
		mos[0].Free;
		end;
	end;

procedure TSIDConvCompress.DoWriteHeader;
	var
	h: TXSIDHeaderRec;
	v: Integer;

	begin
	h.tag:= 'XSHD';
	h.size:= 5;
	h.version:= 1;
	h.format:= Ord(FFormat);
	h.sidCnt:= 1;

	v:= (FCntrl.FNode^.header.flags and $0C) shr 2;
	h.system:= v;
	h.updateRate:= FCntrl.FNode^.updateRate;

	FStream.Write(h, SizeOf(TXSIDHeaderRec));
	end;

procedure TSIDConvCompress.DoWriteMetaData;
	var
	h: TXSIDMetaDataRec;
	d: AnsiString;

	begin
	h.tag:= 'XSMD';

//FIXME Should actually convert it to UTF8.
	d:= AnsiString(FCntrl.FNode^.metaData[FCntrl.FSong]);

	h.size:= Length(d);

	FStream.Write(h, SizeOf(TXSIDMetaDataRec));
	if  Length(d) > 0 then
		FStream.Write(d[1], Length(d));
	end;

procedure TSIDConvCompress.DoWriteSIDDesc;
	var
	h: TXSIDSIDDescRec;
	d: AnsiString;
//	v: Integer;

	begin
	h.tag:= 'XSSD';
	h.sid:= 1;

//	v:= (FCntrl.FNode^.header.flags and $30) shr 4;
//	if  v = 3 then
//		v:= 0;
//	h.sidType:= v;
	h.sidType:= FCntrl.FNode^.sidType;

//FIXME Should actually convert it to UTF8.
	d:= AnsiString(FCntrl.FNode^.sidParams[FCntrl.FSong]);

	h.size:= 2 + Length(d);

	FStream.Write(h, SizeOf(TXSIDSIDDescRec));
	if  Length(d) > 0 then
		FStream.Write(d[1], Length(d));
	end;

procedure TSIDConvCompress.Execute;
	begin
	ConvCountLock.BeginWrite;
	try
		Inc(ConvCount);

		finally
		ConvCountLock.EndWrite;
		end;

	DoWriteHeader;
	DoWriteSIDDesc;
	DoConvertTracks;
	DoWriteMetaData;

	FDone.SetEvent;

	ConvCountLock.BeginWrite;
	try
		Dec(ConvCount);

		finally
		ConvCountLock.EndWrite;
		end;
	end;

{ TSIDConvCompCntrl }

constructor TSIDConvCompCntrl.Create(const ANode: PNodeData; const ASong: Integer;
		const AFormat: TSIDConvCompFmt; const ACompType: TSIDConvCompType;
		const ADumpFile: string);
	begin
	Assert(AFormat <> scfDumpOnly);

	FNode:= ANode;
	FSong:= ASong;
	FFormat:= AFormat;
	FCompType:= ACompType;
	FDumpFile:= ADumpFile;

	FreeOnTerminate:= True;
	inherited Create(False);
	end;

procedure TSIDConvCompCntrl.Execute;
	var
	f: TFileStream;
	s: string;
	m: TMemoryStream;

	begin
	FStream0:= TMemoryStream.Create;
	FStream1:= TMemoryStream.Create;
	FDone0:= TLightweightEvent.Create;
	FDone1:= TLightweightEvent.Create;
	try
		if  FFormat in [scfFormat0, scfDetermine] then
			TSIDConvCompress.Create(Self, scfFormat0, FStream0, FDone0)
		else
			FDone0.SetEvent;

		if  FFormat in [scfFormat1, scfDetermine] then
			TSIDConvCompress.Create(Self, scfFormat1, FStream1, FDone1)
		else
			FDone1.SetEvent;

		FDone0.WaitFor;
		FDone1.WaitFor;

		if  FFormat = scfDetermine then
			if  FStream0.Size < FStream1.Size then
				m:= FStream0
			else
				m:= FStream1
		else if FFormat = scfFormat0 then
			m:= FStream0
		else
			m:= FStream1;

		s:= TPath.ChangeExtension(FDumpFile, 'xsid');
		f:= TFileStream.Create(s, fmCreate);
		try
			m.Position:= 0;
			f.CopyFrom(m, m.Size);

			finally
			f.Free;
			end;

		finally
		FDone1:= TLightweightEvent.Create;
		FDone0:= TLightweightEvent.Create;
		FStream1:= TMemoryStream.Create;
		FStream0:= TMemoryStream.Create;
		end;
	end;


initialization
	ConvCount:= 0;
	ConvCountLock:= TMultiReadExclusiveWriteSynchronizer.Create;


finalization
	ConvCountLock.Free;

end.
