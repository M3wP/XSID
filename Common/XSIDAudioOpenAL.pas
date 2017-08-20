unit XSIDAudioOpenAL;

{$INCLUDE XSID.inc}

interface

uses
	Classes, XSIDTypes, OpenAL;

type

{ TXSIDAudioOpenAL }

 	TXSIDAudioOpenAL = class(TXSIDAudioRenderer)
	protected
		FDevice: PALCDevice;
		FContext: PALCcontext;
		FSource: ALUInt;
		FBuffers: array[0..1] of ALUInt;
		FSampleRate: Cardinal;
		FBufferData: PSmallInt;
		FBufSize: Cardinal;

	public
		constructor Create(const ASampleRate: TXSIDSampleRate;
				const AFrameRate: Cardinal;
				const ABufferSize: TXSIDBufferSize;
				const AParams: TStrings; var ABuffer: PArrSmallInt); override;
		destructor  Destroy; override;

		class function  GetName: AnsiString; override;
		class function  GetWantPlatformDefault: Boolean; override;

		procedure Pause(var ABuffer: PArrSmallInt); override;
		procedure Play(var ABuffer: PArrSmallInt); override;

        procedure SwapBuffers(var ABuffer: PArrSmallInt;
				const ASize: Integer); override;
		procedure TransferBuffer(const ABuffer: PArrSmallInt;
				var ASize: Integer); override;
	end;

implementation

uses
	SysUtils;

{ TXSIDAudioOpenAL }

class function TXSIDAudioOpenAL.GetName: AnsiString;
	begin
    Result:= 'OpenAL Output';
	end;

class function TXSIDAudioOpenAL.GetWantPlatformDefault: Boolean;
	begin
{$IFDEF MSWINDOWS}
	Result:= False;
{$ELSE}
	Result:= True;
{$ENDIF}
	end;

procedure TXSIDAudioOpenAL.Pause(var ABuffer: PArrSmallInt);
	begin
	alSourcePause(FSource);
	end;

procedure TXSIDAudioOpenAL.Play(var ABuffer: PArrSmallInt);
	begin
	alSourcePlay(FSource);
	end;

procedure TXSIDAudioOpenAL.SwapBuffers(var ABuffer: PArrSmallInt;
		const ASize: Integer);
	var
	needPlay: Boolean;
	val: ALInt;
	buffers: array[0..1] of ALUInt;
//	aError: TALEnum;

	begin
	alGetSourcei(FSource, AL_SOURCE_STATE, val);
//	needPlay:= val1 in [AL_INITIAL, AL_STOPPED];
	if  (val = AL_INITIAL)
	or  (val = AL_STOPPED) then
		needPlay:= True
	else
		needPlay:= False;

	alGetSourcei(FSource, AL_BUFFERS_PROCESSED, val);
	while val = 0 do
		begin
		for val:= 0 to 100 do
			;
		alGetSourcei(FSource, AL_BUFFERS_PROCESSED, val);
		end;

//FIXME dengland I think there is a problem with this in that we'll keep using the
//      same, single buffer all the time instead of swapping between the two
//		allocated?  I need to check the API documentation.

	if val > 0 then
		begin
		alSourceUnqueueBuffers(FSource, 1, buffers);

		alBufferData(buffers[0], AL_FORMAT_MONO16, ABuffer, ASize, FSampleRate);
//		ASize:= 0;

		alSourceQueueBuffers(FSource, 1, buffers);
		end;

	if needPlay then
		alSourcePlay(FSource);
	end;

constructor TXSIDAudioOpenAL.Create(const ASampleRate: TXSIDSampleRate;
		const AFrameRate: Cardinal; const ABufferSize: TXSIDBufferSize;
		const AParams: TStrings; var ABuffer: PArrSmallInt);
	var
	err: ALenum;
//	sz: Cardinal;
//	buf: PInteger;

	begin
	inherited Create(ASampleRate, AFrameRate, ABufferSize, AParams, ABuffer);

	//if  not InitOpenAL(callibname) then
		//raise Exception.Create('Unable to intialise OpenAL');

	FDevice:= alcOpenDevice(nil);
	if  FDevice = nil then
		raise Exception.Create('Unable to open OpenAL device');

	FContext:= alcCreateContext(FDevice, nil);
	alcMakeContextCurrent(FContext);

//	err:= alGetError;
	alGetError;

	alGenBuffers(2, @FBuffers);
	err:= alGetError;

	if  err <> AL_NO_ERROR then
		raise Exception.Create('Unable to generate OpenAL buffers');

	alGenSources(1, @FSource);
	err:= alGetError;

	if  err <> AL_NO_ERROR then
		raise Exception.Create('Unable to generate OpenAL source');

	FSampleRate:= ARR_VAL_SAMPLERATE[ASampleRate];
//	sz:= ARR_VAL_BUFFERSIZE[ABufferSize];
	FBufSize:= Round(FSampleRate / AFrameRate * ARR_VAL_BUFFERFACT[ABufferSize]);

	FBufferData:= AllocMem(FBufSize);
//	FBufferData[1]:= AllocMem(sz);

//	buf:= AllocMem(sz);
//	try
//		This is for device/driver latency
		alBufferData(FBuffers[0], AL_FORMAT_MONO16, FBufferData, FBufSize, FSampleRate);

//		This is to prebuffer output
		alBufferData(FBuffers[1], AL_FORMAT_MONO16, FBufferData, FBufSize, FSampleRate);

//		finally
//{$IFDEF DCC}
//		FreeMemory(buf);
//{$ELSE}
//		FreeMemory(buf, sz);
//{$ENDIF}
//		end;

	alSourceQueueBuffers(FSource, 2, @FBuffers);
	alSourcePlay(FSource);

	ABuffer:= PArrSmallInt(FBufferData);
	end;

destructor TXSIDAudioOpenAL.Destroy;
	var
	aContext: PALCcontext;
	aDevice: PALCdevice;

	begin
	aContext:= alcGetCurrentContext;
	aDevice:= alcGetContextsDevice(aContext);
	alcMakeContextCurrent(nil);
	alcDestroyContext(aContext);
	alcCloseDevice(aDevice);

	inherited Destroy;
	end;

procedure TXSIDAudioOpenAL.TransferBuffer(const ABuffer: PArrSmallInt;
		var ASize: Integer);
	var
	needPlay: Boolean;
	val: ALInt;
	buffers: array[0..1] of ALUInt;
//	aError: TALEnum;

	begin
	alGetSourcei(FSource, AL_SOURCE_STATE, val);
//	needPlay:= val1 in [AL_INITIAL, AL_STOPPED];
	if  (val = AL_INITIAL)
	or  (val = AL_STOPPED) then
		needPlay:= True
	else
		needPlay:= False;

	alGetSourcei(FSource, AL_BUFFERS_PROCESSED, val);
	while val = 0 do
		begin
		for val:= 0 to 100 do
			;
		alGetSourcei(FSource, AL_BUFFERS_PROCESSED, val);
		end;

	if val > 0 then
		begin
		alSourceUnqueueBuffers(FSource, 1, buffers);

		alBufferData(buffers[0], AL_FORMAT_MONO16, ABuffer, ASize * 2,
				FSampleRate);
		ASize:= 0;

		alSourceQueueBuffers(FSource, 1, buffers);
		end;

	if needPlay then
		alSourcePlay(FSource);
	end;


initialization
	RegisterRenderer(TXSIDAudioOpenAL);

end.

