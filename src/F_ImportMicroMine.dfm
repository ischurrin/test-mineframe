object Form_ImportMicroMine: TForm_ImportMicroMine
  Left = 0
  Top = 0
  Caption = 'Form_ImportMicroMine'
  ClientHeight = 566
  ClientWidth = 1089
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1089
    Height = 41
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 160
      Top = 13
      Width = 131
      Height = 13
      Caption = #1056#1072#1079#1076#1077#1083#1080#1090#1077#1083#1100' '#1076#1077#1089#1103#1090#1080#1095#1085#1099#1093
    end
    object Label2: TLabel
      Left = 368
      Top = 13
      Width = 99
      Height = 13
      Caption = #1056#1072#1079#1076#1077#1083#1080#1090#1077#1083#1100' '#1087#1086#1083#1077#1081
    end
    object Label3: TLabel
      Left = 864
      Top = 16
      Width = 62
      Height = 13
      Caption = #1053#1077' '#1080#1079#1074#1077#1089#1090#1085#1086
      Visible = False
    end
    object Button1: TButton
      Left = 16
      Top = 8
      Width = 115
      Height = 25
      Caption = #1060#1072#1081#1083' '#1080#1089#1090#1086#1095#1080#1082
      TabOrder = 0
      OnClick = Button1Click
    end
    object Edit_DecimlSeparator: TEdit
      Left = 297
      Top = 10
      Width = 33
      Height = 21
      TabOrder = 1
      Text = ','
    end
    object Edit_FieldSeparator: TEdit
      Left = 473
      Top = 10
      Width = 33
      Height = 21
      TabOrder = 2
      Text = '|'
    end
    object CheckBox_FieldNamesFirstRecord: TCheckBox
      Left = 544
      Top = 12
      Width = 201
      Height = 17
      Caption = #1048#1084#1077#1085#1072' '#1087#1086#1083#1077#1081' '#1074' '#1087#1077#1088#1074#1086#1081' '#1089#1090#1088#1086#1082#1077
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object Button2: TButton
      Left = 736
      Top = 10
      Width = 115
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074' '#1092#1072#1081#1083
      Enabled = False
      TabOrder = 4
      OnClick = Button2Click
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 41
    Width = 1089
    Height = 525
    Align = alClient
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.str'
    Left = 64
    Top = 65
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'txt'
    Left = 136
    Top = 64
  end
end
