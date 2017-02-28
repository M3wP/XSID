inherited XSIDNtOnPatchBandFrame: TXSIDNtOnPatchBandFrame
  Height = 269
  ExplicitHeight = 269
  object Label13: TLabel
    Left = 8
    Top = 8
    Width = 578
    Height = 17
    AutoSize = False
    Caption = '  XSID Note On Events'
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
  object Label14: TLabel
    Left = 16
    Top = 35
    Width = 122
    Height = 13
    Caption = 'Always Output Envelope:'
  end
  object Label15: TLabel
    Left = 16
    Top = 58
    Width = 119
    Height = 13
    Caption = 'Always Output P. Width:'
  end
  object Label16: TLabel
    Left = 16
    Top = 81
    Width = 114
    Height = 13
    Caption = 'Pulse Width After Gate:'
  end
  object Label17: TLabel
    Left = 16
    Top = 104
    Width = 109
    Height = 13
    Caption = 'Frequency After Gate:'
  end
  object Label18: TLabel
    Left = 297
    Top = 35
    Width = 132
    Height = 13
    Caption = 'Sus./Rel. Before Atk./Dec.:'
  end
  object Label19: TLabel
    Left = 297
    Top = 63
    Width = 99
    Height = 13
    Caption = 'Attack/Decay Delay:'
  end
  object Label20: TLabel
    Left = 297
    Top = 95
    Width = 111
    Height = 13
    Caption = 'Sustain/Release Delay:'
  end
  object Label21: TLabel
    Left = 16
    Top = 127
    Width = 116
    Height = 13
    Caption = 'Pulse Width Byte Order:'
  end
  object Label22: TLabel
    Left = 16
    Top = 183
    Width = 111
    Height = 13
    Caption = 'Frequency Byte Order:'
  end
  object Label23: TLabel
    Left = 297
    Top = 127
    Width = 104
    Height = 13
    Caption = 'Pulse Width Lo Delay:'
  end
  object Label24: TLabel
    Left = 297
    Top = 155
    Width = 102
    Height = 13
    Caption = 'Pulse Width Hi Delay:'
  end
  object Label25: TLabel
    Left = 297
    Top = 183
    Width = 99
    Height = 13
    Caption = 'Frequency Lo Delay:'
  end
  object Label26: TLabel
    Left = 297
    Top = 211
    Width = 97
    Height = 13
    Caption = 'Frequency Hi Delay:'
  end
  object Label28: TLabel
    Left = 297
    Top = 239
    Width = 87
    Height = 13
    Caption = 'Hard Sync. Delay:'
  end
  object Label29: TLabel
    Left = 12
    Top = 239
    Width = 57
    Height = 13
    Caption = 'Gate Delay:'
  end
  object chkbxAlwaysEnv: TCheckBox
    Left = 164
    Top = 34
    Width = 81
    Height = 17
    TabOrder = 0
    OnClick = chkbxAlwaysEnvClick
  end
  object chkbxAlwaysPW: TCheckBox
    Left = 164
    Top = 57
    Width = 81
    Height = 17
    TabOrder = 1
    OnClick = chkbxAlwaysPWClick
  end
  object chkbxPWAfterGate: TCheckBox
    Left = 164
    Top = 80
    Width = 81
    Height = 17
    TabOrder = 2
    OnClick = chkbxPWAfterGateClick
  end
  object chkbxFreqAfterGate: TCheckBox
    Left = 164
    Top = 103
    Width = 81
    Height = 17
    TabOrder = 3
    OnClick = chkbxFreqAfterGateClick
  end
  object chkbxSusBeforeAtk: TCheckBox
    Left = 449
    Top = 34
    Width = 81
    Height = 17
    TabOrder = 4
    OnClick = chkbxSusBeforeAtkClick
  end
  object spedtAtkDecDelay: TSpinEdit
    Left = 449
    Top = 60
    Width = 81
    Height = 22
    MaxValue = 120
    MinValue = 0
    TabOrder = 5
    Value = 0
    OnChange = spedtAtkDecDelayChange
  end
  object spedtSusRelDelay: TSpinEdit
    Left = 449
    Top = 92
    Width = 81
    Height = 22
    MaxValue = 120
    MinValue = 0
    TabOrder = 6
    Value = 0
    OnChange = spedtSusRelDelayChange
  end
  object Panel1: TPanel
    Left = 164
    Top = 126
    Width = 81
    Height = 42
    BevelOuter = bvNone
    TabOrder = 7
    object rbtnNtOnPWOrderLoHi: TRadioButton
      Left = 0
      Top = 0
      Width = 73
      Height = 17
      Caption = 'Lo Hi'
      TabOrder = 0
      OnClick = rbtnNtOnPWOrderLoHiClick
    end
    object rbtnNtOnPWOrderHiLo: TRadioButton
      Left = 0
      Top = 23
      Width = 73
      Height = 17
      Caption = 'Hi Lo'
      TabOrder = 1
      OnClick = rbtnNtOnPWOrderLoHiClick
    end
  end
  object Panel2: TPanel
    Left = 164
    Top = 182
    Width = 81
    Height = 42
    BevelOuter = bvNone
    TabOrder = 8
    object rbtnNtOnFreqOrderLoHi: TRadioButton
      Left = 0
      Top = 0
      Width = 73
      Height = 17
      Caption = 'Lo Hi'
      TabOrder = 0
      OnClick = rbtnNtOnFreqOrderLoHiClick
    end
    object rbtnNtOnFreqOrderHiLo: TRadioButton
      Left = 0
      Top = 23
      Width = 73
      Height = 17
      Caption = 'Hi Lo'
      TabOrder = 1
      OnClick = rbtnNtOnFreqOrderLoHiClick
    end
  end
  object spedtNtOnPWLoDelay: TSpinEdit
    Left = 449
    Top = 124
    Width = 81
    Height = 22
    MaxValue = 120
    MinValue = 0
    TabOrder = 9
    Value = 0
    OnChange = spedtNtOnPWLoDelayChange
  end
  object spedtNtOnPWHiDelay: TSpinEdit
    Left = 449
    Top = 152
    Width = 81
    Height = 22
    MaxValue = 120
    MinValue = 0
    TabOrder = 10
    Value = 0
    OnChange = spedtNtOnPWHiDelayChange
  end
  object spedtNtOnFreqLoDelay: TSpinEdit
    Left = 449
    Top = 180
    Width = 81
    Height = 22
    MaxValue = 120
    MinValue = 0
    TabOrder = 11
    Value = 0
    OnChange = spedtNtOnFreqLoDelayChange
  end
  object spedtNtOnFreqHiDelay: TSpinEdit
    Left = 449
    Top = 208
    Width = 81
    Height = 22
    MaxValue = 120
    MinValue = 0
    TabOrder = 12
    Value = 0
    OnChange = spedtNtOnFreqHiDelayChange
  end
  object spedtHardSyncDelay: TSpinEdit
    Left = 449
    Top = 236
    Width = 81
    Height = 22
    MaxValue = 120
    MinValue = 0
    TabOrder = 13
    Value = 0
    OnChange = spedtHardSyncDelayChange
  end
  object spedtGateDelay: TSpinEdit
    Left = 164
    Top = 236
    Width = 81
    Height = 22
    MaxValue = 120
    MinValue = 0
    TabOrder = 14
    Value = 0
    OnChange = spedtGateDelayChange
  end
end
