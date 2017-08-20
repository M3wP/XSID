unit FormSIDConvProgress;

interface

uses
{$IFDEF MSWINDOWS}
	Windows,
{$ENDIF}
    Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
    ComCtrls, StdCtrls;

type
	TSIDConvProgressForm = class(TForm)
		Label1: TLabel;
		Label2: TLabel;
		ProgressBar1: TProgressBar;
		ProgressBar2: TProgressBar;
		Label3: TLabel;
		Label4: TLabel;
		ProgressBar3: TProgressBar;
		Label5: TLabel;
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

var
	SIDConvProgressForm: TSIDConvProgressForm;

implementation

{$R *.dfm}

end.
