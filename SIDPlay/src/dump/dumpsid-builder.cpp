#include "dumpsid-builder.h"


#include "dumpsid.h"

#include <algorithm>
#include <new>

//#include "residfp-emu.h"

DumpSIDBuilder::~DumpSIDBuilder()
{   // Remove all SID emulations
	remove();
}

void DumpSIDBuilder::setFileName(char *fileName)
{
	m_fileName = fileName;
}


// Create a new sid emulation.
unsigned int DumpSIDBuilder::create(unsigned int sids)
{
	m_status = true;

	// Check available devices
	unsigned int count = availDevices();

	if (count && (count < sids))
		sids = count;

	for (count = 0; count < sids; count++)
	{
		try
		{
			sidobjs.insert(new DumpSID(this, m_fileName));
		}
		// Memory alloc failed?
		catch (std::bad_alloc const &)
		{
			m_errorBuffer.assign(name()).append(" ERROR: Unable to create DumpSID object");
			m_status = false;
			break;
		}
	}
	return count;

}

const char *DumpSIDBuilder::credits() const
{
	return "DUMP SID Copyright (c) 2015, Daniel England\n";
}

void DumpSIDBuilder::filter(bool enable)
{
//	std::for_each(sidobjs.begin(), sidobjs.end(), applyParameter<ReSIDfp, bool>(&ReSIDfp::filter, enable));
}

void DumpSIDBuilder::filter6581Curve(double filterCurve)
{
//	std::for_each(sidobjs.begin(), sidobjs.end(), applyParameter<ReSIDfp, double>(&ReSIDfp::filter6581Curve, filterCurve));
}

void DumpSIDBuilder::filter8580Curve(double filterCurve)
{
//	std::for_each(sidobjs.begin(), sidobjs.end(), applyParameter<ReSIDfp, double>(&ReSIDfp::filter8580Curve, filterCurve));
}
