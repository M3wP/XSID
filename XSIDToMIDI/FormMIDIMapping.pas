unit FormMIDIMapping;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
	XSIDToMIDITypes;

type
	TMIDIMappingForm = class(TForm)
		RadioButton1: TRadioButton;
		RadioButton2: TRadioButton;
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		ComboBox1: TComboBox;
		ComboBox2: TComboBox;
		Label4: TLabel;
		Label5: TLabel;
		ComboBox3: TComboBox;
		Button1: TButton;
		Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
		procedure ComboBox2Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
	private
		FMapping: PMIDIInsMapping;
		FInstrument: TSIDInstrument;
		FChanging: Boolean;
		FSourceNotes: array of Integer;
		FDestNotes: array of Integer;

	protected
		procedure DoPopulateControls;

	public
		procedure EditMapping(const AMapping: PMIDIInsMapping;
				const AInstrument: TSIDInstrument; const AIndex: Integer);
	end;

var
	MIDIMappingForm: TMIDIMappingForm;


implementation

{$R *.dfm}

{ TMIDIMappingForm }

procedure TMIDIMappingForm.ComboBox2Change(Sender: TObject);
	begin
	if  not FChanging then
		begin
		FChanging:= True;
		try
			ComboBox3.ItemIndex:= FDestNotes[FSourceNotes[ComboBox2.ItemIndex]];

			finally
			FChanging:= False;
			end;
		end;
	end;

procedure TMIDIMappingForm.ComboBox3Change(Sender: TObject);
	begin
	FDestNotes[FSourceNotes[ComboBox2.ItemIndex]]:= ComboBox3.ItemIndex;
	end;

procedure TMIDIMappingForm.DoPopulateControls;
	var
	i,
	j: Integer;

	begin
	FChanging:= True;
	try
		if  FMapping.DrumMode then
			RadioButton2.Checked:= True
		else
			RadioButton1.Checked:= True;

		i:= FMapping.Channel;
		if  i > 8 then
			Dec(i);

		ComboBox1.ItemIndex:= i;

		CheckBox1.Checked:= FMapping.ExtendForBend;

		CheckBox2.Checked:= FMapping.ChordMode;

		SetLength(FSourceNotes, FInstrument.NotesCount);
		j:= 0;
		for i:= 0 to 127 do
			if  FInstrument.UsedNotes[i] then
				begin
				FSourceNotes[j]:= i;
				Inc(j);
				end;

		SetLength(FDestNotes, 128);
		for i:= 0 to 127 do
			FDestNotes[i]:= FMapping.NoteMap[i];

		ComboBox2.Items.Clear;
		for i:= 0 to High(FSourceNotes) do
			ComboBox2.Items.Add(IntToStr(FSourceNotes[i]));

		ComboBox3.Items.Clear;
		for i:= 0 to 127 do
			ComboBox3.Items.Add(ARR_LBL_STDDRMNTN[i]);

		ComboBox2.ItemIndex:= 0;
		ComboBox3.ItemIndex:= FMapping.NoteMap[FSourceNotes[0]];

		finally
		FChanging:= False;
		end;
	end;

procedure TMIDIMappingForm.EditMapping(const AMapping: PMIDIInsMapping;
		const AInstrument: TSIDInstrument; const AIndex: Integer);
	begin
	FMapping:= AMapping;
	FInstrument:= AInstrument;
	Label2.Caption:= IntToStr(AIndex);

	DoPopulateControls;
	ShowModal;
	end;

procedure TMIDIMappingForm.FormClose(Sender: TObject; var Action: TCloseAction);
	var
	i: Integer;

	begin
	if  ModalResult = mrOk then
		begin
		FMapping.DrumMode:= RadioButton2.Checked;
		i:= ComboBox1.ItemIndex;
		if  i > 8 then
			Inc(i);
		FMapping.Channel:= i;

		FMapping.ExtendForBend:= CheckBox1.Checked;

		FMapping.ChordMode:= CheckBox2.Checked;

		for i:= 0 to High(FSourceNotes) do
			FMapping.NoteMap[FSourceNotes[i]]:= FDestNotes[FSourceNotes[i]];
		end;
	end;

end.
