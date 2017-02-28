object EditEventForm: TEditEventForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Edit Event Data...'
  ClientHeight = 268
  ClientWidth = 373
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 27
    Height = 13
    Caption = 'Data:'
  end
  object Label2: TLabel
    Left = 228
    Top = 8
    Width = 30
    Height = 13
    Caption = 'Value:'
  end
  object Label3: TLabel
    Left = 288
    Top = 36
    Width = 31
    Height = 13
    Caption = 'Label3'
  end
  object lstbxData: TListBox
    Left = 68
    Top = 8
    Width = 137
    Height = 201
    ItemHeight = 13
    TabOrder = 0
    OnClick = lstbxDataClick
  end
  object spedtValue: TSpinEdit
    Left = 288
    Top = 8
    Width = 81
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 1
    Value = 0
    OnChange = spedtValueChange
  end
  object Button1: TButton
    Left = 290
    Top = 235
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
end
