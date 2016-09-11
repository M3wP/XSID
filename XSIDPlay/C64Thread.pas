unit C64Thread;

{$IFDEF FPC}
	{$MODE DELPHI}
{$ENDIF}
{$H+}

interface

uses
	Classes, SyncObjs, C64Types;

type
{ TC64SystemThread }

	TC64SystemThread = class(TThread)
	protected
//		FLock: TCriticalSection;
		FRunSignal: TLightweightEvent;
		FPausedSignal: TLightweightEvent;

		FWasPaused: Boolean;

		FCycPSec: Cardinal;
		FIntrval: Double;

		FCycPUpd: TC64Float;
		FCycResidual: TC64Float;

		FRefreshCnt: Integer;
		FRefreshUpd: Integer;
		FCycRefresh: Cardinal;

		FThsDiff,
		FLstIntrv,
		FThsIntrv,
		FThsComp,
		FLstCompI: Double;

		FCmpOffs,
		FCmpTick: cycle_count;

		FLstTick,
		FThsTick: cycle_count;

		FName: string;

		procedure DoConstruction; virtual; abstract;
		procedure DoDestruction; virtual; abstract;
		procedure DoClock(const ATicks: Cardinal); virtual; abstract;
		procedure DoPause; virtual; abstract;
		procedure DoPlay; virtual; abstract;

		procedure UpdateFrontEnd(const ATicks: Cardinal); virtual;

		procedure Execute; override;

	public
		constructor Create(const ASystemType: TC64SystemType;
				const AUpdateRate: TC64UpdateRate);
		destructor  Destroy; override;

		property  RunSignal: TLightweightEvent read FRunSignal;
		property  PausedSignal: TLightweightEvent read FPausedSignal;

//		procedure Lock;
//		procedure Unlock;
	end;


implementation

uses
	SysUtils;

{ TC64SystemThread }

procedure TC64SystemThread.UpdateFrontEnd(const ATicks: Cardinal);
	begin

	end;

procedure TC64SystemThread.Execute;
	var
	doCycles: TC64Float;
	doTicks: cycle_count;

	begin
//	FLock:= TCriticalSection.Create;
	FRunSignal:= TLightweightEvent.Create;
	FRunSignal.SetEvent;

	FPausedSignal:= TLightweightEvent.Create;
	FPausedSignal.ResetEvent;

//	doTicks:= 0;

	FThsTick:= 0;
	FLstTick:= 0;

	FCmpOffs:= 0;
	FCmpTick:= 0;

	FCycResidual:= 0;
	FRefreshCnt:= 0;

//	It seems that we have to call this here.  See the constructor.
	DoConstruction;

	FLstIntrv:= C64TimerGetTime;
	FLstCompI:= FLstIntrv;

	while not Terminated do
		begin
		FThsIntrv:= C64TimerGetTime;

		FThsDiff:= FThsIntrv - FLstIntrv;
		if  FThsDiff < 0 then
			begin
//			UpdateFrontEnd;
			Continue;
			end;

		doCycles:= FCycPUpd + FCycResidual;
		doTicks:= Trunc(doCycles);
		FCycResidual:= doCycles - doTicks;

		if  FRunSignal.IsSet then
			begin
			if  FWasPaused then
				begin
				FWasPaused:= False;
				DoPlay;
				end;
			DoClock(doTicks);
			end
		else if not FPausedSignal.IsSet then
			begin
			FWasPaused:= True;
			FPausedSignal.SetEvent;
			DoPause;
			end
		else
			FRunSignal.WaitFor(100);

		Inc(FRefreshCnt);
		if  FRefreshCnt > FRefreshUpd then
			begin
			FRefreshCnt:= 0;

			FThsIntrv:= C64TimerGetTime;
			FThsDiff:= FThsIntrv - FLstIntrv;

			FThsTick:= Round(FThsDiff / FIntrval);
			Dec(FThsTick, FCycRefresh);

//			UpdateFrontEnd;
			if  FThsTick <= 0 then
				begin
				FLstIntrv:= FThsIntrv;
				Continue;
				end
			else
				begin
				Sleep(Trunc(FThsTick * FIntrval));
//				C64Wait(Abs(FThsTick) * FIntrval);
				FLstIntrv:= C64TimerGetTime;
				end;
			end;
		end;

	DoDestruction;
	FPausedSignal.Free;
	FRunSignal.Free;
//	FLock.Free;
	end;

constructor TC64SystemThread.Create(const ASystemType: TC64SystemType;
		const AUpdateRate: TC64UpdateRate);
	begin
//	We can't call DoConstruction here because the memory doesn't seem to get
//		allocated in a way in which we can use it if we do...  Annoying.

	FRefreshUpd:= 1 shl Ord(AUpdateRate);
	FCycRefresh:= Trunc(ARR_VAL_SYSCYCPRFS[ASystemType]);
	FCycPUpd:= FCycRefresh / FRefreshUpd;

	FCycPSec:= ARR_VAL_SYSCYCPSEC[ASystemType];
	FIntrval:= (1 / FCycPSec);

	inherited Create(False);
	end;

destructor TC64SystemThread.Destroy;
	begin
//	Don't call DoDestruction here because we aren't calling DoConstruction in
//		the constructor.

	inherited Destroy;
	end;

//procedure TC64SystemThread.Lock;
//	begin
//	FLock.Acquire;
//	end;

//procedure TC64SystemThread.Unlock;
//	begin
//	FLock.Release;
//	end;

end.

