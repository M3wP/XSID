unit FormSIDConvertConfig;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
	Vcl.ExtCtrls, Vcl.Mask, System.ImageList, Vcl.ImgList, SIDConvTypes;

type
	TSIDConvertConfigForm = class(TForm)
		Bevel1: TBevel;
		Label1: TLabel;
		Label2: TLabel;
		ButtonedEdit1: TButtonedEdit;
		ImageList1: TImageList;
		OpenDialog1: TOpenDialog;
		OpenDialog2: TOpenDialog;
		ButtonedEdit2: TButtonedEdit;
		Label3: TLabel;
		ButtonedEdit3: TButtonedEdit;
		Label4: TLabel;
		Label5: TLabel;
		Bevel2: TBevel;
		MaskEdit1: TMaskEdit;
		Label6: TLabel;
		Button1: TButton;
		Button2: TButton;
		LinkLabel1: TLinkLabel;
		LinkLabel2: TLinkLabel;
		FileOpenDialog1: TFileOpenDialog;
		procedure LinkLabel1LinkClick(Sender: TObject; const Link: string;
				LinkType: TSysLinkType);
		procedure ButtonedEdit1RightButtonClick(Sender: TObject);
		procedure ButtonedEdit2RightButtonClick(Sender: TObject);
		procedure ButtonedEdit3RightButtonClick(Sender: TObject);
		procedure FormShow(Sender: TObject);
		procedure Button1Click(Sender: TObject);
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
	if  ButtonedEdit3.Text = '' then
		begin
		s:= 'Output path required.';
		f:= True;
		end;

	if  ButtonedEdit2.Text = '' then
		begin
		s:= 'V.I.C.E. VSID required.';
		f:= True;
		end;

	if  ButtonedEdit1.Text = '' then
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

	FConfig^.songLengths:= ButtonedEdit1.Text;
	FConfig^.viceVSID:= ButtonedEdit2.Text;
	FConfig^.outputPath:= ButtonedEdit3.Text;

	s:= '00:' + StringReplace(MaskEdit1.Text, ' ', '0', [rfReplaceAll]);
	FConfig^.startDelay:= StrToDateTime(s);

	ModalResult:= mrOk;
	end;

procedure TSIDConvertConfigForm.ButtonedEdit1RightButtonClick(Sender: TObject);
	begin
	OpenDialog1.InitialDir:= ExtractFilePath(ButtonedEdit1.Text);
	OpenDialog1.FileName:= ButtonedEdit1.Text;
	if  OpenDialog1.Execute then
		ButtonedEdit1.Text:= OpenDialog1.FileName;
	end;

procedure TSIDConvertConfigForm.ButtonedEdit2RightButtonClick(Sender: TObject);
	begin
	OpenDialog2.InitialDir:= ExtractFilePath(ButtonedEdit2.Text);
	OpenDialog2.FileName:= ButtonedEdit2.Text;
	if  OpenDialog2.Execute then
		ButtonedEdit2.Text:= OpenDialog2.FileName;
	end;

procedure TSIDConvertConfigForm.ButtonedEdit3RightButtonClick(Sender: TObject);
	begin
	FileOpenDialog1.FileName:= ButtonedEdit3.Text;
	if  FileOpenDialog1.Execute then
		ButtonedEdit3.Text:= FileOpenDialog1.FileName;
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

	ButtonedEdit1.Text:= FConfig^.songLengths;
	ButtonedEdit2.Text:= FConfig^.viceVSID;
	ButtonedEdit3.Text:= FConfig^.outputPath;

	MaskEdit1.Text:= FormatDateTime('nn:ss', FConfig^.startDelay);
	end;

procedure TSIDConvertConfigForm.LinkLabel1LinkClick(Sender: TObject;
		const Link: string; LinkType: TSysLinkType);
	begin
	ShellExecute(0, 'OPEN', PChar(Link), '', '', SW_SHOWNORMAL)
	end;

function TSIDConvertConfigForm.ShowConfig(AConfig: PSIDConvConfig;
		const ARequired: Boolean): TModalResult;
	begin
	FConfig:= AConfig;
	FRequired:= ARequired;

	Result:= ShowModal;
	end;

end.
