unit LibReSIDFP;

interface

const
	MODEL_MOS6581 = 1;
	MODEL_MOS8580 = 2;

	SAMPLE_DECIMATE = 1;
	SAMPLE_RESAMPLE  = 2;

	FILTER_DISABLE: LongBool = False;
	FILTER_ENABLE: LongBool = True;

//  This is supposed to be a SmallInt but I can't get that to work.  -800 seems to be
//      about the correct value.  Was it actually -824 or something?  Where did I
//		read that?
//	INPUT_BOOST: SmallInt = -800;
	INPUT_BOOST = $FFFFFCE0;


function  ReSIDCreate: Pointer; stdcall;
		external 'LibReSIDFP.dll' name '_ReSIDCreate@0';
procedure ReSIDDestroy(reSID: Pointer); stdcall;
		external 'LibReSIDFP.dll' name '_ReSIDDestroy@4';
procedure ReSIDWrite(reSID: Pointer; offset: Integer; value: Byte); stdcall;
		external 'LibReSIDFP.dll' name '_ReSIDWrite@12';
function  ReSIDClock(reSID: Pointer; cycles: Integer; buf: PSmallInt): Integer; stdcall;
		external 'LibReSIDFP.dll' name '_ReSIDClock@12';
procedure ReSIDSetSamplingParameters(reSID: Pointer; clockFrequency: Double;
		method: Integer; samplingFrequency, highestAccurateFrequency: Double); stdcall;
		external 'LibReSIDFP.dll' name '_ReSIDSetSamplingParameters@32';
procedure ReSIDSetChipModel(reSID: Pointer; model: Integer); stdcall;
		external 'LibReSIDFP.dll' name '_ReSIDSetChipModel@8';
procedure ReSIDSetFilter6581Curve(reSID: Pointer; curve: Double); stdcall;
		external 'LibReSIDFP.dll' name '_ReSIDSetFilter6581Curve@12';
procedure ReSIDSetFilter8580Curve(reSID: Pointer; curve: Double); stdcall;
		external 'LibReSIDFP.dll' name '_ReSIDSetFilter8580Curve@12';
procedure ReSIDEnableFilter(reSID: Pointer; enable: LongBool); stdcall;
		external 'LibReSIDFP.dll' name '_ReSIDEnableFilter@8';
procedure ReSIDInput(reSID: Pointer; value: Integer); stdcall;
		external 'LibReSIDFP.dll' name '_ReSIDInput@8';
procedure ReSIDClockSilent(reSID: Pointer; cycles: Integer); stdcall;
		external 'LibReSIDFP.dll' name '_ReSIDClockSilent@8';


implementation

end.
