# Ghorvix Hub API Client - Componente Delphi

Componente Delphi para integração com a API Ghorvix Hub, permitindo criar instâncias WhatsApp, obter QR Code para conexão, listar instâncias ativas, enviar mensagens de texto e mídia, editar e excluir mensagens, além de cadastrar e listar contatos e clientes.

## Requisitos

- Delphi 10.1 Berlin ou superior (com suporte a `System.Net.HttpClient`)
- Projeto com suporte a pacotes (Packages)

## Instalação

### 1. Compilar o pacote

1. Abra o Delphi
2. **File > Open Project**
3. Navegue até `Packages\GhorvixHub.dpk` e abra
4. **Project > Build GhorvixHub** (ou pressione Ctrl+F9)

### 2. Instalar na IDE

1. **Component > Install Packages**
2. Clique em **Add**
3. Selecione o arquivo `GhorvixHub.bpl` (gerado na pasta do projeto ou em `Projects\Bpl`)
4. Marque a caixa ao lado de **GhorvixHub** na lista
5. Clique em **OK**

O componente **TGhorvixHubClient** aparecerá na paleta de componentes na aba **Ghorvix**.

### 3. Adicionar ao projeto (sem instalar na IDE)

Se preferir usar sem instalar na paleta:

1. Adicione a pasta `Source` ao **Library Path** do seu projeto
2. Adicione `GhorvixHubClient` na cláusula `uses` da unit desejada
3. Crie a instância em tempo de execução: `FGhorvixHub := TGhorvixHubClient.Create(Self);`

## Uso

### Propriedades

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| **Token** | string | Token de autenticação da API (obrigatório) |
| **BaseURL** | string | URL base da API (padrão: `https://ghorvix.com.br/app/api`) |
| **RegistrationURL** | string | URL para cadastro da empresa (somente leitura: `https://ghorvix.com.br/app`) |
| **OnRequestComplete** | TNotifyEvent | Evento disparado após cada requisição |

### Métodos da API

#### Criar Instância e Obter QR Code
```delphi
var
  Response: TGhorvixHubInstanceResponse;
begin
  // Cria instância e retorna QR Code para escanear no WhatsApp
  Response := GhorvixHubClient1.CreateConnectInstance('minhaInstancia');  // instanceKey opcional
  if Response.Success then
  begin
    // Response.QRCode contém o QR em base64 ou data URL - exiba em TImage ou salve
    // Response.InstanceKey para usar em SendTextMessage/SendMediaMessage
  end
  else
    ShowMessage('Erro: ' + Response.ErrorMessage);
end;
```

#### Listar Instâncias Ativas
```delphi
var
  Response: TGhorvixHubResponse;
begin
  Response := GhorvixHubClient1.ListActiveInstances;
  if Response.Success then
    Memo1.Lines.Text := Response.Content;  // JSON com lista de instâncias
end;
```

#### Enviar Texto
```delphi
var
  Response: TGhorvixHubResponse;
begin
  Response := GhorvixHubClient1.SendTextMessage('5511999999999', 'Mensagem via API', 'minhaInstancia');  // instanceKey opcional
  if Response.Success then
    ShowMessage('Enviado com sucesso')
  else
    ShowMessage('Erro: ' + Response.ErrorMessage);
end;
```

#### Enviar Mídia
```delphi
Response := GhorvixHubClient1.SendMediaMessage(
  '5511999999999',           // to
  'Imagem via API',          // message
  'imagem.jpg',              // fileName
  'image',                   // mediaType
  'image/jpeg',              // mimeType
  '<BASE64_AQUI>',           // base64
  'minhaInstancia'           // instanceKey (opcional)
);
```

#### Editar Mensagem
```delphi
Response := GhorvixHubClient1.EditMessage(
  1,                         // messageId
  '5511999999999',           // to
  'Texto atualizado',        // message
  0                          // status (opcional, padrão 0)
);
```

#### Excluir Mensagem
```delphi
Response := GhorvixHubClient1.DeleteMessage(1);  // messageId
```

#### Cadastrar Contato
```delphi
Response := GhorvixHubClient1.CreateContact(
  'Contato API',           // nome
  '5511999999999',        // whats
  'contato@email.com',    // email
  'Criado pela API',      // observacoes
  -1,                     // clienteId (-1 = null, opcional)
  True                    // ativo (opcional, padrão True)
);
```

#### Listar Contatos
```delphi
Response := GhorvixHubClient1.ListContacts(1, 50, True);  // page, limit, ativo
if Response.Success then
  Memo1.Lines.Text := Response.Content;  // JSON com lista de contatos
```

#### Cadastrar Cliente
```delphi
Response := GhorvixHubClient1.CreateClient(
  'Cliente API',          // nome
  '5511888888888',       // whats
  'cliente@email.com',    // email
  'Cliente criado pela API',  // observacoes
  True                   // ativo (opcional, padrão True)
);
```

#### Listar Clientes
```delphi
Response := GhorvixHubClient1.ListClients(1, 50, True);  // page, limit, ativo
if Response.Success then
  Memo1.Lines.Text := Response.Content;  // JSON com lista de clientes
```

### Estruturas de Resposta

**TGhorvixHubResponse:**
```delphi
type
  TGhorvixHubResponse = record
    Success: Boolean;      // True se HTTP 2xx
    StatusCode: Integer;   // Código HTTP
    Content: string;       // Corpo da resposta (JSON)
    ErrorMessage: string;  // Mensagem de erro (se houver)
  end;
```

**TGhorvixHubInstanceResponse** (para CreateConnectInstance):
```delphi
type
  TGhorvixHubInstanceResponse = record
    Success: Boolean;
    StatusCode: Integer;
    Content: string;
    ErrorMessage: string;
    InstanceKey: string;   // Chave da instância criada
    QRCode: string;       // QR Code em base64 ou data URL
  end;
```

## Estrutura do Projeto

```
ghiw/
├── Source/
│   ├── GhorvixHubClient.pas      # Componente principal
│   └── GhorvixHubClientReg.pas   # Registro design-time
├── Packages/
│   └── GhorvixHub.dpk            # Pacote para instalação
├── ghorvix-hub-api-collection.json
└── README.md
```

## Endpoints da API

O componente implementa os seguintes endpoints da Ghorvix Hub API:

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| POST | /api/v1/instances/create-connect | Criar instância e obter QR Code |
| GET | /api/v1/instances/active | Listar instâncias ativas |
| POST | /api/v1/messages/text | Enviar mensagem de texto |
| POST | /api/v1/messages/media | Enviar mensagem com mídia |
| PUT | /api/v1/messages/{id} | Editar mensagem |
| DELETE | /api/v1/messages/{id} | Excluir mensagem |
| POST | /api/v1/contacts | Cadastrar contato |
| GET | /api/v1/contacts | Listar contatos (page, limit, ativo) |
| POST | /api/v1/clients | Cadastrar cliente |
| GET | /api/v1/clients | Listar clientes (page, limit, ativo) |

## Licença

O componente é **gratuito**, porém funciona apenas para:
- **Teste de 3 dias** na plataforma Ghorvix Hub
- **Assinantes** da plataforma [ghorvix.com.br/app](https://ghorvix.com.br/app)

Para uso em produção, é necessário ser assinante da plataforma.
