#ifdef LIBSIDPLAY_EXPORTS 
#ifdef _MSC_VER
#define LIBSIDPLAY_API __declspec(dllexport)
#else
#define LIBSIDPLAY_API __attribute__((__visibility__("default")))
#endif
#else
#ifdef _MSC_VER
#define LIBSIDPLAY_API __declspec(dllimport)
#else
#define LIBSIDPLAY_API
#endif
#endif

#ifndef _MSC_VER
#define __stdcall __attribute__((stdcall))
#endif

#include "stdint.h"


//typedef enum { MONO = 1, STEREO } playback_t;
//typedef enum { MOS6581, MOS8580 } sid_model_t;
//typedef enum { PAL, NTSC, OLD_NTSC, DREAN } c64_model_t;
//typedef enum { INTERPOLATE, RESAMPLE_INTERPOLATE } sampling_method_t;


extern "C" {
	LIBSIDPLAY_API void* __stdcall DumpSIDCreate(char *name, char *fileName);
	LIBSIDPLAY_API void  __stdcall DumpSIDDestroy(void *dumpSID);
	LIBSIDPLAY_API unsigned int  __stdcall DumpSIDCreateSIDs(void *dumpSID, unsigned int sids);
	LIBSIDPLAY_API bool  __stdcall DumpSIDGetStatus(void *dumpSID);
	LIBSIDPLAY_API const char * __stdcall DumpSIDGetError(void *dumpSID);
//	LIBSIDPLAY_API void * __stdcall DumpSIDGetEmulation(void * dumpSID);




	LIBSIDPLAY_API void* __stdcall SIDTuneCreate(const char* fileName);
	LIBSIDPLAY_API void  __stdcall SIDTuneDestroy(void *sidtune);
	LIBSIDPLAY_API bool  __stdcall SIDTuneGetStatus(void * sidtune);
	LIBSIDPLAY_API unsigned int __stdcall SIDTuneSelectSong(void * sidtune, unsigned int songNum);





	LIBSIDPLAY_API void* __stdcall SIDConfigCreate(void);
	LIBSIDPLAY_API void  __stdcall SIDConfigDestroy(void *sidconfig);
	LIBSIDPLAY_API void  __stdcall SIDConfigSetFrequency(void *sidconfig, uint_least32_t samplerate);
	LIBSIDPLAY_API void  __stdcall SIDConfigSetSamplingMethod(void *sidconfig, int method);
	LIBSIDPLAY_API void  __stdcall SIDConfigSetFastSampling(void *sidconfig, bool fast);
	LIBSIDPLAY_API void  __stdcall SIDConfigSetPlayback(void *sidconfig, int playback);
	LIBSIDPLAY_API void  __stdcall SIDConfigSetSIDEmulation(void *sidconfig, void *emulation);




	LIBSIDPLAY_API void* __stdcall PlayerCreate(void);
	LIBSIDPLAY_API void  __stdcall PlayerDestroy(void *play);
	LIBSIDPLAY_API void  __stdcall PlayerSetROMS(void *play, uint8_t *kernal, uint8_t *basic, uint8_t *character);
	LIBSIDPLAY_API unsigned int __stdcall PlayerGetInfoMaxSIDs(void *play);
	LIBSIDPLAY_API bool __stdcall PlayerSetConfig(void *play, void *sidconfig);
	LIBSIDPLAY_API const char * __stdcall PlayerGetError(void *play);
	LIBSIDPLAY_API bool __stdcall PlayerLoadTune(void *play, void *sidtune);
	LIBSIDPLAY_API double __stdcall PlayerGetCPUFreq(void *play);
	LIBSIDPLAY_API uint_least32_t __stdcall PlayerGetTime(void *play);
	LIBSIDPLAY_API uint_least32_t __stdcall PlayerPlay(void *play, short *buffer, uint_least32_t samples);

}