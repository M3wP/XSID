// LibReSIDFPDLL.cpp : Defines the exported functions for the DLL application.
//

#include "siddefs-fp.h"
#include "LibReSIDFP.h"
#include "SID.h"

extern "C" {
	LIBRESIDFP_API void* __stdcall ReSIDCreate(void)
	{
		reSIDfp::SID *reSID = new reSIDfp::SID;
		return reSID;
	}

	LIBRESIDFP_API void __stdcall ReSIDDestroy(void *reSID)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		delete sid;
	}

	LIBRESIDFP_API int __stdcall ReSIDClock(void* reSID, int cycles, short* buf)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		return sid->clock(cycles, buf);
	}

	LIBRESIDFP_API void __stdcall ReSIDWrite(void* reSID, int offset, unsigned char value)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		sid->write(offset, value);
	}

	LIBRESIDFP_API void __stdcall ReSIDSetSamplingParameters(void* reSID, double clockFrequency, reSIDfp::SamplingMethod method, double samplingFrequency, double highestAccurateFrequency)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		sid->setSamplingParameters(clockFrequency, method, samplingFrequency, highestAccurateFrequency);
	}

	LIBRESIDFP_API void __stdcall ReSIDSetChipModel(void* reSID, reSIDfp::ChipModel model)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		sid->setChipModel(model);
	}

	LIBRESIDFP_API void __stdcall ReSIDSetFilter6581Curve(void* reSID, double filterCurve)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		sid->setFilter6581Curve(filterCurve);
	}

	LIBRESIDFP_API void __stdcall ReSIDSetFilter8580Curve(void* reSID, double filterCurve)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		sid->setFilter8580Curve(filterCurve);
	}

	LIBRESIDFP_API void __stdcall ReSIDEnableFilter(void* reSID, bool enable)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		sid->enableFilter(enable);
	}

	LIBRESIDFP_API void __stdcall ReSIDInput(void* reSID, int value)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		sid->input(value);
	}
}
