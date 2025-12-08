# API Documentation - PBX Moderno Enterprise

Documentação completa da API REST do sistema PBX Moderno Enterprise.

## Base URL

\`\`\`
http://localhost:3000
\`\`\`

## Autenticação

Todas as rotas (exceto `/auth/login`) requerem autenticação via JWT Bearer Token.

### Headers

\`\`\`
Authorization: Bearer {seu_token_jwt}
Content-Type: application/json
\`\`\`

## Endpoints

### Autenticação

#### POST /auth/login

Realiza login no sistema.

**Request Body:**
\`\`\`json
{
  "email": "admin@pbxmoderno.com",
  "senha": "Admin@123"
}
\`\`\`

**Response (200):**
\`\`\`json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "nome": "Administrador",
    "email": "admin@pbxmoderno.com",
    "perfil": "admin",
    "tenantId": 1,
    "tenant": {
      "id": 1,
      "nome": "Empresa Principal"
    }
  }
}
\`\`\`

#### GET /auth/me

Retorna dados do usuário autenticado.

**Response (200):**
\`\`\`json
{
  "id": 1,
  "nome": "Administrador",
  "email": "admin@pbxmoderno.com",
  "perfil": "admin",
  "tenantId": 1
}
\`\`\`

---

### Ramais (Extensions)

#### GET /extensions

Lista todos os ramais do tenant.

**Response (200):**
\`\`\`json
[
  {
    "id": 1,
    "numero": "1000",
    "nome": "João Silva",
    "tipo": "pjsip",
    "callerId": "João <1000>",
    "online": true,
    "ativo": true,
    "ultimoRegistro": "2025-01-10T10:30:00Z"
  }
]
\`\`\`

#### GET /extensions/:id

Busca um ramal específico.

**Response (200):**
\`\`\`json
{
  "id": 1,
  "numero": "1000",
  "nome": "João Silva",
  "senha": "senhaHash",
  "tipo": "pjsip",
  "callerId": "João <1000>",
  "context": "from-internal",
  "codecs": "alaw,ulaw,g729",
  "transporte": "udp",
  "nat": "yes",
  "dtmfMode": "rfc4733",
  "maxContacts": 1,
  "qualifyfreq": 60,
  "online": true,
  "ativo": true
}
\`\`\`

#### POST /extensions

Cria um novo ramal.

**Request Body:**
\`\`\`json
{
  "numero": "1001",
  "nome": "Maria Santos",
  "senha": "senhaSegura123",
  "tipo": "pjsip",
  "callerId": "Maria <1001>",
  "codecs": "alaw,ulaw",
  "ativo": true
}
\`\`\`

**Response (201):**
\`\`\`json
{
  "id": 2,
  "numero": "1001",
  "nome": "Maria Santos",
  "tipo": "pjsip",
  "online": false,
  "ativo": true
}
\`\`\`

#### PATCH /extensions/:id

Atualiza um ramal.

**Request Body:**
\`\`\`json
{
  "nome": "Maria Santos Oliveira",
  "callerId": "Maria Oliveira <1001>"
}
\`\`\`

#### DELETE /extensions/:id

Remove um ramal.

**Response (200):**
\`\`\`json
{
  "message": "Ramal removido com sucesso"
}
\`\`\`

---

### Troncos (Trunks)

#### GET /trunks

Lista todos os troncos.

#### POST /trunks

Cria um novo tronco.

**Request Body:**
\`\`\`json
{
  "nome": "Operadora Principal",
  "tipo": "pjsip",
  "host": "sip.operadora.com.br",
  "porta": 5060,
  "usuario": "minha_conta",
  "senha": "senha_operadora",
  "registrar": true,
  "codecs": "alaw,ulaw",
  "ativo": true
}
\`\`\`

---

### Filas (Queues)

#### GET /queues

Lista todas as filas.

**Response (200):**
\`\`\`json
[
  {
    "id": 1,
    "nome": "Suporte",
    "numero": "4000",
    "estrategia": "ringall",
    "timeout": 15,
    "retry": 5,
    "ativo": true,
    "membros": [
      {
        "id": 1,
        "extensionId": 1,
        "interface": "PJSIP/1000",
        "penalty": 0,
        "paused": false
      }
    ]
  }
]
\`\`\`

#### POST /queues

Cria uma nova fila.

**Request Body:**
\`\`\`json
{
  "nome": "Vendas",
  "numero": "4001",
  "estrategia": "leastrecent",
  "timeout": 20,
  "retry": 5,
  "wrapuptime": 15,
  "maxlen": 10,
  "ativo": true
}
\`\`\`

#### POST /queues/:id/members/:extensionId

Adiciona um ramal à fila.

**Response (201):**
\`\`\`json
{
  "id": 2,
  "queueId": 1,
  "extensionId": 2,
  "interface": "PJSIP/1001",
  "penalty": 0,
  "paused": false
}
\`\`\`

#### DELETE /queues/members/:memberId

Remove um membro da fila.

---

### CDR (Call Detail Records)

#### GET /cdr

Lista registros de chamadas.

**Query Parameters:**
- `dataInicio`: Data inicial (ISO 8601)
- `dataFim`: Data final (ISO 8601)
- `limit`: Limite de registros (padrão: 100)

**Response (200):**
\`\`\`json
[
  {
    "id": 1,
    "uniqueId": "1705400000.123",
    "dataHora": "2025-01-10T14:30:00Z",
    "numeroOrigem": "1000",
    "numeroDestino": "11999998888",
    "ramalOrigem": "1000",
    "disposicao": "ANSWERED",
    "duracao": 125,
    "tempoAtendimento": 5,
    "arquivoGravacao": "/var/spool/asterisk/monitor/..."
  }
]
\`\`\`

#### GET /cdr/stats

Retorna estatísticas de chamadas.

**Query Parameters:**
- `periodo`: "hoje", "semana", "mes" (padrão: "hoje")

**Response (200):**
\`\`\`json
{
  "totalChamadas": 150,
  "atendidas": 130,
  "perdidas": 20,
  "duracaoMedia": 180
}
\`\`\`

---

### Dashboard

#### GET /dashboard/stats

Retorna estatísticas gerais do sistema.

**Response (200):**
\`\`\`json
{
  "ramais": {
    "total": 50,
    "online": 38,
    "offline": 12
  },
  "troncos": {
    "total": 3,
    "online": 3,
    "offline": 0
  },
  "filas": {
    "total": 5
  },
  "chamadas": {
    "total": 1250
  }
}
\`\`\`

#### GET /dashboard/recent-calls

Retorna chamadas recentes.

**Query Parameters:**
- `limit`: Número de registros (padrão: 10)

---

### Tenants

#### GET /tenants

Lista todos os tenants (apenas usuários root).

#### POST /tenants

Cria um novo tenant.

**Request Body:**
\`\`\`json
{
  "nome": "Nova Empresa LTDA",
  "dominio": "nova-empresa.pbx.local",
  "plano": "profissional",
  "maxRamais": 50,
  "maxTroncos": 5,
  "ativo": true
}
\`\`\`

---

### Usuários

#### GET /users

Lista todos os usuários do tenant.

#### POST /users

Cria um novo usuário.

**Request Body:**
\`\`\`json
{
  "nome": "Operador Sistema",
  "email": "operador@empresa.com",
  "senha": "senhaSegura123",
  "perfil": "operador",
  "ativo": true
}
\`\`\`

**Perfis disponíveis:**
- `root`: Acesso total ao sistema
- `admin`: Administrador do tenant
- `operador`: Operador com acesso limitado
- `leitura`: Apenas visualização

---

## Códigos de Status HTTP

- `200 OK`: Requisição bem-sucedida
- `201 Created`: Recurso criado com sucesso
- `400 Bad Request`: Dados inválidos
- `401 Unauthorized`: Não autenticado
- `403 Forbidden`: Sem permissão
- `404 Not Found`: Recurso não encontrado
- `409 Conflict`: Conflito (ex: email já existe)
- `500 Internal Server Error`: Erro no servidor

## Rate Limiting

Atualmente não há limite de requisições, mas recomenda-se implementar rate limiting em produção.

## Versionamento

API Version: 1.0.0

---

Para mais informações, consulte o README.md principal.
