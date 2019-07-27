program XSIDList;

uses
  Vcl.Forms,
  FormXSIDConfig in 'Common\FormXSIDConfig.pas' {XSIDConfigForm},
  FormXSIDFilterConfig in 'Common\FormXSIDFilterConfig.pas' {XSIDFilterConfigForm},
  XSIDAudioDSound in 'Common\XSIDAudioDSound.pas',
  XSIDAudioDump in 'Common\XSIDAudioDump.pas',
  XSIDFiles in 'Common\XSIDFiles.pas',
  XSIDThread in 'Common\XSIDThread.pas',
  XSIDTypes in 'Common\XSIDTypes.pas',
  C64Thread in 'Common\C64Thread.pas',
  C64Types in 'Common\C64Types.pas',
  ReSIDFP in 'Common\ReSIDFP.pas',
  DModXSIDListMain in 'Delphi\DModXSIDListMain.pas' {XSIDListMainDMod: TDataModule},
  FormFilterView in 'Delphi\FormFilterView.pas' {FilterViewForm},
  FormFindEvents in 'Delphi\FormFindEvents.pas' {FindEventsForm},
  FormXSIDListMain in 'Delphi\FormXSIDListMain.pas' {XSIDListMainForm},
  FormFileLoad in 'Common\FormFileLoad.pas' {FileLoadForm},
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
  Application.CreateForm(TXSIDListMainDMod, XSIDListMainDMod);
  Application.CreateForm(TXSIDListMainForm, XSIDListMainForm);
  Application.CreateForm(TFilterViewForm, FilterViewForm);
  Application.CreateForm(TFindEventsForm, FindEventsForm);
  Application.CreateForm(TFileLoadForm, FileLoadForm);
  Application.Run;
end.
