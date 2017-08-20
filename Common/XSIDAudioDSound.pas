unit XSIDAudioDSound;

{$INCLUDE XSID.inc}

{$DEFINE DIRECTSOUND_DYNAMIC_LINK}

interface

uses
	Classes, XSIDTypes, DirectSound;

type

{ TXSIDAudioDSound }

	TXSIDAudioDSound = class(TXSIDAudioRenderer)
	protected
		FDSound: IDirectSound;
		FBuffer: IDirectSoundBuffer;
		FNextHalf: Word;

//		FSampleRate: Cardinal;
		FBufferSize,
		FLastSize: Cardinal;

	public
		constructor Create(const ASampleRate: TXSIDSampleRate;
				const AFrameRate: Cardinal;
				const ABufferSize: TXSIDBufferSize;
				const AParams: TStrings; var ABuffer: PArrSmallInt); override;
		destructor  Destroy; override;

		class function  GetName: AnsiString; override;
		class function  GetWantPlatformDefault: Boolean; override;

		procedure SwapBuffers(var ABuffer: PArrSmallInt;
				const ASize: Integer); override;
		procedure TransferBuffer(const ABuffer: PArrSmallInt;
				var ASize: Integer); override;

		procedure Pause(var ABuffer: PArrSmallInt); override;
		procedure Play(var ABuffer: PArrSmallInt); override;
	end;


implementation

uses
	Windows, MMSystem, ActiveX, SysUtils, Math, Forms;


{ TXSIDAudioDSound }

constructor TXSIDAudioDSound.Create(const ASampleRate: TXSIDSampleRate;
		const AFrameRate: Cardinal; const ABufferSize: TXSIDBufferSize;
		const AParams: TStrings; var ABuffer: PArrSmallInt);
	var
	bufDesc: TDSBufferDesc;
	fmt: TWaveFormatEx;
//	buf: PInteger;
	audio1,
	audio2: PByteArray;
	audio1sz,
	audio2sz: Cardinal;

	begin
	inherited Create(ASampleRate, AFrameRate, ABufferSize, AParams, ABuffer);

//FIXME There is a possibility that we won't have a size number of samples per frame
//      and will there by end up with overflow into the next buffer.  We need to
//      handle that properly.

//	FBufferSize:= ARR_VAL_BUFFERSIZE[ABufferSize];
	FBufferSize:= Round(ARR_VAL_SAMPLERATE[ASampleRate] / AFrameRate *
			ARR_VAL_BUFFERFACT[ABufferSize]);

	CoInitializeEx(nil, COINIT_APARTMENTTHREADED);

	if  not LoadDirectSound then
		raise Exception.Create('Unable to load DirectSound libraries');

	if  DirectSoundCreate(nil, FDSound, nil) <> DS_OK then
		raise Exception.Create('Unable to create DirectSound interface');

	if  FDSound.SetCooperativeLevel(Application.MainFormHandle,
			DSSCL_PRIORITY) <> DS_OK then
//	if  FDSound.SetCooperativeLevel(Application.Handle,
//			DSSCL_NORMAL) <> DS_OK then
		raise Exception.Create('Unable to set DirectSound cooperative level');

	FillChar(bufDesc, SizeOf(TDSCBufferDesc), 0);
	FillChar(fmt, SizeOf(TWaveFormatEx), 0);

	fmt.wFormatTag:= WAVE_FORMAT_PCM;
	fmt.nChannels:= 1;
	fmt.nSamplesPerSec:= ARR_VAL_SAMPLERATE[ASampleRate];
	fmt.wBitsPerSample:= 16;
	fmt.nBlockAlign:= fmt.wBitsPerSample div 8;
	fmt.nAvgBytesPerSec:= fmt.nSamplesPerSec * fmt.nBlockAlign;
	fmt.cbSize:= 0;

	bufDesc.dwSize:= SizeOf(TDSBufferDesc);
	bufDesc.dwFlags:= DSBCAPS_LOCSOFTWARE or DSBCAPS_GETCURRENTPOSITION2 or
			DSBCAPS_GLOBALFOCUS;{ or DSBCAPS_TRUEPLAYPOSITION;}
	bufDesc.lpwfxFormat:= @fmt;
	bufDesc.dwBufferBytes:= FBufferSize * 2;

	if  FDSound.CreateSoundBuffer(bufDesc, FBuffer, nil) <> DS_OK then
		raise Exception.Create('Unable to create DSound buffer');

//	buf:= AllocMem(FBufferSize * 2);
	if  FBuffer.Lock(0, FBufferSize * 2, @audio1, @audio1sz, @audio2,
			@audio2sz, 0) <> DS_OK then
		raise Exception.Create('Unable to lock for initial buffer fill');
	try
//		Move(buf^, audio1^[0], FBufferSize * 2);
		FillChar(audio1^[0], audio1sz, 0);

		finally
		FBuffer.Unlock(audio1, FBufferSize * 2, audio2, 0);
//{$IFDEF DCC}
//		FreeMemory(buf);
//{$ELSE}
//		FreeMemory(buf, FBufferSize * 2);
//{$ENDIF}
		end;

	if  FBuffer.Play(0, 0, DSBPLAY_LOOPING) <> DS_OK then
		raise Exception.Create('Unable to start initial audio playback');

	ABuffer:= nil;
	FNextHalf:= 1;
	FLastSize:= FBufferSize;
	SwapBuffers(ABuffer, FBufferSize);
	end;

destructor TXSIDAudioDSound.Destroy;
	begin
{$IFDEF DCC}
	FBuffer:= nil;
	FDSound:= nil;
{$ELSE}
	FBuffer:= Unassigned;
	FDSound:= Unassigned;
{$ENDIF}

	CoUninitialize;

	inherited Destroy;
	end;

class function TXSIDAudioDSound.GetName: AnsiString;
	begin
	Result:= 'DirectSound Output';
	end;

class function TXSIDAudioDSound.GetWantPlatformDefault: Boolean;
	begin
//dengland If we're here then we do...
	Result:= True;
	end;

procedure TXSIDAudioDSound.Pause(var ABuffer: PArrSmallInt);
	begin
	FBuffer.Stop;
	end;

procedure TXSIDAudioDSound.Play(var ABuffer: PArrSmallInt);
	begin
	if  FBuffer.Play(0, 0, DSBPLAY_LOOPING) <> DS_OK then
		raise Exception.Create('Unable to start initial audio playback');
	end;

procedure TXSIDAudioDSound.SwapBuffers(var ABuffer: PArrSmallInt;
		const ASize: Integer);
	var
	curHalf: Integer;
	expectPos: Cardinal;
	status,
	curPlay,
	curWrite: Cardinal;
	audio1,
	audio2: PByteArray;
	audio1sz,
	audio2sz: Cardinal;
//	sz: Cardinal;
	err: HResult;
	s: string;
//	val: Integer;

	begin
	curHalf:= 1 - FNextHalf;
//	expectPos:= FBufferSize;
	expectPos:= FLastSize;

	if  Assigned(ABuffer) then
//		FBuffer.Unlock(ABuffer, FBufferSize, nil, 0);
		FBuffer.Unlock(ABuffer, ASize, nil, 0);

//	if next buf is lost then restore
	if  FBuffer.GetStatus(status) <> DS_OK then
		raise Exception.Create('Unable to get status of buffer');
	if  (DSBSTATUS_BUFFERLOST and status) <> 0 then
		begin
		if  FBuffer.Restore <> DS_OK then
			raise Exception.Create('Unable to restore the buffer');
		FNextHalf:= 0;
		curHalf:= 1;
//dengland Still not sure what to do here, exactly.  I think this is right...
//		expectPos:= 0;
		end;

//	wait until play pos is in correct half
	if  FBuffer.GetCurrentPosition(@curPlay, @curWrite) <> DS_OK then
		raise Exception.Create('Unable to get position of the buffer');
	while ((curHalf = 0)  and (curPlay > expectPos)) or
			((curHalf = 1) and (curPlay < expectPos)) do
		begin
//		for val:= 0 to 100 do
//			;
		Sleep(10);
		if  FBuffer.GetCurrentPosition(@curPlay, @curWrite) <> DS_OK then
			raise Exception.Create('Unable to get position of the buffer');
		end;

//	err:= FBuffer.Lock(FNextHalf * FBufferSize, FBufferSize, @audio1, @audio1sz,
	err:= FBuffer.Lock(FNextHalf * FBufferSize, FBufferSize, @audio1, @audio1sz,
			@audio2, @audio2sz, 0);
	if err <> DS_OK then
		begin
		case err of
			DSERR_BUFFERLOST:
				s:= 'Buffer Lost';
			DSERR_INVALIDCALL:
				s:= 'Invalid Call';
			DSERR_INVALIDPARAM:
				s:= 'Invalid Param';
			DSERR_PRIOLEVELNEEDED:
				s:= 'Priority Level Needed';
			else
				s:= Format('Unknown $x', [err]);
			end;

		raise Exception.Create('Unable to lock the next buffer: ' + s);
		end;

	ABuffer:= PArrSmallInt(audio1);

//	play next buf
//	if  FBuffers[FNextBuf].Play(0, 0, 0) <> DS_OK then
//		raise Exception.Create('Unable to play the next buffer');

//	set new next buf
	FNextHalf:= curHalf;

	FLastSize:= ASize;
	end;

procedure TXSIDAudioDSound.TransferBuffer(const ABuffer: PArrSmallInt;
		var ASize: Integer);
	var
	curHalf: Integer;
	expectPos: Cardinal;
	status,
	curPlay,
	curWrite: Cardinal;
	audio1,
	audio2: PByteArray;
	audio1sz,
	audio2sz: Cardinal;
	sz: Cardinal;
	err: HResult;
	s: string;
//	val: Integer;

	begin
	curHalf:= 1 - FNextHalf;
	expectPos:= FBufferSize;

//	if next buf is lost then restore
	if  FBuffer.GetStatus(status) <> DS_OK then
		raise Exception.Create('Unable to get status of buffer');
	if  (DSBSTATUS_BUFFERLOST and status) <> 0 then
		begin
		if  FBuffer.Restore <> DS_OK then
			raise Exception.Create('Unable to restore the buffer');
		FNextHalf:= 0;
		curHalf:= 1;
//dengland Still not sure what to do here, exactly.  I think this is right...
//		expectPos:= 0;
		end;

//	wait until play pos is in correct half
	if  FBuffer.GetCurrentPosition(@curPlay, @curWrite) <> DS_OK then
		raise Exception.Create('Unable to get position of the buffer');
	while ((curHalf = 0)  and (curPlay > expectPos)) or
			((curHalf = 1) and (curPlay < expectPos)) do
		begin
//		for val:= 0 to 100 do
//			;
		Sleep(1);
		if  FBuffer.GetCurrentPosition(@curPlay, @curWrite) <> DS_OK then
			raise Exception.Create('Unable to get position of the buffer');
		end;


//	move data into next buf
	if  (ASize * 2) > Integer(FBufferSize) then
		sz:= FBufferSize
	else
		sz:= ASize * 2;
	err:= FBuffer.Lock(FNextHalf * FBufferSize, sz, @audio1, @audio1sz, @audio2,
			@audio2sz, 0);
	if err = DS_OK then
		begin
		Move(ABuffer^[0], audio1^[0], sz);
		FBuffer.Unlock(audio1, sz, audio2, 0);
		end
	 else
		begin
		case err of
			DSERR_BUFFERLOST:
				s:= 'Buffer Lost';
			DSERR_INVALIDCALL:
				s:= 'Invalid Call';
			DSERR_INVALIDPARAM:
				s:= 'Invalid Param';
			DSERR_PRIOLEVELNEEDED:
				s:= 'Priority Level Needed';
			else
				s:= Format('Unknown $x', [err]);
			end;

		raise Exception.Create('Unable to lock the next buffer: ' + s);
		end;
	ASize:= 0;

//	play next buf
//	if  FBuffers[FNextBuf].Play(0, 0, 0) <> DS_OK then
//		raise Exception.Create('Unable to play the next buffer');

//	set new next buf
	FNextHalf:= curHalf;
	end;


initialization
	RegisterRenderer(TXSIDAudioDSound);

end.

