unit XSIDThread;

{$INCLUDE XSID.inc}

interface

uses
{$IFDEF DCC}
	Windows,
{$ENDIF}
	Classes, SyncObjs, C64Types, XSIDTypes, C64Thread, LibReSIDFP;

type
//	TXSIDEventQueue = (reqPattern, reqLFO1, reqLFO2, reqLFO3, reqRealtime);

	TXSIDEventQueueData = record
		Head,
		Tail: PXSIDEvent;
		Count: Integer;
		Next: PXSIDEvent;
		Index: Integer;
		TTL: cycle_count;
	end;

{ TXSIDEventManager }

	TXSIDEventManager = class(TObject)
	protected
//		FLock: TCriticalSection;
//		FQueues: array[TXSIDEventQueue] of TXSIDEventQueueData;
		FQueue: TXSIDEventQueueData;

		procedure DoAddEvent({const AQueue: TXSIDEventQueue;}
				AEvent: PXSIDEvent); {$IFDEF DEF_FNC_XSIDINLNE}inline;{$ENDIF}
		procedure DoClearQueueData{(const AQueue: TXSIDEventQueue)}; {$IFDEF DEF_FNC_XSIDINLNE}inline;{$ENDIF}

	public
		constructor Create;
		destructor  Destroy; override;

//		procedure Lock;
//		procedure Unlock;

		procedure AddEvent({const AQueue: TXSIDEventQueue;}
				const AOffset: cycle_count; const AReg, AValue: reg8);
		procedure InsertEvent({const AQueue: TXSIDEventQueue;}
				const AOffset: cycle_count; const AReg, AValue: reg8);
		procedure CopyEvents({const AQueue: TXSIDEventQueue;}
				const AList: TList);
		procedure ClearEvents(const ARelease: Boolean = True){(const AQueue: TXSIDEventQueue)};
//		procedure ClearAllEvents;
		function  Seek({const AQueue: TXSIDEventQueue; }const AOffset: Integer;
				var AContext: TXSIDContext): Integer;

		procedure Clock(const ATicks: cycle_count; var ADeltaT: cycle_count;
				var AEvents: TXSIDEventArr);
	end;


{ TXSIDStatsThread }
	TXSIDStats = record
		ThsTick,
		DeltaT: cycle_count;
		Perf: TXSIDFloat;
		CmpOffs,
		BufSiz: Integer;
		EvtCnt,
		EvtIdx: Integer;
		Peak: TXSIDFloat;
		Clipped: Boolean;
		fps: Single;
	end;

//	dengland Need an id, as well?
	TXSIDStatsCallback = procedure(const AID: Integer;
			const AStats: TXSIDStats) of object;

	TXSIDStatsThread = class(TThread)
	private
		FLock: TCriticalSection;
		FCallback: TXSIDStatsCallback;
		FID: Integer;
		FStats: TXSIDStats;
		FSleepTime: TXSIDFloat;

		FThen: TDateTime;
		FUpdates: Integer;

	protected
		procedure UpdateMainThread;

		procedure Execute; override;

		procedure UpdateFrontEnd(DeltaT, Ticks: cycle_count; Perf: TXSIDFloat;
				CmpOffs, BufSize, EventCount, EventIdx: Integer;
				peak: TXSIDFloat; clipped: Boolean);

	public
		constructor Create(const AConfig: TXSIDConfig;
				const ACallback: TXSIDStatsCallback; const AID: Integer);
		destructor  Destroy; override;
	end;

{ TXSIDThread }

	TXSIDThread = class(TC64SystemThread)
	private
		FStatsThrd: TXSIDStatsThread;

		FBuf: array[0..15] of SmallInt;
		FBuffer: PArrSmallInt;
		FBufIdx: Integer;

		FSampleRate: Cardinal;
//		FBufferSize,
		FBuffSzDiv2: Cardinal;

	protected
		FAudio: TXSIDAudioRenderer;
		FReSID: Pointer;
		FConfig: TXSIDConfig;
		FEvents: TXSIDEventManager;
		FCallback: TXSIDStatsCallback;
		FID: Integer;
		FEventData: TXSIDEventArr;

		procedure DoConstruction; override;
		procedure DoDestruction; override;
		procedure DoClock(const ATicks: Cardinal); override;
		procedure DoPause; override;
		procedure DoPlay; override;
		procedure UpdateFrontEnd(const ATicks: Cardinal); override;

	public
		constructor Create(const AConfig: TXSIDConfig;
				const ACallback: TXSIDStatsCallback; const AID: Integer = -1;
				const AEvents: TXSIDEventManager = nil);

		procedure SetEnabled(const AVoice: reg8; const AEnable: Boolean);
		procedure SetGain(AValue: reg8);
		procedure RestoreContext(AContext: TXSIDContext);
	end;


var
	GlobalEvents: TXSIDEventManager;
	GlobalXSID: TXSIDThread;

procedure GlobalXSIDStart(const AConfig: TXSIDConfig;
		const ACallback: TXSIDStatsCallback);
procedure GlobalXSIDStop;



implementation

uses
	Math, SysUtils, Forms;


procedure GlobalXSIDStop;
	begin
//	if  Assigned(GlobalController) then
//		begin
//		GlobalController.Terminate;
//		GlobalController.WaitFor;
//		GlobalController.Free;
//		GlobalController:= nil;
//		end;

	if  Assigned(GlobalXSID) then
		begin
		GlobalXSID.Terminate;
		GlobalXSID.WaitFor;
		GlobalXSID.Free;
		GlobalXSID:= nil;
		end;

	if Assigned(GlobalEvents) then
		begin
		GlobalEvents.Free;
		GlobalEvents:= nil;
		end;
	end;

procedure GlobalXSIDStart(const AConfig: TXSIDConfig;
		const ACallback: TXSIDStatsCallback);
	begin
//	GlobalXSIDStop;

	AConfig.Started:= False;
	AConfig.Changed:= False;

	if not Assigned(GlobalEvents) then
		GlobalEvents:= TXSIDEventManager.Create;
//	else
//		GlobalEvents.ClearAllEvents;
//		GlobalEvents.ClearEvents;

	GlobalXSID:= TXSIDThread.Create(AConfig, ACallback, -1);
	GlobalXSID.Priority:= tpTimeCritical;

	while not AConfig.Started do
		begin
		Sleep(100);

{$IFDEF DCC}
		if  MainThreadID = GetCurrentThreadID then
{$ELSE}
		if  MainThreadID = GetThreadID then
{$ENDIF}
			Application.ProcessMessages;
		end;

//	GlobalController:= TXSIDControllerThread.Create(AConfig);
	GlobalXSID.Priority:= tpHigher;

//fixme There needs to be some checking for the startup of the controller
//	Sleep(500);
	end;

{ TXSIDEventManager }

procedure TXSIDEventManager.DoAddEvent({const AQueue: TXSIDEventQueue;}
		AEvent: PXSIDEvent);
	begin
	AEvent^.prev:= FQueue{s[AQueue]}.Tail;
	AEvent^.next:= nil;

	if  Assigned(FQueue{s[AQueue]}.Tail) then
		FQueue{s[AQueue]}.Tail^.next:= AEvent;

	FQueue{s[AQueue]}.Tail:= AEvent;
	if  not Assigned(FQueue{s[AQueue]}.Head) then
		FQueue{s[AQueue]}.Head:= AEvent;

	Inc(FQueue{s[AQueue]}.Count);
	end;

procedure TXSIDEventManager.DoClearQueueData{(const AQueue: TXSIDEventQueue)};
	begin
	FQueue{s[AQueue]}.Head:= nil;
	FQueue{s[AQueue]}.Tail:= nil;
	FQueue{s[AQueue]}.Count:= 0;
	FQueue{s[AQueue]}.Next:= nil;
	FQueue{s[AQueue]}.Index:= -1;
	FQueue{s[AQueue]}.TTL:= 0;
	end;

constructor TXSIDEventManager.Create;
//	var
//	q: TXSIDEventQueue;

	begin
	inherited Create;

//	FLock:= TCriticalSection.Create;

//	for q:= Low(TXSIDEventQueue) to High(TXSIDEventQueue) do
		DoClearQueueData{(q)};
	end;

destructor TXSIDEventManager.Destroy;
	begin
//	ClearAllEvents;
	ClearEvents;

//	FLock.Free;

	inherited Destroy;
	end;

//procedure TXSIDEventManager.Lock;
//	begin
//	FLock.Acquire;
//	end;

//procedure TXSIDEventManager.Unlock;
//	begin
//	FLock.Release;
//	end;

procedure TXSIDEventManager.AddEvent({const AQueue: TXSIDEventQueue;}
		const AOffset: cycle_count; const AReg, AValue: reg8);
	var
	evt: PXSIDEvent;

	begin
	evt:= CreateEvent(AOffset, AReg, AValue);

//	Lock;
//	try
		DoAddEvent({AQueue, }evt);

//		finally
//		Unlock;
//		end;
	end;

procedure TXSIDEventManager.InsertEvent({const AQueue: TXSIDEventQueue;}
		const AOffset: cycle_count; const AReg, AValue: reg8);
	var
	evt: PXSIDEvent;

	begin
	evt:= CreateEvent(AOffset, AReg, AValue);

//	Lock;
//	try
		if  Assigned(FQueue{s[AQueue]}.Next) then
			begin
//			There is a cursor, insert before
//todo 		Need to insert _after_
			evt^.prev:= FQueue{s[AQueue]}.Next;
			evt^.next:= FQueue{s[AQueue]}.Next^.next;
			FQueue{s[AQueue]}.Next^.next:= evt;
			end
		else if Assigned(FQueue{s[AQueue]}.Tail) then
			begin
//			No cursor, but not empty list, insert after last
//todo		Could just call add?
			FQueue{s[AQueue]}.Tail^.next:= evt;
			evt^.prev:= FQueue{s[AQueue]}.Tail;
			evt^.Next:= nil;
			FQueue{s[AQueue]}.Tail:= evt;
			end
		else
			begin
//			No cursor, no list.  Create a new list
//todo		Could just call add?
			evt^.prev:= nil;
			evt^.next:= nil;
			FQueue{s[AQueue]}.Tail:= evt;
			FQueue{s[AQueue]}.Head:= evt;
			end;

		Inc(FQueue{s[AQueue]}.Count);

//		finally
//		Unlock;
//		end;
	end;

procedure TXSIDEventManager.CopyEvents({const AQueue: TXSIDEventQueue;}
		const AList: TList);
	var
	i: Integer;

	begin
//	Lock;
//	try
		for i:= 0 to AList.Count - 1 do
			DoAddEvent({AQueue, }PXSIDEvent(AList[i]));

//		finally
//		Unlock;
//		end;
	end;

procedure TXSIDEventManager.ClearEvents(const ARelease: Boolean){(const AQueue: TXSIDEventQueue)};
	var
	evt,
	dis: PXSIDEvent;

	begin
//	Lock;
//	try
		if  ARelease then
			begin
			evt:= FQueue{s[AQueue]}.Tail;
			if  Assigned(evt) then
				repeat
					dis:= evt;
					evt:= evt^.prev;

					GlobalEventPool.ReleaseEvent(dis);

					until not Assigned(evt);
			end;

		DoClearQueueData{(AQueue)};

//		finally
//		Unlock;
//		end;
	end;

//procedure TXSIDEventManager.ClearAllEvents;
//	var
//	q: TXSIDEventQueue;
//
//	begin
//	Lock;
//	try
//		for q:= Low(TXSIDEventQueue) to High(TXSIDEventQueue) do
//			ClearEvents(q);
//
//		finally
//		Unlock;
//		end;
//	end;

function TXSIDEventManager.Seek({const AQueue: TXSIDEventQueue;}
		const AOffset: Integer; var AContext: TXSIDContext): Integer;
	var
	i: Integer;

	function DoGetNextEvent{(AQueue: TXSIDEventQueue)}: Boolean;
		var
		nxt: PXSIDEvent;

		begin
		if  FQueue{s[AQueue]}.Index < 0 then
			nxt:= FQueue{s[AQueue]}.Head
		else
			nxt:= FQueue{s[AQueue]}.Next^.next;

		if  Assigned(nxt) then
			begin
			FQueue{s[AQueue]}.Next:= nxt;
//			AssignEvent(FThisEvent, FNextEvent^);
			FQueue{s[AQueue]}.TTL:= nxt^.offs;
			Inc(FQueue{s[AQueue]}.Index);

			Result:= True;
			end
		else
			begin
			FQueue{s[AQueue]}.TTL:= 0;
			Result:= False;
			end;
		end;

	begin
	Result:= 0;
//	Lock;
//	try
		FQueue{s[AQueue]}.Index:= -1;
		FQueue{s[AQueue]}.Next:= nil;
		FQueue{s[AQueue]}.TTL:= 0;

//		finally
//		Unlock;
//		end;

	for i:= 0 to High(AContext) do
		begin
		AContext[i].isUsed:= False;
		AContext[i].value:= 0;
		end;


	while  DoGetNextEvent do
		begin
		if  Assigned(FQueue.Next) then
			begin
			if ((Result + FQueue.TTL) > AOffset)  then
				Break;

			AContext[FQueue.Next^.data.reg].isUsed:= True;
			AContext[FQueue.Next^.data.reg].value:= FQueue.Next^.data.val;

			Inc(Result, FQueue.TTL);
			end;
		end;
	end;

procedure TXSIDEventManager.Clock(const ATicks: cycle_count;
		var ADeltaT: cycle_count; var AEvents: TXSIDEventArr);
	var
//	i: TXSIDEventQueue;
//	d: array[TXSIDEventQueue] of Boolean;
	d: Boolean;
	t: cycle_count;

	function DoGetNextEvent{(AQueue: TXSIDEventQueue)}: Boolean;
		var
		nxt: PXSIDEvent;

		begin
		if  FQueue{s[AQueue]}.Index < 0 then
			nxt:= FQueue{s[AQueue]}.Head
		else
			nxt:= FQueue{s[AQueue]}.Next^.next;

		if  Assigned(nxt) then
			begin
			FQueue{s[AQueue]}.Next:= nxt;
//			AssignEvent(FThisEvent, FNextEvent^);
			FQueue{s[AQueue]}.TTL:= nxt^.offs;
			Inc(FQueue{s[AQueue]}.Index);

//todo		Need to instantly write and move to next for any events with 0 offs?

			Result:= True;
			end
		else
			begin
			FQueue{s[AQueue]}.TTL:= 0;
			Result:= False;
			end;
		end;

	procedure DoNextEvent{(const AQueue: TXSIDEventQueue)};
//		var
//		evt: PReSIDEvent;

		begin
//todo	Why do I need this?
		if  Assigned(FQueue{s[AQueue]}.Next) then
			begin
			SetLength(AEvents, Length(AEvents) + 1);
			AEvents[0].reg:= FQueue{s[AQueue]}.Next^.data.reg;
			AEvents[0].val:= FQueue{s[AQueue]}.Next^.data.val;

//			if AQueue <> reqPattern then
//				begin
////				Assert(FQueues[AQueue].Index = 0);
//
//				evt:= FQueues[AQueue].Next;
//
//				FQueues[AQueue].Head:= evt^.next;
//				if Assigned(evt^.next) then
//					evt^.next^.prev:= nil
//				else
//					FQueues[AQueue].Tail:= nil;
//
//				Dec(FQueues[AQueue].Count);
//				Dec(FQueues[AQueue].Index);
//
//				GlobalEventPool.ReleaseEvent(evt);
//
////				DoGetNextEvent(AQueue);
//				end;
			end;
		end;

	procedure DoExpireEvent({const AQueue: TXSIDEventQueue;}
			ATicks: cycle_count);
		var
		doEvent: Boolean;
		doTicks: cycle_count;

		begin
//		Lock;
//		try
			if (ATicks >= FQueue{s[AQueue]}.TTL) then
				begin
//				doTicks:= FQueues[AQueue].TTL;
				doEvent:= True;
				end
			else
				begin
				doTicks:= ATicks;
				Dec(FQueue{s[AQueue]}.TTL, doTicks);
				doEvent:= False;
				end;

//			finally
//			Unlock;
//			end;

		if  doEvent then
			begin
//			Lock;
//			try
				DoNextEvent{(AQueue)};
				DoGetNextEvent{(AQueue)};

//				finally
//				Unlock;
//				end;
			end;

//Hmm..  What's this?  Already commented out...
//		Dec(ATicks, doTicks);
		end;

	begin
	t:= ATicks;
	SetLength(AEvents, 0);

//	Lock;
//	try
//		for i:= Low(TXSIDEventQueue) to High(TXSIDEventQueue) do
			d{[i]}:= FQueue{s[i]}.TTL > 0;

//		for i:= Low(TXSIDEventQueue) to High(TXSIDEventQueue) do
			if  FQueue{s[i]}.TTL = 0 then
				d{[i]}:= DoGetNextEvent{(i)};

//Hmm..  What's this?  Already commented out...
//		d:= FQueues[reqPattern].TTL > 0;

//		for i:= Low(TXSIDEventQueue) to High(TXSIDEventQueue) do
			if d{[i]} then
				if FQueue{s[i]}.TTL < t then
					t:= FQueue{s[i]}.TTL;
//		finally
//		Unlock;
//		end;

	ADeltaT:= t;

//	for i:= Low(TXSIDEventQueue) to High(TXSIDEventQueue) do
//		begin
		if  d{[i]} then
			DoExpireEvent({i, }t);
//Hmm..  What's this?  Already commented out...
//		else
//			Dec(FThsTick);
//		end;
	end;



{ TXSIDStatsThread }

procedure TXSIDStatsThread.UpdateMainThread;
	var
//	s: string;
	hr1,
	hr2,
	mn1,
	mn2,
	sc1,
	sc2,
	ms1,
	ms2: Word;
	msn,
	mst,
	msd: Cardinal;

	begin
	FLock.Acquire;
	try
		Inc(FUpdates);

		DecodeTime(FThen, hr1, mn1, sc1, ms1);
		DecodeTime(Now, hr2, mn2, sc2, ms2);

		mst:= hr1 * 60 * 60 * 1000 + mn1 * 60 * 1000 + sc1 * 1000 + ms1;
		msn:= hr2 * 60 * 60 * 1000 + mn2 * 60 * 1000 + sc2 * 1000 + ms2;
		msd:= msn - mst;

		if  msd > 1000 then
			begin
			FStats.fps:= FUpdates / msd * 1000;

			FThen:= Now;
			FUpdates:= 0;
			end;
//		else
//			FStats.fps:= -1;

		if  Assigned(FCallback) then
			FCallback(FID, FStats);

		FStats.ThsTick:= 0;

		finally
		FLock.Release;
		end;
	end;

procedure TXSIDStatsThread.Execute;
	begin
	while not Terminated do
		begin
		Synchronize(UpdateMainThread);

		Sleep(Round(FSleepTime));
		end;
	end;

constructor TXSIDStatsThread.Create(const AConfig: TXSIDConfig;
		const ACallback: TXSIDStatsCallback; const AID: Integer);
	begin
	FLock:= TCriticalSection.Create;

	FStats.fps:= -1.0;
	FStats.ThsTick:= 0;
	FCallback:= ACallback;
	FID:= AID;

	FThen:= Now;
	FUpdates:= 0;

	FSleepTime:= 1 / (ARR_VAL_SYSRFRSHPS[AConfig.System] / 1000);

	inherited Create(False);
	FreeOnTerminate:= True;
	end;

destructor TXSIDStatsThread.Destroy;
	begin
//	FLogFile.Free;
	FLock.Free;

	inherited Destroy;
	end;

procedure TXSIDStatsThread.UpdateFrontEnd(DeltaT, Ticks: cycle_count;
		Perf: TXSIDFloat; CmpOffs, BufSize, EventCount, EventIdx: Integer;
		peak: TXSIDFloat; clipped: Boolean);
	begin
//	if  FLock.TryEnter then
	FLock.Acquire;
		try
			FStats.DeltaT:= DeltaT;
			FStats.ThsTick:= FStats.ThsTick + Ticks;
			FStats.Perf:= Perf;
			FStats.CmpOffs:= CmpOffs;
			FStats.BufSiz:= BufSize;
			FStats.EvtCnt:= EventCount;
			FStats.EvtIdx:= EventIdx;
			FStats.Peak:= peak;
			FStats.Clipped:= clipped;

			finally
			FLock.Release;
			end;
	end;

{ TXSIDThread }

procedure TXSIDThread.DoConstruction;
	var
	sl: TStringList;
	r: TXSIDAudioRendererClass;
	rm: TRoundingMode;

	begin
	FName:= 'XSID';

	rm:= GetRoundMode;
//	SetRoundMode(rmNearest);

//	Hmm...
	FConfig.Lock;
	try
		FSampleRate:= ARR_VAL_SAMPLERATE[FConfig.SampleRate];

//FIXME There is a possibility that we won't have a size number of samples per frame
//      and will there by end up with overflow into the next buffer.  We need to
//      handle that properly.

//		FBufferSize:= ARR_VAL_BUFFERSIZE[FConfig.BufferSize];
//		FBufferSize:= Round(FSampleRate / Round(ARR_VAL_SYSRFRSHPS[FConfig.System]) *
//				ARR_VAL_BUFFERFACT[FConfig.BufferSize]);
//		FBuffSzDiv2:= FBufferSize div 2;
		FBuffSzDiv2:= Round(FSampleRate / Round(ARR_VAL_SYSRFRSHPS[FConfig.System]) *
				ARR_VAL_BUFFERFACT[FConfig.BufferSize]) div 2;

		finally
		FConfig.Unlock;
		end;

//	Lock;
//	try
//dengland This code uses C-style floating point handling and needs the
//		exceptions masked.  I wonder if I should store the previous mask and
//		restore it?

//      I don't think the code needs this anymore.
//		SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide,
//				exOverflow, exUnderflow, exPrecision]);

		sl:= TStringList.Create;
		try
			r:= GlobalRenderers.ItemByName(FConfig.Renderer);
			if  not Assigned(r) then
				begin
				r:= GlobalRenderers.DefaultRenderer;
				r.FillParameterNames(sl);
				end
			else
				sl.AddStrings(FConfig.GetRenderParams);

			FAudio:= r.Create(FConfig.SampleRate,
					Round(ARR_VAL_SYSRFRSHPS[FConfig.System]), FConfig.BufferSize,
					sl, FBuffer);

			finally
			sl.Free;
			end;

		FFreeRun:= not FAudio.GetIsRealTime;

		SetLength(FEventData, 0);

		FReSID:= ReSIDCreate;
		ReSIDSetSamplingParameters(FReSID, ARR_VAL_SYSCYCPSEC[FConfig.System],
				Ord(FConfig.Interpolation), FSampleRate, {16384} 0.9 * FSampleRate / 2);
		ReSIDSetChipModel(FReSID, Ord(FConfig.Model));

		ReSIDSetFilter6581Curve(FReSID, FConfig.Filter6581);
		ReSIDSetFilter8580Curve(FReSID, FConfig.Filter8580);

		ReSIDEnableFilter(FReSID, FConfig.FilterEnable);

		if  (FConfig.Model = csmMOS8580)
		and (FConfig.DigiBoostEnable) then
			ReSIDInput(FReSID, Integer(INPUT_BOOST))
		else
			ReSIDInput(FReSID, 0);

		FStatsThrd:= TXSIDStatsThread.Create(FConfig, FCallback, FID);

//		finally
//		Unlock;
//		end;

	SetRoundMode(rm);

	FConfig.Started:= True;
	end;

procedure TXSIDThread.DoDestruction;
	begin
//	Not sure if I need to lock it really...
//	FLock.Acquire;
//	try
		if  FAudio.RequireAllData
		and (FBufIdx > 0) then
			FAudio.TransferBuffer(FBuffer, FBufIdx);

		SetLength(FEventData, 0);

		FAudio.Free;

		FStatsThrd.Terminate;
//		FStatsThrd.WaitFor;
//		FStatsThrd.Free;

		ReSIDDestroy(FReSID);

//		finally
//		FLock.Release;
//		end;
	end;

procedure TXSIDThread.DoPause;
	begin
	FConfig.Started:= False;
	FAudio.Pause(FBuffer);
	end;

procedure TXSIDThread.DoPlay;
	begin
	FConfig.Started:= True;
	FAudio.Play(FBuffer);
	end;

procedure TXSIDThread.RestoreContext(AContext: TXSIDContext);
	var
	i: Integer;

	begin
//FIXME  This may still result in some oddities sometimes.  We need to do something
//		sensible with the registers, taking into consideration what they are used
//		for.

//FIXME  We may also need to check if we can actually fit two clocks into the audio
//      buffer...

//	FAudio.SwapBuffers(FBuffer);
//	FBufIdx:= 0;

	for i:= 0 to High(AContext) do
		if  not AContext[i].isUsed then
			begin
			ReSIDWrite(FReSID, i, 0);
			{FBufIdx:= FBufIdx + }ReSIDClock(FReSID, 2, @(FBuf[0]));
			end;

	for i:= 0 to High(AContext) do
		if  AContext[i].isUsed then
			begin
			ReSIDWrite(FReSID, i, AContext[i].value);
			{FBufIdx:= FBufIdx + }ReSIDClock(FReSID, 2, @(FBuf[0]));
			end;
	end;

procedure TXSIDThread.DoClock(const ATicks: Cardinal);
	var
	t: cycle_count;
	i,
	j: Integer;
//	doEvent: Boolean;

	begin
//	doEvent:= False;

//	UpdateFrontEnd;

//	FLstTick:= FThsTick;
	FLstTick:= ATicks;
	while (FLstTick > 0) and (not Terminated) do
		begin
		FEvents.Clock(FLstTick, t, FEventData);
		Dec(FLstTick, t);

		UpdateFrontEnd(t);

		while (t > 0) and (not Terminated) do
			begin
//			FBufIdx:= FBufIdx + FReSID.clock(t,
//					@(FBuf[FBufIdx]), Integer(FBuffSzDiv2) - FBufIdx);

//			j:= ReSIDClock(FReSID, 1, @(FBuffer[FBufIdx]));
			j:= ReSIDClock(FReSID, 1, @(FBuf[0]));

			if  Cardinal(FBufIdx + j) >= FBuffSzDiv2 then
//			if  (FRefreshCnt = FRefreshUpd)
//			and (FBufIdx >= 2048) then
				begin
//				FAudio.TransferBuffer(@FBuffer, FBufIdx);
				FAudio.SwapBuffers(FBuffer, FBufIdx * 2);
				FBufIdx:= 0;
//				UpdateFrontEnd;
				end;

			if j > 0 then
				begin
				Move(FBuf[0], FBuffer[FBufIdx], j * 2);
				Inc(FBufIdx, j);
				end;

			Dec(FLstTick, 1);
			Dec(t, 1);
			end;

		if  Length(FEventData) > 0 then
			begin
//			Lock;
//			try
				for i:= 0 to High(FEventData) do
//					FReSID.write(FEventData[i].reg, FEventData[i].val);
					ReSIDWrite(FReSID, FEventData[i].reg, FEventData[i].val);

//				finally
//				Unlock;
//				end;
			end;
		end;

	FThsTick:= 0;
	end;

procedure TXSIDThread.UpdateFrontEnd(const ATicks: Cardinal);
	var
	p: Single;

	begin
//	Lock;
//	try
		p:= (Integer(FCycPSec) - Integer(ATicks)) / Integer(FCycPSec) * 100;

		FStatsThrd.UpdateFrontEnd(FLstTick, ATicks, p,  FCmpOffs, FBufIdx,
//				FThsTick, FLstTick, FReSID.peakoutput, FReSID.clipped);
				ATicks, FLstTick, 0, False);

//		FReSID.peakoutput:= 0;
//		FReSID.clipped:= False;

//		finally
//		Unlock;
//		end;
	end;

constructor TXSIDThread.Create(const AConfig: TXSIDConfig;
		const ACallback: TXSIDStatsCallback; const AID: Integer;
		const AEvents: TXSIDEventManager);
	begin
	FConfig:= AConfig;
	FCallback:= ACallback;
	FID:= AID;
	if  not Assigned(AEvents) then
		FEvents:= GlobalEvents
	else
		FEvents:= AEvents;

	inherited Create(FConfig.System, FConfig.UpdateRate);

	FreeOnTerminate:= True;
	end;

procedure TXSIDThread.SetEnabled(const AVoice: reg8; const AEnable: Boolean);
	begin
//	Lock;
//	try
//FIXME
//		FReSID.SetEnableVoice(AVoice, AEnable);

//		finally
//		Unlock;
//		end;
	end;

procedure TXSIDThread.SetGain(AValue: reg8);
	begin
//	Lock;
//	try
//FIXME?
//		FReSID.write_gain(AValue);

//		finally
//		Unlock;
//		end;
	end;

end.

