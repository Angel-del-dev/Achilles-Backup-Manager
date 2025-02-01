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
      Top = 25
      Width = 177
      Height = 355
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
        WordWrap = True
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
    end
    object Panel3: TPanel
      Left = 176
      Top = 25
      Width = 447
      Height = 355
      Align = alRight
      TabOrder = 1
      object sbBackupList: TScrollBox
        Left = 1
        Top = 1
        Width = 445
        Height = 353
        Align = alClient
        TabOrder = 2
        ExplicitLeft = 48
        ExplicitTop = 48
        ExplicitWidth = 185
        ExplicitHeight = 41
        object lbBackups: TListBox
          Left = 0
          Top = 0
          Width = 441
          Height = 349
          Align = alClient
          ItemHeight = 15
          TabOrder = 0
          ExplicitLeft = 48
          ExplicitTop = 32
          ExplicitWidth = 121
          ExplicitHeight = 97
        end
      end
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
      object PRemove: TPanel
        Left = 72
        Top = 129
        Width = 313
        Height = 88
        TabOrder = 1
        Visible = False
        object lblRemove: TLabel
          Left = 40
          Top = 29
          Width = 239
          Height = 15
          Caption = 'Would you like to remove the current profile?'
        end
        object BtnCancelRemove: TButton
          Left = 147
          Top = 55
          Width = 75
          Height = 25
          Caption = 'Cancel'
          TabOrder = 0
          OnClick = BtnCancelRemoveClick
        end
        object BtnConfirmRemove: TButton
          Left = 227
          Top = 55
          Width = 75
          Height = 25
          Caption = 'Confirm'
          TabOrder = 1
          OnClick = BtnConfirmRemoveClick
        end
      end
    end
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 622
      Height = 24
      Align = alTop
      TabOrder = 2
      object BtnActions: TSpeedButton
        Left = 1
        Top = 1
        Width = 57
        Height = 22
        Align = alLeft
        Caption = 'Actions'
        Flat = True
        OnClick = BtnActionsMenuClick
        ExplicitLeft = 176
        ExplicitTop = 8
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
  object PopupActionsMenu: TPopupMenu
    Left = 577
    Top = 33
    object Profile1: TMenuItem
      Caption = 'Profile'
      object Create1: TMenuItem
        Caption = 'Create'
        OnClick = BtnAddProfileClick
      end
      object Removecurrent1: TMenuItem
        Caption = 'Remove current'
        OnClick = Removecurrent1Click
      end
    end
  end
end
