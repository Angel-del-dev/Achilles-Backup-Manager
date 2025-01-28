object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Achilles backup manager'
  ClientHeight = 381
  ClientWidth = 624
  Color = clBtnFace
  Constraints.MaxHeight = 420
  Constraints.MaxWidth = 640
  Constraints.MinHeight = 420
  Constraints.MinWidth = 640
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 381
    Align = alClient
    TabOrder = 0
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 177
      Height = 379
      Align = alLeft
      TabOrder = 0
      object Label1: TLabel
        Left = 8
        Top = 11
        Width = 77
        Height = 15
        Caption = 'Current profile'
      end
      object Label2: TLabel
        Left = 8
        Top = 118
        Width = 71
        Height = 15
        Caption = 'Origin route:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label3: TLabel
        Left = 8
        Top = 160
        Width = 73
        Height = 15
        Caption = 'Target route:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblOrigin: TLabel
        Left = 8
        Top = 139
        Width = 46
        Height = 15
        Caption = 'lblOrigin'
      end
      object lblTarget: TLabel
        Left = 8
        Top = 181
        Width = 46
        Height = 15
        Caption = 'lblTarget'
      end
      object ProfileSelector: TComboBox
        Left = 8
        Top = 32
        Width = 161
        Height = 23
        TabOrder = 0
        OnSelect = ProfileSelectorSelect
      end
      object DefaultCheckbox: TCheckBox
        Left = 8
        Top = 72
        Width = 97
        Height = 17
        Caption = 'Default'
        TabOrder = 1
        OnClick = DefaultCheckboxClick
      end
      object BtnAddProfile: TButton
        Left = 6
        Top = 232
        Width = 163
        Height = 25
        Caption = 'Add profile'
        TabOrder = 2
        OnClick = BtnAddProfileClick
      end
    end
    object Panel3: TPanel
      Left = 176
      Top = 1
      Width = 447
      Height = 379
      Align = alRight
      TabOrder = 1
      object PanelCreateProfile: TPanel
        Left = 32
        Top = 92
        Width = 377
        Height = 193
        TabOrder = 0
        Visible = False
        object Label4: TLabel
          Left = 24
          Top = 16
          Width = 35
          Height = 15
          Caption = 'Name:'
        end
        object BtnCancelProfileCreation: TButton
          Left = 208
          Top = 160
          Width = 75
          Height = 25
          Caption = 'Cancel'
          TabOrder = 0
          OnClick = BtnCancelProfileCreationClick
        end
        object BtnConfirmProfileCreation: TButton
          Left = 289
          Top = 160
          Width = 75
          Height = 25
          Caption = 'Confirm'
          TabOrder = 1
          OnClick = BtnConfirmProfileCreationClick
        end
        object edNewProfileName: TEdit
          Left = 24
          Top = 37
          Width = 121
          Height = 23
          Hint = 'Name'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          TextHint = 'Name of the profile'
        end
        object btnChooseOriginPath: TButton
          Left = 24
          Top = 80
          Width = 337
          Height = 25
          Caption = 'Origin path'
          TabOrder = 3
          OnClick = btnChooseOriginPathClick
        end
        object btnTargetPath: TButton
          Left = 24
          Top = 111
          Width = 337
          Height = 25
          Caption = 'Target path'
          TabOrder = 4
          OnClick = btnTargetPathClick
        end
      end
    end
  end
  object Connection: TFDConnection
    Params.Strings = (
      'ConnectionDef=Connection')
    LoginPrompt = False
    Left = 30
    Top = 389
  end
end
