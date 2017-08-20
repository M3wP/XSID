object Form1: TForm1
  Left = 312
  Top = 116
  Caption = 'Convert SID Dump to XSID'
  ClientHeight = 441
  ClientWidth = 385
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 11
    Width = 55
    Height = 13
    Caption = 'Dump File:'
    Color = clBtnFace
    ParentColor = False
  end
  object Label2: TLabel
    Left = 8
    Top = 49
    Width = 80
    Height = 13
    Caption = 'Output Format:'
    Color = clBtnFace
    ParentColor = False
  end
  object Label3: TLabel
    Left = 8
    Top = 76
    Width = 38
    Height = 13
    Caption = 'System:'
    Color = clBtnFace
    ParentColor = False
  end
  object Label4: TLabel
    Left = 8
    Top = 103
    Width = 46
    Height = 13
    Caption = 'SID Type:'
    Color = clBtnFace
    ParentColor = False
  end
  object Label5: TLabel
    Left = 8
    Top = 213
    Width = 59
    Height = 13
    Caption = 'SID Params:'
    Color = clBtnFace
    ParentColor = False
  end
  object Label6: TLabel
    Left = 8
    Top = 294
    Width = 56
    Height = 13
    Caption = 'Meta Data:'
    Color = clBtnFace
    ParentColor = False
  end
  object Label7: TLabel
    Left = 8
    Top = 130
    Width = 67
    Height = 13
    Caption = 'Update Rate:'
    Color = clBtnFace
    ParentColor = False
  end
  object SpeedButton1: TSpeedButton
    Left = 354
    Top = 8
    Width = 23
    Height = 22
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      18000000000000030000130B0000130B00000000000000000000C0C0C0C0C0C0
      C0C0C0C0C0C0BFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBF
      BFBFBFBFBEBEBEC0C0C0C0C0C0ABAEAF959FA15B64673C46493C46493C46493C
      46493C46483D47493E47493F494B3E47494B4B4B515151909090C0C0C01C6C80
      0BA1C917ABD315A9D314A9D112A8D110A8D00DA4CC0784A4097F9F0886A70AA5
      CD0D5C6E5151518F8F8FC0C0C0278AA410ACD51CADD61AACD517ABD416ABD314
      AAD212A9D20EA6CE057E9D0982A20A8EB1157F9A4B4B4BAAAAAAC0C0C0278BA5
      10ACD523AFD81FAED71DADD61AACD518ABD415AAD313AAD30A9DC3077F9E0986
      A620819A686868C0C0C0C0C0C02790AA13B1DA2DB3DC27B0D922AED721AED61D
      ADD619ACD416ABD30CA4CB0780A00479970F1010767676C0C0C0C0C0C02794AE
      17C2EF4BCBF73EC2EC31B7E026AFD821AED61EADD61AACD50EA4CC0980A00979
      94373737767676C0C0C0C0C0C02794AF1BC9F663DBFF5BD7FF50CFFA3EC0EA2A
      B2DB22AED61EAED610A6CD0A81A0087894363636767676C0C0C0C0C0C02794B0
      1ECAF86FE1FF67DEFF63DBFF5AD5FE43C3EE2BB2DB22AFD712A6CE0A81A10879
      95363636767676C0C0C0C0C0C02794B122CCF97AE6FF72E3FE6EE1FE66DCFF5A
      D6FE3FC0EB27B0D914A7CF0B81A1087895363636767676C0C0C0C0C0C02794B1
      26CEFA87EDFF7CE8FE75E4FE6EE0FE64DCFF52D0FB34B8E215A8D00D81A10879
      96363636767676C0C0C0C0C0C02794B128D1FB8EF1FF83ECFE7DE9FE74E3FE69
      DFFF5CD8FF43C4EF17A9D10D82A2087995363636767676C0C0C0C0C0C02794B2
      2CD2FB93F4FE89EFFE81EBFE77E6FE6DE0FE61DBFF4CCDF81CACD50D82A20878
      95363636737373C0C0C0C0C0C02696B42DD2FB97F7FF8AF1FF83ECFF79E7FF6D
      E1FF61DCFF50D2FD1FB1DA0F86A7098DAF636363A6A6A6C0C0C0C0C0C0306A7A
      31CDF032CBEE31CAED2FC9EE2CC7ED29C6EC26C4EC22C3EC1CBFEB19BBE724A1
      C0828282C0C0C0C0C0C0C0C0C086868671717172727272727272727272727272
      7272727272727272727272727272737373B9B9B9C0C0C0C0C0C0}
    OnClick = SpeedButton1Click
  end
  object ComboBox1: TComboBox
    Left = 104
    Top = 46
    Width = 117
    Height = 21
    Style = csDropDownList
    ItemIndex = 1
    TabOrder = 0
    Text = 'Format 1'
    Items.Strings = (
      'Format 0'
      'Format 1')
  end
  object ComboBox2: TComboBox
    Left = 104
    Top = 73
    Width = 117
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 1
    Text = 'PAL'
    Items.Strings = (
      'PAL'
      'NTSC'
      'NTSC Old'
      'PAL N (Drean)'
      'Nominal (1MHz/50Hz)')
  end
  object ComboBox3: TComboBox
    Left = 104
    Top = 100
    Width = 117
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 2
    Text = 'Any'
    Items.Strings = (
      'Any'
      'MOS6581'
      'MOS8580')
  end
  object Memo1: TMemo
    Left = 104
    Top = 210
    Width = 273
    Height = 75
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 162
    Width = 144
    Height = 24
    Alignment = taLeftJustify
    Caption = 'Compress Tracks:'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object CheckBox2: TCheckBox
    Left = 248
    Top = 48
    Width = 129
    Height = 24
    Caption = 'Process Voice 1'
    Checked = True
    State = cbChecked
    TabOrder = 5
  end
  object CheckBox3: TCheckBox
    Left = 248
    Top = 75
    Width = 129
    Height = 24
    Caption = 'Process Voice 2'
    Checked = True
    State = cbChecked
    TabOrder = 6
  end
  object CheckBox4: TCheckBox
    Left = 248
    Top = 102
    Width = 129
    Height = 24
    Caption = 'Process Voice 3'
    Checked = True
    State = cbChecked
    TabOrder = 7
  end
  object CheckBox5: TCheckBox
    Left = 248
    Top = 129
    Width = 129
    Height = 24
    Caption = 'Process Filt./Mixer'
    Checked = True
    State = cbChecked
    TabOrder = 8
  end
  object Memo2: TMemo
    Left = 104
    Top = 291
    Width = 273
    Height = 102
    ScrollBars = ssVertical
    TabOrder = 9
  end
  object Button1: TButton
    Left = 302
    Top = 408
    Width = 75
    Height = 25
    Caption = 'Convert'
    TabOrder = 10
    OnClick = Button1Click
  end
  object ComboBox4: TComboBox
    Left = 104
    Top = 127
    Width = 117
    Height = 21
    Style = csDropDownList
    ItemIndex = 4
    TabOrder = 11
    Text = '16X'
    Items.Strings = (
      '1X'
      '2X'
      '4X'
      '8X'
      '16X')
  end
  object Edit1: TEdit
    Left = 104
    Top = 8
    Width = 249
    Height = 21
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 12
  end
  object OpenDialog1: TOpenDialog
    Left = 256
    Top = 4
  end
end
