object SIDConvProgressForm: TSIDConvProgressForm
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Conversion Progress'
  ClientHeight = 180
  ClientWidth = 442
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  PopupMode = pmAuto
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 34
    Width = 35
    Height = 13
    Caption = 'Songs:'
  end
  object Label2: TLabel
    Left = 8
    Top = 86
    Width = 58
    Height = 13
    Caption = 'Sub Songs:'
  end
  object Label3: TLabel
    Left = 76
    Top = 55
    Width = 33
    Height = 13
    Caption = 'Label3'
  end
  object Label4: TLabel
    Left = 76
    Top = 8
    Width = 178
    Height = 13
    Caption = 'Paused waiting for available CPU...'
    Visible = False
  end
  object Label5: TLabel
    Left = 8
    Top = 126
    Width = 41
    Height = 13
    Caption = 'Process:'
  end
  object ProgressBar1: TProgressBar
    Left = 76
    Top = 32
    Width = 358
    Height = 17
    TabOrder = 0
  end
  object ProgressBar2: TProgressBar
    Left = 76
    Top = 84
    Width = 358
    Height = 17
    TabOrder = 1
  end
  object ProgressBar3: TProgressBar
    Left = 76
    Top = 124
    Width = 358
    Height = 17
    TabOrder = 2
  end
end
