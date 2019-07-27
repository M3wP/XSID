object FilterViewForm: TFilterViewForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'Filter Insight Viewer'
  ClientHeight = 283
  ClientWidth = 635
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox1: TPaintBox
    Left = 0
    Top = 41
    Width = 635
    Height = 161
    Align = alTop
    OnPaint = PaintBox1Paint
  end
  object Shape1: TShape
    Left = 8
    Top = 41
    Width = 1
    Height = 160
    Pen.Color = clWhite
    Visible = False
  end
  object ScrollBar1: TScrollBar
    Left = 0
    Top = 202
    Width = 635
    Height = 17
    Align = alTop
    Max = 0
    PageSize = 0
    TabOrder = 0
    OnScroll = ScrollBar1Scroll
    ExplicitLeft = -8
    ExplicitTop = 233
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 635
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 4
      Top = 10
      Width = 30
      Height = 13
      Caption = 'Zoom:'
    end
    object ComboBox1: TComboBox
      Left = 96
      Top = 7
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 0
      Text = '25%'
      OnChange = ComboBox1Change
      Items.Strings = (
        '10%'
        '25%'
        '33%'
        '50%'
        '66%'
        '75%'
        '100%'
        '200%'
        '400%')
    end
  end
end
