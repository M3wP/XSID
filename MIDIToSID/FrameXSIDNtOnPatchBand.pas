//------------------------------------------------------------------------------
//FrameXSIDNtOnPatchBand
//======================
//Frame for the XSID NoteOn Patch Band in the MIDI To SID application.
//
//
//Copyright (C) 2017, Daniel England.
//All Rights Reserved.  Released under the GPL.
//
//This program is free software: you can redistribute it and/or modify it under
//the terms of the GNU General Public License as published by the Free Software
//Foundation, either version 3 of the License, or (at your option) any later
//version.
//
//This program is distributed in the hope that it will be useful, but WITHOUT
//ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//details.
//
//You should have received a copy of the GNU General Public License along with
//this program.  If not, see <http://www.gnu.org/licenses/>.
//
//------------------------------------------------------------------------------
unit FrameXSIDNtOnPatchBand;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
	FramePatchBandBase, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin, XSIDConvertor;

type
	TXSIDNtOnPatchBandFrame = class(TPatchBandBaseFrame)
		Label13: TLabel;
		Label14: TLabel;
		Label15: TLabel;
		Label16: TLabel;
		Label17: TLabel;
		Label18: TLabel;
		Label19: TLabel;
		Label20: TLabel;
		Label21: TLabel;
		Label22: TLabel;
		Label23: TLabel;
		Label24: TLabel;
		Label25: TLabel;
		Label26: TLabel;
		Label28: TLabel;
		Label29: TLabel;
		chkbxAlwaysEnv: TCheckBox;
		chkbxAlwaysPW: TCheckBox;
		chkbxPWAfterGate: TCheckBox;
		chkbxFreqAfterGate: TCheckBox;
		chkbxSusBeforeAtk: TCheckBox;
		spedtAtkDecDelay: TSpinEdit;
		spedtSusRelDelay: TSpinEdit;
		Panel1: TPanel;
		rbtnNtOnPWOrderLoHi: TRadioButton;
		rbtnNtOnPWOrderHiLo: TRadioButton;
		Panel2: TPanel;
		rbtnNtOnFreqOrderLoHi: TRadioButton;
		rbtnNtOnFreqOrderHiLo: TRadioButton;
		spedtNtOnPWLoDelay: TSpinEdit;
		spedtNtOnPWHiDelay: TSpinEdit;
		spedtNtOnFreqLoDelay: TSpinEdit;
		spedtNtOnFreqHiDelay: TSpinEdit;
		spedtHardSyncDelay: TSpinEdit;
		spedtGateDelay: TSpinEdit;
		procedure chkbxAlwaysEnvClick(Sender: TObject);
		procedure chkbxAlwaysPWClick(Sender: TObject);
		procedure chkbxPWAfterGateClick(Sender: TObject);
		procedure chkbxFreqAfterGateClick(Sender: TObject);
		procedure rbtnNtOnPWOrderLoHiClick(Sender: TObject);
		procedure rbtnNtOnFreqOrderLoHiClick(Sender: TObject);
		procedure chkbxSusBeforeAtkClick(Sender: TObject);
		procedure spedtAtkDecDelayChange(Sender: TObject);
		procedure spedtSusRelDelayChange(Sender: TObject);
		procedure spedtNtOnPWLoDelayChange(Sender: TObject);
		procedure spedtNtOnPWHiDelayChange(Sender: TObject);
		procedure spedtNtOnFreqLoDelayChange(Sender: TObject);
		procedure spedtNtOnFreqHiDelayChange(Sender: TObject);
		procedure spedtHardSyncDelayChange(Sender: TObject);
		procedure spedtGateDelayChange(Sender: TObject);
	private
		FBand: TXSIDNtOnPatchBand;
	protected
	public
		procedure PrepareControls; override;
	end;


implementation

{$R *.dfm}

uses
	MIDIToSIDTypes;


{ TXSIDNtOnPatchBandFrame }

procedure TXSIDNtOnPatchBandFrame.chkbxAlwaysEnvClick(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.NtOnAlwaysEnv:= chkbxAlwaysEnv.Checked;
	end;

procedure TXSIDNtOnPatchBandFrame.chkbxAlwaysPWClick(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.NtOnAlwaysPW:= chkbxAlwaysPW.Checked;
	end;

procedure TXSIDNtOnPatchBandFrame.chkbxFreqAfterGateClick(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.NtOnFreqAfterGate:= chkbxFreqAfterGate.Checked;
	end;

procedure TXSIDNtOnPatchBandFrame.chkbxPWAfterGateClick(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.NtOnPWAfterGate:= chkbxPWAfterGate.Checked;
	end;

procedure TXSIDNtOnPatchBandFrame.chkbxSusBeforeAtkClick(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.NtOnSusBeforeAtk:= chkbxSusBeforeAtk.Checked;
	end;

procedure TXSIDNtOnPatchBandFrame.PrepareControls;
	begin
	FBand:= FHostForm.Patch.BandByName('XSID NoteOn') as TXSIDNtOnPatchBand;

	chkbxAlwaysEnv.Checked:= FBand.NtOnAlwaysEnv;
	chkbxAlwaysPW.Checked:= FBand.NtOnAlwaysPW;
	chkbxPWAfterGate.Checked:= FBand.NtOnPWAfterGate;
	chkbxFreqAfterGate.Checked:= FBand.NtOnFreqAfterGate;
	chkbxSusBeforeAtk.Checked:= FBand.NtOnSusBeforeAtk;
	spedtAtkDecDelay.Value:= FBand.NtOnAtkDecDelay;
	spedtSusRelDelay.Value:= FBand.NtOnSusRelDelay;

	if  FBand.NtOnPWOrder = sboLoHi then
		rbtnNtOnPWOrderLoHi.Checked:= True
	else
		rbtnNtOnPWOrderHiLo.Checked:= True;

	spedtNtOnPWHiDelay.Value:= FBand.NtOnPWHiDelay;
	spedtNtOnPWLoDelay.Value:= FBand.NtOnPWLoDelay;

	if  FBand.NtOnFreqOrder = sboLoHi then
		rbtnNtOnFreqOrderLoHi.Checked:= True
	else
		rbtnNtOnFreqOrderHiLo.Checked:= True;

	spedtNtOnFreqHiDelay.Value:= FBand.NtOnFreqHiDelay;
	spedtNtOnFreqLoDelay.Value:= FBand.NtOnFreqLoDelay;

	spedtHardSyncDelay.Value:= FBand.NtOnHardSyncDelay;
	spedtGateDelay.Value:= FBand.NtOnGateDelay;
	end;

procedure TXSIDNtOnPatchBandFrame.rbtnNtOnFreqOrderLoHiClick(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		if  rbtnNtOnFreqOrderLoHi.Checked then
			FBand.NtOnFreqOrder:= sboLoHi
		else
			FBand.NtOnFreqOrder:= sboHiLo;
	end;

procedure TXSIDNtOnPatchBandFrame.rbtnNtOnPWOrderLoHiClick(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		if  rbtnNtOnPWOrderLoHi.Checked then
			FBand.NtOnPWOrder:= sboLoHi
		else
			FBand.NtOnPWOrder:= sboHiLo;
	end;

procedure TXSIDNtOnPatchBandFrame.spedtAtkDecDelayChange(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.NtOnAtkDecDelay:= spedtAtkDecDelay.Value;
	end;

procedure TXSIDNtOnPatchBandFrame.spedtGateDelayChange(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.NtOnGateDelay:= spedtGateDelay.Value;
	end;

procedure TXSIDNtOnPatchBandFrame.spedtHardSyncDelayChange(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.NtOnHardSyncDelay:= spedtHardSyncDelay.Value;
	end;

procedure TXSIDNtOnPatchBandFrame.spedtNtOnFreqHiDelayChange(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.NtOnFreqHiDelay:= spedtNtOnFreqHiDelay.Value;
	end;

procedure TXSIDNtOnPatchBandFrame.spedtNtOnFreqLoDelayChange(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.NtOnFreqLoDelay:= spedtNtOnFreqLoDelay.Value;
	end;

procedure TXSIDNtOnPatchBandFrame.spedtNtOnPWHiDelayChange(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.NtOnPWHiDelay:= spedtNtOnPWHiDelay.Value;
	end;

procedure TXSIDNtOnPatchBandFrame.spedtNtOnPWLoDelayChange(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.NtOnPWLoDelay:= spedtNtOnPWLoDelay.Value;
	end;

procedure TXSIDNtOnPatchBandFrame.spedtSusRelDelayChange(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.NtOnSusRelDelay:= spedtSusRelDelay.Value;
	end;

end.
