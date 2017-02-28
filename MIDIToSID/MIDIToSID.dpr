program MIDIToSID;

uses
  Vcl.Forms,
  FormMIDIToSIDMain in 'FormMIDIToSIDMain.pas' {MIDIToSIDMainForm},
  SMFTypes in 'SMFTypes.pas',
  MIDIToSIDTypes in 'MIDIToSIDTypes.pas',
  FormPatchEditSelect in 'FormPatchEditSelect.pas' {PatchEditSelectForm},
  FormPatchEditor in 'FormPatchEditor.pas' {PatchEditorForm},
  FormChannelMap in 'FormChannelMap.pas' {ChannelMapForm},
  FormEditEvent in 'FormEditEvent.pas' {EditEventForm},
  C64Types in 'C64Types.pas',
  MIDIToSIDClasses in 'MIDIToSIDClasses.pas',
  XSIDConvertor in 'XSIDConvertor.pas',
  FramePatchBandBase in 'FramePatchBandBase.pas' {PatchBandBaseFrame: TFrame},
  FrameXSIDNtOnPatchBand in 'FrameXSIDNtOnPatchBand.pas' {XSIDNtOnPatchBandFrame: TFrame},
  FrameXSIDCtrlPatchBand in 'FrameXSIDCtrlPatchBand.pas' {XSIDCtrlPatchBandFrame: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMIDIToSIDMainForm, MIDIToSIDMainForm);
  Application.CreateForm(TPatchEditSelectForm, PatchEditSelectForm);
  Application.CreateForm(TPatchEditorForm, PatchEditorForm);
  Application.CreateForm(TChannelMapForm, ChannelMapForm);
  Application.CreateForm(TEditEventForm, EditEventForm);
  Application.Run;
end.
