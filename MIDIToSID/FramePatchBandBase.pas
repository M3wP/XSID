//------------------------------------------------------------------------------
//FramePatchBandBase
//==================
//Base frame for the Patch Bands in the MIDI To SID application.
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
unit FramePatchBandBase;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
	FormPatchEditor;

type
	TPatchBandBaseFrame = class(TFrame)
	private
		{ Private declarations }
	protected
		FHostForm: TPatchEditorForm;

	public
		procedure Attach(const AHost: TPatchEditorForm); virtual;
		procedure Detach; virtual;
		procedure PrepareControls; virtual; abstract;
	end;


implementation

{$R *.dfm}

{ TPatchBandBaseFrame }

procedure TPatchBandBaseFrame.Attach(const AHost: TPatchEditorForm);
	begin
	FHostForm:= AHost;
	end;

procedure TPatchBandBaseFrame.Detach;
	begin
	FHostForm:= nil;
	end;

end.
