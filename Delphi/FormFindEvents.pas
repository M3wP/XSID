unit FormFindEvents;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
	Vcl.CheckLst;

type
	TFindEventsForm = class(TForm)
		Label1: TLabel;
		Label2: TLabel;
		CheckListBox1: TCheckListBox;
		CheckBox1: TCheckBox;
		CheckBox2: TCheckBox;
		CheckBox3: TCheckBox;
		CheckBox4: TCheckBox;
		CheckBox5: TCheckBox;
		CheckBox6: TCheckBox;
		CheckBox7: TCheckBox;
		CheckBox8: TCheckBox;
		Button1: TButton;
		Label3: TLabel;
		procedure CheckBox7Click(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure CheckListBox1ClickCheck(Sender: TObject);
		procedure Button1Click(Sender: TObject);
	private
		FStartEvent: Cardinal;
		FEndEvent: Cardinal;
		FValue: Byte;
		FRegs: set of Byte;

	public
		property StartEvent: Cardinal read FStartEvent write FStartEvent;
		property EndEvent: Cardinal read FEndEvent write FEndEvent;
	end;


var
	FindEventsForm: TFindEventsForm;

implementation

{$R *.dfm}

uses
	C64Types, XSIDTypes, DModXSIDListMain, FormXSIDListMain, VirtualTrees;


procedure TFindEventsForm.Button1Click(Sender: TObject);
	var
	ev: PXSIDEvent;
	n: PVirtualNode;

	begin
	while FStartEvent < FEndEvent do
		begin
		ev:= PXSIDEvent(XSIDListMainDMod.Events[FStartEvent]);
		if  (ev^.data.reg in FRegs)
		and ((ev^.data.val and FValue) <> 0) then
			begin
			n:= XSIDListMainForm.vstEvents.GetFirst(False);
			while Assigned(n) and (n^.Index <> FStartEvent) do
				n:= XSIDListMainForm.vstEvents.GetNext(n);

			XSIDListMainForm.vstEvents.Selected[n]:= True;
			XSIDListMainForm.vstEvents.ScrollIntoView(n, True);
			Break;
			end;

		Inc(FStartEvent);
		end;
	end;

procedure TFindEventsForm.CheckBox7Click(Sender: TObject);
	begin
	FValue:= FValue xor (Sender as TCheckBox).Tag;
	Label3.Caption:= '$' + IntToHex(FValue, 2);
	end;


procedure TFindEventsForm.CheckListBox1ClickCheck(Sender: TObject);
	var
	i: Byte;

	begin
	FRegs:= [];

	for i:= 0 to 24 do
		if  CheckListBox1.Checked[i] then
            Include(FRegs, i);
	end;

procedure TFindEventsForm.FormCreate(Sender: TObject);
	var
	i: Integer;

	begin
	for i:= 0 to 24 do
		CheckListBox1.Items.Add(ARR_LIT_LBL_SIDREGS[i]);
	end;

end.
