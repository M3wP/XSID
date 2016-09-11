unit FormXSIDPlayMain;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
	Vcl.ComCtrls, ReSIDFiles, ReSIDTypes, ReSIDThread;

type
	TTrackBar = class(Vcl.ComCtrls.TTrackbar)
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
		FXSIDConfig: TXSIDConfig;
		FPlayConfig: TReSIDConfig;
		FFirstTime: Boolean;
		FTBNoUpdate: Boolean;

		procedure TBMouseDown(Sender: TObject; Button: TMouseButton;
				Shift: TShiftState; X, Y: Integer);
		procedure TBMouseUp(Sender: TObject; Button: TMouseButton;
				Shift: TShiftState; X, Y: Integer);

		procedure DoLoadFile(const AFileName: string);
		procedure StatsCallback(const AStats: TReSIDStats);
	public
		{ Public declarations }
	end;

var
	XSIDPlayMainForm: TXSIDPlayMainForm;

implementation

uses
	C64Types, FormReSIDConfig, ReSIDAudioDSound;

{$R *.dfm}

{ TForm1 }

procedure TXSIDPlayMainForm.Button1Click(Sender: TObject);
	begin
	if  not OpenDialog1.Execute then
		Exit;

	TrackBar1.OnMouseUp:= nil;
	TrackBar1.OnMouseDown:= nil;

	GlobalReSIDStop;

	GlobalEvents:= TReSIDEventManager.Create;
	DoLoadFile(OpenDialog1.FileName);

	FPlayConfig.Assign(GlobalConfig);

//TODO Need override flags checking.

	if  FXSIDConfig.System > cstAny then
		FPlayConfig.System:= FXSIDConfig.System;

	FPlayConfig.UpdateRate:= FXSIDConfig.UpdateRate;

	if  FXSIDConfig.Model > csmAny then
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

	GlobalReSIDStart(FPlayConfig, StatsCallback);

	Button3.Enabled:= True;
	Button3.Caption:= 'Pause';
	Button3.Tag:= 0;

	TrackBar1.OnMouseUp:= TBMouseUp;
	TrackBar1.OnMouseDown:= TBMouseDown;
	end;

procedure TXSIDPlayMainForm.Button2Click(Sender: TObject);
	begin
	ReSIDConfigForm:= TReSIDConfigForm.Create(Self);
	try
		if  ReSIDConfigForm.ShowModal = mrOk then
			begin
			TrackBar1.OnMouseUp:= nil;
			TrackBar1.OnMouseDown:= nil;
			TrackBar1.Position:= 0;

			GlobalConfig.Assign(ReSIDConfigForm.Config);
			GlobalReSIDStop;

			Button3.Enabled:= False;
			Button3.Caption:= 'Pause';
			Button3.Tag:= 0;
			end;

		finally
		ReSIDConfigForm.Release;
		ReSIDConfigForm:= nil;
		end;
	end;

procedure TXSIDPlayMainForm.Button3Click(Sender: TObject);
	begin
	if  Button3.Tag = 0 then
		begin
		GlobalReSID.RunSignal.ResetEvent;
		GlobalReSID.PausedSignal.WaitFor;
		Button3.Caption:= 'Play';
		Button3.Tag:= 1;
		end
	else
		begin
		GlobalReSID.RunSignal.SetEvent;
		GlobalReSID.PausedSignal.ResetEvent;
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

		TrackBar1.Max:= ReSIDLoadFileXSID(AFileName, el, nil, FXSIDConfig) + 12;
		TrackBar1.Position:= 0;
		TrackBar1.SliderVisible:= True;

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
	InitialiseConfig(ChangeFileExt(Application.ExeName, '.ini'));

	FPlayConfig:= TReSIDConfig.Create(nil);
	end;

procedure TXSIDPlayMainForm.FormDestroy(Sender: TObject);
	begin
	GlobalReSIDStop;

	FPlayConfig.Free;
	FXSIDConfig.Free;
	end;

procedure TXSIDPlayMainForm.FormShow(Sender: TObject);
	begin
	if  FFirstTime then
		begin
{$IFDEF WIN32}
		if not SetPriorityClass(GetCurrentProcess, HIGH_PRIORITY_CLASS) then
			ShowMessage('Set priority failed');
{$ENDIF}

//		GlobalReSIDStart(GlobalConfig, nil);
		FFirstTime:= False;
		end;
	end;

procedure TXSIDPlayMainForm.StatsCallback(const AStats: TReSIDStats);
	begin
	if  not FTBNoUpdate then
		TrackBar1.Position:= TrackBar1.Position + AStats.ThsTick;
	end;

procedure TXSIDPlayMainForm.TBMouseDown(Sender: TObject; Button: TMouseButton;
		Shift: TShiftState; X, Y: Integer);
	begin
	FTBNoUpdate:= True;
	end;

procedure TXSIDPlayMainForm.TBMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
		X, Y: Integer);
	var
	space,
	offset,
	pos: Integer;
	ctx: TReSIDContext;

	begin
	space:= 11;
	offset:= X - space;

	if  offset < 0 then
		offset:= 0;

	with TrackBar1 do
		pos:= Round(Min + offset / (Width - 2 * space) * (Max - Min));

	GlobalReSID.RunSignal.ResetEvent;
	GlobalReSID.PausedSignal.WaitFor;

	TrackBar1.Position:= GlobalEvents.Seek(pos, ctx);

	GlobalReSID.RestoreContext(ctx);

	GlobalReSID.RunSignal.SetEvent;
	GlobalReSID.PausedSignal.ResetEvent;

	FTBNoUpdate:= False;
	end;

end.
