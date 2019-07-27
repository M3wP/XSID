// LibReSIDFPDLL.cpp : Defines the exported functions for the DLL application.
//

#include "siddefs-fp.h"
#include "LibReSIDFP.h"
#include "SID.h"

extern "C" {
	LIBRESIDFP_API void* LIBRESIDFP_CC ReSIDCreate(void)
	{
		reSIDfp::SID *reSID = new reSIDfp::SID;
		return reSID;
	}

	LIBRESIDFP_API void LIBRESIDFP_CC ReSIDDestroy(void *reSID)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		delete sid;
	}

	LIBRESIDFP_API int LIBRESIDFP_CC ReSIDClock(void* reSID, int cycles, short* buf)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		return sid->clock(cycles, buf);
	}

	LIBRESIDFP_API unsigned char LIBRESIDFP_CC ReSIDRead(void* reSID, int offset)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		return sid->read(offset);
	}

	LIBRESIDFP_API void LIBRESIDFP_CC ReSIDWrite(void* reSID, int offset, unsigned char value)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		sid->write(offset, value);
	}

	LIBRESIDFP_API void LIBRESIDFP_CC ReSIDSetSamplingParameters(void* reSID, double clockFrequency, reSIDfp::SamplingMethod method, double samplingFrequency, double highestAccurateFrequency)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		sid->setSamplingParameters(clockFrequency, method, samplingFrequency, highestAccurateFrequency);
	}

	LIBRESIDFP_API void LIBRESIDFP_CC ReSIDSetChipModel(void* reSID, reSIDfp::ChipModel model)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		sid->setChipModel(model);
	}

	LIBRESIDFP_API void LIBRESIDFP_CC ReSIDSetFilter6581Curve(void* reSID, double filterCurve)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		sid->setFilter6581Curve(filterCurve);
	}

	LIBRESIDFP_API void LIBRESIDFP_CC ReSIDSetFilter8580Curve(void* reSID, double filterCurve)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		sid->setFilter8580Curve(filterCurve);
	}

	LIBRESIDFP_API void LIBRESIDFP_CC ReSIDEnableFilter(void* reSID, bool enable)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		sid->enableFilter(enable);
	}

	LIBRESIDFP_API void LIBRESIDFP_CC ReSIDInput(void* reSID, int value)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		sid->input(value);
	}

	LIBRESIDFP_API void LIBRESIDFP_CC ReSIDClockSilent(void* reSID, int cycles)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		sid->clockSilent(cycles);
	}

	LIBRESIDFP_API void LIBRESIDFP_CC ReSIDMute(void* reSID, int channel, bool enable)
	{
		reSIDfp::SID *sid = reinterpret_cast<reSIDfp::SID*>(reSID);
		sid->mute(channel, enable);
	}
}
