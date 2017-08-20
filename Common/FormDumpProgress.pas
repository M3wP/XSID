unit FormDumpProgress;

{$IFDEF FPC}
    {$MODE Delphi}
{$ENDIF}

interface

uses
	Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
	ExtCtrls;

type

{ TDumpProgressForm }

	TDumpProgressForm = class(TForm)
		Bevel1: TBevel;
		Label1: TLabel;
		Label2: TLabel;
		ProgressBar1: TProgressBar;
		Button1: TButton;
		procedure Button1Click(Sender: TObject);
		procedure FormDestroy(Sender: TObject);

	private type
		TSubProgressData = record
			Text: TLabel;
			Progress: TProgressBar;
		end;

	private
		FSubProgressData: array of TSubProgressData;

		function  GetSubProgressBar(const AIndex: Integer): TProgressBar;
		function  GetSubProgressText(const AIndex: Integer): TLabel;

	public
		procedure SetSubProgressCount(const ACount: Integer);

		property  SubProgressBar[const AIndex: Integer]: TProgressBar read GetSubProgressBar;
		property  SubProgressText[const AIndex: Integer]: TLabel read GetSubProgressText;
	end;

var
	DumpProgressForm: TDumpProgressForm;

implementation

{$R *.dfm}

uses
	FormXSIDToMIDIMain;


procedure TDumpProgressForm.Button1Click(Sender: TObject);
	begin
	XSIDToMIDIMainForm.DumpAbort:= True;
	end;

procedure TDumpProgressForm.FormDestroy(Sender: TObject);
	begin
	SetSubProgressCount(0);
	end;

function TDumpProgressForm.GetSubProgressBar(const AIndex: Integer): TProgressBar;
	begin
	Result:= FSubProgressData[AIndex].Progress;
	end;

function TDumpProgressForm.GetSubProgressText(const AIndex: Integer): TLabel;
	begin
	Result:= FSubProgressData[AIndex].Text;
	end;

procedure TDumpProgressForm.SetSubProgressCount(const ACount: Integer);
	var
	i: Integer;

	begin
	if  Length(FSubProgressData) > 0 then
		for i:= 0 to High(FSubProgressData) do
			begin
			FSubProgressData[i].Text.Free;
			FSubProgressData[i].Progress.Free;
			end;

	SetLength(FSubProgressData, ACount);
	ClientHeight:= 144 + 23 * ACount;

	for i:= 0 to ACount - 1 do
		begin
		FSubProgressData[i].Text:= TLabel.Create(Self);
		FSubProgressData[i].Text.Left:= 8;
		FSubProgressData[i].Text.Top:= 93 + i * 23;
		FSubProgressData[i].Text.Caption:= '';
		FSubProgressData[i].Text.Parent:= Self;

		FSubProgressData[i].Progress:= TProgressBar.Create(Self);
		FSubProgressData[i].Progress.Left:= 72;
		FSubProgressData[i].Progress.Top:= 92 + i * 23;
		FSubProgressData[i].Progress.Width:= 240;
		FSubProgressData[i].Progress.Parent:= Self;
		FSubProgressData[i].Progress.Smooth:= True;
		end;
	end;

end.

