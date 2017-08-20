program SIDConvert;

uses
  Forms,
  FormSIDConvertMain in 'Delphi\FormSIDConvertMain.pas' {SIDConvertMainForm},
  FormSIDConvertConfig in 'Delphi\FormSIDConvertConfig.pas' {SIDConvertConfigForm},
  SIDConvTypes in 'Common\SIDConvTypes.pas',
  SIDPlay in 'Common\SIDPlay.pas',
  FormSIDConvProgress in 'Common\FormSIDConvProgress.pas' {SIDConvProgressForm},
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
  URangeEncoder in 'LZMA.442b\compression\RangeCoder\URangeEncoder.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TSIDConvertMainForm, SIDConvertMainForm);
  Application.CreateForm(TSIDConvertConfigForm, SIDConvertConfigForm);
  Application.CreateForm(TSIDConvProgressForm, SIDConvProgressForm);
  Application.Run;
end.
