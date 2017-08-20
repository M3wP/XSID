unit FormXSIDFilterConfig;

{$IFDEF FPC}
    {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFNDEF FPC}
    Windows,
{$ELSE}
    LCLIntf, LCLType, LMessages,
{$ENDIF}
    Messages, SysUtils, Variants,
	Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
	ComCtrls, C64Types;

type
	TXSIDFilterConfigForm = class(TForm)
		Button2: TButton;
		Button1: TButton;
		Button3: TButton;
		TrackBar1: TTrackBar;
		Edit1: TEdit;
		procedure FormShow(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure TrackBar1Change(Sender: TObject);
		procedure Edit1KeyPress(Sender: TObject; var Key: Char);
		procedure Button3Click(Sender: TObject);
	private
		FFirstTime: Boolean;
		FPopulating: Boolean;
		FModel: TC64SIDModel;
		FFilter: Double;
		FDefault: Double;

	public
		property Model: TC64SIDModel read FModel write FModel;
		property Filter: Double read FFilter write FFilter;
	end;

var
	XSIDFilterConfigForm: TXSIDFilterConfigForm;

implementation

{$R *.dfm}

procedure TXSIDFilterConfigForm.Button3Click(Sender: TObject);
	begin
	FFilter:= FDefault;

	if FModel = csmMOS6581 then
		TrackBar1.Position:= Trunc(FFilter * 100)
	else
		TrackBar1.Position:= Trunc(FFilter);
	end;

procedure TXSIDFilterConfigForm.Edit1KeyPress(Sender: TObject; var Key: Char);
	var
	v: Double;

	begin
	if  Key = #13 then
		begin
		if  not TryStrToFloat(Edit1.Text, v) then
			if FModel = csmMOS6581 then
				v:= TrackBar1.Position / 100
			else
				v:= TrackBar1.Position;

		if  FModel = csmMOS6581 then
			begin
			if  v < 0.01 then
				v:= 0.01
			else if  v > 1.0 then
				v:= 1.0;
			end
		else
			begin
			if  v < 150 then
				v:= 150
			else if  v > 22050 then
				v:= 22050;
			end;

		FFilter:= v;

		FPopulating:= True;
		try
			if FModel = csmMOS6581 then
				begin
				Edit1.Text:= FormatFloat('0.00', FFilter);
				TrackBar1.Position:= Trunc(FFilter * 100);
				end
			else
				begin
				Edit1.Text:= FormatFloat('0', FFilter);
				TrackBar1.Position:= Trunc(FFilter);
				end;

			finally
			FPopulating:= False;
			end;

		Key:= #0;

		Button2.Enabled:= True;
		end;
	end;

procedure TXSIDFilterConfigForm.FormCreate(Sender: TObject);
	begin
	FFirstTime:= True;
	end;

procedure TXSIDFilterConfigForm.FormShow(Sender: TObject);
	begin
	if  FFirstTime then
		begin
		FDefault:= FFilter;

		FPopulating:= True;
		try
			if FModel = csmMOS6581 then
				begin
				TrackBar1.Max:= 100;
				TrackBar1.Min:= 0;
				TrackBar1.Position:= Trunc(FFilter * 100);
				Edit1.Text:= FormatFloat('0.00', FFilter);
				end
			else
				begin
				TrackBar1.Max:= 22050;
				TrackBar1.Min:= 150;
				TrackBar1.Position:= Trunc(FFilter);
				Edit1.Text:= FormatFloat('0', FFilter);
				end;

			finally
			FPopulating:= False;
			end;
		end;

	FFirstTime:= False;
	end;

procedure TXSIDFilterConfigForm.TrackBar1Change(Sender: TObject);
	begin
	if  not FPopulating then
		begin
		if FModel = csmMOS6581 then
			begin
			FFilter:= TrackBar1.Position / 100;
			Edit1.Text:= FormatFloat('0.00', FFilter);
			end
		else
			begin
			FFilter:= TrackBar1.Position;
			Edit1.Text:= FormatFloat('0', FFilter);
			end;

		Button2.Enabled:= True;
		end;
	end;

end.
