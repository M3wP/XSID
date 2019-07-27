unit ReSIDFP;

{$IFDEF FPC}
	{$IFDEF CPU64}
		{$DEFINE DEF_RESIDFP_CPU64}
	{$ELSE}
		{$DEFINE DEF_RESIDFP_CPU32}
	{$ENDIF}
{$ELSE}
	{$IFDEF CPU64BITS}
		{$DEFINE DEF_RESIDFP_CPU64}
	{$ELSE}
		{$DEFINE DEF_RESIDFP_CPU32}
	{$ENDIF}
{$ENDIF}

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

{$IFNDEF MSWINDOWS}
	LIB_RESID = 'ReSIDFP';

	{$LINKLIB ReSIDFP.so}

{$ELSE}
	LIB_RESID = 'LibReSIDFP.dll';
{$ENDIF}


{$IFDEF DEF_RESIDFP_CPU64}
function  ReSIDCreate: Pointer; external LIB_RESID;
procedure ReSIDDestroy(reSID: Pointer); external LIB_RESID;
procedure ReSIDWrite(reSID: Pointer; offset: Integer; value: Byte); external LIB_RESID;
function  ReSIDClock(reSID: Pointer; cycles: Integer; buf: PSmallInt): Integer; external LIB_RESID;
procedure ReSIDSetSamplingParameters(reSID: Pointer; clockFrequency: Double;
		method: Integer; samplingFrequency, highestAccurateFrequency: Double); external LIB_RESID;
procedure ReSIDSetChipModel(reSID: Pointer; model: Integer); external LIB_RESID;
procedure ReSIDSetFilter6581Curve(reSID: Pointer; curve: Double); external LIB_RESID;
procedure ReSIDSetFilter8580Curve(reSID: Pointer; curve: Double); external LIB_RESID;
procedure ReSIDEnableFilter(reSID: Pointer; enable: LongBool); external LIB_RESID;
procedure ReSIDInput(reSID: Pointer; value: Integer); external LIB_RESID;
procedure ReSIDClockSilent(reSID: Pointer; cycles: Integer); external LIB_RESID;
procedure ReSIDMute(reSID: Pointer; channel: Integer; enable: LongBool); external LIB_RESID;
{$ELSE}
{$IFDEF MSWINDOWS}
function  ReSIDCreate: Pointer; stdcall; external LIB_RESID name '_ReSIDCreate@0';
procedure ReSIDDestroy(reSID: Pointer); stdcall; external LIB_RESID name '_ReSIDDestroy@4';
procedure ReSIDWrite(reSID: Pointer; offset: Integer; value: Byte); stdcall; external LIB_RESID name '_ReSIDWrite@12';
function  ReSIDClock(reSID: Pointer; cycles: Integer; buf: PSmallInt): Integer; stdcall; external LIB_RESID name '_ReSIDClock@12';
procedure ReSIDSetSamplingParameters(reSID: Pointer; clockFrequency: Double;
		method: Integer; samplingFrequency, highestAccurateFrequency: Double); stdcall; external LIB_RESID name '_ReSIDSetSamplingParameters@32';
procedure ReSIDSetChipModel(reSID: Pointer; model: Integer); stdcall; external LIB_RESID name '_ReSIDSetChipModel@8';
procedure ReSIDSetFilter6581Curve(reSID: Pointer; curve: Double); stdcall; external LIB_RESID name '_ReSIDSetFilter6581Curve@12';
procedure ReSIDSetFilter8580Curve(reSID: Pointer; curve: Double); stdcall; external LIB_RESID name '_ReSIDSetFilter8580Curve@12';
procedure ReSIDEnableFilter(reSID: Pointer; enable: LongBool); stdcall; external LIB_RESID name '_ReSIDEnableFilter@8';
procedure ReSIDInput(reSID: Pointer; value: Integer); stdcall; external LIB_RESID name '_ReSIDInput@8';
procedure ReSIDClockSilent(reSID: Pointer; cycles: Integer); stdcall; external LIB_RESID name '_ReSIDClockSilent@8';
procedure ReSIDMute(reSID: Pointer; channel: Integer; enable: LongBool); stdcall; external LIB_RESID name '_ReSIDMute@12';
{$ELSE}
function  ReSIDCreate: Pointer; stdcall; external LIB_RESID;
procedure ReSIDDestroy(reSID: Pointer); stdcall; external LIB_RESID;
procedure ReSIDWrite(reSID: Pointer; offset: Integer; value: Byte); stdcall; external LIB_RESID;
function  ReSIDClock(reSID: Pointer; cycles: Integer; buf: PSmallInt): Integer; stdcall; external LIB_RESID;
procedure ReSIDSetSamplingParameters(reSID: Pointer; clockFrequency: Double;
				method: Integer; samplingFrequency, highestAccurateFrequency: Double); stdcall; external LIB_RESID;
procedure ReSIDSetChipModel(reSID: Pointer; model: Integer); stdcall; external LIB_RESID;
procedure ReSIDSetFilter6581Curve(reSID: Pointer; curve: Double); stdcall; external LIB_RESID;
procedure ReSIDSetFilter8580Curve(reSID: Pointer; curve: Double); stdcall; external LIB_RESID;
procedure ReSIDEnableFilter(reSID: Pointer; enable: LongBool); stdcall; external LIB_RESID;
procedure ReSIDInput(reSID: Pointer; value: Integer); stdcall; external LIB_RESID;
procedure ReSIDClockSilent(reSID: Pointer; cycles: Integer); stdcall; external LIB_RESID;
procedure ReSIDMute(reSID: Pointer; channel: Integer; enable: LongBool); stdcall; external LIB_RESID;
{$ENDIF}
{$ENDIF}

implementation

end.
