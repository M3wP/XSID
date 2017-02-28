object MIDIToSIDMainForm: TMIDIToSIDMainForm
  Left = 0
  Top = 0
  Caption = 'MIDI To SID'
  ClientHeight = 588
  ClientWidth = 701
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 701
    Height = 22
    AutoSize = True
    Caption = 'ToolBar1'
    TabOrder = 0
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Caption = 'ToolButton1'
      ImageIndex = 0
    end
  end
  object vstEvents: TVirtualStringTree
    AlignWithMargins = True
    Left = 4
    Top = 26
    Width = 693
    Height = 558
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
    TabOrder = 1
    TreeOptions.AutoOptions = [toAutoScrollOnExpand, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
    TreeOptions.MiscOptions = [toFullRepaintOnResize, toGridExtensions, toInitOnSave, toReportMode, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowHorzGridLines, toShowVertGridLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnAddToSelection = vstEventsAddToSelection
    OnGetText = vstEventsGetText
    Columns = <
      item
        Position = 0
        Width = 60
        WideText = 'Index'
      end
      item
        Position = 1
        Width = 60
        WideText = 'Offset'
      end
      item
        Position = 2
        Width = 140
        WideText = 'Type'
      end
      item
        Position = 3
        Width = 75
        WideText = 'Channel'
      end
      item
        Position = 4
        Width = 325
        WideText = 'Data'
      end>
  end
  object MainMenu1: TMainMenu
    Left = 496
    Top = 8
    object File1: TMenuItem
      Caption = '&File'
      object Open1: TMenuItem
        Action = ActFileOpen
      end
      object OpenProject1: TMenuItem
        Action = ActFileOpenProject
      end
      object SaveProject1: TMenuItem
        Action = ActFileSaveProject
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object ProcessFile1: TMenuItem
        Action = ActFileProcess
      end
    end
    object Edit1: TMenuItem
      Caption = '&Edit'
      object EditEventData1: TMenuItem
        Action = ActEditEvent
      end
    end
    object View1: TMenuItem
      Caption = '&View'
    end
    object Tools1: TMenuItem
      Caption = '&Tools'
      object PatchEditor1: TMenuItem
        Action = ActToolsPatchEdit
      end
      object ChannelMap1: TMenuItem
        Action = ActToolsChannelMap
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
    end
  end
  object ActionList1: TActionList
    OnUpdate = ActionList1Update
    Left = 552
    Top = 8
    object ActFileOpen: TAction
      Category = 'File'
      Caption = '&Open...'
      ShortCut = 16463
      OnExecute = ActFileOpenExecute
    end
    object ActToolsPatchEdit: TAction
      Category = 'Tools'
      Caption = 'Patch Editor...'
      OnExecute = ActToolsPatchEditExecute
      OnUpdate = ActToolsPatchEditUpdate
    end
    object ActToolsChannelMap: TAction
      Category = 'Tools'
      Caption = 'Channel Map...'
      OnExecute = ActToolsChannelMapExecute
      OnUpdate = ActToolsChannelMapUpdate
    end
    object ActEditEvent: TAction
      Category = 'Edit'
      Caption = 'Edit Event Data...'
      OnExecute = ActEditEventExecute
      OnUpdate = ActEditEventUpdate
    end
    object ActFileProcess: TAction
      Category = 'File'
      Caption = 'Process File'
      OnExecute = ActFileProcessExecute
      OnUpdate = ActFileProcessUpdate
    end
    object ActFileOpenProject: TAction
      Category = 'File'
      Caption = 'Open &Project...'
      OnExecute = ActFileOpenProjectExecute
    end
    object ActFileSaveProject: TAction
      Category = 'File'
      Caption = '&Save Project...'
      ShortCut = 16467
      OnExecute = ActFileSaveProjectExecute
      OnUpdate = ActFileSaveProjectUpdate
    end
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'mid'
    Filter = 'MIDI Files (*.mid)|*.mid'
    Options = [ofReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Open MIDI File...'
    Left = 616
    Top = 8
  end
  object OpenDialog2: TOpenDialog
    DefaultExt = 'mid2sid'
    Filter = 'MIDI To SID Projects (*.mid2sid)|*.mid2sid'
    Options = [ofReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Open MIDI To SID Project File...'
    Left = 616
    Top = 56
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'mid2sid'
    Filter = 'MIDI To SID Project Files (*.mid2sid)|*.mid2sid'
    Options = [ofOverwritePrompt, ofPathMustExist, ofEnableSizing]
    Title = 'Save MIDI To SID Project File...'
    Left = 552
    Top = 56
  end
end
