object XSIDListMainForm: TXSIDListMainForm
  Left = 0
  Top = 0
  Caption = 'XSID List'
  ClientHeight = 567
  ClientWidth = 710
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Menu = XSIDListMainDMod.MainMenu1
  OldCreateOrder = False
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 710
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
    Top = 48
    Width = 702
    Height = 515
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.Options = [hoColumnResize, hoVisible]
    TabOrder = 1
    TreeOptions.AutoOptions = [toAutoScroll]
    TreeOptions.MiscOptions = [toFullRepaintOnResize, toGridExtensions, toInitOnSave, toReportMode, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowHorzGridLines, toShowVertGridLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    TreeOptions.StringOptions = []
    OnAddToSelection = vstEventsAddToSelection
    OnGetText = vstEventsGetText
    ExplicitLeft = -1
    ExplicitTop = 29
    ExplicitHeight = 537
    Columns = <
      item
        Position = 0
        Text = 'Index'
        Width = 75
      end
      item
        Position = 1
        Text = 'Offset'
        Width = 75
      end
      item
        Position = 2
        Text = 'Register'
        Width = 225
      end
      item
        Position = 3
        Text = 'Value'
        Width = 300
      end>
  end
  object TrackBar1: TTrackBar
    Left = 0
    Top = 22
    Width = 710
    Height = 22
    Align = alTop
    Enabled = False
    SliderVisible = False
    ShowSelRange = False
    TabOrder = 2
    TickStyle = tsNone
  end
end
