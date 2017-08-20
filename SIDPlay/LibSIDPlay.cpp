// LIBSIDPlay.cpp : Defines the exported functions for the DLL application.
//

#include "LIBSIDPlay.h"
#include "dump/dumpsid-builder.h"
#include "player.h"
#include "SidTune.h"
#include "SidConfig.h"


extern "C" {
	LIBSIDPLAY_API void* LIBSIDPLAY_CC DumpSIDCreate(char *name, char *fileName)
	{
		DumpSIDBuilder *dump = new DumpSIDBuilder(name);

		dump->setFileName(fileName);
		return dump;
	}

	LIBSIDPLAY_API void  LIBSIDPLAY_CC DumpSIDDestroy(void *dumpSID)
	{
		DumpSIDBuilder *dump = reinterpret_cast<DumpSIDBuilder*>(dumpSID);
		delete dump;
	}

	LIBSIDPLAY_API unsigned int  LIBSIDPLAY_CC DumpSIDCreateSIDs(void *dumpSID, unsigned int sids)
	{
		DumpSIDBuilder *dump = reinterpret_cast<DumpSIDBuilder*>(dumpSID);
		return dump->create(sids);
	}

	LIBSIDPLAY_API bool  LIBSIDPLAY_CC DumpSIDGetStatus(void *dumpSID)
	{
		DumpSIDBuilder *dump = reinterpret_cast<DumpSIDBuilder*>(dumpSID);
		return dump->getStatus();
	}

	LIBSIDPLAY_API const char * LIBSIDPLAY_CC DumpSIDGetError(void *dumpSID)
	{
		DumpSIDBuilder *dump = reinterpret_cast<DumpSIDBuilder*>(dumpSID);
		return dump->error();
	}
	
//	LIBSIDPLAY_API void * LIBSIDPLAY_CC DumpSIDGetEmulation(void * dumpSID)
//	{
//		DumpSIDBuilder *dump = reinterpret_cast<DumpSIDBuilder*>(dumpSID);
//		return dump->get();
//	}





	LIBSIDPLAY_API void* __stdcall SIDTuneCreate(const char* fileName)
	{
		SidTune *tune = new SidTune(fileName);
		return tune;
	}

	LIBSIDPLAY_API void  __stdcall SIDTuneDestroy(void *sidtune)
	{
		SidTune *tune = reinterpret_cast<SidTune*>(sidtune);
		delete tune;
	}

	LIBSIDPLAY_API bool  __stdcall SIDTuneGetStatus(void * sidtune)
	{
		SidTune *tune = reinterpret_cast<SidTune*>(sidtune);
		return tune->getStatus();
	}

	LIBSIDPLAY_API unsigned int __stdcall SIDTuneSelectSong(void * sidtune, unsigned int songNum)
	{
		SidTune *tune = reinterpret_cast<SidTune*>(sidtune);
		return tune->selectSong(songNum);
	}





	LIBSIDPLAY_API void* __stdcall SIDConfigCreate(void)
	{
		SidConfig *config = new SidConfig;
		return config;
	}

	LIBSIDPLAY_API void  __stdcall SIDConfigDestroy(void *sidconfig)
	{
		SidConfig *config = reinterpret_cast<SidConfig*>(sidconfig);
		delete config;
	}

	LIBSIDPLAY_API void  __stdcall SIDConfigSetFrequency(void *sidconfig, uint_least32_t samplerate)
	{
		SidConfig *config = reinterpret_cast<SidConfig*>(sidconfig);
		config->frequency = samplerate;
	}

	LIBSIDPLAY_API void  __stdcall SIDConfigSetSamplingMethod(void *sidconfig, int method)
	{
		SidConfig *config = reinterpret_cast<SidConfig*>(sidconfig);
		config->samplingMethod = static_cast<SidConfig::sampling_method_t>(method);
	}

	LIBSIDPLAY_API void  __stdcall SIDConfigSetFastSampling(void *sidconfig, bool fast)
	{
		SidConfig *config = reinterpret_cast<SidConfig*>(sidconfig);
		config->fastSampling = fast;
	}

	LIBSIDPLAY_API void  __stdcall SIDConfigSetPlayback(void *sidconfig, int playback)
	{
		SidConfig *config = reinterpret_cast<SidConfig*>(sidconfig);
		config->playback = static_cast<SidConfig::playback_t>(playback);
	}

	LIBSIDPLAY_API void  __stdcall SIDConfigSetSIDEmulation(void *sidconfig, void *emulation)
	{
		SidConfig *config = reinterpret_cast<SidConfig*>(sidconfig);
		config->sidEmulation = reinterpret_cast<sidbuilder *>(emulation);
	}





	LIBSIDPLAY_API void* __stdcall PlayerCreate(void)
	{
		SIDPLAYFP_NAMESPACE::Player *player = new SIDPLAYFP_NAMESPACE::Player;
		return player;
	}

	LIBSIDPLAY_API void __stdcall PlayerDestroy(void *play)
	{
		SIDPLAYFP_NAMESPACE::Player *player = reinterpret_cast<SIDPLAYFP_NAMESPACE::Player*>(play);
		delete player;
	}

	LIBSIDPLAY_API void  __stdcall PlayerSetROMS(void *play, uint8_t *kernal, uint8_t *basic, uint8_t *character)
	{
		SIDPLAYFP_NAMESPACE::Player *player = reinterpret_cast<SIDPLAYFP_NAMESPACE::Player*>(play);

		player->setRoms(kernal, basic, character);
	}

	LIBSIDPLAY_API unsigned int __stdcall PlayerGetInfoMaxSIDs(void *play)
	{
		SIDPLAYFP_NAMESPACE::Player *player = reinterpret_cast<SIDPLAYFP_NAMESPACE::Player*>(play);

		return player->info().maxsids();
	}

	LIBSIDPLAY_API bool __stdcall PlayerSetConfig(void *play, void *sidconfig)
	{
		SIDPLAYFP_NAMESPACE::Player *player = reinterpret_cast<SIDPLAYFP_NAMESPACE::Player*>(play);
		SidConfig *config = reinterpret_cast<SidConfig*>(sidconfig);

		return player->config(*config);
	}

	LIBSIDPLAY_API const char * __stdcall PlayerGetError(void *play)
	{
		SIDPLAYFP_NAMESPACE::Player *player = reinterpret_cast<SIDPLAYFP_NAMESPACE::Player*>(play);
		return player->error();
	}

	LIBSIDPLAY_API bool __stdcall PlayerLoadTune(void *play, void *sidtune)
	{
		SIDPLAYFP_NAMESPACE::Player *player = reinterpret_cast<SIDPLAYFP_NAMESPACE::Player*>(play);
		SidTune *tune = reinterpret_cast<SidTune*>(sidtune);

		return player->load(tune);
	}

	LIBSIDPLAY_API double __stdcall PlayerGetCPUFreq(void *play)
	{
		SIDPLAYFP_NAMESPACE::Player *player = reinterpret_cast<SIDPLAYFP_NAMESPACE::Player*>(play);
		return player->cpuFreq();
	}

	LIBSIDPLAY_API uint_least32_t __stdcall PlayerGetTime(void *play)
	{
		SIDPLAYFP_NAMESPACE::Player *player = reinterpret_cast<SIDPLAYFP_NAMESPACE::Player*>(play);
		return player->time();
	}

	LIBSIDPLAY_API uint_least32_t __stdcall PlayerPlay(void *play, short *buffer, uint_least32_t samples)
	{
		SIDPLAYFP_NAMESPACE::Player *player = reinterpret_cast<SIDPLAYFP_NAMESPACE::Player*>(play);
		return player->play(buffer, samples);
	}

}