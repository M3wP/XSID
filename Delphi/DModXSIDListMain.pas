unit DModXSIDListMain;

interface

uses
	System.SysUtils, System.Classes, Vcl.Graphics, Vcl.ExtCtrls, Vcl.Dialogs,
	System.Actions, Vcl.ActnList, Vcl.Menus, SyncObjs, C64Types, XSIDTypes,
	XSIDFiles, XSIDThread, VirtualTrees;

type
	TXSIDListMainDMod = class(TDataModule)
		Timer1: TTimer;
		OpenDialog1: TOpenDialog;
		MainMenu1: TMainMenu;
		File1: TMenuItem;
		Open1: TMenuItem;
		Edit1: TMenuItem;
		View1: TMenuItem;
		Filter1: TMenuItem;
		Voice11: TMenuItem;
		Voice21: TMenuItem;
		Voice31: TMenuItem;
		Filter2: TMenuItem;
		Tools1: TMenuItem;
		CreateDump1: TMenuItem;
		Options1: TMenuItem;
		PlayRate1: TMenuItem;
		N1001: TMenuItem;
		N501: TMenuItem;
		N251: TMenuItem;
		Help1: TMenuItem;
		ActionList1: TActionList;
		ActFileOpen: TAction;
		ActViewVoice1: TAction;
		ActViewVoice2: TAction;
		ActViewVoice3: TAction;
		ActViewFilter: TAction;
		ActOptionsPlay50PC: TAction;
		ActOptionsPlay100PC: TAction;
		ActToolsCreateDump: TAction;
		ActOptionsPlay25PC: TAction;
		SaveDialog1: TSaveDialog;
		ActOptionsMuteVoice1: TAction;
		ActOptionsMuteVoice2: TAction;
		ActOptionsMuteVoice3: TAction;
		ActOptionsMuteFilter: TAction;
		PlayMute1: TMenuItem;
		Voice12: TMenuItem;
		Voice22: TMenuItem;
		Voice32: TMenuItem;
		Filter3: TMenuItem;
		procedure Timer1Timer(Sender: TObject);
		procedure ActFileOpenExecute(Sender: TObject);
		procedure ActOptionsPlay50PCExecute(Sender: TObject);
		procedure ActOptionsPlay50PCUpdate(Sender: TObject);
		procedure ActOptionsPlay100PCExecute(Sender: TObject);
		procedure ActOptionsPlay100PCUpdate(Sender: TObject);
		procedure ActOptionsPlay25PCExecute(Sender: TObject);
		procedure ActOptionsPlay25PCUpdate(Sender: TObject);
		procedure ActToolsCreateDumpExecute(Sender: TObject);
		procedure ActViewVoice1Execute(Sender: TObject);
		procedure ActOptionsMuteVoice1Update(Sender: TObject);
		procedure ActOptionsMuteVoice2Update(Sender: TObject);
		procedure ActOptionsMuteVoice3Update(Sender: TObject);
		procedure ActOptionsMuteFilterUpdate(Sender: TObject);
		procedure ActOptionsMuteVoice1Execute(Sender: TObject);
	private
		FPlayClr: Integer;
		FXSIDConfig: TXSIDFileConfig;
		FPlayConfig: TXSIDConfig;
		FEvents: TList;
		FPlaying: Boolean;
		FStartNode,
		FNowNode: PVirtualNode;
		FFiltering: Boolean;
		FFilterRegs: TXSIDRegisters;
		FTotalTime: Cardinal;

		procedure DoUpdateEventFilter;
		procedure DoUpdateVoiceMute;

		procedure SetNowNode(const ANode: PVirtualNode);
		procedure SetStartNode(const ANode: PVirtualNode);

	protected
		procedure DoLoadFile(const AFileName: string);
		procedure LoadCallback(const AStage: TXSIDFileStage;
				const APosition, ASize: Int64);
		procedure StatsCallback(const AID: Integer; const AStats: TXSIDStats);

	public
		constructor Create(AOwner: TComponent); override;
		destructor  Destroy; override;

		procedure StartPlay;
		procedure StopPlay;

		property  XSIDConfig: TXSIDFileConfig read FXSIDConfig;
		property  PlayConfig: TXSIDConfig read FPlayConfig;
		property  Events: TList read FEvents;
		property  Playing: Boolean read FPlaying;
		property  StartNode: PVirtualNode read FStartNode write SetStartNode;
		property  NowNode: PVirtualNode read FNowNode;

		property  Filtering: Boolean read FFiltering;
		property  FilterRegs: TXSIDRegisters read FFilterRegs;
	end;


var
  XSIDListMainDMod: TXSIDListMainDMod;


implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}


{$R *.dfm}

uses
	Vcl.Forms, Vcl.ComCtrls, FormFileLoad, FormXSIDListMain, FormFindEvents,
	FormFilterView;


const
	ARR_VAL_CLR_PLAY: array[0..6] of TColor =
			(clWhite, clSilver, clMedGray, clGray, clGray, clMedGray, clSilver);


procedure TXSIDListMainDMod.ActFileOpenExecute(Sender: TObject);
	begin
	if not OpenDialog1.Execute then
		Exit;

	GlobalXSIDStop;

	FileLoadForm:= TFileLoadForm.Create(Application.MainForm);
	try
		FileLoadForm.Show;
		Application.ProcessMessages;

		GlobalEvents:= TXSIDEventManager.Create;
		DoLoadFile(OpenDialog1.FileName);
		XSIDListMainForm.vstEvents.RootNodeCount:= FEvents.Count;

		FindEventsForm.StartEvent:= 0;
		FindEventsForm.EndEvent:= FEvents.Count;

		FileLoadForm.Hide;

		finally
		FileLoadForm.Release;
		FileLoadForm:= nil;
		end;

	FPlayConfig.Assign(GlobalConfig);

//TODO Need override flags checking.

	if  FXSIDConfig.System > cstUnknown then
		FPlayConfig.System:= FXSIDConfig.System;

	FPlayConfig.UpdateRate:= FXSIDConfig.UpdateRate;

	if  FXSIDConfig.Model > csmAny then
		FPlayConfig.Model:= FXSIDConfig.Model;

	FPlayConfig.FilterEnable:= FXSIDConfig.FilterEnable;
	FPlayConfig.Filter6581:= FXSIDConfig.Filter6581;
	FPlayConfig.Filter8580:= FXSIDConfig.Filter8580;
	FPlayConfig.DigiBoostEnable:= FXSIDConfig.DigiBoostEnable;

	GlobalXSIDStart(FPlayConfig, StatsCallback);

	GlobalXSID.RunSignal.ResetEvent;
	GlobalXSID.PausedSignal.WaitFor;
	end;

procedure TXSIDListMainDMod.ActOptionsMuteFilterUpdate(Sender: TObject);
	begin
	ActOptionsMuteFilter.Enabled:= Assigned(GlobalXSID) and
			not (GlobalXSID.RunSignal.WaitFor(0) = wrSignaled);
	end;

procedure TXSIDListMainDMod.ActOptionsMuteVoice1Execute(Sender: TObject);
	begin
	DoUpdateVoiceMute;
	end;

procedure TXSIDListMainDMod.ActOptionsMuteVoice1Update(Sender: TObject);
	begin
	ActOptionsMuteVoice1.Enabled:= Assigned(GlobalXSID) and
			not (GlobalXSID.RunSignal.WaitFor(0) = wrSignaled);
	end;

procedure TXSIDListMainDMod.ActOptionsMuteVoice2Update(Sender: TObject);
	begin
	ActOptionsMuteVoice2.Enabled:= Assigned(GlobalXSID) and
			not (GlobalXSID.RunSignal.WaitFor(0) = wrSignaled);
	end;

procedure TXSIDListMainDMod.ActOptionsMuteVoice3Update(Sender: TObject);
	begin
	ActOptionsMuteVoice3.Enabled:= Assigned(GlobalXSID) and
			not (GlobalXSID.RunSignal.WaitFor(0) = wrSignaled);
	end;

procedure TXSIDListMainDMod.ActOptionsPlay100PCExecute(Sender: TObject);
	begin
	GlobalXSID.SetDelayCount(1);
	end;

procedure TXSIDListMainDMod.ActOptionsPlay100PCUpdate(Sender: TObject);
	begin
	ActOptionsPlay100PC.Enabled:= Assigned(GlobalXSID) and
			not (GlobalXSID.RunSignal.WaitFor(0) = wrSignaled);
	end;

procedure TXSIDListMainDMod.ActOptionsPlay25PCExecute(Sender: TObject);
	begin
	GlobalXSID.SetDelayCount(4);
	end;

procedure TXSIDListMainDMod.ActOptionsPlay25PCUpdate(Sender: TObject);
	begin
	ActOptionsPlay25PC.Enabled:= Assigned(GlobalXSID) and
			not (GlobalXSID.RunSignal.WaitFor(0) = wrSignaled);
	end;

procedure TXSIDListMainDMod.ActOptionsPlay50PCExecute(Sender: TObject);
	begin
	GlobalXSID.SetDelayCount(2);
	end;

procedure TXSIDListMainDMod.ActOptionsPlay50PCUpdate(Sender: TObject);
	begin
	ActOptionsPlay50PC.Enabled:= Assigned(GlobalXSID) and
			not (GlobalXSID.RunSignal.WaitFor(0) = wrSignaled);
	end;

procedure TXSIDListMainDMod.ActToolsCreateDumpExecute(Sender: TObject);
	begin
	if  SaveDialog1.Execute then
		XSIDSaveFileDump(SaveDialog1.FileName, FEvents);
	end;

procedure TXSIDListMainDMod.ActViewVoice1Execute(Sender: TObject);
	begin
	DoUpdateEventFilter;
	end;

constructor TXSIDListMainDMod.Create(AOwner: TComponent);
	begin
	inherited;

	FEvents:= TList.Create;
	FPlayConfig:= TXSIDConfig.Create(nil);

	FFilterRegs:= [$00..$18];

	InitialiseConfig(ChangeFileExt(Application.ExeName, '.ini'));
	end;

destructor TXSIDListMainDMod.Destroy;
	begin
	if  FPlaying then
		StopPlay;

	FinaliseConfig(ChangeFileExt(Application.ExeName, '.ini'));

	FEvents.Free;
	FPlayConfig.Free;

	inherited;
	end;

procedure TXSIDListMainDMod.DoLoadFile(const AFileName: string);
	begin
	if  Assigned(FXSIDConfig) then
		begin
		FXSIDConfig.Free;
		FXSIDConfig:= nil;
		end;

	FTotalTime:= XSIDLoadFileXSID(AFileName, FEvents, LoadCallback, FXSIDConfig);
	GlobalEvents.CopyEvents(FEvents);

	XSIDListMainForm.TrackBar1.Max:= FTotalTime;
	XSIDListMainForm.TrackBar1.Position:= 0;
	XSIDListMainForm.TrackBar1.SliderVisible:= True;

	FilterViewForm.Sync;
	end;

procedure TXSIDListMainDMod.DoUpdateEventFilter;
	var
	n: PVirtualNode;
//	e: set of $00..$18;

	begin
	FFilterRegs:= [];
	if  ActViewVoice1.Checked then
		FFilterRegs:= FFilterRegs + [$00..$06];
	if  ActViewVoice2.Checked then
		FFilterRegs:= FFilterRegs + [$07..$0D];
	if  ActViewVoice3.Checked then
		FFilterRegs:= FFilterRegs + [$0E..$14];
	if  ActViewFilter.Checked then
		FFilterRegs:= FFilterRegs + [$15..$18];

	FFiltering:= not (ActViewVoice1.Checked and ActViewVoice2.Checked and
			ActViewVoice3.Checked and ActViewFilter.Checked);

	XSIDListMainForm.vstEvents.BeginUpdate;
	try
		n:= XSIDListMainForm.vstEvents.GetFirst(False);
		while Assigned(n) do
			begin
			XSIDListMainForm.vstEvents.IsFiltered[n]:= not
					(PXSIDEvent(FEvents[n^.Index])^.data.reg in FFilterRegs);

			n:= XSIDListMainForm.vstEvents.GetNext(n);
			end;

		finally
		XSIDListMainForm.vstEvents.EndUpdate;
		end;

//dengland This will cause a nasty bug when selecting nodes beyond filtered ones.
//	XSIDListMainForm.vstEvents.Invalidate;
	end;

procedure TXSIDListMainDMod.DoUpdateVoiceMute;
	begin
	GlobalXSID.SetEnabled(0, ActOptionsMuteVoice1.Checked);
	GlobalXSID.SetEnabled(1, ActOptionsMuteVoice2.Checked);
	GlobalXSID.SetEnabled(2, ActOptionsMuteVoice3.Checked);
	GlobalXSID.SetEnabled(3, ActOptionsMuteFilter.Checked);
	end;

procedure TXSIDListMainDMod.LoadCallback(const AStage: TXSIDFileStage;
		const APosition, ASize: Int64);
	begin
	if  AStage = rfsPrepare then
		begin
		FileLoadForm.ProgressBar1.Min:= 0;
		FileLoadForm.ProgressBar1.Max:= ASize - 1;
		FileLoadForm.ProgressBar1.Position:= APosition;
		end
	else if  AStage = rfsLoad then
		FileLoadForm.ProgressBar1.Position:= APosition
	else if  (AStage = rfsInitialise)
	and (APosition > -1) then
		begin
		FileLoadForm.Label1.Caption:= 'Initialising';
		FileLoadForm.ProgressBar1.Style:= pbstMarquee;
		end;

	Application.ProcessMessages;
	end;

procedure TXSIDListMainDMod.SetNowNode(const ANode: PVirtualNode);
	begin
//	FNowNode:= ANode;
//
//	if  not FPlaying then
//		begin
//		FStartNode:= ANode;
//
//		FindEventsForm.StartEvent:= ANode^.Index + 1;
//		FindEventsForm.EndEvent:= FEvents.Count;
//		end;
	end;

procedure TXSIDListMainDMod.SetStartNode(const ANode: PVirtualNode);
	begin
	if  not FPlaying then
		begin
		FStartNode:= ANode;
		FNowNode:= ANode;

		FindEventsForm.StartEvent:= ANode^.Index + 1;
		FindEventsForm.EndEvent:= FEvents.Count;

		FilterViewForm.TrackStart;
		end;
	end;

procedure TXSIDListMainDMod.StartPlay;
	var
	i: Integer;
	offs: Cardinal;
	n: PVirtualNode;
	ctx: TXSIDContext;

	begin
	FPlaying:= True;

	offs:= 0;
	i:= 0;
	n:= XSIDListMainForm.vstEvents.GetFirst(False);
	while  Assigned(n) and (not XSIDListMainForm.vstEvents.Selected[n]) do
		begin
		Inc(offs, PXSIDEvent(FEvents[i])^.offs);
		Inc(i);
		n:= XSIDListMainForm.vstEvents.GetNext(n);
		end;

	FilterViewForm.TrackNow(True);
	FilterViewForm.ScrollBar1.Enabled:= False;
//	FilterViewForm.Shape1.Visible:= True;

	GlobalXSID.RunSignal.ResetEvent;
	GlobalXSID.PausedSignal.WaitFor;

	GlobalEvents.Seek(offs, ctx);
	GlobalXSID.RestoreContext(ctx);

	GlobalXSID.RunSignal.SetEvent;
	GlobalXSID.PausedSignal.ResetEvent;
	end;

procedure TXSIDListMainDMod.StatsCallback(const AID: Integer; const AStats: TXSIDStats);
	var
	n,
	lstvw: PVirtualNode;

	begin
	if  FPlaying then
		begin
		XSIDListMainForm.TrackBar1.Position:= XSIDListMainForm.TrackBar1.Position +
				AStats.ThsTick;

		lstvw:= nil;
		n:= FNowNode;
		while  Assigned(n) and (n^.Index < Cardinal(AStats.EvtIdx)) do
			begin
			if  not (vsFiltered in n^.States) then
				lstvw:= n;

			n:= XSIDListMainForm.vstEvents.GetNext(n);
			end;

		if  Assigned(n)
		and (vsFiltered in n^.States) then
			n:= lstvw;

		if  Assigned(n) then
			begin
			FNowNode:= n;

			XSIDListMainForm.vstEvents.Selected[n]:= True;
			XSIDListMainForm.vstEvents.ScrollIntoView(n, True);

			FilterViewForm.TrackNow;
			end;
		end;
	end;

procedure TXSIDListMainDMod.StopPlay;
	begin
	GlobalXSID.RunSignal.ResetEvent;
	GlobalXSID.PausedSignal.WaitFor;

	FPlaying:= False;

	FStartNode:= FNowNode;

	FilterViewForm.ScrollBar1.Enabled:= True;
//	FilterViewForm.Shape1.Visible:= False;

	FilterViewForm.TrackStart;
	end;

procedure TXSIDListMainDMod.Timer1Timer(Sender: TObject);
	begin
	Inc(FPlayClr);
	if  FPlayClr > 6 then
		FPlayClr:= 0;

	FilterViewForm.Shape1.Pen.Color:= ARR_VAL_CLR_PLAY[FPlayClr];
	end;

end.
