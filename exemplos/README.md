# Exemplo de Uso - Ghorvix Hub API Client

Projeto de demonstração do componente `TGhorvixHubClient`.

## Como executar

1. Instale o pacote GhorvixHub (veja o README principal)
2. Abra `ExemploUso.dpr` ou `ExemploUso.dproj` no Delphi
3. Se o projeto não encontrar a unit `GhorvixHubClient`, adicione `..\Source` em **Project > Options > Delphi Compiler > Search path**
4. Compile e execute (F9)

## Funcionalidades demonstradas

| Botão | Método | Descrição |
|-------|--------|-----------|
| Criar Instância | `CreateConnectInstance` | Cria instância WhatsApp e obtém QR Code |
| Listar Instâncias | `ListActiveInstances` | Lista instâncias ativas |
| Enviar Texto | `SendTextMessage` | Envia mensagem de texto |
| Enviar Texto com IA | `SendTextMessageWithAI` | Envia texto usando reescrita leve com IA |
| Enviar Mídia | `SendMediaMessageFromFile` | Seleciona arquivo (imagem/documento/áudio) e o componente converte internamente para base64 |
| Enviar em Massa | `SendBulkMessages` / `SendBulkMessagesFromFile` | Dispara campanha para múltiplos destinatários (com ou sem mídia) |
| Mensagens Recebidas | `ListReceivedMessages` | Lista mensagens recebidas |
| Cadastrar Contato | `CreateContact` | Cadastra novo contato |
| Listar Contatos | `ListContacts` | Lista contatos |
| Cadastrar Cliente | `CreateClient` | Cadastra novo cliente |
| Listar Clientes | `ListClients` | Lista clientes |
| Polling | `PollingEnabled` | Busca automática de mensagens a cada X ms |

## Configuração

Antes de usar, informe:
- **Token**: Seu token da API (obtenha em https://ghorvix.com.br/app)
- **Base URL**: URL da API (padrão: https://ghorvix.com.br/app/api)
