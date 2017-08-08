unit ReSIDAudioDump;

{$INCLUDE ReSID.inc}

interface

uses
	Classes, ReSIDTypes;

type

 { TReSIDAudioDump }

	TReSIDAudioDump = class(TReSIDAudioRenderer)
	protected
		FFileName: string;
		FMemory: TMemoryStream;
		FSampleRate: Cardinal;
		FBufferSize: Cardinal;

		procedure DoWriteWavDump;

	public
		constructor Create(const ASampleRate: TReSIDSampleRate;
				const AFrameRate: Cardinal;
				const ABufferSize: TReSIDBufferSize;
				const AParams: TStrings; var ABuffer: PArrSmallInt); override;
		destructor  Destroy; override;

		class function  GetName: AnsiString; override;
		class function  GetRequireAllData: Boolean; override;
		class procedure FillParameterNames(const AStrings: TStrings); override;

		procedure SwapBuffers(var ABuffer: PArrSmallInt;
				const ASize: Integer); override;
		procedure TransferBuffer(const ABuffer: PArrSmallInt;
				var ASize: Integer); override;
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

{ TReSIDAudioDump }

class function TReSIDAudioDump.GetName: AnsiString;
	begin
	Result:= 'WAV Writer';
	end;

class function TReSIDAudioDump.GetRequireAllData: Boolean;
	begin
	Result:= True;
	end;

procedure TReSIDAudioDump.SwapBuffers(var ABuffer: PArrSmallInt;
		const ASize: Integer);
	begin
	FMemory.WriteBuffer(ABuffer^[0], ASize);
//	ASize:= 0;
	end;

procedure TReSIDAudioDump.DoWriteWavDump;
	var
	fs: TFileStream;
	riff: TRIFFHeader;
	fmt: TWAVFMTHeader;
	dat: TWAVDATHeader;

	begin
	if  FMemory.Size > 0 then
		begin
		fs:= TFileStream.Create(FFileName, fmCreate);
		riff.id:= AnsiString('RIFF');
		riff.size:= FMemory.Size + SizeOf(TRIFFHeader) + SizeOf(TWAVFMTHeader) +
				SizeOf(TWAVDATHeader) - 8;
		riff.ty:= AnsiString('WAVE');

		fs.Write(riff, SizeOf(TRIFFHeader));

		fmt.id:= AnsiString('fmt ');
		fmt.size:= SizeOf(TWAVFMTHeader) - 8;
		fmt.comp:= 1;

		fmt.chan:= 1;
		fmt.rate:= FSampleRate;
		fmt.sig:= 16;

		fmt.align:= fmt.sig div 8 * fmt.chan;
		fmt.avg:= fmt.rate * fmt.align;

		fs.Write(fmt, SizeOf(TWAVFMTHeader));

		dat.id:= AnsiString('data');
		dat.size:= FMemory.Size;

		fs.Write(dat, SizeOf(TWAVDATHeader));

		FMemory.Seek(0, soBeginning);
		fs.CopyFrom(FMemory, FMemory.Size);
		fs.Free;
		end;
	end;

constructor TReSIDAudioDump.Create(const ASampleRate: TReSIDSampleRate;
		const AFrameRate: Cardinal; const ABufferSize: TReSIDBufferSize;
		const AParams: TStrings; var ABuffer: PArrSmallInt);
	var
	i: Integer;

	begin
	inherited Create(ASampleRate, AFrameRate, ABufferSize, AParams, ABuffer);

	FSampleRate:= ARR_VAL_SAMPLERATE[ASampleRate];
	FMemory:= TMemoryStream.Create;

	FBufferSize:= Round(ARR_VAL_SAMPLERATE[ASampleRate] / AFrameRate *
			ARR_VAL_BUFFERFACT[ABufferSize]);

	i:= AParams.IndexOfName('File Name');
	if i > -1 then
		FFileName:= AParams.ValueFromIndex[i]
//dengland Should make sure that the extension is wav here or also support raw?
	else
		FFileName:= 'Dump.WAV';

	ABuffer:= AllocMem(FBufferSize * 2);
	end;

destructor TReSIDAudioDump.Destroy;
	begin
	DoWriteWavDump;

	FMemory.Free;

	inherited Destroy;
	end;

class procedure TReSIDAudioDump.FillParameterNames(const AStrings: TStrings);
	begin
	inherited FillParameterNames(AStrings);

	AStrings.Add('File Name=Dump.WAV');
	end;

procedure TReSIDAudioDump.TransferBuffer(const ABuffer: PArrSmallInt;
		var ASize: Integer);
	begin
	FMemory.WriteBuffer(ABuffer^[0], ASize * 2);
	ASize:= 0;
	end;


initialization
	RegisterRenderer(TReSIDAudioDump);

end.

