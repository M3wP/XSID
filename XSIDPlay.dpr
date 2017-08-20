program XSIDPlay;

uses
  Forms,
  FormXSIDPlayMain in 'Delphi/FormXSIDPlayMain.pas' {XSIDPlayMainForm},
  C64Thread in 'Common/C64Thread.pas',
  C64Types in 'Common/C64Types.pas',
  ReSIDFP in 'Common/ReSIDFP.pas',
  XSIDFiles in 'Common/XSIDFiles.pas',
  XSIDThread in 'Common/XSIDThread.pas',
  XSIDTypes in 'Common/XSIDTypes.pas',
  XSIDAudioDSound in 'Common/XSIDAudioDSound.pas',
  FormXSIDConfig in 'Common/FormXSIDConfig.pas' {ReSIDConfigForm},
  FormXSIDFilterConfig in 'Common/FormXSIDFilterConfig.pas' {ReSIDFilterConfigForm},
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
  XSIDAudioDump in 'Common/XSIDAudioDump.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TXSIDPlayMainForm, XSIDPlayMainForm);
  Application.Run;
end.
