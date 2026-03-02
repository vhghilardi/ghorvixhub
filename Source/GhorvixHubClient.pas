{*******************************************************************************
  Ghorvix Hub API Client Component
  Componente Delphi para integração com a API Ghorvix Hub
*******************************************************************************}
unit GhorvixHubClient;

interface

uses
  System.Classes, System.SysUtils, System.JSON, System.Net.HttpClient,
  System.Net.HttpClientComponent, System.Net.URLClient;

type
  TGhorvixHubResponse = record
    Success: Boolean;
    StatusCode: Integer;
    Content: string;
    ErrorMessage: string;
  end;

  TGhorvixHubClient = class(TComponent)
  private
    FToken: string;
    FBaseURL: string;
    FHTTPClient: TNetHTTPClient;
    FHTTPRequest: TNetHTTPRequest;
    FOnRequestComplete: TNotifyEvent;
    function GetRegistrationURL: string;
    function GetHTTPClient: TNetHTTPClient;
    function GetHTTPRequest: TNetHTTPRequest;
    procedure SetToken(const Value: string);
    procedure SetBaseURL(const Value: string);
  protected
    function DoRequest(const AMethod, AEndpoint, ABody: string): TGhorvixHubResponse;
    function BuildURL(const APath: string): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Enviar Texto - POST /api/v1/messages/text }
    function SendTextMessage(const ATo, AMessage: string): TGhorvixHubResponse;

    { Enviar Mídia - POST /api/v1/messages/media }
    function SendMediaMessage(const ATo, AMessage, AFileName, AMediaType, AMimeType, ABase64: string): TGhorvixHubResponse;

    { Editar Mensagem - PUT /api/v1/messages/{id}
    function EditMessage(const AMessageId: Integer; const ATo, AMessage: string; AStatus: Integer = 0): TGhorvixHubResponse;

    { Excluir Mensagem - DELETE /api/v1/messages/{id}
    function DeleteMessage(const AMessageId: Integer): TGhorvixHubResponse;
  published
    property Token: string read FToken write SetToken;
    property BaseURL: string read FBaseURL write SetBaseURL;
    property RegistrationURL: string read GetRegistrationURL stored False;  // URL para cadastro: https://ghorvix.com.br/app
    property OnRequestComplete: TNotifyEvent read FOnRequestComplete write FOnRequestComplete;
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
end;

destructor TGhorvixHubClient.Destroy;
begin
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

function TGhorvixHubClient.SendTextMessage(const ATo, AMessage: string): TGhorvixHubResponse;
var
  Body: TJSONObject;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('to', ATo);
    Body.AddPair('message', AMessage);
    Result := DoRequest('POST', 'api/v1/messages/text', Body.ToJSON);
  finally
    Body.Free;
  end;
end;

function TGhorvixHubClient.SendMediaMessage(const ATo, AMessage, AFileName,
  AMediaType, AMimeType, ABase64: string): TGhorvixHubResponse;
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

end.
