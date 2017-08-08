program XSIDToMIDI;

uses
  Vcl.Forms,
  FormXSIDToMIDIMain in 'FormXSIDToMIDIMain.pas' {XSIDToMIDIMainForm},
  FormFileLoad in 'FormFileLoad.pas' {FileLoadForm},
  C64Types in 'C64Types.pas',
  XSIDFiles in 'XSIDFiles.pas',
  ULZBinTree in '..\LZMA.442b\compression\LZ\ULZBinTree.pas',
  ULZInWindow in '..\LZMA.442b\compression\LZ\ULZInWindow.pas',
  ULZOutWindow in '..\LZMA.442b\compression\LZ\ULZOutWindow.pas',
  ULZMABase in '..\LZMA.442b\compression\LZMA\ULZMABase.pas',
  ULZMACommon in '..\LZMA.442b\compression\LZMA\ULZMACommon.pas',
  ULZMADecoder in '..\LZMA.442b\compression\LZMA\ULZMADecoder.pas',
  ULZMAEncoder in '..\LZMA.442b\compression\LZMA\ULZMAEncoder.pas',
  UBitTreeDecoder in '..\LZMA.442b\compression\RangeCoder\UBitTreeDecoder.pas',
  UBitTreeEncoder in '..\LZMA.442b\compression\RangeCoder\UBitTreeEncoder.pas',
  URangeDecoder in '..\LZMA.442b\compression\RangeCoder\URangeDecoder.pas',
  URangeEncoder in '..\LZMA.442b\compression\RangeCoder\URangeEncoder.pas',
  XSIDTypes in 'XSIDTypes.pas',
  XSIDAudioDump in 'XSIDAudioDump.pas',
  XSIDToMIDITypes in 'XSIDToMIDITypes.pas',
  XSIDThread in 'XSIDThread.pas',
  C64Thread in 'C64Thread.pas',
  LibReSIDFP in 'LibReSIDFP.pas',
  FormDumpProgress in 'FormDumpProgress.pas' {DumpProgressForm},
  FormMIDIMapping in 'FormMIDIMapping.pas' {MIDIMappingForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TXSIDToMIDIMainForm, XSIDToMIDIMainForm);
  Application.CreateForm(TFileLoadForm, FileLoadForm);
  Application.CreateForm(TDumpProgressForm, DumpProgressForm);
  Application.CreateForm(TMIDIMappingForm, MIDIMappingForm);
  Application.Run;
end.
