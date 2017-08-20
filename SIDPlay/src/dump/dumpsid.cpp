#include "dumpsid.h"

#include <sstream>
#include <string>
#include <algorithm>
#include <iostream>
#include <fstream>

//#include "residfp/siddefs-fp.h"
#include "siddefs.h"

#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif

const char* DumpSID::getCredits()
{
	if (m_credit.empty())
	{
		// Setup credits
		std::ostringstream ss;
		ss << "DumpSID (C) 2015 Daniel England\n";
		m_credit = ss.str();
	}

	return m_credit.c_str();
}

DumpSID::DumpSID(sidbuilder *builder, char *fileName) :
sidemu(builder)
//m_sid(*(new RESID_NAMESPACE::SID))
{
	m_buffer = new short[OUTPUTBUFFERSIZE];

	m_ofile = new std::ofstream(fileName);

	reset(0);
}

DumpSID::~DumpSID()
{
//	delete &m_sid;
	delete[] m_buffer;
	m_ofile->flush();
	delete m_ofile;
}

void DumpSID::filter6581Curve(double filterCurve)
{
//	m_sid.setFilter6581Curve(filterCurve);
}

void DumpSID::filter8580Curve(double filterCurve)
{
//	m_sid.setFilter8580Curve(filterCurve);
}

// Standard component options
void DumpSID::reset(uint8_t volume)
{
	m_accessClk = 0;

	m_ticks = 0;

//	m_sid.reset();
//	m_sid.write(0x18, volume);
}

uint8_t DumpSID::read(uint_least8_t addr)
{
	clock();
//	return m_sid.read(addr);
	return 0xFF;
}

void DumpSID::write(uint_least8_t addr, uint8_t data)
{
	clock();
//	m_sid.write(addr, data);

	*m_ofile << m_ticks << " " << (int)addr << " " << (int)data << "\n";

	m_ticks = 0;
}

void DumpSID::clock()
{
	const event_clock_t cycles = m_context->getTime(m_accessClk, EVENT_CLOCK_PHI1);
	m_accessClk += cycles;
//	m_bufferpos += m_sid.clock(cycles, m_buffer + m_bufferpos);

	m_ticks += cycles;
}

void DumpSID::filter(bool enable)
{
//	m_sid.enableFilter(enable);
}

void DumpSID::sampling(float systemclock, float freq,
	SidConfig::sampling_method_t method, bool fast SID_UNUSED)
{
/*	reSIDfp::SamplingMethod sampleMethod;
	switch (method)
	{
	case SidConfig::INTERPOLATE:
		sampleMethod = reSIDfp::DECIMATE;
		break;
	case SidConfig::RESAMPLE_INTERPOLATE:
		sampleMethod = reSIDfp::RESAMPLE;
		break;
	default:
		m_status = false;
		m_error = ERR_INVALID_SAMPLING;
		return;
	}

	try
	{
		// Round half frequency to the nearest multiple of 5000
		const int halfFreq = 5000 * ((static_cast<int>(freq)+5000) / 10000);
		m_sid.setSamplingParameters(systemclock, sampleMethod, freq, std::min(halfFreq, 20000));
	}
	catch (RESID_NAMESPACE::SIDError const &e)
	{
		m_status = false;
		m_error = ERR_UNSUPPORTED_FREQ;
		return;
	}*/

	m_status = true;
}

// Set the emulated SID model
void DumpSID::model(SidConfig::sid_model_t model)
{
/*	reSIDfp::ChipModel chipModel;
	switch (model)
	{
	case SidConfig::MOS6581:
		chipModel = reSIDfp::MOS6581;
		break;
	case SidConfig::MOS8580:
		chipModel = reSIDfp::MOS8580;
		break;
	default:
		m_status = false;
		m_error = ERR_INVALID_CHIP;
		return;
	}

	m_sid.setChipModel(chipModel);*/
	m_status = true;
}
