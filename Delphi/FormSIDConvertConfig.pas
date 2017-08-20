unit FormSIDConvertConfig;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
	Vcl.ExtCtrls, Vcl.Mask, System.ImageList, Vcl.ImgList, SIDConvTypes, Vcl.Buttons;

type
	TSIDConvertConfigForm = class(TForm)
		Bevel1: TBevel;
		Label1: TLabel;
		Label2: TLabel;
		OpenDialog1: TOpenDialog;
		OpenDialog2: TOpenDialog;
		Label3: TLabel;
		Label4: TLabel;
		Label5: TLabel;
		Bevel2: TBevel;
		MaskEdit1: TMaskEdit;
		Label6: TLabel;
		Button1: TButton;
		Button2: TButton;
		FileOpenDialog1: TFileOpenDialog;
		SpeedButton1: TSpeedButton;
		SpeedButton2: TSpeedButton;
		SpeedButton3: TSpeedButton;
		Edit1: TEdit;
		Edit2: TEdit;
		Edit3: TEdit;
		Label7: TLabel;
		Label8: TLabel;
		procedure FormShow(Sender: TObject);
		procedure Button1Click(Sender: TObject);
		procedure SpeedButton1Click(Sender: TObject);
		procedure SpeedButton2Click(Sender: TObject);
		procedure SpeedButton3Click(Sender: TObject);
		procedure Label7Click(Sender: TObject);
		procedure Label8Click(Sender: TObject);
	private
		FConfig: PSIDConvConfig;
		FRequired: Boolean;

	public
		function  ShowConfig(AConfig: PSIDConvConfig;
				const ARequired: Boolean = False): TModalResult;
	end;

var
	SIDConvertConfigForm: TSIDConvertConfigForm;

implementation

{$R *.dfm}

uses
	System.UITypes, Winapi.ShellAPI;


procedure TSIDConvertConfigForm.Button1Click(Sender: TObject);
	var
	f: Boolean;
	s: string;

	begin
	f:= False;
	if  Edit3.Text = '' then
		begin
		s:= 'Output path required.';
		f:= True;
		end;

//	if  Edit2.Text = '' then
//		begin
//		s:= 'V.I.C.E. VSID required.';
//		f:= True;
//		end;

	if  Edit1.Text = '' then
		begin
		s:= 'HVSC Songlengths required.';
		f:= True;
		end;

	if  f then
		begin
		MessageBeep(MB_ICONERROR);
		MessageDlg(s, mtError, [mbOk], 0);
		Exit;
		end;

	FConfig^.songLengths:= Edit1.Text;
	FConfig^.viceVSID:= Edit2.Text;
	FConfig^.outputPath:= Edit3.Text;

	s:= '00:' + StringReplace(MaskEdit1.Text, ' ', '0', [rfReplaceAll]);
	FConfig^.startDelay:= StrToDateTime(s);

	ModalResult:= mrOk;
	end;

procedure TSIDConvertConfigForm.FormShow(Sender: TObject);
	begin
	if  FRequired then
		begin
		Button2.Caption:= 'Quit';
		Button2.ModalResult:= mrAbort;
		end
	else
		begin
		Button2.Caption:= 'Cancel';
		Button2.ModalResult:= mrCancel;
		end;

	Edit1.Text:= FConfig^.songLengths;
	Edit2.Text:= FConfig^.viceVSID;
	Edit3.Text:= FConfig^.outputPath;

	MaskEdit1.Text:= FormatDateTime('nn:ss', FConfig^.startDelay);
	end;

procedure TSIDConvertConfigForm.Label7Click(Sender: TObject);
	begin
	ShellExecute(0, 'OPEN', PChar('http://www.hvsc.c64.org/'), '', '', SW_SHOWNORMAL);
	end;

procedure TSIDConvertConfigForm.Label8Click(Sender: TObject);
	begin
	ShellExecute(0, 'OPEN', PChar('http://vice-emu.sourceforge.net/'), '', '',
			SW_SHOWNORMAL);
	end;

function TSIDConvertConfigForm.ShowConfig(AConfig: PSIDConvConfig;
		const ARequired: Boolean): TModalResult;
	begin
	FConfig:= AConfig;
	FRequired:= ARequired;

	Result:= ShowModal;
	end;

procedure TSIDConvertConfigForm.SpeedButton1Click(Sender: TObject);
	begin
	OpenDialog1.InitialDir:= ExtractFilePath(Edit1.Text);
	OpenDialog1.FileName:= Edit1.Text;
	if  OpenDialog1.Execute then
		Edit1.Text:= OpenDialog1.FileName;
	end;

procedure TSIDConvertConfigForm.SpeedButton2Click(Sender: TObject);
	begin
	OpenDialog2.InitialDir:= ExtractFilePath(Edit2.Text);
	OpenDialog2.FileName:= Edit2.Text;

	OpenDialog2.Filter:= 'VSID Executable (VSID.EXE)|VSID.EXE';
	OpenDialog2.DefaultExt:= 'exe';

	if  OpenDialog2.Execute then
		Edit2.Text:= OpenDialog2.FileName;
	end;

procedure TSIDConvertConfigForm.SpeedButton3Click(Sender: TObject);
	begin
	FileOpenDialog1.FileName:= Edit3.Text;
	if  FileOpenDialog1.Execute then
		Edit3.Text:= FileOpenDialog1.FileName;
	end;

end.
