//------------------------------------------------------------------------------
//FrameXSIDCtrlPatchBand
//======================
//Frame for the XSID Controller Patch Band in the MIDI To SID application.
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
unit FrameXSIDCtrlPatchBand;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
	FramePatchBandBase, XSIDConvertor, Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.ExtCtrls;

type
	TXSIDCtrlPatchBandFrame = class(TPatchBandBaseFrame)
		Label30: TLabel;
		Label31: TLabel;
		Label32: TLabel;
		Label33: TLabel;
		Label34: TLabel;
		Label35: TLabel;
		Label36: TLabel;
		Panel3: TPanel;
		rbtnCtrlPWOrderLoHi: TRadioButton;
		rbtnCtrlPWOrderHiLo: TRadioButton;
		Panel4: TPanel;
		rbtnCtrlFreqOrderLoHi: TRadioButton;
		rbtnCtrlFreqOrderHiLo: TRadioButton;
		spedtCtrlPWLoDelay: TSpinEdit;
		spedtCtrlPWHiDelay: TSpinEdit;
		spedtCtrlFreqLoDelay: TSpinEdit;
		spedtCtrlFreqHiDelay: TSpinEdit;
		procedure rbtnCtrlPWOrderLoHiClick(Sender: TObject);
		procedure rbtnCtrlFreqOrderLoHiClick(Sender: TObject);
		procedure spedtCtrlPWLoDelayChange(Sender: TObject);
		procedure spedtCtrlPWHiDelayChange(Sender: TObject);
		procedure spedtCtrlFreqLoDelayChange(Sender: TObject);
		procedure spedtCtrlFreqHiDelayChange(Sender: TObject);
	private
		FBand: TXSIDCtrlPatchBand;

	protected

	public
		procedure PrepareControls; override;

	end;


implementation

{$R *.dfm}

uses
	MIDIToSIDTypes;


{ TXSIDCtrlPatchBandFrame }

procedure TXSIDCtrlPatchBandFrame.PrepareControls;
	begin
	FBand:= FHostForm.Patch.BandByName('XSID Controller') as TXSIDCtrlPatchBand;

	if  FBand.CtrlPWOrder = sboLoHi then
		rbtnCtrlPWOrderLoHi.Checked:= True
	else
		rbtnCtrlPWOrderHiLo.Checked:= True;

	spedtCtrlPWHiDelay.Value:= FBand.CtrlPWHiDelay;
	spedtCtrlPWLoDelay.Value:= FBand.CtrlPWLoDelay;

	if  FBand.CtrlFreqOrder = sboLoHi then
		rbtnCtrlFreqOrderLoHi.Checked:= True
	else
		rbtnCtrlFreqOrderHiLo.Checked:= True;

	spedtCtrlFreqHiDelay.Value:= FBand.CtrlFreqHiDelay;
	spedtCtrlFreqLoDelay.Value:= FBand.CtrlFreqLoDelay;
	end;

procedure TXSIDCtrlPatchBandFrame.rbtnCtrlFreqOrderLoHiClick(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		if  rbtnCtrlFreqOrderLoHi.Checked then
			FBand.CtrlFreqOrder:= sboLoHi
		else
			FBand.CtrlFreqOrder:= sboHiLo;
	end;

procedure TXSIDCtrlPatchBandFrame.rbtnCtrlPWOrderLoHiClick(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		if  rbtnCtrlPWOrderLoHi.Checked then
			FBand.CtrlPWOrder:= sboLoHi
		else
			FBand.CtrlPWOrder:= sboHiLo;
	end;

procedure TXSIDCtrlPatchBandFrame.spedtCtrlFreqHiDelayChange(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.CtrlFreqHiDelay:= spedtCtrlFreqHiDelay.Value;
	end;

procedure TXSIDCtrlPatchBandFrame.spedtCtrlFreqLoDelayChange(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.CtrlFreqLoDelay:= spedtCtrlFreqLoDelay.Value;
	end;

procedure TXSIDCtrlPatchBandFrame.spedtCtrlPWHiDelayChange(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.CtrlPWHiDelay:= spedtCtrlPWHiDelay.Value;
	end;

procedure TXSIDCtrlPatchBandFrame.spedtCtrlPWLoDelayChange(Sender: TObject);
	begin
	if  not FHostForm.Changing then
		FBand.CtrlPWLoDelay:= spedtCtrlPWLoDelay.Value;
	end;

end.
