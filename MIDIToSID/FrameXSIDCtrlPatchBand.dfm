inherited XSIDCtrlPatchBandFrame: TXSIDCtrlPatchBandFrame
  Height = 150
  ExplicitHeight = 150
  object Label30: TLabel
    Left = 8
    Top = 8
    Width = 578
    Height = 17
    AutoSize = False
    Caption = '  XSID Controller Events'
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
  object Label31: TLabel
    Left = 16
    Top = 35
    Width = 116
    Height = 13
    Caption = 'Pulse Width Byte Order:'
  end
  object Label32: TLabel
    Left = 16
    Top = 91
    Width = 111
    Height = 13
    Caption = 'Frequency Byte Order:'
  end
  object Label33: TLabel
    Left = 297
    Top = 35
    Width = 104
    Height = 13
    Caption = 'Pulse Width Lo Delay:'
  end
  object Label34: TLabel
    Left = 297
    Top = 63
    Width = 102
    Height = 13
    Caption = 'Pulse Width Hi Delay:'
  end
  object Label35: TLabel
    Left = 297
    Top = 91
    Width = 99
    Height = 13
    Caption = 'Frequency Lo Delay:'
  end
  object Label36: TLabel
    Left = 297
    Top = 119
    Width = 97
    Height = 13
    Caption = 'Frequency Hi Delay:'
  end
  object Panel3: TPanel
    Left = 164
    Top = 34
    Width = 81
    Height = 42
    BevelOuter = bvNone
    TabOrder = 0
    object rbtnCtrlPWOrderLoHi: TRadioButton
      Left = 0
      Top = 0
      Width = 73
      Height = 17
      Caption = 'Lo Hi'
      TabOrder = 0
      OnClick = rbtnCtrlPWOrderLoHiClick
    end
    object rbtnCtrlPWOrderHiLo: TRadioButton
      Left = 0
      Top = 23
      Width = 73
      Height = 17
      Caption = 'Hi Lo'
      TabOrder = 1
      OnClick = rbtnCtrlPWOrderLoHiClick
    end
  end
  object Panel4: TPanel
    Left = 164
    Top = 90
    Width = 81
    Height = 42
    BevelOuter = bvNone
    TabOrder = 1
    object rbtnCtrlFreqOrderLoHi: TRadioButton
      Left = 0
      Top = 0
      Width = 73
      Height = 17
      Caption = 'Lo Hi'
      TabOrder = 0
      OnClick = rbtnCtrlFreqOrderLoHiClick
    end
    object rbtnCtrlFreqOrderHiLo: TRadioButton
      Left = 0
      Top = 23
      Width = 73
      Height = 17
      Caption = 'Hi Lo'
      TabOrder = 1
      OnClick = rbtnCtrlFreqOrderLoHiClick
    end
  end
  object spedtCtrlPWLoDelay: TSpinEdit
    Left = 449
    Top = 32
    Width = 81
    Height = 22
    MaxValue = 120
    MinValue = 0
    TabOrder = 2
    Value = 0
    OnChange = spedtCtrlPWLoDelayChange
  end
  object spedtCtrlPWHiDelay: TSpinEdit
    Left = 449
    Top = 60
    Width = 81
    Height = 22
    MaxValue = 120
    MinValue = 0
    TabOrder = 3
    Value = 0
    OnChange = spedtCtrlPWHiDelayChange
  end
  object spedtCtrlFreqLoDelay: TSpinEdit
    Left = 449
    Top = 88
    Width = 81
    Height = 22
    MaxValue = 120
    MinValue = 0
    TabOrder = 4
    Value = 0
    OnChange = spedtCtrlFreqLoDelayChange
  end
  object spedtCtrlFreqHiDelay: TSpinEdit
    Left = 449
    Top = 116
    Width = 81
    Height = 22
    MaxValue = 120
    MinValue = 0
    TabOrder = 5
    Value = 0
    OnChange = spedtCtrlFreqHiDelayChange
  end
end
