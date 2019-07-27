unit FormXSIDListMain;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees,
	Vcl.ComCtrls, Vcl.ToolWin, System.Actions, Vcl.ActnList, Vcl.Menus,
	DModXSIDListMain;

type
	TXSIDListMainForm = class(TForm)
		ToolBar1: TToolBar;
		ToolButton1: TToolButton;
		vstEvents: TVirtualStringTree;
		TrackBar1: TTrackBar;
		procedure vstEventsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
				Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
		procedure vstEventsAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
		procedure FormKeyPress(Sender: TObject; var Key: Char);
	private
		function  DoDecodeReg(const AReg, AData: Byte): string;

	protected

	public

	end;

var
	XSIDListMainForm: TXSIDListMainForm;

implementation

{$R *.dfm}

uses
	C64Types, XSIDTypes;


{ TXSIDListMainForm }

function TXSIDListMainForm.DoDecodeReg(const AReg, AData: Byte): string;
	function  DoDecodeVocCntrl: string;
		var
		i: Integer;

		begin
		Result:= '';
		for i:= 7 downto 0 do
			if  (AData and (1 shl i)) <> 0 then
				begin
				if  Length(Result) > 0 then
					Result:= Result + ', ';
				Result:= Result + ARR_LIT_LBL_VOCCNTRL[i];
				end;
		end;

	function  DoDecodeVocReg(const AHigh, ALow: string): string;
		var
		n: Byte;

		begin
		n:= (AData and $F0) shr 4;
		Result:= AHigh + ':  ' + IntToStr(n) + ' $' + IntToHex(n, 1) + '; ' + ALow +
				':  ' + IntToStr(AData and $0F) + ' $' + IntToHex(AData and $0F, 1);
		end;

	function  DoDecodeFltRes: string;
		var
		n: Byte;
		i: Integer;

		begin
		Result:= '';
		for i:= 3 downto 0 do
			if  (AData and (1 shl i)) <> 0 then
				begin
				if  Length(Result) > 0 then
					Result:= Result + ', ';
				Result:= Result + ARR_LIT_LBL_FLTRES[i];
				end;

		n:= (AData and $F0) shr 4;
		Result:= 'Res:  ' + IntToStr(n) + ' $' + IntToHex(n, 1) + '; ' + Result;
		end;

	function  DoDecodeFltCntrl: string;
		var
		i: Integer;

		begin
		Result:= '';
		for i:= 3 downto 0 do
			if  (AData and (1 shl (i + 4))) <> 0 then
				begin
				if  Length(Result) > 0 then
					Result:= Result + ', ';
				Result:= Result + ARR_LIT_LBL_FLTCNTRL[i];
				end;

		Result:= 'Volume:  ' + IntToStr(AData and $0F) + ' $' +
				IntToHex(AData and $0F, 1) + '; ' + Result;
		end;

	begin
	if  AReg in [$04, $0B, $12] then
		Result:= DoDecodeVocCntrl
	else if AReg in [$05, $0C, $13] then
		Result:= DoDecodeVocReg('Attack', 'Decay')
	else if AReg in [$06, $0D, $14] then
		Result:= DoDecodeVocReg('Sustain', 'Release')
	else if AReg = $17 then
		Result:= DoDecodeFltRes
	else if AReg = $18 then
		Result:= DoDecodeFltCntrl
	else
		Result:= '';
	end;

procedure TXSIDListMainForm.FormKeyPress(Sender: TObject; var Key: Char);
	begin
	if  Key = #32 then
		begin
		if  not XSIDListMainDMod.Playing then
			XSIDListMainDMod.StartPlay
		else
			XSIDListMainDMod.StopPlay;
		end;
	end;

procedure TXSIDListMainForm.vstEventsAddToSelection(Sender: TBaseVirtualTree;
		Node: PVirtualNode);
	var
	n: PVirtualNode;
	p: Cardinal;

	begin
	if  not XSIDListMainDMod.Playing then
		begin
		XSIDListMainDMod.StartNode:= Node;

		p:= 0;
		n:= vstEvents.GetFirst(False);
		while  Assigned(n) and (n <> Node) do
			begin
			Inc(p, PXSIDEvent(XSIDListMainDMod.Events[n^.Index])^.offs);

			n:= XSIDListMainForm.vstEvents.GetNext(n);
			end;

		TrackBar1.Position:= p;
		end;
	end;

procedure TXSIDListMainForm.vstEventsGetText(Sender: TBaseVirtualTree;
		Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
		var CellText: string);
	var
	ev: PXSIDEvent;

	begin
	ev:= PXSIDEvent(XSIDListMainDMod.Events[Node^.Index]);

	if  Column = 0 then
		CellText:= IntToStr(Node^.Index)
	else if Column = 1 then
		CellText:= IntToStr(ev^.offs)
	else if Column = 2 then
		CellText:= ARR_LIT_LBL_SIDREGS[ev^.data.reg]
	else
		CellText:= Format('%-3d', [ev^.data.val]) + ' $' +
				IntToHex(ev^.data.val, 2) + '  [' +
				DoDecodeReg(ev^.data.reg, ev^.data.val) + ']';
	end;

end.

