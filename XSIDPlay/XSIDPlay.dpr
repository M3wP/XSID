program XSIDPlay;

uses
  Vcl.Forms,
  FormXSIDPlayMain in 'FormXSIDPlayMain.pas' {XSIDPlayMainForm},
  C64Thread in 'C64Thread.pas',
  C64Types in 'C64Types.pas',
  DirectSound in 'DirectSound.pas',
  DXTypes in 'DXTypes.pas',
  LibReSIDFP in 'LibReSIDFP.pas',
  ReSIDFiles in 'ReSIDFiles.pas',
  ReSIDThread in 'ReSIDThread.pas',
  ReSIDTypes in 'ReSIDTypes.pas',
  ReSIDAudioDSound in 'ReSIDAudioDSound.pas',
  FormReSIDConfig in 'FormReSIDConfig.pas' {ReSIDConfigForm},
  FormReSIDFilterConfig in 'FormReSIDFilterConfig.pas' {ReSIDFilterConfigForm},
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
  URangeEncoder in '..\LZMA.442b\compression\RangeCoder\URangeEncoder.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TXSIDPlayMainForm, XSIDPlayMainForm);
  Application.Run;
end.
