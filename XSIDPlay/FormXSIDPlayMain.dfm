object XSIDPlayMainForm: TXSIDPlayMainForm
  Left = 0
  Top = 0
  Caption = 'XSID Player'
  ClientHeight = 433
  ClientWidth = 615
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 48
    Width = 24
    Height = 13
    Caption = 'Title:'
  end
  object Label2: TLabel
    Left = 8
    Top = 67
    Width = 30
    Height = 13
    Caption = 'Artist:'
  end
  object Label3: TLabel
    Left = 60
    Top = 48
    Width = 3
    Height = 13
  end
  object Label4: TLabel
    Left = 60
    Top = 67
    Width = 3
    Height = 13
  end
  object Label5: TLabel
    Left = 268
    Top = 48
    Width = 36
    Height = 13
    Caption = 'Album:'
  end
  object Label6: TLabel
    Left = 268
    Top = 67
    Width = 27
    Height = 13
    Caption = 'Date:'
  end
  object Label7: TLabel
    Left = 268
    Top = 86
    Width = 73
    Height = 13
    Caption = 'Track Number:'
  end
  object Label8: TLabel
    Left = 356
    Top = 48
    Width = 3
    Height = 13
  end
  object Label9: TLabel
    Left = 356
    Top = 67
    Width = 3
    Height = 13
  end
  object Label10: TLabel
    Left = 356
    Top = 86
    Width = 3
    Height = 13
  end
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Load...'
    TabOrder = 0
    OnClick = Button1Click
  end
  object TrackBar1: TTrackBar
    Left = 8
    Top = 108
    Width = 599
    Height = 25
    PageSize = 100
    SliderVisible = False
    TabOrder = 1
    TickMarks = tmBoth
    TickStyle = tsNone
  end
  object Button2: TButton
    Left = 532
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Configure...'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 8
    Top = 148
    Width = 75
    Height = 25
    Caption = 'Pause'
    Enabled = False
    TabOrder = 3
    OnClick = Button3Click
  end
  object ListBox1: TListBox
    Left = 396
    Top = 296
    Width = 211
    Height = 129
    ItemHeight = 13
    TabOrder = 4
  end
  object ListBox2: TListBox
    Left = 396
    Top = 148
    Width = 211
    Height = 129
    ItemHeight = 13
    TabOrder = 5
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.vsid'
    Filter = 'XSID Files (*.xsid)|*.xsid'
    Title = 'Open VSID File...'
    Left = 336
    Top = 8
  end
end
