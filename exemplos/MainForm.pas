{*******************************************************************************
  Ghorvix Hub API Client - Exemplo de Uso
  Demonstra o uso dos métodos do componente TGhorvixHubClient
*******************************************************************************}
unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, GhorvixHubClient;

type
  TFormMain = class(TForm)
    MemoLog: TMemo;
    PanelTop: TPanel;
    LabelToken: TLabel;
    EditToken: TEdit;
    LabelBaseURL: TLabel;
    EditBaseURL: TEdit;
    LabelInstancia: TLabel;
    EditInstancia: TEdit;
    BtnCriarInstancia: TButton;
    BtnListarInstancias: TButton;
    BtnEnviarTexto: TButton;
    BtnEnviarMidia: TButton;
    BtnListarRecebidas: TButton;
    BtnCadastrarContato: TButton;
    BtnListarContatos: TButton;
    BtnCadastrarCliente: TButton;
    BtnListarClientes: TButton;
    PanelBotoes: TPanel;
    GroupBoxPolling: TGroupBox;
    CheckPolling: TCheckBox;
    EditPollingInterval: TEdit;
    LabelPolling: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnCriarInstanciaClick(Sender: TObject);
    procedure BtnListarInstanciasClick(Sender: TObject);
    procedure BtnEnviarTextoClick(Sender: TObject);
    procedure BtnEnviarMidiaClick(Sender: TObject);
    procedure BtnListarRecebidasClick(Sender: TObject);
    procedure BtnCadastrarContatoClick(Sender: TObject);
    procedure BtnListarContatosClick(Sender: TObject);
    procedure BtnCadastrarClienteClick(Sender: TObject);
    procedure BtnListarClientesClick(Sender: TObject);
    procedure CheckPollingClick(Sender: TObject);
  private
    FGhorvixHub: TGhorvixHubClient;
    OpenDialogMidia: TOpenDialog;
    procedure Log(const AMsg: string);
    procedure OnReceivedMessages(Sender: TObject; const Response: TGhorvixHubResponse);
  public
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FGhorvixHub := TGhorvixHubClient.Create(Self);
  FGhorvixHub.OnReceivedMessages := OnReceivedMessages;
  OpenDialogMidia := TOpenDialog.Create(Self);
  OpenDialogMidia.Filter := 'Imagens|*.jpg;*.jpeg;*.png;*.gif;*.webp|' +
    'Documentos|*.pdf;*.doc;*.docx;*.xls;*.xlsx|' +
    'Áudio|*.mp3;*.ogg;*.wav;*.m4a;*.aac|' +
    'Todos os arquivos|*.*';
  OpenDialogMidia.FilterIndex := 0;
  EditBaseURL.Text := 'https://ghorvix.com.br/app';
  EditInstancia.Text := 'minhaInstancia';
  EditPollingInterval.Text := '5000';
  Log('Configure Token, BaseURL e Instância antes de usar.');
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FGhorvixHub.PollingEnabled := False;
end;

procedure TFormMain.Log(const AMsg: string);
begin
  MemoLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' - ' + AMsg);
  MemoLog.Lines.Add('');
end;

procedure TFormMain.OnReceivedMessages(Sender: TObject; const Response: TGhorvixHubResponse);
begin
  if Response.Success then
    Log('[Polling] Mensagens recebidas: ' + Response.Content)
  else
    Log('[Polling] Erro: ' + Response.ErrorMessage);
end;

procedure TFormMain.BtnCriarInstanciaClick(Sender: TObject);
var
  Resp: TGhorvixHubInstanceResponse;
begin
  FGhorvixHub.Token := EditToken.Text;
  FGhorvixHub.BaseURL := EditBaseURL.Text;
  Log('Criando instância...');
  Resp := FGhorvixHub.CreateConnectInstance(Trim(EditInstancia.Text));
  if Resp.Success then
  begin
    if (Trim(EditInstancia.Text) = '') and (Resp.InstanceKey <> '') then
      EditInstancia.Text := Resp.InstanceKey;
    Log('Sucesso! InstanceKey: ' + Resp.InstanceKey);
    if Resp.QRCode <> '' then
      Log('QRCode disponível em Response.QRCode (base64)');
  end
  else
    Log('Erro: ' + Resp.ErrorMessage);
end;

procedure TFormMain.BtnListarInstanciasClick(Sender: TObject);
var
  Resp: TGhorvixHubResponse;
begin
  FGhorvixHub.Token := EditToken.Text;
  FGhorvixHub.BaseURL := EditBaseURL.Text;
  Log('Listando instâncias ativas...');
  Resp := FGhorvixHub.ListActiveInstances;
  if Resp.Success then
    Log('Resposta: ' + Resp.Content)
  else
    Log('Erro: ' + Resp.ErrorMessage);
end;

procedure TFormMain.BtnEnviarTextoClick(Sender: TObject);
var
  Resp: TGhorvixHubResponse;
  Numero, Msg: string;
begin
  Numero := InputBox('Enviar Texto', 'Número (ex: 5511999999999):', '5511999999999');
  if Numero = '' then Exit;
  Msg := InputBox('Enviar Texto', 'Mensagem:', 'Teste via API');
  FGhorvixHub.Token := EditToken.Text;
  FGhorvixHub.BaseURL := EditBaseURL.Text;
  Log('Enviando mensagem para ' + Numero + '...');
  Resp := FGhorvixHub.SendTextMessage(Numero, Msg, Trim(EditInstancia.Text));
  if Resp.Success then
    Log('Mensagem enviada com sucesso!')
  else
    Log('Erro: ' + Resp.ErrorMessage);
end;

procedure TFormMain.BtnEnviarMidiaClick(Sender: TObject);
var
  Resp: TGhorvixHubResponse;
  Numero, Msg: string;
begin
  if not OpenDialogMidia.Execute then
    Exit;
  Numero := InputBox('Enviar Mídia', 'Número (ex: 5511999999999):', '5511999999999');
  if Numero = '' then Exit;
  Msg := InputBox('Enviar Mídia', 'Legenda (opcional):', '');
  try
    FGhorvixHub.Token := EditToken.Text;
    FGhorvixHub.BaseURL := EditBaseURL.Text;
    Log('Enviando mídia do arquivo ' + OpenDialogMidia.FileName + ' para ' + Numero + '...');
    Resp := FGhorvixHub.SendMediaMessageFromFile(
      Numero, Msg, OpenDialogMidia.FileName,
      Trim(EditInstancia.Text)
    );
    if Resp.Success then
      Log('Mídia enviada com sucesso!')
    else
      Log('Erro: ' + Resp.ErrorMessage);
  except
    on E: Exception do
      Log('Erro ao ler arquivo: ' + E.Message);
  end;
end;

procedure TFormMain.BtnListarRecebidasClick(Sender: TObject);
var
  Resp: TGhorvixHubResponse;
begin
  FGhorvixHub.Token := EditToken.Text;
  FGhorvixHub.BaseURL := EditBaseURL.Text;
  Log('Listando mensagens recebidas...');
  Resp := FGhorvixHub.ListReceivedMessages(1, 50, '', '', Trim(EditInstancia.Text));
  if Resp.Success then
    Log('Resposta: ' + Resp.Content)
  else
    Log('Erro: ' + Resp.ErrorMessage);
end;

procedure TFormMain.BtnCadastrarContatoClick(Sender: TObject);
var
  Resp: TGhorvixHubResponse;
begin
  FGhorvixHub.Token := EditToken.Text;
  FGhorvixHub.BaseURL := EditBaseURL.Text;
  Log('Cadastrando contato...');
  Resp := FGhorvixHub.CreateContact(
    'Contato Exemplo',
    '5511999999999',
    'contato@exemplo.com',
    'Criado pelo exemplo',
    -1,  // clienteId: -1 = null
    True
  );
  if Resp.Success then
    Log('Contato cadastrado! Resposta: ' + Resp.Content)
  else
    Log('Erro: ' + Resp.ErrorMessage);
end;

procedure TFormMain.BtnListarContatosClick(Sender: TObject);
var
  Resp: TGhorvixHubResponse;
begin
  FGhorvixHub.Token := EditToken.Text;
  FGhorvixHub.BaseURL := EditBaseURL.Text;
  Log('Listando contatos...');
  Resp := FGhorvixHub.ListContacts(1, 50, True);
  if Resp.Success then
    Log('Resposta: ' + Resp.Content)
  else
    Log('Erro: ' + Resp.ErrorMessage);
end;

procedure TFormMain.BtnCadastrarClienteClick(Sender: TObject);
var
  Resp: TGhorvixHubResponse;
begin
  FGhorvixHub.Token := EditToken.Text;
  FGhorvixHub.BaseURL := EditBaseURL.Text;
  Log('Cadastrando cliente...');
  Resp := FGhorvixHub.CreateClient(
    'Cliente Exemplo',
    '5511888888888',
    'cliente@exemplo.com',
    'Cliente criado pelo exemplo',
    True
  );
  if Resp.Success then
    Log('Cliente cadastrado! Resposta: ' + Resp.Content)
  else
    Log('Erro: ' + Resp.ErrorMessage);
end;

procedure TFormMain.BtnListarClientesClick(Sender: TObject);
var
  Resp: TGhorvixHubResponse;
begin
  FGhorvixHub.Token := EditToken.Text;
  FGhorvixHub.BaseURL := EditBaseURL.Text;
  Log('Listando clientes...');
  Resp := FGhorvixHub.ListClients(1, 50, True);
  if Resp.Success then
    Log('Resposta: ' + Resp.Content)
  else
    Log('Erro: ' + Resp.ErrorMessage);
end;

procedure TFormMain.CheckPollingClick(Sender: TObject);
begin
  FGhorvixHub.Token := EditToken.Text;
  FGhorvixHub.BaseURL := EditBaseURL.Text;
  FGhorvixHub.PollingInstanceKey := Trim(EditInstancia.Text);
  FGhorvixHub.PollingInterval := StrToIntDef(EditPollingInterval.Text, 5000);
  FGhorvixHub.PollingEnabled := CheckPolling.Checked;
  if CheckPolling.Checked then
    Log('Polling ativado (intervalo: ' + EditPollingInterval.Text + ' ms)')
  else
    Log('Polling desativado');
end;

end.
