#include <cstdint>

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

#ifdef _MSC_VER
#ifdef _WIN64
#define LIBRESIDFP_CC 
#else
#define LIBRESIDFP_CC __stdcall
#endif
#else
#if INTPTR_MAX == INT64_MAX
#define LIBRESIDFP_CC 
#elif INTPTR_MAX == INT32_MAX
#define LIBRESIDFP_CC __attribute__((stdcall))
#else
#error Unknown pointer size or missing size macros!
#endif
#endif

extern "C" {
	LIBRESIDFP_API void* LIBRESIDFP_CC ReSIDCreate(void);
	LIBRESIDFP_API void  LIBRESIDFP_CC ReSIDDestroy(void *reSID);
		
	LIBRESIDFP_API int  LIBRESIDFP_CC ReSIDClock(void* reSID, int cycles, short* buf);
	LIBRESIDFP_API void LIBRESIDFP_CC ReSIDWrite(void* reSID, int offset, unsigned char value);
	LIBRESIDFP_API void LIBRESIDFP_CC ReSIDSetSamplingParameters(void* reSID, double clockFrequency, reSIDfp::SamplingMethod method, double samplingFrequency, double highestAccurateFrequency);
	LIBRESIDFP_API void LIBRESIDFP_CC ReSIDSetChipModel(void* reSID, reSIDfp::ChipModel model);
	LIBRESIDFP_API void LIBRESIDFP_CC ReSIDClockSilent(void* reSID, int cycles);
}
