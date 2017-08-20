object DumpProgressForm: TDumpProgressForm
  Left = 788
  Top = 197
  BorderStyle = bsNone
  Caption = 'FileLoadForm'
  ClientHeight = 144
  ClientWidth = 320
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  Position = poOwnerFormCenter
  OnDestroy = FormDestroy
  DesignSize = (
    320
    144)
  PixelsPerInch = 96
  TextHeight = 15
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 320
    Height = 144
    Align = alClient
    Style = bsRaised
    ExplicitHeight = 253
  end
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 304
    Height = 16
    Alignment = taCenter
    AutoSize = False
    Caption = 'Creating Dump Files'
    Color = clBtnFace
    ParentColor = False
  end
  object Label2: TLabel
    Left = 8
    Top = 40
    Width = 304
    Height = 16
    Alignment = taCenter
    AutoSize = False
    Caption = 'Please Wait...'
    Color = clBtnFace
    ParentColor = False
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 66
    Width = 304
    Height = 20
    Smooth = True
    Step = 1
    TabOrder = 0
  end
  object Button1: TButton
    Left = 237
    Top = 111
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = Button1Click
  end
end
