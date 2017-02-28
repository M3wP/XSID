object PatchEditSelectForm: TPatchEditSelectForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Patch Select'
  ClientHeight = 412
  ClientWidth = 362
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 31
    Height = 13
    Caption = 'Patch:'
  end
  object lstbxPatches: TListBox
    Left = 88
    Top = 8
    Width = 266
    Height = 365
    ItemHeight = 13
    TabOrder = 0
    OnClick = lstbxPatchesClick
  end
  object btnEdit: TButton
    Left = 279
    Top = 379
    Width = 75
    Height = 25
    Caption = 'Edit...'
    TabOrder = 1
    OnClick = btnEditClick
  end
  object Button1: TButton
    Left = 198
    Top = 379
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Done'
    ModalResult = 2
    TabOrder = 2
  end
end
