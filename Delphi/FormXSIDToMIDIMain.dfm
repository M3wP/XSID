object XSIDToMIDIMainForm: TXSIDToMIDIMainForm
  Left = 0
  Top = 0
  Caption = 'XSID To MIDI'
  ClientHeight = 731
  ClientWidth = 950
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object vstInstruments: TVirtualStringTree
    AlignWithMargins = True
    Left = 4
    Top = 101
    Width = 942
    Height = 453
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoVisible]
    TabOrder = 0
    TreeOptions.AutoOptions = [toAutoScrollOnExpand, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
    TreeOptions.MiscOptions = [toFullRepaintOnResize, toGridExtensions, toInitOnSave, toReportMode, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowHorzGridLines, toShowVertGridLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnDblClick = vstInstrumentsDblClick
    OnGetText = vstInstrumentsGetText
    Columns = <
      item
        Position = 0
        Width = 60
        WideText = 'Index'
      end
      item
        Position = 1
        Width = 125
        WideText = 'Name'
      end
      item
        Position = 2
        Width = 60
        WideText = 'Voice'
      end
      item
        Position = 3
        Width = 60
        WideText = 'Attack'
      end
      item
        Position = 4
        Width = 60
        WideText = 'Decay'
      end
      item
        Position = 5
        Width = 60
        WideText = 'Release'
      end
      item
        Position = 6
        Width = 140
        WideText = 'Waveforms'
      end
      item
        Position = 7
        Width = 125
        WideText = 'Effects'
      end
      item
        Position = 8
        Width = 75
        WideText = 'Note Count'
      end
      item
        Position = 9
        Width = 75
        WideText = 'Used Notes'
      end
      item
        Position = 10
        Width = 75
        WideText = 'Bend Range'
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 950
    Height = 97
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      950
      97)
    object Label1: TLabel
      Left = 4
      Top = 11
      Width = 47
      Height = 13
      Caption = 'XSID File:'
    end
    object Label5: TLabel
      Left = 204
      Top = 40
      Width = 24
      Height = 13
      Caption = 'Title:'
    end
    object Label6: TLabel
      Left = 204
      Top = 59
      Width = 30
      Height = 13
      Caption = 'Artist:'
    end
    object Label7: TLabel
      Left = 256
      Top = 40
      Width = 3
      Height = 13
    end
    object Label8: TLabel
      Left = 256
      Top = 59
      Width = 3
      Height = 13
    end
    object Label9: TLabel
      Left = 464
      Top = 40
      Width = 36
      Height = 13
      Caption = 'Album:'
    end
    object Label10: TLabel
      Left = 464
      Top = 59
      Width = 27
      Height = 13
      Caption = 'Date:'
    end
    object Label11: TLabel
      Left = 464
      Top = 76
      Width = 73
      Height = 13
      Caption = 'Track Number:'
    end
    object Label12: TLabel
      Left = 552
      Top = 40
      Width = 3
      Height = 13
    end
    object Label13: TLabel
      Left = 552
      Top = 59
      Width = 3
      Height = 13
    end
    object Label14: TLabel
      Left = 552
      Top = 76
      Width = 3
      Height = 13
    end
    object SpeedButton1: TSpeedButton
      Left = 923
      Top = 8
      Width = 23
      Height = 22
      Anchors = [akTop, akRight]
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
    object Button7: TButton
      Left = 96
      Top = 35
      Width = 75
      Height = 25
      Caption = 'Dump Wav'
      TabOrder = 0
      OnClick = Button7Click
    end
    object Edit5: TEdit
      Left = 96
      Top = 8
      Width = 829
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 558
    Width = 950
    Height = 173
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      950
      173)
    object Label2: TLabel
      Left = 4
      Top = 8
      Width = 22
      Height = 13
      Caption = 'Log:'
    end
    object Label3: TLabel
      Left = 4
      Top = 39
      Width = 25
      Height = 13
      Caption = 'Wav:'
    end
    object Label4: TLabel
      Left = 177
      Top = 114
      Width = 70
      Height = 13
      Caption = 'Max. Threads:'
    end
    object Label15: TLabel
      Left = 464
      Top = 8
      Width = 27
      Height = 13
      Caption = 'MIDI:'
    end
    object Label16: TLabel
      Left = 464
      Top = 37
      Width = 26
      Height = 13
      Caption = 'BPM:'
    end
    object Label17: TLabel
      Left = 464
      Top = 64
      Width = 44
      Height = 13
      Caption = 'Division:'
    end
    object Label18: TLabel
      Left = 653
      Top = 37
      Width = 56
      Height = 13
      Caption = 'Time Num.:'
    end
    object Label19: TLabel
      Left = 653
      Top = 64
      Width = 69
      Height = 13
      Caption = 'Time Denom.:'
    end
    object Label20: TLabel
      Left = 4
      Top = 147
      Width = 59
      Height = 13
      Caption = 'Project Dir.:'
    end
    object Label21: TLabel
      Left = 4
      Top = 114
      Width = 78
      Height = 13
      Caption = 'Param. Latency:'
    end
    object SpeedButton2: TSpeedButton
      Left = 923
      Top = 144
      Width = 23
      Height = 22
      Anchors = [akTop, akRight]
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
      OnClick = SpeedButton2Click
    end
    object Button2: TButton
      Left = 177
      Top = 3
      Width = 75
      Height = 25
      Caption = 'Dump Ins'
      TabOrder = 0
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 96
      Top = 3
      Width = 75
      Height = 25
      Caption = 'Dump Filt'
      TabOrder = 1
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 96
      Top = 34
      Width = 75
      Height = 25
      Caption = 'Dump Filt'
      TabOrder = 2
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 177
      Top = 34
      Width = 75
      Height = 25
      Caption = 'Dump Ins'
      TabOrder = 3
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 258
      Top = 34
      Width = 75
      Height = 25
      Caption = 'Dump All'
      TabOrder = 4
      OnClick = Button6Click
    end
    object CheckBox1: TCheckBox
      Left = 96
      Top = 65
      Width = 237
      Height = 17
      Caption = 'Dump Filt./Mixer With All'
      Checked = True
      State = cbChecked
      TabOrder = 5
    end
    object CheckBox2: TCheckBox
      Left = 96
      Top = 88
      Width = 237
      Height = 17
      Caption = 'Process Filt./Mixer With Instruments'
      TabOrder = 6
    end
    object Edit1: TEdit
      Left = 258
      Top = 111
      Width = 75
      Height = 21
      NumbersOnly = True
      TabOrder = 7
      Text = '0'
    end
    object Button1: TButton
      Left = 552
      Top = 88
      Width = 75
      Height = 25
      Caption = 'Dump Ins'
      TabOrder = 8
      OnClick = Button1Click
    end
    object Edit2: TEdit
      Left = 552
      Top = 34
      Width = 75
      Height = 21
      TabOrder = 9
      Text = '120'
    end
    object Edit3: TEdit
      Left = 552
      Top = 61
      Width = 75
      Height = 21
      TabOrder = 10
      Text = '168'
    end
    object Edit4: TEdit
      Left = 752
      Top = 34
      Width = 75
      Height = 21
      NumbersOnly = True
      TabOrder = 11
      Text = '4'
    end
    object ComboBox1: TComboBox
      Left = 752
      Top = 61
      Width = 75
      Height = 21
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 12
      Text = '4'
      Items.Strings = (
        '2'
        '4'
        '8'
        '16')
    end
    object Button8: TButton
      Left = 552
      Top = 3
      Width = 75
      Height = 25
      Caption = 'Mapping...'
      TabOrder = 13
      OnClick = Button8Click
    end
    object Button9: TButton
      Left = 633
      Top = 88
      Width = 75
      Height = 25
      Caption = 'Dump All'
      TabOrder = 14
      OnClick = Button9Click
    end
    object Button10: TButton
      Left = 633
      Top = 3
      Width = 75
      Height = 25
      Caption = 'Save...'
      TabOrder = 15
      OnClick = Button10Click
    end
    object Button11: TButton
      Left = 714
      Top = 3
      Width = 75
      Height = 25
      Caption = 'Load...'
      TabOrder = 16
      OnClick = Button11Click
    end
    object SpinEdit1: TSpinEdit
      Left = 96
      Top = 111
      Width = 61
      Height = 22
      MaxValue = 15
      MinValue = 3
      TabOrder = 17
      Value = 9
    end
    object Edit6: TEdit
      Left = 96
      Top = 144
      Width = 829
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 18
    end
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'xsid'
    Filter = 'XSID Files (*.xsid)|*.xsid'
    Options = [ofReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Open XSID File...'
    Left = 624
    Top = 36
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'xs2m'
    Filter = 'XSID To MIDI Projects (*.xs2m)|*.xs2m'
    Options = [ofOverwritePrompt, ofPathMustExist, ofEnableSizing]
    Title = 'Save XSID To MIDI Project...'
    Left = 624
    Top = 84
  end
  object OpenDialog2: TOpenDialog
    DefaultExt = 'xs2m'
    Filter = 'XSID To MIDI Projects (*.xs2m)|*.xs2m'
    Options = [ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Load XSID To MIDI Project...'
    Left = 676
    Top = 84
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoForceFileSystem, fdoPathMustExist, fdoDontAddToRecent]
    Title = 'Select Project Folder...'
    Left = 684
    Top = 208
  end
  object Taskbar1: TTaskbar
    TaskBarButtons = <>
    TabProperties = []
    Left = 748
    Top = 40
  end
end
