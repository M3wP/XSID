//------------------------------------------------------------------------------
//FormEditEvent
//=============
//Form for editing MIDI events in the MIDI To SID application.
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
unit FormEditEvent;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SMFTypes,
  Vcl.StdCtrls, Vcl.Samples.Spin;

type
	TEditEventForm = class(TForm)
		Label1: TLabel;
		lstbxData: TListBox;
		spedtValue: TSpinEdit;
		Label2: TLabel;
		Label3: TLabel;
		Button1: TButton;
		procedure lstbxDataClick(Sender: TObject);
		procedure spedtValueChange(Sender: TObject);
	private
		FEvent: PSMFMTev;
		FChanging: Boolean;
		FSelected: Integer;

		function  DoGetDataText(const AIndex: Integer): string;

	protected
		procedure PrepareControls;

	public
		procedure EditEvent(const AEvent: PSMFMTev);
	end;


var
	EditEventForm: TEditEventForm;


implementation

{$R *.dfm}

{ TEditEventForm }

function TEditEventForm.DoGetDataText(const AIndex: Integer): string;
	begin
	Result:= Format('%2.2d - %3.3d ($%2.2x)', [AIndex, FEvent^.Data[AIndex],
			FEvent^.Data[AIndex]]);
	end;

procedure TEditEventForm.EditEvent(const AEvent: PSMFMTev);
	begin
	FEvent:= AEvent;

	PrepareControls;

	ShowModal;
	end;

procedure TEditEventForm.lstbxDataClick(Sender: TObject);
	var
	i: Integer;

	begin
	FSelected:= -1;

	for i:= 0 to lstbxData.Count - 1 do
		if  lstbxData.Selected[i] then
			begin
			FSelected:= i;
			Break;
			end;

	if  FSelected > -1 then
		begin
		FChanging:= True;
		try
			spedtValue.Value:= FEvent^.Data[FSelected];
			spedtValue.ReadOnly:= FSelected = 0;

			if  FSelected = 0 then
				spedtValue.Color:= clBtnFace
			else
                spedtValue.Color:= clWindow;

			finally
			FChanging:= False;
			end;
		end;
	end;

procedure TEditEventForm.PrepareControls;
	var
	i: Integer;

	begin
	lstbxData.Items.BeginUpdate;
	try
		lstbxData.Items.Clear;

		for i:= 0 to High(FEvent^.Data) do
			lstbxData.Items.Add(DoGetDataText(i));

		finally
		lstbxData.Items.EndUpdate;
		end;

	lstbxData.Selected[0]:= True;
	lstbxDataClick(Self);
	end;

procedure TEditEventForm.spedtValueChange(Sender: TObject);
	begin
	Label3.Caption:= '($' + IntToHex(spedtValue.Value, 2) + ')';

	if  not FChanging then
		begin
		FEvent^.Data[FSelected]:= spedtValue.Value;
		lstbxData.Items[FSelected]:= DoGetDataText(FSelected);
		end;
	end;

end.
