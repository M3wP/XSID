unit XSIDAudioDump;

{$INCLUDE XSID.inc}

interface

uses
	Classes, XSIDTypes;

type

 { TXSIDAudioDump }

	TXSIDAudioDump = class(TXSIDAudioRenderer)
	protected
		FFileName: string;
		FTempFile: TFileStream;
		FTempFileName: string;
		FSampleRate: Cardinal;
		FBufferSize: Cardinal;
		FWavSize: Integer;

		procedure DoWriteWavDump;

	public
		constructor Create(const ASampleRate: TXSIDSampleRate;
				const AFrameRate: Cardinal;
				const ABufferSize: TXSIDBufferSize;
				const AParams: TStrings; var ABuffer: PArrSmallInt); override;
		destructor  Destroy; override;

		class function  GetName: AnsiString; override;
		class function  GetRequireAllData: Boolean; override;
		class procedure FillParameterNames(const AStrings: TStrings); override;
		class function  GetIsRealTime: Boolean; override;

		procedure SwapBuffers(var ABuffer: PArrSmallInt;
				const ASize: Integer); override;
		procedure TransferBuffer(const ABuffer: PArrSmallInt;
				var ASize: Integer); override;

		procedure Pause(var ABuffer: PArrSmallInt); override;
		procedure Play(var ABuffer: PArrSmallInt); override;
	end;


implementation


type
	PRIFFHeader = ^TRIFFHeader;
	TRIFFHeader = packed record
		id: array[0..3] of AnsiChar;
		size: Integer;
		ty: array[0..3] of AnsiChar;
	end;

	PWAVFMTHeader = ^TWAVFMTHeader;
	TWAVFMTHeader = packed record
		id: array[0..3] of AnsiChar;
		size: Integer;
		comp: Word;
		chan: Word;
		rate: Cardinal;
		avg: Cardinal;
		align: Word;
		sig: Word;
//		extra: Word;
	end;

	PWAVDATHeader = ^TWAVDATHeader;
	TWAVDATHeader = packed record
		id: array[0..3] of AnsiChar;
		size: Integer;
	end;

{ TXSIDAudioDump }

class function TXSIDAudioDump.GetIsRealTime: Boolean;
	begin
    Result:= False;
	end;

class function TXSIDAudioDump.GetName: AnsiString;
	begin
	Result:= 'WAV Writer';
	end;

class function TXSIDAudioDump.GetRequireAllData: Boolean;
	begin
	Result:= True;
	end;

procedure TXSIDAudioDump.Pause(var ABuffer: PArrSmallInt);
	begin

	end;

procedure TXSIDAudioDump.Play(var ABuffer: PArrSmallInt);
	begin
	end;

procedure TXSIDAudioDump.SwapBuffers(var ABuffer: PArrSmallInt;
		const ASize: Integer);
	begin
	FTempFile.WriteBuffer(ABuffer^[0], ASize);
	Inc(FWavSize, ASize);
	end;

procedure TXSIDAudioDump.DoWriteWavDump;
	var
//	fs: TFileStream;
//	riff: TRIFFHeader;
//	fmt: TWAVFMTHeader;
//	dat: TWAVDATHeader;
	val: Integer;

	begin
//	if  FTempFile.Size > 0 then
//		begin
//		fs:= TFileStream.Create(FFileName, fmCreate);
//		riff.id:= AnsiString('RIFF');
//		riff.size:= FTempFile.Size + SizeOf(TRIFFHeader) + SizeOf(TWAVFMTHeader) +
//				SizeOf(TWAVDATHeader) - 8;
//		riff.ty:= AnsiString('WAVE');
//
//		fs.Write(riff, SizeOf(TRIFFHeader));
//
//		fmt.id:= AnsiString('fmt ');
//		fmt.size:= SizeOf(TWAVFMTHeader) - 8;
//		fmt.comp:= 1;
//
//		fmt.chan:= 1;
//		fmt.rate:= FSampleRate;
//		fmt.sig:= 16;
//
//		fmt.align:= fmt.sig div 8 * fmt.chan;
//		fmt.avg:= fmt.rate * fmt.align;
//
//		fs.Write(fmt, SizeOf(TWAVFMTHeader));
//
//		dat.id:= AnsiString('data');
//		dat.size:= FTempFile.Size;
//
//		fs.Write(dat, SizeOf(TWAVDATHeader));
//
//		FTempFile.Seek(0, soBeginning);
//		fs.CopyFrom(FTempFile, FTempFile.Size);
//		fs.Free;
//		end;

	FTempFile.Position:= 4;
	val:= FWavSize + SizeOf(TRIFFHeader) + SizeOf(TWAVFMTHeader) +
			SizeOf(TWAVDATHeader) - 8;
	FTempFile.Write(val, 4);

	FTempFile.Position:= SizeOf(TRIFFHeader) + SizeOf(TWAVFMTHeader) + 4;
	val:= FWavSize;
	FTempFile.Write(val, 4);
	end;

constructor TXSIDAudioDump.Create(const ASampleRate: TXSIDSampleRate;
		const AFrameRate: Cardinal; const ABufferSize: TXSIDBufferSize;
		const AParams: TStrings; var ABuffer: PArrSmallInt);
	var
	i: Integer;
	riff: TRIFFHeader;
	fmt: TWAVFMTHeader;
	dat: TWAVDATHeader;

	begin
	inherited Create(ASampleRate, AFrameRate, ABufferSize, AParams, ABuffer);

	FSampleRate:= ARR_VAL_SAMPLERATE[ASampleRate];
//	FTempFileName:= TPath.GetRandomFileName;
	i:= AParams.IndexOfName('File Name');
	if i > -1 then
		FFileName:= AParams.ValueFromIndex[i]
//dengland Should make sure that the extension is wav here or also support raw?
	else
		FFileName:= 'Dump.WAV';

	FTempFile:= TFileStream.Create(FFileName, fmCreate);

//	FTempFile:= TMemoryStream.Create;
//	FTempFile.SetSize(700*1024*1024);
//	FTempFile.SetSize(0);

	riff.id:= AnsiString('RIFF');
	riff.size:= 0;
	riff.ty:= AnsiString('WAVE');

	FTempFile.Write(riff, SizeOf(TRIFFHeader));

	fmt.id:= AnsiString('fmt ');
	fmt.size:= SizeOf(TWAVFMTHeader) - 8;
	fmt.comp:= 1;

	fmt.chan:= 1;
	fmt.rate:= FSampleRate;
	fmt.sig:= 16;

	fmt.align:= fmt.sig div 8 * fmt.chan;
	fmt.avg:= fmt.rate * fmt.align;

	FTempFile.Write(fmt, SizeOf(TWAVFMTHeader));

	dat.id:= AnsiString('data');
	dat.size:= 0;

	FTempFile.Write(dat, SizeOf(TWAVDATHeader));

	FWavSize:= 0;

	FBufferSize:= Round(ARR_VAL_SAMPLERATE[ASampleRate] / AFrameRate *
			ARR_VAL_BUFFERFACT[ABufferSize]);

	ABuffer:= AllocMem(FBufferSize * 2);
	end;

destructor TXSIDAudioDump.Destroy;
	begin
	DoWriteWavDump;

	FTempFile.Free;
//	TFile.Delete(FTempFileName);

	inherited Destroy;
	end;

class procedure TXSIDAudioDump.FillParameterNames(const AStrings: TStrings);
	begin
	inherited FillParameterNames(AStrings);

	AStrings.Add('File Name=Dump.WAV');
	end;

procedure TXSIDAudioDump.TransferBuffer(const ABuffer: PArrSmallInt;
		var ASize: Integer);
	begin
	FTempFile.WriteBuffer(ABuffer^[0], ASize * 2);
	Inc(FWavSize, ASize * 2);
	ASize:= 0;
	end;


initialization
	RegisterRenderer(TXSIDAudioDump);

end.

