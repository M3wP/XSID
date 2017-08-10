object MIDIMappingForm: TMIDIMappingForm
  Left = 0
  Top = 0
  Caption = 'MIDI Mapping...'
  ClientHeight = 382
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
  DesignSize = (
    377
    382)
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
    Top = 135
    Width = 43
    Height = 13
    Caption = 'Channel:'
  end
  object Label4: TLabel
    Left = 24
    Top = 299
    Width = 37
    Height = 13
    Caption = 'Source:'
  end
  object Label5: TLabel
    Left = 192
    Top = 299
    Width = 30
    Height = 13
    Caption = 'Dest.:'
  end
  object Label6: TLabel
    Left = 24
    Top = 208
    Width = 42
    Height = 13
    Caption = 'P.Width:'
  end
  object Label7: TLabel
    Left = 24
    Top = 43
    Width = 31
    Height = 13
    Caption = 'Name:'
  end
  object RadioButton1: TRadioButton
    Left = 8
    Top = 107
    Width = 113
    Height = 17
    Caption = 'Note Mode'
    Checked = True
    TabOrder = 0
    TabStop = True
  end
  object RadioButton2: TRadioButton
    Left = 8
    Top = 271
    Width = 113
    Height = 17
    Caption = 'Drum Mode'
    TabOrder = 1
  end
  object ComboBox1: TComboBox
    Left = 90
    Top = 132
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
    Top = 296
    Width = 75
    Height = 21
    Style = csDropDownList
    TabOrder = 3
    OnChange = ComboBox2Change
  end
  object ComboBox3: TComboBox
    Left = 248
    Top = 296
    Width = 121
    Height = 21
    Style = csDropDownList
    TabOrder = 4
    OnChange = ComboBox3Change
  end
  object Button1: TButton
    Left = 294
    Top = 349
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
    ExplicitTop = 332
  end
  object Button2: TButton
    Left = 213
    Top = 349
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 6
    ExplicitTop = 332
  end
  object CheckBox1: TCheckBox
    Left = 90
    Top = 159
    Width = 279
    Height = 17
    Caption = 'Extend Note Duration for Bend'
    TabOrder = 7
  end
  object CheckBox2: TCheckBox
    Left = 90
    Top = 182
    Width = 198
    Height = 17
    Caption = 'Chord Mode (no bends, no legato)'
    TabOrder = 8
  end
  object ComboBox4: TComboBox
    Left = 90
    Top = 205
    Width = 97
    Height = 21
    Style = csDropDownList
    TabOrder = 9
    Items.Strings = (
      'None'
      'Single'
      'Double')
  end
  object CheckBox3: TCheckBox
    Left = 90
    Top = 232
    Width = 279
    Height = 17
    Caption = 'Output Effect Reference'
    TabOrder = 10
  end
  object CheckBox4: TCheckBox
    Left = 90
    Top = 67
    Width = 179
    Height = 17
    Caption = 'Suppress Output in Dump All'
    TabOrder = 11
  end
  object Edit1: TEdit
    Left = 90
    Top = 40
    Width = 279
    Height = 21
    MaxLength = 127
    TabOrder = 12
    Text = 'Edit1'
  end
end
