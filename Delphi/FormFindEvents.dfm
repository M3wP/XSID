object FindEventsForm: TFindEventsForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Find Events'
  ClientHeight = 240
  ClientWidth = 385
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 49
    Height = 13
    Caption = 'Registers:'
  end
  object Label2: TLabel
    Left = 8
    Top = 132
    Width = 35
    Height = 13
    Caption = 'Values:'
  end
  object Label3: TLabel
    Left = 92
    Top = 160
    Width = 3
    Height = 13
  end
  object CheckListBox1: TCheckListBox
    Left = 92
    Top = 8
    Width = 285
    Height = 97
    OnClickCheck = CheckListBox1ClickCheck
    ItemHeight = 13
    TabOrder = 0
  end
  object CheckBox1: TCheckBox
    Tag = 1
    Left = 344
    Top = 131
    Width = 30
    Height = 17
    Caption = '0'
    TabOrder = 1
    OnClick = CheckBox7Click
  end
  object CheckBox2: TCheckBox
    Tag = 2
    Left = 308
    Top = 131
    Width = 30
    Height = 17
    Caption = '1'
    TabOrder = 2
    OnClick = CheckBox7Click
  end
  object CheckBox3: TCheckBox
    Tag = 4
    Left = 272
    Top = 131
    Width = 30
    Height = 17
    Caption = '2'
    TabOrder = 3
    OnClick = CheckBox7Click
  end
  object CheckBox4: TCheckBox
    Tag = 8
    Left = 236
    Top = 131
    Width = 30
    Height = 17
    Caption = '3'
    TabOrder = 4
    OnClick = CheckBox7Click
  end
  object CheckBox5: TCheckBox
    Tag = 16
    Left = 200
    Top = 131
    Width = 30
    Height = 17
    Caption = '4'
    TabOrder = 5
    OnClick = CheckBox7Click
  end
  object CheckBox6: TCheckBox
    Tag = 32
    Left = 164
    Top = 131
    Width = 30
    Height = 17
    Caption = '5'
    TabOrder = 6
    OnClick = CheckBox7Click
  end
  object CheckBox7: TCheckBox
    Tag = 64
    Left = 128
    Top = 131
    Width = 30
    Height = 17
    Caption = '6'
    TabOrder = 7
    OnClick = CheckBox7Click
  end
  object CheckBox8: TCheckBox
    Tag = 128
    Left = 92
    Top = 131
    Width = 30
    Height = 17
    Caption = '7'
    TabOrder = 8
    OnClick = CheckBox7Click
  end
  object Button1: TButton
    Left = 302
    Top = 207
    Width = 75
    Height = 25
    Caption = 'Next'
    TabOrder = 9
    OnClick = Button1Click
  end
end
