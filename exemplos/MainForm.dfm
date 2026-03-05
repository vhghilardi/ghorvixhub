object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'Ghorvix Hub - Exemplo de Uso'
  ClientHeight = 500
  ClientWidth = 820
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 15
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 820
    Height = 140
    Align = alTop
    TabOrder = 0
    object LabelToken: TLabel
      Left = 12
      Top = 12
      Width = 32
      Height = 15
      Caption = 'Token'
    end
    object LabelBaseURL: TLabel
      Left = 12
      Top = 64
      Width = 48
      Height = 15
      Caption = 'Base URL'
    end
    object LabelInstancia: TLabel
      Left = 420
      Top = 12
      Width = 47
      Height = 15
      Caption = 'Inst'#226'ncia'
    end
    object EditToken: TEdit
      Left = 12
      Top = 32
      Width = 400
      Height = 23
      TabOrder = 0
      TextHint = 'Cole seu token da API aqui'
    end
    object EditBaseURL: TEdit
      Left = 12
      Top = 84
      Width = 400
      Height = 23
      TabOrder = 1
    end
    object EditInstancia: TEdit
      Left = 420
      Top = 32
      Width = 200
      Height = 23
      TabOrder = 2
      TextHint = 'minhaInstancia'
    end
  end
  object PanelBotoes: TPanel
    Left = 0
    Top = 140
    Width = 820
    Height = 103
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object BtnCriarInstancia: TButton
      Left = 12
      Top = 8
      Width = 140
      Height = 25
      Caption = 'Criar Inst'#226'ncia'
      TabOrder = 0
      OnClick = BtnCriarInstanciaClick
    end
    object BtnListarInstancias: TButton
      Left = 158
      Top = 8
      Width = 140
      Height = 25
      Caption = 'Listar Inst'#226'ncias'
      TabOrder = 1
      OnClick = BtnListarInstanciasClick
    end
    object BtnEnviarTexto: TButton
      Left = 304
      Top = 8
      Width = 100
      Height = 25
      Caption = 'Enviar Texto'
      TabOrder = 2
      OnClick = BtnEnviarTextoClick
    end
    object BtnEnviarMidia: TButton
      Left = 410
      Top = 8
      Width = 100
      Height = 25
      Caption = 'Enviar M'#237'dia'
      TabOrder = 3
      OnClick = BtnEnviarMidiaClick
    end
    object BtnListarRecebidas: TButton
      Left = 516
      Top = 8
      Width = 120
      Height = 25
      Caption = 'Mensagens Recebidas'
      TabOrder = 9
      OnClick = BtnListarRecebidasClick
    end
    object BtnCadastrarContato: TButton
      Left = 12
      Top = 39
      Width = 120
      Height = 25
      Caption = 'Cadastrar Contato'
      TabOrder = 4
      OnClick = BtnCadastrarContatoClick
    end
    object BtnListarContatos: TButton
      Left = 138
      Top = 39
      Width = 100
      Height = 25
      Caption = 'Listar Contatos'
      TabOrder = 6
      OnClick = BtnListarContatosClick
    end
    object BtnCadastrarCliente: TButton
      Left = 244
      Top = 39
      Width = 120
      Height = 25
      Caption = 'Cadastrar Cliente'
      TabOrder = 8
      OnClick = BtnCadastrarClienteClick
    end
    object BtnListarClientes: TButton
      Left = 370
      Top = 39
      Width = 100
      Height = 25
      Caption = 'Listar Clientes'
      TabOrder = 5
      OnClick = BtnListarClientesClick
    end
    object GroupBoxPolling: TGroupBox
      Left = 660
      Top = 4
      Width = 152
      Height = 93
      Caption = ' Polling '
      TabOrder = 7
      object LabelPolling: TLabel
        Left = 12
        Top = 48
        Width = 76
        Height = 15
        Caption = 'Intervalo (ms):'
      end
      object CheckPolling: TCheckBox
        Left = 19
        Top = 25
        Width = 130
        Height = 17
        Caption = 'Ativar polling'
        TabOrder = 0
        OnClick = CheckPollingClick
      end
      object EditPollingInterval: TEdit
        Left = 12
        Top = 64
        Width = 80
        Height = 23
        TabOrder = 1
        Text = '5000'
      end
    end
  end
  object MemoLog: TMemo
    Left = 0
    Top = 243
    Width = 820
    Height = 257
    Align = alClient
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
end
