unit SIDPlay;

{$IFDEF FPC}
	{$IFDEF CPU64}
		{$DEFINE DEF_SIDPLAY_CPU64}
	{$ELSE}
		{$DEFINE DEF_SIDPLAY_CPU32}
	{$ENDIF}
{$ELSE}
	{$IFDEF CPU64BITS}
		{$DEFINE DEF_SIDPLAY_CPU64}
	{$ELSE}
		{$DEFINE DEF_SIDPLAY_CPU32}
	{$ENDIF}
{$ENDIF}

interface

const
{$IFNDEF MSWINDOWS}
	LIB_SIDPLAY = 'SIDPlay';

	{$LINKLIB SIDPlay.so}

{$ELSE}
	LIB_SIDPLAY = 'LibSIDPlay.dll';
{$ENDIF}

{$IFDEF DEF_SIDPLAY_CPU64}
function  DumpSIDCreate(name, fileName: PAnsiChar): Pointer;  external LIB_SIDPLAY;
procedure DumpSIDDestroy(dumpSID: Pointer);  external LIB_SIDPLAY;
function  DumpSIDCreateSIDs(dumpSID: Pointer; sids: Cardinal): Cardinal;  external LIB_SIDPLAY;
function  DumpSIDGetStatus(dumpSID: Pointer): LongBool;  external LIB_SIDPLAY;
function  DumpSIDGetError(dumpSID: Pointer): PAnsiChar;  external LIB_SIDPLAY;
//	LIBSIDPLAY_API void * __stdcall DumpSIDGetEmulation(void * dumpSID);


function  SIDTuneCreate(const fileName: PAnsiChar): Pointer;  external LIB_SIDPLAY;
procedure SIDTuneDestroy(sidtune: Pointer);  external LIB_SIDPLAY;
function  SIDTuneGetStatus(sidtune: Pointer): LongBool;  external LIB_SIDPLAY;
function  SIDTuneSelectSong(sidtune: Pointer; songNum: Cardinal): Cardinal;  external LIB_SIDPLAY;


function  SIDConfigCreate: Pointer;  external LIB_SIDPLAY;
procedure SIDConfigDestroy(sidconfig: Pointer);  external LIB_SIDPLAY;
procedure SIDConfigSetFrequency(sidconfig: Pointer; samplerate: Cardinal);  external LIB_SIDPLAY;
procedure SIDConfigSetSamplingMethod(sidconfig: Pointer; method: Integer);  external LIB_SIDPLAY;
procedure SIDConfigSetFastSampling(sidconfig: Pointer; fast: LongBool);  external LIB_SIDPLAY;
procedure SIDConfigSetPlayback(sidconfig: Pointer; playback: Integer);  external LIB_SIDPLAY;
procedure SIDConfigSetSIDEmulation(sidconfig: Pointer; emulation: Pointer);  external LIB_SIDPLAY;


function  PlayerCreate: Pointer;  external LIB_SIDPLAY;
procedure PlayerDestroy(play: Pointer);  external LIB_SIDPLAY;
procedure PlayerSetROMS(play: Pointer; kernal, basic, character: PByte);  external LIB_SIDPLAY;
function  PlayerGetInfoMaxSIDs(play: Pointer): Cardinal;  external LIB_SIDPLAY;
function  PlayerSetConfig(play, sidconfig: Pointer): LongBool;  external LIB_SIDPLAY;
function  PlayerGetError(play: Pointer): PAnsiChar;  external LIB_SIDPLAY;
function  PlayerLoadTune(play, sidtune: Pointer): LongBool;  external LIB_SIDPLAY;
function  PlayerGetCPUFreq(play: Pointer): Double;  external LIB_SIDPLAY;
function  PlayerGetTime(play: Pointer): Cardinal;  external LIB_SIDPLAY;
function  PlayerPlay(play: Pointer; buffer: PSmallInt; samples: Cardinal): Cardinal;  external LIB_SIDPLAY;
{$ELSE}
{$IFDEF MSWINDOWS}
function  DumpSIDCreate(name, fileName: PAnsiChar): Pointer; stdcall;
		external LIB_SIDPLAY name '_DumpSIDCreate@8';
procedure DumpSIDDestroy(dumpSID: Pointer); stdcall;
		external LIB_SIDPLAY name '_DumpSIDDestroy@4';
function  DumpSIDCreateSIDs(dumpSID: Pointer; sids: Cardinal): Cardinal; stdcall;
		external LIB_SIDPLAY name '_DumpSIDCreateSIDs@8';
function  DumpSIDGetStatus(dumpSID: Pointer): LongBool; stdcall;
		external LIB_SIDPLAY name '_DumpSIDGetStatus@4';
function  DumpSIDGetError(dumpSID: Pointer): PAnsiChar; stdcall;
		external LIB_SIDPLAY name '_DumpSIDGetError@4';
//	LIBSIDPLAY_API void * __stdcall DumpSIDGetEmulation(void * dumpSID);


function  SIDTuneCreate(const fileName: PAnsiChar): Pointer; stdcall;
		external LIB_SIDPLAY name '_SIDTuneCreate@4';
procedure SIDTuneDestroy(sidtune: Pointer); stdcall;
		external LIB_SIDPLAY name '_SIDTuneDestroy@4';
function  SIDTuneGetStatus(sidtune: Pointer): LongBool; stdcall;
		external LIB_SIDPLAY name '_SIDTuneGetStatus@4';
function  SIDTuneSelectSong(sidtune: Pointer; songNum: Cardinal): Cardinal; stdcall;
		external LIB_SIDPLAY name '_SIDTuneSelectSong@8';


function  SIDConfigCreate: Pointer; stdcall;
		external LIB_SIDPLAY name '_SIDConfigCreate@0';
procedure SIDConfigDestroy(sidconfig: Pointer); stdcall;
		external LIB_SIDPLAY name '_SIDConfigDestroy@4';
procedure SIDConfigSetFrequency(sidconfig: Pointer; samplerate: Cardinal); stdcall;
		external LIB_SIDPLAY name '_SIDConfigSetFrequency@8';
procedure SIDConfigSetSamplingMethod(sidconfig: Pointer; method: Integer); stdcall;
		external LIB_SIDPLAY name '_SIDConfigSetSamplingMethod@8';
procedure SIDConfigSetFastSampling(sidconfig: Pointer; fast: LongBool); stdcall;
		external LIB_SIDPLAY name '_SIDConfigSetFastSampling@8';
procedure SIDConfigSetPlayback(sidconfig: Pointer; playback: Integer); stdcall;
		external LIB_SIDPLAY name '_SIDConfigSetPlayback@8';
procedure SIDConfigSetSIDEmulation(sidconfig: Pointer; emulation: Pointer); stdcall;
		external LIB_SIDPLAY name '_SIDConfigSetSIDEmulation@8';


function  PlayerCreate: Pointer; stdcall;
		external LIB_SIDPLAY name '_PlayerCreate@0';
procedure PlayerDestroy(play: Pointer); stdcall;
		external LIB_SIDPLAY name '_PlayerDestroy@4';
procedure PlayerSetROMS(play: Pointer; kernal, basic, character: PByte); stdcall;
		external LIB_SIDPLAY name '_PlayerSetROMS@16';
function  PlayerGetInfoMaxSIDs(play: Pointer): Cardinal; stdcall;
		external LIB_SIDPLAY name '_PlayerGetInfoMaxSIDs@4';
function  PlayerSetConfig(play, sidconfig: Pointer): LongBool; stdcall;
		external LIB_SIDPLAY name '_PlayerSetConfig@8';
function  PlayerGetError(play: Pointer): PAnsiChar; stdcall;
		external LIB_SIDPLAY name '_PlayerGetError@4';
function  PlayerLoadTune(play, sidtune: Pointer): LongBool; stdcall;
		external LIB_SIDPLAY name '_PlayerLoadTune@8';
function  PlayerGetCPUFreq(play: Pointer): Double; stdcall;
		external LIB_SIDPLAY name '_PlayerGetCPUFreq@4';
function  PlayerGetTime(play: Pointer): Cardinal; stdcall;
		external LIB_SIDPLAY name '_PlayerGetTime@4';
function  PlayerPlay(play: Pointer; buffer: PSmallInt;
		samples: Cardinal): Cardinal; stdcall;
		external LIB_SIDPLAY name '_PlayerPlay@12';
{$ELSE}
function  DumpSIDCreate(name, fileName: PAnsiChar): Pointer; stdcall; external LIB_SIDPLAY;
procedure DumpSIDDestroy(dumpSID: Pointer); stdcall; external LIB_SIDPLAY;
function  DumpSIDCreateSIDs(dumpSID: Pointer; sids: Cardinal): Cardinal; stdcall; external LIB_SIDPLAY;
function  DumpSIDGetStatus(dumpSID: Pointer): LongBool; stdcall; external LIB_SIDPLAY;
function  DumpSIDGetError(dumpSID: Pointer): PAnsiChar; stdcall; external LIB_SIDPLAY;
//	LIBSIDPLAY_API void * __stdcall DumpSIDGetEmulation(void * dumpSID);


function  SIDTuneCreate(const fileName: PAnsiChar): Pointer; stdcall; external LIB_SIDPLAY;
procedure SIDTuneDestroy(sidtune: Pointer); stdcall; external LIB_SIDPLAY;
function  SIDTuneGetStatus(sidtune: Pointer): LongBool; stdcall; external LIB_SIDPLAY;
function  SIDTuneSelectSong(sidtune: Pointer; songNum: Cardinal): Cardinal; stdcall; external LIB_SIDPLAY;


function  SIDConfigCreate: Pointer; stdcall; external LIB_SIDPLAY;
procedure SIDConfigDestroy(sidconfig: Pointer); stdcall; external LIB_SIDPLAY;
procedure SIDConfigSetFrequency(sidconfig: Pointer; samplerate: Cardinal); stdcall; external LIB_SIDPLAY;
procedure SIDConfigSetSamplingMethod(sidconfig: Pointer; method: Integer); stdcall; external LIB_SIDPLAY;
procedure SIDConfigSetFastSampling(sidconfig: Pointer; fast: LongBool); stdcall; external LIB_SIDPLAY;
procedure SIDConfigSetPlayback(sidconfig: Pointer; playback: Integer); stdcall; external LIB_SIDPLAY;
procedure SIDConfigSetSIDEmulation(sidconfig: Pointer; emulation: Pointer); stdcall; external LIB_SIDPLAY;


function  PlayerCreate: Pointer; stdcall; external LIB_SIDPLAY;
procedure PlayerDestroy(play: Pointer); stdcall; external LIB_SIDPLAY;
procedure PlayerSetROMS(play: Pointer; kernal, basic, character: PByte); stdcall; external LIB_SIDPLAY;
function  PlayerGetInfoMaxSIDs(play: Pointer): Cardinal; stdcall; external LIB_SIDPLAY;
function  PlayerSetConfig(play, sidconfig: Pointer): LongBool; stdcall; external LIB_SIDPLAY;
function  PlayerGetError(play: Pointer): PAnsiChar; stdcall; external LIB_SIDPLAY;
function  PlayerLoadTune(play, sidtune: Pointer): LongBool; stdcall; external LIB_SIDPLAY;
function  PlayerGetCPUFreq(play: Pointer): Double; stdcall; external LIB_SIDPLAY;
function  PlayerGetTime(play: Pointer): Cardinal; stdcall; external LIB_SIDPLAY;
function  PlayerPlay(play: Pointer; buffer: PSmallInt; samples: Cardinal): Cardinal; stdcall; external LIB_SIDPLAY;
{$ENDIF}
{$ENDIF}


implementation

end.
