object frmConfiguracao: TfrmConfiguracao
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Configura'#231#227'o do Sistema'
  ClientHeight = 212
  ClientWidth = 457
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlFundo: TPanel
    Left = 0
    Top = 0
    Width = 457
    Height = 212
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 0
    ExplicitLeft = 200
    ExplicitTop = 72
    ExplicitWidth = 185
    ExplicitHeight = 41
    object pnlControles: TPanel
      Left = 1
      Top = 1
      Width = 455
      Height = 169
      Align = alTop
      TabOrder = 0
      object gpbConfiguracoes: TGroupBox
        Left = 7
        Top = 6
        Width = 439
        Height = 155
        Caption = 'Configura'#231#245'es de envio de e-mail'
        TabOrder = 0
        object Label2: TLabel
          Left = 24
          Top = 47
          Width = 40
          Height = 13
          Caption = 'Usu'#225'rio:'
        end
        object Label1: TLabel
          Left = 24
          Top = 21
          Width = 44
          Height = 13
          Caption = 'Servidor:'
        end
        object lblSenha: TLabel
          Left = 24
          Top = 73
          Width = 34
          Height = 13
          Caption = 'Senha:'
        end
        object lblPorta: TLabel
          Left = 24
          Top = 100
          Width = 30
          Height = 13
          Caption = 'Porta:'
        end
        object edtUsuario: TEdit
          Left = 86
          Top = 44
          Width = 203
          Height = 21
          TabOrder = 0
        end
        object edtServidorSmtp: TEdit
          Left = 86
          Top = 18
          Width = 330
          Height = 21
          TabOrder = 1
        end
        object edtSenha: TEdit
          Left = 86
          Top = 71
          Width = 203
          Height = 21
          PasswordChar = '#'
          TabOrder = 2
        end
        object edtPorta: TEdit
          Left = 86
          Top = 97
          Width = 59
          Height = 21
          TabOrder = 3
        end
        object chkSSL: TCheckBox
          Left = 86
          Top = 126
          Width = 203
          Height = 17
          Caption = 'Utilizar SSL'
          TabOrder = 4
        end
      end
    end
    object pnlBotoes: TPanel
      Left = 1
      Top = 170
      Width = 455
      Height = 41
      Align = alClient
      TabOrder = 1
      ExplicitLeft = 0
      ExplicitTop = 231
      ExplicitHeight = 63
      object btnGravar: TButton
        Left = 280
        Top = 9
        Width = 75
        Height = 25
        Caption = 'Gravar'
        TabOrder = 0
        OnClick = btnGravarClick
      end
      object btnCancelar: TButton
        Left = 368
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Cancelar'
        ModalResult = 2
        TabOrder = 1
      end
    end
  end
end
