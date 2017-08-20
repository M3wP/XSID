#ifdef _MSC_VER
#include "stdafx.h"
#endif
#include "siddefs-fp.h"

#ifdef LIBRESIDFP_EXPORTS 
#ifdef _MSC_VER
#define LIBRESIDFP_API __declspec(dllexport)
#else
#define LIBRESIDFP_API __attribute__((__visibility__("default")))
#endif
#else
#ifdef _MSC_VER
#define LIBRESIDFP_API __declspec(dllimport)
#else
#define LIBRESIDFP_API
#endif
#endif

#ifndef _MSC_VER
#define __stdcall __attribute__((stdcall))
#endif

extern "C" {
	LIBRESIDFP_API void* __stdcall ReSIDCreate(void);
	LIBRESIDFP_API void  __stdcall ReSIDDestroy(void *reSID);
		
	LIBRESIDFP_API int  __stdcall ReSIDClock(void* reSID, int cycles, short* buf);
	LIBRESIDFP_API void __stdcall ReSIDWrite(void* reSID, int offset, unsigned char value);
	LIBRESIDFP_API void __stdcall ReSIDSetSamplingParameters(void* reSID, double clockFrequency, reSIDfp::SamplingMethod method, double samplingFrequency, double highestAccurateFrequency);
	LIBRESIDFP_API void __stdcall ReSIDSetChipModel(void* reSID, reSIDfp::ChipModel model);
	LIBRESIDFP_API void __stdcall ReSIDClockSilent(void* reSID, int cycles);
}
