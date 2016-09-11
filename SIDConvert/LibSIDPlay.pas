unit LibSIDPlay;

interface

function  DumpSIDCreate(name, fileName: PAnsiChar): Pointer; stdcall;
		external 'LibSIDPlay.dll' name '_DumpSIDCreate@8';
procedure DumpSIDDestroy(dumpSID: Pointer); stdcall;
		external 'LibSIDPlay.dll' name '_DumpSIDDestroy@4';
function  DumpSIDCreateSIDs(dumpSID: Pointer; sids: Cardinal): Cardinal; stdcall;
		external 'LibSIDPlay.dll' name '_DumpSIDCreateSIDs@8';
function  DumpSIDGetStatus(dumpSID: Pointer): LongBool; stdcall;
		external 'LibSIDPlay.dll' name '_DumpSIDGetStatus@4';
function  DumpSIDGetError(dumpSID: Pointer): PAnsiChar; stdcall;
		external 'LibSIDPlay.dll' name '_DumpSIDGetError@4';
//	LIBSIDPLAY_API void * __stdcall DumpSIDGetEmulation(void * dumpSID);


function  SIDTuneCreate(const fileName: PAnsiChar): Pointer; stdcall;
		external 'LibSIDPlay.dll' name '_SIDTuneCreate@4';
procedure SIDTuneDestroy(sidtune: Pointer); stdcall;
		external 'LibSIDPlay.dll' name '_SIDTuneDestroy@4';
function  SIDTuneGetStatus(sidtune: Pointer): LongBool; stdcall;
		external 'LibSIDPlay.dll' name '_SIDTuneGetStatus@4';
function  SIDTuneSelectSong(sidtune: Pointer; songNum: Cardinal): Cardinal; stdcall;
		external 'LibSIDPlay.dll' name '_SIDTuneSelectSong@8';


function  SIDConfigCreate: Pointer; stdcall;
		external 'LibSIDPlay.dll' name '_SIDConfigCreate@0';
procedure SIDConfigDestroy(sidconfig: Pointer); stdcall;
		external 'LibSIDPlay.dll' name '_SIDConfigDestroy@4';
procedure SIDConfigSetFrequency(sidconfig: Pointer; samplerate: Cardinal); stdcall;
		external 'LibSIDPlay.dll' name '_SIDConfigSetFrequency@8';
procedure SIDConfigSetSamplingMethod(sidconfig: Pointer; method: Integer); stdcall;
		external 'LibSIDPlay.dll' name '_SIDConfigSetSamplingMethod@8';
procedure SIDConfigSetFastSampling(sidconfig: Pointer; fast: LongBool); stdcall;
		external 'LibSIDPlay.dll' name '_SIDConfigSetFastSampling@8';
procedure SIDConfigSetPlayback(sidconfig: Pointer; playback: Integer); stdcall;
		external 'LibSIDPlay.dll' name '_SIDConfigSetPlayback@8';
procedure SIDConfigSetSIDEmulation(sidconfig: Pointer; emulation: Pointer); stdcall;
		external 'LibSIDPlay.dll' name '_SIDConfigSetSIDEmulation@8';


function  PlayerCreate: Pointer; stdcall;
		external 'LibSIDPlay.dll' name '_PlayerCreate@0';
procedure PlayerDestroy(play: Pointer); stdcall;
		external 'LibSIDPlay.dll' name '_PlayerDestroy@4';
procedure PlayerSetROMS(play: Pointer; kernal, basic, character: PByte); stdcall;
		external 'LibSIDPlay.dll' name '_PlayerSetROMS@16';
function  PlayerGetInfoMaxSIDs(play: Pointer): Cardinal; stdcall;
		external 'LibSIDPlay.dll' name '_PlayerGetInfoMaxSIDs@4';
function  PlayerSetConfig(play, sidconfig: Pointer): LongBool; stdcall;
		external 'LibSIDPlay.dll' name '_PlayerSetConfig@8';
function  PlayerGetError(play: Pointer): PAnsiChar; stdcall;
		external 'LibSIDPlay.dll' name '_PlayerGetError@4';
function  PlayerLoadTune(play, sidtune: Pointer): LongBool; stdcall;
		external 'LibSIDPlay.dll' name '_PlayerLoadTune@8';
function  PlayerGetCPUFreq(play: Pointer): Double; stdcall;
		external 'LibSIDPlay.dll' name '_PlayerGetCPUFreq@4';
function  PlayerGetTime(play: Pointer): Cardinal; stdcall;
		external 'LibSIDPlay.dll' name '_PlayerGetTime@4';
function  PlayerPlay(play: Pointer; buffer: PSmallInt;
		samples: Cardinal): Cardinal; stdcall;
		external 'LibSIDPlay.dll' name '_PlayerPlay@12';



implementation

end.
