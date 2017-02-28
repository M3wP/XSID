object PatchEditorForm: TPatchEditorForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Patch Editor'
  ClientHeight = 637
  ClientWidth = 594
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 64
    Width = 269
    Height = 17
    AutoSize = False
    Caption = '  Envelope Generator'
    Color = clBtnShadow
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlightText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Transparent = False
    Layout = tlCenter
  end
  object Label2: TLabel
    Left = 16
    Top = 100
    Width = 35
    Height = 13
    Caption = 'Attack:'
  end
  object Label3: TLabel
    Left = 16
    Top = 135
    Width = 34
    Height = 13
    Caption = 'Decay:'
  end
  object Label4: TLabel
    Left = 16
    Top = 170
    Width = 39
    Height = 13
    Caption = 'Sustain:'
  end
  object Label5: TLabel
    Left = 16
    Top = 205
    Width = 42
    Height = 13
    Caption = 'Release:'
  end
  object Label6: TLabel
    Left = 8
    Top = 8
    Width = 578
    Height = 17
    AutoSize = False
    Caption = '  General'
    Color = clBtnShadow
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlightText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Transparent = False
    Layout = tlCenter
  end
  object Label7: TLabel
    Left = 16
    Top = 34
    Width = 31
    Height = 13
    Caption = 'Name:'
  end
  object Label8: TLabel
    Left = 289
    Top = 64
    Width = 297
    Height = 17
    AutoSize = False
    Caption = '  Waveform Generator'
    Color = clBtnShadow
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlightText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Transparent = False
    Layout = tlCenter
  end
  object Label9: TLabel
    Left = 297
    Top = 92
    Width = 54
    Height = 13
    Caption = 'Waveform:'
  end
  object Label10: TLabel
    Left = 297
    Top = 142
    Width = 38
    Height = 13
    Caption = 'Effects:'
  end
  object Label11: TLabel
    Left = 297
    Top = 174
    Width = 60
    Height = 13
    Caption = 'Pulse Width:'
  end
  object Label12: TLabel
    Left = 297
    Top = 200
    Width = 28
    Height = 13
    Caption = 'Filter:'
  end
  object Label27: TLabel
    Left = 297
    Top = 223
    Width = 104
    Height = 13
    Caption = 'Hard Oscillator Sync.:'
  end
  object lblAtk: TLabel
    Left = 242
    Top = 100
    Width = 3
    Height = 13
  end
  object lblDec: TLabel
    Left = 242
    Top = 135
    Width = 3
    Height = 13
  end
  object lblSus: TLabel
    Left = 242
    Top = 170
    Width = 3
    Height = 13
  end
  object lblRel: TLabel
    Left = 242
    Top = 205
    Width = 3
    Height = 13
  end
  object Bevel1: TBevel
    Left = 0
    Top = 252
    Width = 593
    Height = 8
    Shape = bsBottomLine
  end
  object trkbrAttack: TTrackBar
    Left = 84
    Top = 92
    Width = 150
    Height = 29
    Hint = '0'
    Max = 15
    ParentShowHint = False
    ShowHint = True
    ShowSelRange = False
    TabOrder = 0
    TickMarks = tmTopLeft
    OnChange = trkbrAttackChange
  end
  object trkbrDecay: TTrackBar
    Left = 84
    Top = 127
    Width = 150
    Height = 29
    Hint = '0'
    Max = 15
    ParentShowHint = False
    ShowHint = True
    ShowSelRange = False
    TabOrder = 1
    TickMarks = tmTopLeft
    OnChange = trkbrDecayChange
  end
  object trkbrSustain: TTrackBar
    Left = 84
    Top = 162
    Width = 150
    Height = 29
    Hint = '0'
    Max = 15
    ParentShowHint = False
    ShowHint = True
    ShowSelRange = False
    TabOrder = 2
    TickMarks = tmTopLeft
    OnChange = trkbrSustainChange
  end
  object trkbrRelease: TTrackBar
    Left = 84
    Top = 197
    Width = 150
    Height = 29
    Hint = '0'
    Max = 15
    ParentShowHint = False
    ShowHint = True
    ShowSelRange = False
    TabOrder = 3
    TickMarks = tmTopLeft
    OnChange = trkbrReleaseChange
  end
  object edtName: TEdit
    Left = 84
    Top = 31
    Width = 489
    Height = 21
    TabOrder = 4
    Text = 'edtName'
    OnChange = edtNameChange
  end
  object chkbxTriangle: TCheckBox
    Left = 373
    Top = 91
    Width = 97
    Height = 17
    Caption = 'Triangle'
    TabOrder = 5
    OnClick = chkbxTriangleClick
  end
  object chkbxSaw: TCheckBox
    Left = 373
    Top = 114
    Width = 97
    Height = 17
    Caption = 'Sawtooth'
    TabOrder = 6
    OnClick = chkbxSawClick
  end
  object chkbxPulse: TCheckBox
    Left = 476
    Top = 91
    Width = 97
    Height = 17
    Caption = 'Pulse'
    TabOrder = 7
    OnClick = chkbxPulseClick
  end
  object chkbxNoise: TCheckBox
    Left = 476
    Top = 114
    Width = 97
    Height = 17
    Caption = 'Noise'
    TabOrder = 8
    OnClick = chkbxNoiseClick
  end
  object chkbxSync: TCheckBox
    Left = 373
    Top = 141
    Width = 97
    Height = 17
    Caption = 'Sync.'
    TabOrder = 9
    OnClick = chkbxSyncClick
  end
  object chkbxRing: TCheckBox
    Left = 476
    Top = 141
    Width = 97
    Height = 17
    Caption = 'Ring Mod.'
    TabOrder = 10
    OnClick = chkbxRingClick
  end
  object spedtPWidth: TSpinEdit
    Left = 373
    Top = 171
    Width = 97
    Height = 22
    MaxValue = 4095
    MinValue = 0
    TabOrder = 11
    Value = 0
    OnChange = spedtPWidthChange
  end
  object chkbxFilter: TCheckBox
    Left = 476
    Top = 199
    Width = 97
    Height = 17
    TabOrder = 12
    OnClick = chkbxFilterClick
  end
  object Button1: TButton
    Left = 511
    Top = 604
    Width = 75
    Height = 25
    Caption = 'Apply'
    Enabled = False
    TabOrder = 13
  end
  object Button2: TButton
    Left = 430
    Top = 604
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 14
  end
  object Button3: TButton
    Left = 349
    Top = 604
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 15
  end
  object chkbxHardSync: TCheckBox
    Left = 476
    Top = 222
    Width = 81
    Height = 17
    TabOrder = 16
    OnClick = chkbxHardSyncClick
  end
  object Button4: TButton
    Left = 8
    Top = 245
    Width = 75
    Height = 25
    Caption = 'Band Select'
    TabOrder = 17
    OnClick = Button4Click
  end
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 276
    Width = 593
    Height = 309
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    TabOrder = 18
  end
  object PopupMenu1: TPopupMenu
    Left = 104
    Top = 244
  end
end
