program XSIDToMIDI;

{$MODE Delphi}

{$IFDEF UNIX}
	{$DEFINE USECTHREADS}
{$ENDIF}

uses
{$IFDEF UNIX}
  cthreads,
{$ENDIF}
  Forms,
  Interfaces,
  FormXSIDToMIDIMain in 'FPC\FormXSIDToMIDIMain.pas' {XSIDToMIDIMainForm},
  FormFileLoad in 'Common\FormFileLoad.pas' {FileLoadForm},
  C64Types in 'Common\C64Types.pas',
  XSIDFiles in 'Common\XSIDFiles.pas',
  ULZBinTree in 'LZMA.442b\compression\LZ\ULZBinTree.pas',
  ULZInWindow in 'LZMA.442b\compression\LZ\ULZInWindow.pas',
  ULZOutWindow in 'LZMA.442b\compression\LZ\ULZOutWindow.pas',
  ULZMABase in 'LZMA.442b\compression\LZMA\ULZMABase.pas',
  ULZMACommon in 'LZMA.442b\compression\LZMA\ULZMACommon.pas',
  ULZMADecoder in 'LZMA.442b\compression\LZMA\ULZMADecoder.pas',
  ULZMAEncoder in 'LZMA.442b\compression\LZMA\ULZMAEncoder.pas',
  UBitTreeDecoder in 'LZMA.442b\compression\RangeCoder\UBitTreeDecoder.pas',
  UBitTreeEncoder in 'LZMA.442b\compression\RangeCoder\UBitTreeEncoder.pas',
  URangeDecoder in 'LZMA.442b\compression\RangeCoder\URangeDecoder.pas',
  URangeEncoder in 'LZMA.442b\compression\RangeCoder\URangeEncoder.pas',
  XSIDTypes in 'Common\XSIDTypes.pas',
  XSIDAudioDump in 'Common\XSIDAudioDump.pas',
  XSIDToMIDITypes in 'Common\XSIDToMIDITypes.pas',
  XSIDThread in 'Common\XSIDThread.pas',
  C64Thread in 'Common\C64Thread.pas',
  ReSIDFP in 'Common\ReSIDFP.pas',
  FormDumpProgress in 'Common\FormDumpProgress.pas' {DumpProgressForm},
  FormMIDIMapping in 'Common\FormMIDIMapping.pas' {MIDIMappingForm};

{$R *.res}

begin
  Application.Initialize;
{$IFDEF MSWINDOWS}
  Application.MainFormOnTaskbar := True;
{$ENDIF}
  Application.CreateForm(TXSIDToMIDIMainForm, XSIDToMIDIMainForm);
  Application.CreateForm(TMIDIMappingForm, MIDIMappingForm);
  Application.Run;
end.
