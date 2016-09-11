#ifndef DUMPSID_H
#define DUMPSID_H

#include <stdint.h>

//#include "SID.h"
#include "SidConfig.h"
#include "sidemu.h"
#include "event.h"

#include <iostream>
#include <fstream>


class sidbuilder;

//#define RESID_NAMESPACE reSIDfp

class DumpSID : public sidemu
{
private:
//	RESID_NAMESPACE::SID &m_sid;

	int m_ticks = 0;

	std::ofstream* m_ofile;

public:
	static const char* getCredits();

public:
	DumpSID(sidbuilder *builder, char *fileName);
	~DumpSID();

	// Standard component functions
	void reset() { sidemu::reset(); }
	void reset(uint8_t volume);

	uint8_t read(uint_least8_t addr);
	void write(uint_least8_t addr, uint8_t data);

	// Standard SID functions
	void clock();
	void filter(bool enable);
	void voice(unsigned int num, bool mute) { /* m_sid.mute(num, mute); */ }

	bool getStatus() const { return m_status; }

	// Specific to resid
	void sampling(float systemclock, float freq,
		SidConfig::sampling_method_t method, bool fast);

	void filter6581Curve(double filterCurve);
	void filter8580Curve(double filterCurve);
	void model(SidConfig::sid_model_t model);
};

#endif // DUMPSID_H