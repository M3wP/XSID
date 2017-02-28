object ChannelMapForm: TChannelMapForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Channel Map'
  ClientHeight = 347
  ClientWidth = 398
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 69
    Height = 13
    Caption = 'MIDI Channel:'
  end
  object Label2: TLabel
    Left = 260
    Top = 8
    Width = 49
    Height = 13
    Caption = 'SID Voice:'
  end
  object lstbxChannels: TListBox
    Left = 112
    Top = 8
    Width = 121
    Height = 269
    ItemHeight = 13
    TabOrder = 0
    OnClick = lstbxChannelsClick
  end
  object rbtnVoice1: TRadioButton
    Left = 340
    Top = 31
    Width = 50
    Height = 17
    Caption = '1'
    TabOrder = 1
    OnClick = rbtnVoice1Click
  end
  object rbtnVoice2: TRadioButton
    Left = 340
    Top = 54
    Width = 50
    Height = 17
    Caption = '2'
    TabOrder = 2
    OnClick = rbtnVoice2Click
  end
  object rbtnVoice3: TRadioButton
    Left = 340
    Top = 77
    Width = 50
    Height = 17
    Caption = '3'
    TabOrder = 3
    OnClick = rbtnVoice3Click
  end
  object Button1: TButton
    Left = 315
    Top = 314
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 4
  end
  object rbtnVoiceNone: TRadioButton
    Left = 340
    Top = 8
    Width = 50
    Height = 17
    Caption = 'None'
    TabOrder = 5
    OnClick = rbtnVoiceNoneClick
  end
end
