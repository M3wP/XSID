object FileLoadForm: TFileLoadForm
  Left = 788
  Top = 197
  BorderStyle = bsNone
  Caption = 'FileLoadForm'
  ClientHeight = 120
  ClientWidth = 320
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 14
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 320
    Height = 120
    Align = alClient
    Style = bsRaised
  end
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 304
    Height = 16
    Alignment = taCenter
    AutoSize = False
    Caption = 'Loading'
    Color = clBtnFace
    ParentColor = False
  end
  object Label2: TLabel
    Left = 8
    Top = 40
    Width = 312
    Height = 16
    Alignment = taCenter
    AutoSize = False
    Caption = 'Please wait...'
    Color = clBtnFace
    ParentColor = False
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 80
    Width = 304
    Height = 20
    Smooth = True
    TabOrder = 0
  end
end
