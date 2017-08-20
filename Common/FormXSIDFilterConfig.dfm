object XSIDFilterConfigForm: TXSIDFilterConfigForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Select Filter Curve Value'
  ClientHeight = 128
  ClientWidth = 435
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  PopupMode = pmAuto
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Button2: TButton
    Left = 273
    Top = 97
    Width = 75
    Height = 25
    Caption = 'OK'
    Enabled = False
    ModalResult = 1
    TabOrder = 0
  end
  object Button1: TButton
    Left = 352
    Top = 97
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object Button3: TButton
    Left = 185
    Top = 97
    Width = 75
    Height = 25
    Caption = 'Reset'
    TabOrder = 2
    OnClick = Button3Click
  end
  object TrackBar1: TTrackBar
    Left = 8
    Top = 12
    Width = 419
    Height = 25
    ShowSelRange = False
    TabOrder = 3
    TickStyle = tsNone
    OnChange = TrackBar1Change
  end
  object Edit1: TEdit
    Left = 306
    Top = 52
    Width = 121
    Height = 21
    Alignment = taRightJustify
    TabOrder = 4
    Text = 'Edit1'
    OnKeyPress = Edit1KeyPress
  end
end
