unit FormFileLoad;

interface

uses
	Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
	ExtCtrls;

type
{ TFileLoadForm }

	TFileLoadForm = class(TForm)
	  Bevel1: TBevel;
	  Label1: TLabel;
	  Label2: TLabel;
	  ProgressBar1: TProgressBar;

	private

	public

	end;

var
	FileLoadForm: TFileLoadForm;

implementation

{$R *.dfm}


end.

