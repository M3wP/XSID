unit FormXSIDPlayMain;

{$MODE Delphi}

interface

uses
	LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants,
	Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
	ComCtrls, XSIDFiles, XSIDTypes, XSIDThread;

type
	TTrackBar = class(ComCtrls.TTrackbar)
	protected
		property OnMouseUp;
		property OnMouseDown;
	end;

	TXSIDPlayMainForm = class(TForm)
		Button1: TButton;
		OpenDialog1: TOpenDialog;
		TrackBar1: TTrackBar;
		Button2: TButton;
		Button3: TButton;
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		Label5: TLabel;
		Label6: TLabel;
		Label7: TLabel;
		Label8: TLabel;
		Label9: TLabel;
		Label10: TLabel;
		ListBox1: TListBox;
		ListBox2: TListBox;
		procedure Button1Click(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure FormShow(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure Button2Click(Sender: TObject);
		procedure Button3Click(Sender: TObject);
	private
		FXSIDConfig: TXSIDFileConfig;
		FPlayConfig: TXSIDConfig;
		FFirstTime: Boolean;
		FTBNoUpdate: Boolean;

		procedure TBMouseDown(Sender: TObject; Button: TMouseButton;
				Shift: TShiftState; X, Y: Integer);
		procedure TBMouseUp(Sender: TObject; Button: TMouseButton;
				Shift: TShiftState; X, Y: Integer);

		procedure DoLoadFile(const AFileName: string);
		procedure StatsCallback(const AID: Integer; const AStats: TXSIDStats);
	public
		{ Public declarations }
	end;

var
	XSIDPlayMainForm: TXSIDPlayMainForm;

implementation

uses
	SyncObjs, C64Types, FormXSIDConfig,
{$IFDEF MSWINDOWS}
    XSIDAudioDSound,
{$ENDIF}
    XSIDAudioOpenAL;

{$R *.lfm}

{ TForm1 }

procedure TXSIDPlayMainForm.Button1Click(Sender: TObject);
	begin
	if  not OpenDialog1.Execute then
		Exit;

	TrackBar1.OnMouseUp:= nil;
	TrackBar1.OnMouseDown:= nil;

	GlobalXSIDStop;
	GlobalEvents:= TXSIDEventManager.Create;

	DoLoadFile(OpenDialog1.FileName);

	FPlayConfig.Assign(GlobalConfig);

	if  not FPlayConfig.SystemOverride
	and (FXSIDConfig.System > cstUnknown) then
		FPlayConfig.System:= FXSIDConfig.System;

	if  not FPlayConfig.UpdateRateOverride then
		FPlayConfig.UpdateRate:= FXSIDConfig.UpdateRate;

	if  not FPlayConfig.ModelOverride
	and (FXSIDConfig.Model > csmAny) then
		FPlayConfig.Model:= FXSIDConfig.Model;

	FPlayConfig.FilterEnable:= FXSIDConfig.FilterEnable;
	FPlayConfig.Filter6581:= FXSIDConfig.Filter6581;
	FPlayConfig.Filter8580:= FXSIDConfig.Filter8580;
	FPlayConfig.DigiBoostEnable:= FXSIDConfig.DigiBoostEnable;

	Label3.Caption:= string(FXSIDConfig.Title);
	Label4.Caption:= string(FXSIDConfig.Artist);
	Label8.Caption:= string(FXSIDConfig.Album);
	Label9.Caption:= string(FXSIDConfig.Date);
	Label10.Caption:= string(FXSIDConfig.TrackNumber);

	GlobalXSIDStart(FPlayConfig, StatsCallback);

	Button3.Enabled:= True;
	Button3.Caption:= 'Pause';
	Button3.Tag:= 0;

	TrackBar1.OnMouseUp:= TBMouseUp;
	TrackBar1.OnMouseDown:= TBMouseDown;
	end;

procedure TXSIDPlayMainForm.Button2Click(Sender: TObject);
	begin
	XSIDConfigForm:= TXSIDConfigForm.Create(Self);
	try
		if  XSIDConfigForm.ShowModal = mrOk then
			begin
			TrackBar1.OnMouseUp:= nil;
			TrackBar1.OnMouseDown:= nil;
			TrackBar1.Position:= 0;

			GlobalConfig.Assign(XSIDConfigForm.Config);
			GlobalXSIDStop;

			Button3.Enabled:= False;
			Button3.Caption:= 'Pause';
			Button3.Tag:= 0;
			end;

		finally
		XSIDConfigForm.Release;
		XSIDConfigForm:= nil;
		end;
	end;

procedure TXSIDPlayMainForm.Button3Click(Sender: TObject);
	begin
	if  Button3.Tag = 0 then
		begin
		GlobalXSID.RunSignal.ResetEvent;
		GlobalXSID.PausedSignal.WaitFor(INFINITE);
		Button3.Caption:= 'Play';
		Button3.Tag:= 1;
		end
	else
		begin
		GlobalXSID.RunSignal.SetEvent;
		GlobalXSID.PausedSignal.ResetEvent;
		Button3.Caption:= 'Pause';
		Button3.Tag:= 0;
		end;
	end;

procedure TXSIDPlayMainForm.DoLoadFile(const AFileName: string);
	var
	el: TList;

	begin
	if  Assigned(FXSIDConfig) then
		begin
		FXSIDConfig.Free;
		FXSIDConfig:= nil;
		end;

	el:= TList.Create;
	try
		GlobalEvents.ClearEvents;

//		Make sounds stop at start
		GlobalEvents.AddEvent(2, 4, 0);
		GlobalEvents.AddEvent(2, 11, 0);
		GlobalEvents.AddEvent(2, 18, 0);

		TrackBar1.Max:= XSIDLoadFileXSID(AFileName, el, nil, FXSIDConfig) + 12;
		TrackBar1.Position:= 0;
		//TrackBar1.Visible:= True;

		GlobalEvents.CopyEvents(el);

//		Make sounds stop at end
		GlobalEvents.AddEvent(2, 4, 0);
		GlobalEvents.AddEvent(2, 11, 0);
		GlobalEvents.AddEvent(2, 18, 0);

		finally
		el.Free;
		end;
	end;

procedure TXSIDPlayMainForm.FormCreate(Sender: TObject);
	begin
	FXSIDConfig:= nil;
	FFirstTime:= True;
	InitialiseConfig(ChangeFileExt(Application.ExeName, '.ini'), True);

	FPlayConfig:= TXSIDConfig.Create(nil);
	end;

procedure TXSIDPlayMainForm.FormDestroy(Sender: TObject);
	begin
	GlobalXSIDStop;

	FinaliseConfig(ChangeFileExt(Application.ExeName, '.ini'));

	FPlayConfig.Free;
	FXSIDConfig.Free;
	end;

procedure TXSIDPlayMainForm.FormShow(Sender: TObject);
	begin
	if  FFirstTime then
		begin
{$IFDEF MSWINDOWS}
{$IFNDEF FPC}
		if not SetPriorityClass(GetCurrentProcess, HIGH_PRIORITY_CLASS) then
			ShowMessage('Set priority failed');
{$ENDIF}
{$ENDIF}

//		GlobalXSIDStart(GlobalConfig, nil);
		FFirstTime:= False;
		end;
	end;

procedure TXSIDPlayMainForm.StatsCallback(const AID: Integer;
        const AStats: TXSIDStats);
	begin
	if  not FTBNoUpdate then
		TrackBar1.Position:= TrackBar1.Position + AStats.ThsTick;
	end;

procedure TXSIDPlayMainForm.TBMouseDown(Sender: TObject; Button: TMouseButton;
		Shift: TShiftState; X, Y: Integer);
	begin
	FTBNoUpdate:= True;
	end;

procedure TXSIDPlayMainForm.TBMouseUp(Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer);
	var
	space,
	offset,
	pos,
	lastPos: Integer;
	ctx: TXSIDContext;

	begin
	space:= 11;
	offset:= X - space;

	if  offset < 0 then
		offset:= 0;

	with TrackBar1 do
		pos:= Round(Min + offset / (Width - 2 * space) * (Max - Min));

	GlobalXSID.RunSignal.ResetEvent;
	GlobalXSID.PausedSignal.WaitFor(INFINITE);

	lastPos:= GlobalEvents.Seek(pos, ctx);

	GlobalXSID.RestoreContext(ctx);

	if  lastPos < pos then
		GlobalXSID.Zoom(pos - lastPos);

	TrackBar1.Position:= pos;

	GlobalXSID.RunSignal.SetEvent;
	GlobalXSID.PausedSignal.ResetEvent;

	FTBNoUpdate:= False;
	end;

end.
