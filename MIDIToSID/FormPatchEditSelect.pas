//------------------------------------------------------------------------------
//FormPatchEditSelect
//===================
//Form for selecting Patches to edit in the MIDI To SID application.
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
unit FormPatchEditSelect;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
	MIDIToSIDClasses;

type
	TPatchEditSelectForm = class(TForm)
		lstbxPatches: TListBox;
		btnEdit: TButton;
		Label1: TLabel;
		Button1: TButton;
		procedure FormShow(Sender: TObject);
		procedure lstbxPatchesClick(Sender: TObject);
		procedure btnEditClick(Sender: TObject);
	private
		FProject: TMIDIToSIDProject;
		FSelected: Integer;
	public
        procedure EditPatches(const AProject: TMIDIToSIDProject);
	end;

var
	PatchEditSelectForm: TPatchEditSelectForm;

implementation

{$R *.dfm}

uses
	FormPatchEditor;


procedure TPatchEditSelectForm.btnEditClick(Sender: TObject);
	begin
	PatchEditorForm.EditPatch(FProject, FSelected);

	lstbxPatches.Items[FSelected]:= FProject.SIDPatches[FSelected].Name;
	end;

procedure TPatchEditSelectForm.EditPatches(const AProject: TMIDIToSIDProject);
	begin
	FProject:= AProject;
	ShowModal;
	end;

procedure TPatchEditSelectForm.FormShow(Sender: TObject);
	var
	i: Integer;

	begin
	lstbxPatches.Items.BeginUpdate;
	try
		lstbxPatches.Items.Clear;

		for i:= Low(TSIDPatches) to High(TSIDPatches) do
			lstbxPatches.Items.Add(FProject.SIDPatches[i].Name);

		finally
		lstbxPatches.Items.EndUpdate;
		end;

	lstbxPatches.Selected[0]:= True;
	lstbxPatchesClick(Self);
	end;

procedure TPatchEditSelectForm.lstbxPatchesClick(Sender: TObject);
	var
	i: Integer;

	begin
	FSelected:= -1;
	for i:= 0 to lstbxPatches.Items.Count - 1 do
		if  lstbxPatches.Selected[i] then
			begin
			FSelected:= i;
			Break;
			end;

	btnEdit.Enabled:= FSelected > -1;
	end;

end.
