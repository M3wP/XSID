object XSIDListMainDMod: TXSIDListMainDMod
  OldCreateOrder = False
  Height = 295
  Width = 403
  object Timer1: TTimer
    Interval = 60
    OnTimer = Timer1Timer
    Left = 351
    Top = 12
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'xsid'
    Filter = 'XSID Files (*.xsid)|*.xsid'
    Options = [ofReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Open XSID File...'
    Left = 23
    Top = 72
  end
  object MainMenu1: TMainMenu
    Left = 103
    Top = 12
    object File1: TMenuItem
      Caption = '&File'
      object Open1: TMenuItem
        Action = ActFileOpen
      end
    end
    object Edit1: TMenuItem
      Caption = '&Edit'
    end
    object View1: TMenuItem
      Caption = '&View'
      object Filter1: TMenuItem
        Caption = 'Show Events'
        object Voice11: TMenuItem
          Action = ActViewVoice1
          AutoCheck = True
        end
        object Voice21: TMenuItem
          Action = ActViewVoice2
          AutoCheck = True
        end
        object Voice31: TMenuItem
          Action = ActViewVoice3
          AutoCheck = True
        end
        object Filter2: TMenuItem
          Action = ActViewFilter
          AutoCheck = True
        end
      end
    end
    object Tools1: TMenuItem
      Caption = '&Tools'
      object CreateDump1: TMenuItem
        Action = ActToolsCreateDump
      end
    end
    object Options1: TMenuItem
      Caption = 'Options'
      object PlayRate1: TMenuItem
        Caption = 'Play Rate'
        object N1001: TMenuItem
          Action = ActOptionsPlay100PC
          AutoCheck = True
        end
        object N501: TMenuItem
          Action = ActOptionsPlay50PC
          AutoCheck = True
        end
        object N251: TMenuItem
          Action = ActOptionsPlay25PC
          AutoCheck = True
        end
      end
      object PlayMute1: TMenuItem
        Caption = 'Play Mute'
        object Voice12: TMenuItem
          Action = ActOptionsMuteVoice1
          AutoCheck = True
        end
        object Voice22: TMenuItem
          Action = ActOptionsMuteVoice2
          AutoCheck = True
        end
        object Voice32: TMenuItem
          Action = ActOptionsMuteVoice3
          AutoCheck = True
        end
        object Filter3: TMenuItem
          Action = ActOptionsMuteFilter
          AutoCheck = True
        end
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
    end
  end
  object ActionList1: TActionList
    Left = 23
    Top = 12
    object ActFileOpen: TAction
      Category = 'File'
      Caption = '&Open...'
      ShortCut = 16463
      OnExecute = ActFileOpenExecute
    end
    object ActViewVoice1: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'Voice 1'
      Checked = True
      OnExecute = ActViewVoice1Execute
    end
    object ActViewVoice2: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'Voice 2'
      Checked = True
      OnExecute = ActViewVoice1Execute
    end
    object ActViewVoice3: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'Voice 3'
      Checked = True
      OnExecute = ActViewVoice1Execute
    end
    object ActViewFilter: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'Filter'
      Checked = True
      OnExecute = ActViewVoice1Execute
    end
    object ActOptionsPlay50PC: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = '50%'
      GroupIndex = 2
      OnExecute = ActOptionsPlay50PCExecute
      OnUpdate = ActOptionsPlay50PCUpdate
    end
    object ActOptionsPlay100PC: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = '100%'
      Checked = True
      GroupIndex = 2
      OnExecute = ActOptionsPlay100PCExecute
      OnUpdate = ActOptionsPlay100PCUpdate
    end
    object ActToolsCreateDump: TAction
      Category = 'Tools'
      Caption = 'Create Dump...'
      OnExecute = ActToolsCreateDumpExecute
    end
    object ActOptionsPlay25PC: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = '25%'
      GroupIndex = 2
      OnExecute = ActOptionsPlay25PCExecute
      OnUpdate = ActOptionsPlay25PCUpdate
    end
    object ActOptionsMuteVoice1: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Voice 1'
      OnExecute = ActOptionsMuteVoice1Execute
      OnUpdate = ActOptionsMuteVoice1Update
    end
    object ActOptionsMuteVoice2: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Voice 2'
      OnExecute = ActOptionsMuteVoice1Execute
      OnUpdate = ActOptionsMuteVoice2Update
    end
    object ActOptionsMuteVoice3: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Voice 3'
      OnExecute = ActOptionsMuteVoice1Execute
      OnUpdate = ActOptionsMuteVoice3Update
    end
    object ActOptionsMuteFilter: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Filter'
      OnExecute = ActOptionsMuteVoice1Execute
      OnUpdate = ActOptionsMuteFilterUpdate
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 103
    Top = 72
  end
end
