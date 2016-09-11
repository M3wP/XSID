{$IFDEF FPC}
	{$MODE DELPHI}
	{$DEFINE DEF_FNC_RESIDINLNE}

	{$IFDEF UNIX}
		{$DEFINE USECTHREADS}
	{$ENDIF}
{$ELSE}
	{$DEFINE DEF_FNC_RESIDINLNE}
//Delphi can have an internal error when inlines are on for these units
	{.UNDEF DEF_FNC_RESIDINLNE}
{$ENDIF}

{$H+}

