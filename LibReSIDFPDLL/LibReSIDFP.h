#include "stdafx.h"
#include "siddefs-fp.h"

#ifdef LIBRESIDFP_EXPORTS
#define LIBRESIDFP_API __declspec(dllexport) 
#else
#define LIBRESIDFP_API __declspec(dllimport) 
#endif

extern "C" {
	LIBRESIDFP_API void* __stdcall ReSIDCreate(void);
	LIBRESIDFP_API void  __stdcall ReSIDDestroy(void *reSID);
		
	LIBRESIDFP_API int  __stdcall ReSIDClock(void* reSID, int cycles, short* buf);
	LIBRESIDFP_API void __stdcall ReSIDWrite(void* reSID, int offset, unsigned char value);
	LIBRESIDFP_API void __stdcall ReSIDSetSamplingParameters(void* reSID, double clockFrequency, reSIDfp::SamplingMethod method, double samplingFrequency, double highestAccurateFrequency);
	LIBRESIDFP_API void __stdcall ReSIDSetChipModel(void* reSID, reSIDfp::ChipModel model);
}