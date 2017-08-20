program DumpConvert;

{$IFDEF FPC}
    {$MODE Delphi}
{$ENDIF}

uses
{$IFNDEF FPC}
{$ELSE}
  Interfaces,
{$ENDIF}
  Forms,
  FormDumpConvertMain in 'Common\FormDumpConvertMain.pas' {Form1},
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
{$IFDEF MSWINDOWS}
  Application.MainFormOnTaskbar := True;
{$ENDIF}
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
