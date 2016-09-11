#ifndef DUMPSID_BUILDER_H
#define DUMPSID_BUILDER_H

#include "sidbuilder.h"
#include "siddefs.h"

/**
* ReSIDfp Builder Class
*/
class SID_EXTERN DumpSIDBuilder : public sidbuilder
{
private:
	char *m_fileName;

public:
	DumpSIDBuilder(const char * const name) :
		sidbuilder(name) {}
	~DumpSIDBuilder();

	void setFileName(char *fileName);

	/**
	* Available sids.
	*
	* @return the number of available sids, 0 = endless.
	*/
	unsigned int availDevices() const { return 1; }

	/**
	* Create the sid emu.
	*
	* @param sids the number of required sid emu
	*/
	unsigned int create(unsigned int sids);

	const char *credits() const;

	/// @name global settings
	/// Settings that affect all SIDs.
	//@{
	/**
	* enable/disable filter.
	*/
	void filter(bool enable);

	/**
	* Set 6581 filter curve.
	*
	* @param filterCurve from 0.0 (light) to 1.0 (dark) (default 0.5)
	*/
	void filter6581Curve(double filterCurve);

	/**
	* Set 8580 filter curve.
	*
	* @param filterCurve curve center frequency (default 12500)
	*/
	void filter8580Curve(double filterCurve);
	//@}
};

#endif // DUMPSID_BUILDER_H
