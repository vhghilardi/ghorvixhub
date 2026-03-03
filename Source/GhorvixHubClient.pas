{*******************************************************************************
  Ghorvix Hub API Client Component
  Componente Delphi para integração com a API Ghorvix Hub
*******************************************************************************}
unit GhorvixHubClient;

interface

uses
  System.Classes, System.SysUtils, System.JSON, System.Net.HttpClient,
  System.Net.HttpClientComponent, System.Net.URLClient, System.NetEncoding,
  Vcl.ExtCtrls;

type
  TGhorvixHubReceivedMessagesEvent = procedure(Sender: TObject; const Response: TGhorvixHubResponse) of object;

  TGhorvixHubResponse = record
    Success: Boolean;
    StatusCode: Integer;
    Content: string;
    ErrorMessage: string;
  end;

  TGhorvixHubInstanceResponse = record
    Success: Boolean;
    StatusCode: Integer;
    Content: string;
    ErrorMessage: string;
    InstanceKey: string;   // Chave da instância criada
    QRCode: string;       // QRCode em base64 ou data URL para exibir
  end;

  TGhorvixHubClient = class(TComponent)
  private
    FToken: string;
    FBaseURL: string;
    FHTTPClient: TNetHTTPClient;
    FHTTPRequest: TNetHTTPRequest;
    FOnRequestComplete: TNotifyEvent;
    FTimer: TTimer;
    FPollingInterval: Integer;
    FPollingEnabled: Boolean;
    FPollingInstanceKey: string;
    FOnReceivedMessages: TGhorvixHubReceivedMessagesEvent;
    function GetRegistrationURL: string;
    function GetHTTPClient: TNetHTTPClient;
    function GetHTTPRequest: TNetHTTPRequest;
    procedure SetToken(const Value: string);
    procedure SetBaseURL(const Value: string);
    procedure SetPollingEnabled(const Value: Boolean);
    procedure SetPollingInterval(const Value: Integer);
    procedure PollingTimerTick(Sender: TObject);
  protected
    function DoRequest(const AMethod, AEndpoint, ABody: string): TGhorvixHubResponse;
    function BuildURL(const APath: string): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Criar e Conectar Instância - POST /api/v1/instances/create-connect - Retorna QRCode }
    function CreateConnectInstance(const AInstanceKey: string = ''): TGhorvixHubInstanceResponse;

    { Listar Instâncias Ativas - GET /api/v1/instances/active }
    function ListActiveInstances: TGhorvixHubResponse;

    { Enviar Texto - POST /api/v1/messages/text }
    function SendTextMessage(const ATo, AMessage: string; const AInstanceKey: string = ''): TGhorvixHubResponse;

    { Enviar Mídia - POST /api/v1/messages/media }
    function SendMediaMessage(const ATo, AMessage, AFileName, AMediaType, AMimeType, ABase64: string; const AInstanceKey: string = ''): TGhorvixHubResponse;

    { Editar Mensagem - PUT /api/v1/messages/{id}
    function EditMessage(const AMessageId: Integer; const ATo, AMessage: string; AStatus: Integer = 0): TGhorvixHubResponse;

    { Excluir Mensagem - DELETE /api/v1/messages/{id}
    function DeleteMessage(const AMessageId: Integer): TGhorvixHubResponse;

    { Cadastrar Contato - POST /api/v1/contacts }
    function CreateContact(const ANome, AWhats, AEmail, AObservacoes: string; AClienteId: Integer = -1; AAtivo: Boolean = True): TGhorvixHubResponse;

    { Listar Contatos - GET /api/v1/contacts }
    function ListContacts(APage: Integer = 1; ALimit: Integer = 50; AAtivo: Boolean = True): TGhorvixHubResponse;

    { Cadastrar Cliente - POST /api/v1/clients }
    function CreateClient(const ANome, AWhats, AEmail, AObservacoes: string; AAtivo: Boolean = True): TGhorvixHubResponse;

    { Listar Clientes - GET /api/v1/clients }
    function ListClients(APage: Integer = 1; ALimit: Integer = 50; AAtivo: Boolean = True): TGhorvixHubResponse;

    { Listar Mensagens Recebidas - GET /api/v1/messages/received (marca como lida) }
    function ListReceivedMessages(APage: Integer = 1; ALimit: Integer = 50; const AStartDate: string = ''; const AEndDate: string = ''; const AInstanceKey: string = ''): TGhorvixHubResponse;
  published
    property Token: string read FToken write SetToken;
    property BaseURL: string read FBaseURL write SetBaseURL;
    property RegistrationURL: string read GetRegistrationURL stored False;  // URL para cadastro: https://ghorvix.com.br/app
    property OnRequestComplete: TNotifyEvent read FOnRequestComplete write FOnRequestComplete;
    { Polling de mensagens recebidas }
    property PollingEnabled: Boolean read FPollingEnabled write SetPollingEnabled default False;
    property PollingInterval: Integer read FPollingInterval write SetPollingInterval default 5000;
    property PollingInstanceKey: string read FPollingInstanceKey write FPollingInstanceKey;
    property OnReceivedMessages: TGhorvixHubReceivedMessagesEvent read FOnReceivedMessages write FOnReceivedMessages;
  end;

implementation

{ TGhorvixHubClient }

constructor TGhorvixHubClient.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FToken := '';
  FBaseURL := 'https://ghorvix.com.br/app/api';
  FHTTPClient := nil;
  FHTTPRequest := nil;
  FPollingInterval := 5000;
  FPollingEnabled := False;
  FPollingInstanceKey := '';
  FOnReceivedMessages := nil;
end;

destructor TGhorvixHubClient.Destroy;
begin
  FPollingEnabled := False;
  if Assigned(FTimer) then
  begin
    FTimer.Free;
    FTimer := nil;
  end;
  if Assigned(FHTTPRequest) then
    FHTTPRequest.Free;
  if Assigned(FHTTPClient) then
    FHTTPClient.Free;
  inherited;
end;

function TGhorvixHubClient.GetHTTPClient: TNetHTTPClient;
begin
  if not Assigned(FHTTPClient) then
    FHTTPClient := TNetHTTPClient.Create(nil);
  Result := FHTTPClient;
end;

function TGhorvixHubClient.GetHTTPRequest: TNetHTTPRequest;
begin
  if not Assigned(FHTTPRequest) then
  begin
    FHTTPRequest := TNetHTTPRequest.Create(nil);
    FHTTPRequest.Client := GetHTTPClient;
  end;
  Result := FHTTPRequest;
end;

function TGhorvixHubClient.GetRegistrationURL: string;
begin
  Result := 'https://ghorvix.com.br/app';
end;

procedure TGhorvixHubClient.SetToken(const Value: string);
begin
  FToken := Value;
end;

procedure TGhorvixHubClient.SetBaseURL(const Value: string);
var
  S: string;
begin
  S := Trim(Value);
  if S <> '' then
    FBaseURL := S.TrimRight(['/']);
end;

procedure TGhorvixHubClient.SetPollingEnabled(const Value: Boolean);
begin
  if FPollingEnabled = Value then
    Exit;
  FPollingEnabled := Value;
  if FPollingEnabled then
  begin
    if not Assigned(FTimer) then
    begin
      FTimer := TTimer.Create(Self);
      FTimer.OnTimer := PollingTimerTick;
    end;
    FTimer.Interval := FPollingInterval;
    FTimer.Enabled := True;
  end
  else
    if Assigned(FTimer) then
      FTimer.Enabled := False;
end;

procedure TGhorvixHubClient.SetPollingInterval(const Value: Integer);
begin
  if Value < 1000 then
    FPollingInterval := 1000
  else
    FPollingInterval := Value;
  if Assigned(FTimer) then
    FTimer.Interval := FPollingInterval;
end;

procedure TGhorvixHubClient.PollingTimerTick(Sender: TObject);
var
  Resp: TGhorvixHubResponse;
begin
  if not Assigned(FOnReceivedMessages) then
    Exit;
  Resp := ListReceivedMessages(1, 50, '', '', FPollingInstanceKey);
  FOnReceivedMessages(Self, Resp);
end;

function TGhorvixHubClient.BuildURL(const APath: string): string;
var
  Path: string;
begin
  Path := APath;
  if Path.StartsWith('/') then
    Delete(Path, 1, 1);
  Result := FBaseURL + '/' + Path;
end;

function TGhorvixHubClient.DoRequest(const AMethod, AEndpoint, ABody: string): TGhorvixHubResponse;
var
  Req: TNetHTTPRequest;
  Resp: IHTTPResponse;
  URL: string;
  BodyStream: TStringStream;
begin
  Result.Success := False;
  Result.StatusCode := 0;
  Result.Content := '';
  Result.ErrorMessage := '';

  if FToken = '' then
  begin
    Result.ErrorMessage := 'Token não configurado. Defina a propriedade Token.';
    Exit;
  end;

  URL := BuildURL(AEndpoint);

  try
    Req := GetHTTPRequest;
    Req.CustomHeaders['x-api-token'] := FToken;
    Req.CustomHeaders['Content-Type'] := 'application/json';

    if ABody <> '' then
    begin
      BodyStream := TStringStream.Create(ABody, TEncoding.UTF8);
      try
        if AMethod = 'POST' then
          Resp := Req.Post(URL, BodyStream)
        else if AMethod = 'PUT' then
          Resp := Req.Put(URL, BodyStream)
        else
          Resp := nil;
      finally
        BodyStream.Free;
      end;
    end
    else
    begin
      if AMethod = 'DELETE' then
        Resp := Req.Delete(URL)
      else if AMethod = 'GET' then
        Resp := Req.Get(URL)
      else
        Resp := nil;
    end;

    if Assigned(Resp) then
    begin
      Result.StatusCode := Resp.StatusCode;
      Result.Content := Resp.ContentAsString;
      Result.Success := (Result.StatusCode >= 200) and (Result.StatusCode < 300);

      if not Result.Success then
        Result.ErrorMessage := Format('HTTP %d: %s', [Result.StatusCode, Result.Content]);
    end;

    if Assigned(FOnRequestComplete) then
      FOnRequestComplete(Self);
  except
    on E: Exception do
      Result.ErrorMessage := E.Message;
  end;
end;

function TGhorvixHubClient.CreateConnectInstance(const AInstanceKey: string): TGhorvixHubInstanceResponse;
var
  Body: TJSONObject;
  BaseResp: TGhorvixHubResponse;
  JSON: TJSONObject;
  Val: TJSONValue;
begin
  Result.Success := False;
  Result.StatusCode := 0;
  Result.Content := '';
  Result.ErrorMessage := '';
  Result.InstanceKey := '';
  Result.QRCode := '';

  Body := TJSONObject.Create;
  try
    if AInstanceKey <> '' then
      Body.AddPair('instanceKey', AInstanceKey);
    BaseResp := DoRequest('POST', 'api/v1/instances/create-connect', Body.ToJSON);
  finally
    Body.Free;
  end;

  Result.Success := BaseResp.Success;
  Result.StatusCode := BaseResp.StatusCode;
  Result.Content := BaseResp.Content;
  Result.ErrorMessage := BaseResp.ErrorMessage;

  if BaseResp.Success and (BaseResp.Content <> '') then
  begin
    try
      JSON := TJSONObject.ParseJSONValue(BaseResp.Content) as TJSONObject;
      if Assigned(JSON) then
      try
        Val := JSON.GetValue('instanceKey');
        if Assigned(Val) then
          Result.InstanceKey := Val.Value;
        Val := JSON.GetValue('qrCode');
        if Assigned(Val) then
          Result.QRCode := Val.Value
        else
        begin
          Val := JSON.GetValue('qrcode');
          if Assigned(Val) then
            Result.QRCode := Val.Value;
        end;
      finally
        JSON.Free;
      end;
    except
      // Ignora erro de parse - Content permanece disponível
    end;
  end;
end;

function TGhorvixHubClient.ListActiveInstances: TGhorvixHubResponse;
begin
  Result := DoRequest('GET', 'api/v1/instances/active', '');
end;

function TGhorvixHubClient.SendTextMessage(const ATo, AMessage: string; const AInstanceKey: string): TGhorvixHubResponse;
var
  Body: TJSONObject;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('to', ATo);
    Body.AddPair('message', AMessage);
    if AInstanceKey <> '' then
      Body.AddPair('instanceKey', AInstanceKey);
    Result := DoRequest('POST', 'api/v1/messages/text', Body.ToJSON);
  finally
    Body.Free;
  end;
end;

function TGhorvixHubClient.SendMediaMessage(const ATo, AMessage, AFileName,
  AMediaType, AMimeType, ABase64: string; const AInstanceKey: string): TGhorvixHubResponse;
var
  Body: TJSONObject;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('to', ATo);
    Body.AddPair('message', AMessage);
    Body.AddPair('fileName', AFileName);
    Body.AddPair('mediaType', AMediaType);
    Body.AddPair('mimeType', AMimeType);
    Body.AddPair('base64', ABase64);
    if AInstanceKey <> '' then
      Body.AddPair('instanceKey', AInstanceKey);
    Result := DoRequest('POST', 'api/v1/messages/media', Body.ToJSON);
  finally
    Body.Free;
  end;
end;

function TGhorvixHubClient.EditMessage(const AMessageId: Integer; const ATo,
  AMessage: string; AStatus: Integer): TGhorvixHubResponse;
var
  Body: TJSONObject;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('to', ATo);
    Body.AddPair('message', AMessage);
    Body.AddPair('status', TJSONNumber.Create(AStatus));
    Result := DoRequest('PUT', Format('api/v1/messages/%d', [AMessageId]), Body.ToJSON);
  finally
    Body.Free;
  end;
end;

function TGhorvixHubClient.DeleteMessage(const AMessageId: Integer): TGhorvixHubResponse;
begin
  Result := DoRequest('DELETE', Format('api/v1/messages/%d', [AMessageId]), '');
end;

function TGhorvixHubClient.CreateContact(const ANome, AWhats, AEmail, AObservacoes: string; AClienteId: Integer; AAtivo: Boolean): TGhorvixHubResponse;
var
  Body: TJSONObject;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('nome', ANome);
    Body.AddPair('whats', AWhats);
    Body.AddPair('email', AEmail);
    Body.AddPair('observacoes', AObservacoes);
    if AClienteId >= 0 then
      Body.AddPair('clienteId', TJSONNumber.Create(AClienteId))
    else
      Body.AddPair('clienteId', TJSONNull.Create);
    Body.AddPair('ativo', TJSONBool.Create(AAtivo));
    Result := DoRequest('POST', 'api/v1/contacts', Body.ToJSON);
  finally
    Body.Free;
  end;
end;

function TGhorvixHubClient.ListContacts(APage, ALimit: Integer; AAtivo: Boolean): TGhorvixHubResponse;
var
  Endpoint: string;
begin
  Endpoint := Format('api/v1/contacts?page=%d&limit=%d&ativo=%s', [APage, ALimit, LowerCase(BoolToStr(AAtivo, True))]);
  Result := DoRequest('GET', Endpoint, '');
end;

function TGhorvixHubClient.CreateClient(const ANome, AWhats, AEmail, AObservacoes: string; AAtivo: Boolean): TGhorvixHubResponse;
var
  Body: TJSONObject;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('nome', ANome);
    Body.AddPair('whats', AWhats);
    Body.AddPair('email', AEmail);
    Body.AddPair('observacoes', AObservacoes);
    Body.AddPair('ativo', TJSONBool.Create(AAtivo));
    Result := DoRequest('POST', 'api/v1/clients', Body.ToJSON);
  finally
    Body.Free;
  end;
end;

function TGhorvixHubClient.ListClients(APage, ALimit: Integer; AAtivo: Boolean): TGhorvixHubResponse;
var
  Endpoint: string;
begin
  Endpoint := Format('api/v1/clients?page=%d&limit=%d&ativo=%s', [APage, ALimit, LowerCase(BoolToStr(AAtivo, True))]);
  Result := DoRequest('GET', Endpoint, '');
end;

function TGhorvixHubClient.ListReceivedMessages(APage, ALimit: Integer; const AStartDate, AEndDate, AInstanceKey: string): TGhorvixHubResponse;
var
  Endpoint: string;
begin
  Endpoint := Format('api/v1/messages/received?page=%d&limit=%d', [APage, ALimit]);
  if Trim(AStartDate) <> '' then
    Endpoint := Endpoint + '&startDate=' + TNetEncoding.URL.Encode(Trim(AStartDate));
  if Trim(AEndDate) <> '' then
    Endpoint := Endpoint + '&endDate=' + TNetEncoding.URL.Encode(Trim(AEndDate));
  if Trim(AInstanceKey) <> '' then
    Endpoint := Endpoint + '&instanceKey=' + TNetEncoding.URL.Encode(Trim(AInstanceKey));
  Result := DoRequest('GET', Endpoint, '');
end;

end.
