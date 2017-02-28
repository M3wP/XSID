//------------------------------------------------------------------------------
//FormPatchEditor
//===============
//Form for editing the Patches in the MIDI To SID application.
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
unit FormPatchEditor;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Generics.Collections, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
	Vcl.Dialogs, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
	MIDIToSIDClasses, Vcl.Menus;

type
	TPatchEditorForm = class(TForm)
		Label1: TLabel;
		trkbrAttack: TTrackBar;
		Label2: TLabel;
		trkbrDecay: TTrackBar;
		Label3: TLabel;
		trkbrSustain: TTrackBar;
		Label4: TLabel;
		trkbrRelease: TTrackBar;
		Label5: TLabel;
		Label6: TLabel;
		edtName: TEdit;
		Label7: TLabel;
		Label8: TLabel;
		Label9: TLabel;
		chkbxTriangle: TCheckBox;
		chkbxSaw: TCheckBox;
		chkbxPulse: TCheckBox;
		chkbxNoise: TCheckBox;
		Label10: TLabel;
		chkbxSync: TCheckBox;
		chkbxRing: TCheckBox;
		Label11: TLabel;
		spedtPWidth: TSpinEdit;
		chkbxFilter: TCheckBox;
		Label12: TLabel;
		Button1: TButton;
		Button2: TButton;
		Button3: TButton;
		Label27: TLabel;
		chkbxHardSync: TCheckBox;
		lblAtk: TLabel;
		lblDec: TLabel;
		lblSus: TLabel;
		lblRel: TLabel;
		Bevel1: TBevel;
		Button4: TButton;
		ScrollBox1: TScrollBox;
		PopupMenu1: TPopupMenu;
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure trkbrAttackChange(Sender: TObject);
		procedure edtNameChange(Sender: TObject);
		procedure trkbrDecayChange(Sender: TObject);
		procedure trkbrSustainChange(Sender: TObject);
		procedure trkbrReleaseChange(Sender: TObject);
		procedure chkbxTriangleClick(Sender: TObject);
		procedure chkbxSawClick(Sender: TObject);
		procedure chkbxPulseClick(Sender: TObject);
		procedure chkbxNoiseClick(Sender: TObject);
		procedure chkbxSyncClick(Sender: TObject);
		procedure chkbxRingClick(Sender: TObject);
		procedure spedtPWidthChange(Sender: TObject);
		procedure chkbxFilterClick(Sender: TObject);
		procedure chkbxHardSyncClick(Sender: TObject);
		procedure Button4Click(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
	private
		FPatch: TSIDPatch;

		FProject: TMIDIToSIDProject;
		FIndex: Integer;
		FChanging: Boolean;

		FFrames: TList<TFrame>;
		FCurrentFrame: TFrame;

	protected
		procedure PrepareControls;
		procedure MenuItemOnClick(ASender: TObject);

	public
		procedure EditPatch(const AProject: TMIDIToSIDProject;
				const AIndex: Integer);

		property  Changing: Boolean read FChanging;
		property  Patch: TSIDPatch read FPatch;
	end;

var
	PatchEditorForm: TPatchEditorForm;

implementation

{$R *.dfm}

uses
	MIDIToSIDTypes, FramePatchBandBase;


{ TPatchEditorForm }

procedure TPatchEditorForm.Button4Click(Sender: TObject);
	var
	p: TPoint;

	begin
	p.X:= Button4.Left + Button4.Width div 2;
	p.Y:= Button4.Top + Button4.Height;
	p:= ClientToScreen(p);

	PopupMenu1.Popup(p.X, p.Y);
	end;

procedure TPatchEditorForm.chkbxFilterClick(Sender: TObject);
	begin
	if  not FChanging then
		FPatch.Filter:= chkbxFilter.Checked;
	end;

procedure TPatchEditorForm.chkbxHardSyncClick(Sender: TObject);
	begin
	if  not FChanging then
		FPatch.NtOnHardSync:= chkbxHardSync.Checked;
	end;

procedure TPatchEditorForm.chkbxNoiseClick(Sender: TObject);
	begin
	if  not FChanging then
		if  chkbxNoise.Checked then
			Include(FPatch.Waveforms, swvNoise)
		else
			Exclude(FPatch.Waveforms, swvNoise);
	end;

procedure TPatchEditorForm.chkbxPulseClick(Sender: TObject);
	begin
	if  not FChanging then
		if  chkbxPulse.Checked then
			Include(FPatch.Waveforms, swvPulse)
		else
			Exclude(FPatch.Waveforms, swvPulse);
	end;

procedure TPatchEditorForm.chkbxRingClick(Sender: TObject);
	begin
	if  not FChanging then
		if  chkbxRing.Checked then
			Include(FPatch.Effects, sefRing)
		else
			Exclude(FPatch.Effects, sefRing);
	end;

procedure TPatchEditorForm.chkbxSawClick(Sender: TObject);
	begin
	if  not FChanging then
		if  chkbxSaw.Checked then
			Include(FPatch.Waveforms, swvSaw)
		else
			Exclude(FPatch.Waveforms, swvSaw);
	end;

procedure TPatchEditorForm.chkbxSyncClick(Sender: TObject);
	begin
	if  not FChanging then
		if  chkbxSync.Checked then
			Include(FPatch.Effects, sefSync)
		else
			Exclude(FPatch.Effects, sefSync);
	end;

procedure TPatchEditorForm.chkbxTriangleClick(Sender: TObject);
	begin
	if  not FChanging then
		if  chkbxTriangle.Checked then
			Include(FPatch.Waveforms, swvTriangle)
		else
			Exclude(FPatch.Waveforms, swvTriangle);
	end;

procedure TPatchEditorForm.EditPatch(const AProject: TMIDIToSIDProject;
		const AIndex: Integer);
	begin
	FProject:= AProject;
	FIndex:= AIndex;
	FPatch.Assign(FProject.SIDPatches[AIndex]);

	PrepareControls;

	ShowModal;
	end;

procedure TPatchEditorForm.edtNameChange(Sender: TObject);
	begin
	if  not FChanging then
		FPatch.Name:= edtName.Text;
	end;

procedure TPatchEditorForm.FormClose(Sender: TObject; var Action: TCloseAction);
	begin
	if  ModalResult = mrOk then
		begin
        FPatch.Default:= False;
		FProject.SIDPatches[FIndex].Assign(FPatch);
        FProject.Dirty:= True;
		end;
	end;

procedure TPatchEditorForm.FormCreate(Sender: TObject);
	var
	i: Integer;
	f: TPatchBandBaseFrame;
	mi: TMenuItem;

	begin
	FPatch.Initialise('internal');

	FFrames:= TList<TFrame>.Create;

	for i:= 0 to PatchBandClasses.Count - 1 do
		begin
		f:= PatchBandClasses[i].GetFrame.Create(Self) as TPatchBandBaseFrame;

		f.Attach(Self);
		FFrames.Add(f);

		mi:= TMenuItem.Create(Self);
		mi.Caption:= PatchBandClasses[i].GetName;
		mi.Tag:= i;
		mi.OnClick:= MenuItemOnClick;

		PopupMenu1.Items.Add(mi);
		end;

	FCurrentFrame:= nil;
	end;

procedure TPatchEditorForm.FormDestroy(Sender: TObject);
	var
	i: Integer;

	begin
	FCurrentFrame:= nil;

	for i:= FFrames.Count - 1 downto 0 do
		begin
		(FFrames[i] as TPatchBandBaseFrame).Detach;
		FFrames[i].Free;
		end;

	FFrames.Free;
	end;

procedure TPatchEditorForm.MenuItemOnClick(ASender: TObject);
	var
	i: Integer;
	mi: TMenuItem;

	begin
	if  Assigned(FCurrentFrame) then
		FCurrentFrame.Visible:= False;

	for i:= 0 to PopupMenu1.Items.Count - 1 do
		PopupMenu1.Items[i].Checked:= False;

	mi:= ASender as TMenuItem;
	mi.Checked:= True;

	FCurrentFrame:= FFrames[mi.Tag];
	FCurrentFrame.Left:= 0;
	FCurrentFrame.Top:= 0;
	FCurrentFrame.Parent:= ScrollBox1;
	FCurrentFrame.Visible:= True;
	end;

procedure TPatchEditorForm.PrepareControls;
	var
	i: Integer;

	begin
	FChanging:= True;
	try
		edtName.Text:= FPatch.Name;
		trkbrAttack.Position:= FPatch.Attack;
		trkbrDecay.Position:= FPatch.Decay;
		trkbrSustain.Position:= FPatch.Sustain;
		trkbrRelease.Position:= FPatch.Release;

		chkbxTriangle.Checked:= swvTriangle in FPatch.Waveforms;
		chkbxSaw.Checked:= swvSaw in FPatch.Waveforms;
		chkbxPulse.Checked:= swvPulse in FPatch.Waveforms;
		chkbxNoise.Checked:= swvNoise in FPatch.Waveforms;

		chkbxSync.Checked:= sefSync in FPatch.Effects;
		chkbxRing.Checked:= sefRing in FPatch.Effects;

		spedtPWidth.Value:= FPatch.PulseWidth;
		chkbxFilter.Checked:= FPatch.Filter;

		chkbxHardSync.Checked:= FPatch.NtOnHardSync;

		for i:= 0 to FFrames.Count - 1 do
			(FFrames[i] as TPatchBandBaseFrame).PrepareControls;

		finally
		FChanging:= False;
		end;
	end;

procedure TPatchEditorForm.spedtPWidthChange(Sender: TObject);
	begin
	if  not FChanging then
		FPatch.PulseWidth:= spedtPWidth.Value;
	end;

procedure TPatchEditorForm.trkbrAttackChange(Sender: TObject);
	begin
	trkbrAttack.Hint:= IntToStr(trkbrAttack.Position);
	lblAtk.Caption:= IntToHex(trkbrAttack.Position, 2);

	if  not FChanging then
		FPatch.Attack:= trkbrAttack.Position;
	end;

procedure TPatchEditorForm.trkbrDecayChange(Sender: TObject);
	begin
	trkbrDecay.Hint:= IntToStr(trkbrDecay.Position);
	lblDec.Caption:= IntToHex(trkbrDecay.Position, 2);

	if  not FChanging then
		FPatch.Decay:= trkbrDecay.Position;

	end;

procedure TPatchEditorForm.trkbrReleaseChange(Sender: TObject);
	begin
	trkbrRelease.Hint:= IntToStr(trkbrRelease.Position);
	lblRel.Caption:= IntToHex(trkbrRelease.Position, 2);

	if  not FChanging then
		FPatch.Release:= trkbrRelease.Position;
	end;

procedure TPatchEditorForm.trkbrSustainChange(Sender: TObject);
	begin
	trkbrSustain.Hint:= IntToStr(trkbrSustain.Position);
	lblSus.Caption:= IntToHex(trkbrSustain.Position, 2);

	if  not FChanging then
		FPatch.Sustain:= trkbrSustain.Position;
	end;

end.
