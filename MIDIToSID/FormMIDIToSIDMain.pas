//------------------------------------------------------------------------------
//FormMIDIToSIDMain
//=================
//Application main form for the MIDI To SID application.
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
unit FormMIDIToSIDMain;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
	System.Actions, Vcl.ActnList, Vcl.Menus, Vcl.ComCtrls, Vcl.ToolWin, SMFTypes,
	VirtualTrees, MIDIToSIDClasses;

type
	TMIDIToSIDMainForm = class(TForm)
		MainMenu1: TMainMenu;
		ActionList1: TActionList;
		OpenDialog1: TOpenDialog;
		ToolBar1: TToolBar;
		ToolButton1: TToolButton;
		File1: TMenuItem;
		Edit1: TMenuItem;
		View1: TMenuItem;
		Tools1: TMenuItem;
		Help1: TMenuItem;
		ActFileOpen: TAction;
		Open1: TMenuItem;
		vstEvents: TVirtualStringTree;
		ActToolsPatchEdit: TAction;
		PatchEditor1: TMenuItem;
		ActToolsChannelMap: TAction;
		ChannelMap1: TMenuItem;
		ActEditEvent: TAction;
		EditEventData1: TMenuItem;
		N1: TMenuItem;
		ActFileProcess: TAction;
		ProcessFile1: TMenuItem;
		ActFileOpenProject: TAction;
		OpenDialog2: TOpenDialog;
		OpenProject1: TMenuItem;
		SaveDialog1: TSaveDialog;
		ActFileSaveProject: TAction;
		SaveProject1: TMenuItem;
		procedure ActFileOpenExecute(Sender: TObject);
		procedure vstEventsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
				Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
		procedure ActToolsPatchEditExecute(Sender: TObject);
		procedure ActToolsChannelMapExecute(Sender: TObject);
		procedure ActEditEventExecute(Sender: TObject);
		procedure vstEventsAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
		procedure ActFileProcessExecute(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
		procedure ActFileOpenProjectExecute(Sender: TObject);
		procedure ActFileSaveProjectExecute(Sender: TObject);
		procedure ActToolsPatchEditUpdate(Sender: TObject);
		procedure ActToolsChannelMapUpdate(Sender: TObject);
		procedure ActFileSaveProjectUpdate(Sender: TObject);
		procedure ActFileProcessUpdate(Sender: TObject);
		procedure ActEditEventUpdate(Sender: TObject);
	private
		FProject: TMIDIToSIDProject;
		FSelected: PSMFMTev;

        procedure DoLoadProjectSMF;

	public
		{ Public declarations }
	end;

var
	MIDIToSIDMainForm: TMIDIToSIDMainForm;


implementation

{$R *.dfm}

uses
	UITypes, FormPatchEditSelect, FormChannelMap, FormEditEvent;

type
	PPSMFMTev = ^PSMFMTev;


procedure TMIDIToSIDMainForm.ActEditEventExecute(Sender: TObject);
	begin
	EditEventForm.EditEvent(FSelected);

	vstEvents.Invalidate;
	end;

procedure TMIDIToSIDMainForm.ActEditEventUpdate(Sender: TObject);
	begin
	ActEditEvent.Enabled:= Assigned(FProject) and Assigned(FSelected);
	end;

procedure TMIDIToSIDMainForm.ActFileOpenExecute(Sender: TObject);
	begin
	if  Assigned(FProject)
	and FProject.Dirty then
		if  MessageDlg('Current Project is not saved.  Are you sure you want to ' +
				'create a new project?', mtConfirmation, [mbYes, mbNO], -1) = mrNo then
			Exit;

	if  not OpenDialog1.Execute then
		Exit;

	if  Assigned(FProject) then
		begin
		FProject.Free;
		vstEvents.RootNodeCount:= 0;
		end;

	FProject:= TMIDIToSIDProject.Create;
	FProject.SMFFileName:= OpenDialog1.FileName;
	FProject.ProjFileName:= ChangeFileExt(OpenDialog1.FileName, '.mid2sid');

	DoLoadProjectSMF;

	FProject.Dirty:= True;
	end;

procedure TMIDIToSIDMainForm.ActFileOpenProjectExecute(Sender: TObject);
	begin
	if  Assigned(FProject)
	and FProject.Dirty then
		if  MessageDlg('Current Project is not saved.  Are you sure you want to ' +
				'open a project?', mtConfirmation, [mbYes, mbNO], -1) = mrNo then
			Exit;

	if  not OpenDialog2.Execute then
		Exit;

	if  Assigned(FProject) then
		begin
		FProject.Free;
		vstEvents.RootNodeCount:= 0;
		end;

	FProject:= TMIDIToSIDProject.Create;
	FProject.LoadFromXML(OpenDialog2.FileName);

	DoLoadProjectSMF;

	FProject.Dirty:= False;
	end;

procedure TMIDIToSIDMainForm.ActFileProcessExecute(Sender: TObject);
	begin
	ProcessSMF(FProject);
	end;

procedure TMIDIToSIDMainForm.ActFileProcessUpdate(Sender: TObject);
	begin
	ActFileProcess.Enabled:= Assigned(FProject);
	end;

procedure TMIDIToSIDMainForm.ActFileSaveProjectExecute(Sender: TObject);
	begin
	if  not Assigned(FProject) then
		Exit;

	if  (not FProject.HasSaved) then
		begin
		SaveDialog1.FileName:= FProject.ProjFileName;

		if  (not SaveDialog1.Execute) then
			Exit
		else
			FProject.ProjFileName:= SaveDialog1.FileName;
		end;

	FProject.SaveToXML;
	FProject.HasSaved:= True;
	FProject.Dirty:= False;
	end;

procedure TMIDIToSIDMainForm.ActFileSaveProjectUpdate(Sender: TObject);
	begin
	ActFileSaveProject.Enabled:= Assigned(FProject);
	end;

procedure TMIDIToSIDMainForm.ActionList1Update(Action: TBasicAction;
		var Handled: Boolean);
	var
	s: string;

	begin
	if  Assigned(FProject) then
		begin
		s:= ChangeFileExt(ExtractFileName(FProject.ProjFileName), '');
		if  FProject.Dirty then
			s:= s + '*';

		s:= s + ' - ';
		end
	else
		s:= '';

	s:= s + 'MIDI To SID';

	Caption:= s;
	end;

procedure TMIDIToSIDMainForm.ActToolsChannelMapExecute(Sender: TObject);
	begin
	ChannelMapForm.EditChannelMap(FProject);
	end;

procedure TMIDIToSIDMainForm.ActToolsChannelMapUpdate(Sender: TObject);
	begin
	ActToolsChannelMap.Enabled:= Assigned(FProject);
	end;

procedure TMIDIToSIDMainForm.ActToolsPatchEditExecute(Sender: TObject);
	begin
	PatchEditSelectForm.EditPatches(FProject);
	end;

procedure TMIDIToSIDMainForm.ActToolsPatchEditUpdate(Sender: TObject);
	begin
	ActToolsPatchEdit.Enabled:= Assigned(FProject);
	end;

procedure TMIDIToSIDMainForm.DoLoadProjectSMF;
	var
	f: TFileStream;
	i: Cardinal;
	tch: PSMFChunk;
	trk: PSMFMTrk;
	evt: PSMFMTev;
	n: PVirtualNode;
	p: PPSMFMTev;

	begin
	f:= TFileStream.Create(FProject.SMFFileName, fmOpenRead);
	try
		ReadSMF(FProject.SMF, f);

		finally
		f.Free;
		end;

	i:= 0;
	if  Assigned(FProject.SMF) then
		begin
		tch:= FProject.SMF^.First^.Next;
		if  Assigned(tch) then
			begin
			trk:= tch^.Data;

			evt:= trk^.First;
			while Assigned(evt) do
				begin
				Inc(i);
				evt:= evt^.Next;
				end;
			end;
		end;

	vstEvents.NodeDataSize:= SizeOf(Pointer);
	vstEvents.RootNodeCount:= i;

	if  Assigned(FProject.SMF) then
		begin
		tch:= FProject.SMF^.First^.Next;
		if  Assigned(tch) then
			begin
			trk:= tch^.Data;

			n:= vstEvents.GetFirst(False);
			evt:= trk^.First;
			while Assigned(evt) do
				begin
				p:= PPSMFMTev(vstEvents.GetNodeData(n));
				p^:= evt;

				evt:= evt^.Next;
				n:= vstEvents.GetNext(n);
				end;
			end;
		end;
	end;

procedure TMIDIToSIDMainForm.FormCreate(Sender: TObject);
	begin
//	FProject:= TMIDIToSIDProject.Create;
	end;

procedure TMIDIToSIDMainForm.vstEventsAddToSelection(Sender: TBaseVirtualTree;
		Node: PVirtualNode);
	var
//	i: Cardinal;
//	tch: PSMFChunk;
//	trk: PSMFMTrk;
	evt: PSMFMTev;

	begin
	FSelected:= nil;

//	tch:= FSMFile^.First^.Next;
//	trk:= tch^.Data;
//
//	i:= 0;
//	evt:= trk^.First;
//	while i < Node^.Index do
//		begin
//		Inc(i);
//		evt:= evt^.Next;
//		end;

	evt:= PPSMFMTev(vstEvents.GetNodeData(Node))^;

	FSelected:= evt;
	end;

procedure TMIDIToSIDMainForm.vstEventsGetText(Sender: TBaseVirtualTree;
		Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
		var CellText: string);
	var
	i: Cardinal;
//	tch: PSMFChunk;
//	trk: PSMFMTrk;
	evt: PSMFMTev;

	begin
	if  Column = 0 then
		CellText:= IntToStr(Node^.Index)
	else
		begin
//		tch:= FSMFile^.First^.Next;
//		trk:= tch^.Data;
//
//		i:= 0;
//		evt:= trk^.First;
//		while i < Node^.Index do
//			begin
//			Inc(i);
//			evt:= evt^.Next;
//			end;
		evt:= PPSMFMTev(vstEvents.GetNodeData(Node))^;

		if  Column = 1 then
			CellText:= IntToStr(evt^.Delta)
		else if  Column = 2 then
			CellText:= ARR_LIT_LBL_SMFFAMILY[evt^.Family]
		else if  Column = 3 then
			if evt^.Family = sefSystem then
				CellText:= '0'
			else
				CellText:= IntToStr((evt^.Data[0] and $0F) + 1)
		else
			begin
			CellText:= '';
			if  (evt^.Family = sefSystem)
			and (evt^.Data[0] = $FF)
			and (evt^.Data[1] in [1, 2, 3, 4, 5]) then
				begin
				CellText:= IntToHex(evt^.Data[1], 2) + ' ';

				for i:= 3 to High(evt^.Data) do
					CellText:= CellText + string(AnsiChar(evt^.Data[i]));
				end
			else
				for i:= 0 to High(evt^.Data) do
					CellText:= CellText + IntToHex(evt^.Data[i], 2) + ' ';
			end;
		end;
	end;

end.
