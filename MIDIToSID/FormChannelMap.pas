//------------------------------------------------------------------------------
//FormChannelMap
//==============
//Form for editing the MIDI Channel to SID Voice mapping in the MIDI To SID
//application.
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
unit FormChannelMap;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
	MIDIToSIDClasses;

type
	TChannelMapForm = class(TForm)
		Label1: TLabel;
		lstbxChannels: TListBox;
		Label2: TLabel;
		rbtnVoice1: TRadioButton;
		rbtnVoice2: TRadioButton;
		rbtnVoice3: TRadioButton;
		Button1: TButton;
    	rbtnVoiceNone: TRadioButton;
		procedure FormShow(Sender: TObject);
		procedure lstbxChannelsClick(Sender: TObject);
		procedure rbtnVoice1Click(Sender: TObject);
		procedure rbtnVoice2Click(Sender: TObject);
		procedure rbtnVoice3Click(Sender: TObject);
    	procedure rbtnVoiceNoneClick(Sender: TObject);
	private
		FSelected: Integer;
		FProject: TMIDIToSIDProject;
		FChanging: Boolean;
	public
		procedure EditChannelMap(const AProject: TMIDIToSIDProject);
	end;

var
	ChannelMapForm: TChannelMapForm;


implementation

{$R *.dfm}

uses
	MIDIToSIDTypes;


procedure TChannelMapForm.EditChannelMap(const AProject: TMIDIToSIDProject);
	begin
	FProject:= AProject;
	ShowModal;
	end;

procedure TChannelMapForm.FormShow(Sender: TObject);
	var
	i: Integer;

	begin
	lstbxChannels.Items.BeginUpdate;
	try
		lstbxChannels.Items.Clear;

		for i:= Low(TSIDChannelMap) to High(TSIDChannelMap) do
			lstbxChannels.Items.Add(IntToStr(i));

		finally
		lstbxChannels.Items.EndUpdate;
		end;

	lstbxChannels.Selected[0]:= True;
	lstbxChannelsClick(Self);
	end;

procedure TChannelMapForm.lstbxChannelsClick(Sender: TObject);
	var
	i: Integer;

	begin
	FSelected:= -1;

	for i:= 0 to lstbxChannels.Items.Count - 1 do
		if  lstbxChannels.Selected[i] then
			begin
			FSelected:= i + 1;
			Break;
			end;

	FChanging:= True;
	try
		if  FSelected > -1 then
			case FProject.SIDChannelMap[FSelected] of
				svsVoice1:
					rbtnVoice1.Checked:= True;
				svsVoice2:
					rbtnVoice2.Checked:= True;
				svsVoice3:
					rbtnVoice3.Checked:= True;
				else
					rbtnVoiceNone.Checked:= True;
				end
		else
			begin
			rbtnVoice1.Checked:= False;
			rbtnVoice2.Checked:= False;
			rbtnVoice3.Checked:= False;
			end;

		finally
		FChanging:= False;
		end;
	end;

procedure TChannelMapForm.rbtnVoice1Click(Sender: TObject);
	begin
	if  not FChanging then
		begin
		FProject.SIDChannelMap[FSelected]:= svsVoice1;
		FProject.Dirty:= True;
		end;
	end;

procedure TChannelMapForm.rbtnVoice2Click(Sender: TObject);
	begin
	if  not FChanging then
		begin
		FProject.SIDChannelMap[FSelected]:= svsVoice2;
		FProject.Dirty:= True;
		end;
	end;

procedure TChannelMapForm.rbtnVoice3Click(Sender: TObject);
	begin
	if  not FChanging then
		begin
		FProject.SIDChannelMap[FSelected]:= svsVoice3;
		FProject.Dirty:= True;
		end;
	end;

procedure TChannelMapForm.rbtnVoiceNoneClick(Sender: TObject);
	begin
	if  not FChanging then
		begin
		FProject.SIDChannelMap[FSelected]:= svsNone;
		FProject.Dirty:= True;
		end;
	end;

end.
