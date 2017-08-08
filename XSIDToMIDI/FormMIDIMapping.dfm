object MIDIMappingForm: TMIDIMappingForm
  Left = 0
  Top = 0
  Caption = 'MIDI Mapping...'
  ClientHeight = 365
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 12
    Width = 57
    Height = 13
    Caption = 'Instrument:'
  end
  object Label2: TLabel
    Left = 90
    Top = 12
    Width = 31
    Height = 13
    Caption = 'Label2'
  end
  object Label3: TLabel
    Left = 24
    Top = 72
    Width = 43
    Height = 13
    Caption = 'Channel:'
  end
  object Label4: TLabel
    Left = 24
    Top = 212
    Width = 37
    Height = 13
    Caption = 'Source:'
  end
  object Label5: TLabel
    Left = 192
    Top = 212
    Width = 30
    Height = 13
    Caption = 'Dest.:'
  end
  object RadioButton1: TRadioButton
    Left = 8
    Top = 44
    Width = 113
    Height = 17
    Caption = 'Note Mode'
    Checked = True
    TabOrder = 0
    TabStop = True
  end
  object RadioButton2: TRadioButton
    Left = 8
    Top = 184
    Width = 113
    Height = 17
    Caption = 'Drum Mode'
    TabOrder = 1
  end
  object ComboBox1: TComboBox
    Left = 90
    Top = 69
    Width = 75
    Height = 21
    Style = csDropDownList
    TabOrder = 2
    Items.Strings = (
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9'
      '11'
      '12'
      '13'
      '14'
      '15'
      '16')
  end
  object ComboBox2: TComboBox
    Left = 90
    Top = 209
    Width = 75
    Height = 21
    Style = csDropDownList
    TabOrder = 3
    OnChange = ComboBox2Change
  end
  object ComboBox3: TComboBox
    Left = 248
    Top = 209
    Width = 121
    Height = 21
    Style = csDropDownList
    TabOrder = 4
    OnChange = ComboBox3Change
  end
  object Button1: TButton
    Left = 294
    Top = 332
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object Button2: TButton
    Left = 213
    Top = 332
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 6
  end
  object CheckBox1: TCheckBox
    Left = 90
    Top = 96
    Width = 279
    Height = 17
    Caption = 'Extend Note Duration for Bend'
    TabOrder = 7
  end
  object CheckBox2: TCheckBox
    Left = 90
    Top = 119
    Width = 198
    Height = 17
    Caption = 'Chord Mode (no bends, no legato)'
    TabOrder = 8
  end
end
