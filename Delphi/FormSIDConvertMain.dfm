object SIDConvertMainForm: TSIDConvertMainForm
  Left = 0
  Top = 0
  Caption = 'SID to XSID Conversion Utility'
  ClientHeight = 459
  ClientWidth = 824
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 331
    Top = 401
    Width = 46
    Height = 13
    Caption = 'SID Type:'
  end
  object Label3: TLabel
    Left = 331
    Top = 347
    Width = 38
    Height = 13
    Caption = 'System:'
  end
  object Label2: TLabel
    Left = 8
    Top = 13
    Width = 80
    Height = 13
    Caption = 'Output Format:'
  end
  object Label1: TLabel
    Left = 331
    Top = 87
    Width = 54
    Height = 13
    Caption = 'Subsongs:'
  end
  object Label5: TLabel
    Left = 8
    Top = 65
    Width = 35
    Height = 13
    Caption = 'Songs:'
  end
  object Label6: TLabel
    Left = 543
    Top = 136
    Width = 59
    Height = 13
    Caption = 'SID Params:'
  end
  object Label7: TLabel
    Left = 543
    Top = 253
    Width = 56
    Height = 13
    Caption = 'Meta Data:'
  end
  object Label8: TLabel
    Left = 331
    Top = 374
    Width = 67
    Height = 13
    Caption = 'Update Rate:'
  end
  object Label9: TLabel
    Left = 699
    Top = 38
    Width = 36
    Height = 24
    AutoSize = False
    Caption = '   '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
  end
  object Label10: TLabel
    Left = 543
    Top = 109
    Width = 86
    Height = 13
    Caption = 'Override Length:'
  end
  object Label11: TLabel
    Left = 242
    Top = 13
    Width = 114
    Height = 13
    Caption = 'Compression Method:'
  end
  object VirtualStringTree1: TVirtualStringTree
    Left = 8
    Top = 84
    Width = 309
    Height = 336
    DragMode = dmAutomatic
    DragOperations = [doCopy]
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.MainColumn = -1
    TabOrder = 0
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toInitOnSave, toReportMode, toToggleOnDblClick, toWheelPanning, toEditOnClick]
    TreeOptions.PaintOptions = [toShowDropmark, toThemeAware, toUseBlendedImages]
    OnDragOver = VirtualStringTree1DragOver
    OnDragDrop = VirtualStringTree1DragDrop
    OnFocusChanged = VirtualStringTree1FocusChanged
    OnGetText = VirtualStringTree1GetText
    Columns = <>
  end
  object VirtualStringTree2: TVirtualStringTree
    Left = 331
    Top = 106
    Width = 200
    Height = 195
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.MainColumn = -1
    TabOrder = 1
    TreeOptions.MiscOptions = [toCheckSupport, toFullRepaintOnResize, toInitOnSave, toReportMode, toToggleOnDblClick, toWheelPanning, toEditOnClick]
    TreeOptions.PaintOptions = [toShowDropmark, toThemeAware, toUseBlendedImages]
    OnChecking = VirtualStringTree2Checking
    OnFocusChanged = VirtualStringTree2FocusChanged
    OnFocusChanging = VirtualStringTree2FocusChanging
    OnGetText = VirtualStringTree2GetText
    OnInitNode = VirtualStringTree2InitNode
    Columns = <>
  end
  object ComboBox1: TComboBox
    Left = 104
    Top = 10
    Width = 117
    Height = 21
    Style = csDropDownList
    ItemIndex = 2
    TabOrder = 2
    Text = '<Determine Best>'
    Items.Strings = (
      'Format 0'
      'Format 1'
      '<Determine Best>'
      '<Dump Only>')
  end
  object ComboBox2: TComboBox
    Left = 427
    Top = 344
    Width = 104
    Height = 21
    Style = csDropDownList
    Enabled = False
    ItemIndex = 1
    TabOrder = 3
    Text = 'PAL'
    Items.Strings = (
      'Default'
      'PAL'
      'NTSC'
      'Any')
  end
  object ComboBox3: TComboBox
    Left = 427
    Top = 398
    Width = 104
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 4
    Text = 'Any'
    OnChange = ComboBox3Change
    Items.Strings = (
      'Any'
      'MOS6581'
      'MOS8580')
  end
  object CheckBox6: TCheckBox
    Left = 580
    Top = 12
    Width = 109
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Archive Songs:'
    TabOrder = 5
    Visible = False
  end
  object Memo1: TMemo
    Left = 543
    Top = 155
    Width = 273
    Height = 84
    ScrollBars = ssVertical
    TabOrder = 6
  end
  object Memo2: TMemo
    Left = 543
    Top = 272
    Width = 273
    Height = 148
    ScrollBars = ssVertical
    TabOrder = 7
  end
  object Button2: TButton
    Left = 741
    Top = 426
    Width = 75
    Height = 25
    Caption = 'Play'
    TabOrder = 8
    OnClick = Button2Click
  end
  object Button1: TButton
    Left = 741
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Configure...'
    TabOrder = 9
    OnClick = Button1Click
  end
  object ComboBox4: TComboBox
    Left = 427
    Top = 371
    Width = 104
    Height = 21
    Style = csDropDownList
    ItemIndex = 4
    TabOrder = 10
    Text = '16X'
    OnChange = ComboBox4Change
    Items.Strings = (
      '1X'
      '2X'
      '4X'
      '8X'
      '16X')
  end
  object Button3: TButton
    Left = 741
    Top = 37
    Width = 75
    Height = 25
    Caption = 'Convert'
    TabOrder = 11
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 456
    Top = 426
    Width = 75
    Height = 25
    Caption = 'Reset'
    TabOrder = 12
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 456
    Top = 307
    Width = 75
    Height = 25
    Caption = 'Select All'
    TabOrder = 13
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 375
    Top = 307
    Width = 75
    Height = 25
    Caption = 'Defaut'
    TabOrder = 14
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 242
    Top = 426
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 15
    OnClick = Button7Click
  end
  object MaskEdit1: TMaskEdit
    Left = 674
    Top = 106
    Width = 61
    Height = 21
    Alignment = taRightJustify
    EditMask = '!99:99;1;0'
    MaxLength = 5
    TabOrder = 16
    Text = '  : 1'
    OnKeyPress = MaskEdit1KeyPress
  end
  object Button8: TButton
    Left = 741
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Reset'
    TabOrder = 17
    OnClick = Button8Click
  end
  object ComboBox5: TComboBox
    Left = 375
    Top = 10
    Width = 156
    Height = 21
    Style = csDropDownList
    ItemIndex = 2
    TabOrder = 18
    Text = 'LZMA - Smallest, Slower'
    Items.Strings = (
      'None - Largest, Fastest'
      'Deflate - Smaller, Faster'
      'LZMA - Smallest, Slower')
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 200
    OnTimer = Timer1Timer
    Left = 728
    Top = 4
  end
end
