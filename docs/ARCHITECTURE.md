# Arquitetura do Sistema - PBX Moderno Enterprise

## Visão Geral

O PBX Moderno Enterprise é um sistema distribuído de telefonia empresarial com arquitetura em três camadas:

1. **Frontend (Apresentação)**: Interface web React
2. **Backend (Aplicação)**: API REST NestJS
3. **Asterisk (Telefonia)**: Motor de comunicação

## Diagrama de Arquitetura

\`\`\`
┌─────────────────────────────────────────────────────────┐
│                      FRONTEND                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │        React + TailwindCSS + Zustand             │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐ │  │
│  │  │  Dashboard │  │  Extensions│  │   Queues   │ │  │
│  │  └────────────┘  └────────────┘  └────────────┘ │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │ HTTP/REST + JWT
                     ▼
┌─────────────────────────────────────────────────────────┐
│                      BACKEND                            │
│  ┌──────────────────────────────────────────────────┐  │
│  │          NestJS + TypeORM                        │  │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐  │  │
│  │  │ Auth │ │Users │ │ Exts │ │Queue │ │ CDR  │  │  │
│  │  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘  │  │
│  └────────────┬──────────────────────────┬──────────┘  │
└───────────────┼──────────────────────────┼─────────────┘
                │                          │
                │ SQL                      │ AMI/ARI
                ▼                          ▼
    ┌────────────────────┐    ┌────────────────────────┐
    │    PostgreSQL      │    │      Asterisk 20+      │
    │  ┌──────────────┐  │    │  ┌──────────────────┐ │
    │  │   Database   │  │◄───┤  │ Realtime PJSIP   │ │
    │  │   + Realtime │  │    │  │   + Dialplan     │ │
    │  └──────────────┘  │    │  └──────────────────┘ │
    └────────────────────┘    └────────────────────────┘
\`\`\`

## Componentes Principais

### 1. Frontend React

**Responsabilidades:**
- Interface de usuário responsiva
- Gerenciamento de estado (Zustand)
- Comunicação com API REST
- Autenticação JWT
- Validação de formulários

**Tecnologias:**
- React 18
- Vite (build tool)
- TailwindCSS
- Axios
- React Router

### 2. Backend NestJS

**Responsabilidades:**
- API REST
- Lógica de negócio
- Autenticação e autorização
- Gerenciamento de banco de dados
- Integração com Asterisk
- Isolamento multitenant

**Módulos:**

#### Auth Module
- Login/Logout
- Geração de tokens JWT
- Validação de credenciais
- Estratégias Passport (JWT, Local)

#### Tenants Module
- Gestão de empresas/clientes
- Configurações por tenant
- Limites de recursos

#### Users Module
- Usuários do sistema
- Perfis e permissões (RBAC)
- Hash de senhas (bcrypt)

#### Extensions Module
- CRUD de ramais
- Sincronização com Asterisk Realtime
- Monitoramento de status

#### Trunks Module
- CRUD de troncos SIP
- Configuração de registro
- Status de conexão

#### Queues Module
- CRUD de filas
- Gerenciamento de membros
- Estratégias de distribuição

#### CDR Module
- Registro de chamadas
- Filtros e buscas
- Estatísticas

#### Dashboard Module
- Agregação de dados
- Estatísticas em tempo real
- Métricas do sistema

#### Asterisk Module
- Conexão AMI/ARI
- Comandos Asterisk
- Monitoramento

### 3. PostgreSQL

**Responsabilidades:**
- Persistência de dados
- Asterisk Realtime Database
- Transações ACID
- Relacionamentos entre entidades

**Principais Tabelas:**
- `tenants`: Empresas/clientes
- `system_users`: Usuários do sistema
- `extensions`: Ramais
- `trunks`: Troncos SIP
- `queues`: Filas de atendimento
- `queue_members`: Membros de filas
- `cdr`: Registros de chamadas
- `ps_endpoints`: PJSIP endpoints (Realtime)
- `ps_auths`: PJSIP autenticações (Realtime)
- `ps_aors`: PJSIP registros (Realtime)

### 4. Asterisk

**Responsabilidades:**
- Processamento de chamadas
- Roteamento
- Filas de atendimento
- URAs
- Gravação de chamadas
- CDR

**Componentes:**
- **PJSIP**: Stack SIP moderno
- **Dialplan**: Lógica de roteamento
- **AMI**: Interface de gerenciamento
- **ARI**: API REST do Asterisk
- **Realtime**: Configuração via banco de dados

## Fluxos de Dados

### Fluxo de Autenticação

\`\`\`
1. Usuário → Frontend: Login (email/senha)
2. Frontend → Backend: POST /auth/login
3. Backend → Database: Valida credenciais
4. Backend: Gera token JWT
5. Backend → Frontend: Retorna token + dados do usuário
6. Frontend: Armazena token no localStorage
7. Frontend: Adiciona token em todas as requisições
\`\`\`

### Fluxo de Criação de Ramal

\`\`\`
1. Frontend → Backend: POST /extensions (dados do ramal)
2. Backend: Valida dados
3. Backend → Database: Insere ramal na tabela extensions
4. Backend → Database: Cria ps_endpoints, ps_auths, ps_aors (Realtime)
5. Asterisk: Detecta mudanças no Realtime
6. Asterisk: Carrega configuração do ramal
7. Backend → Frontend: Retorna ramal criado
\`\`\`

### Fluxo de Chamada

\`\`\`
1. Telefone → Asterisk: INVITE SIP
2. Asterisk: Consulta Realtime (ps_endpoints, ps_auths)
3. Asterisk: Autentica ramal
4. Asterisk: Executa dialplan (extensions.conf)
5. Asterisk: Roteia chamada conforme configuração
6. Asterisk: Grava CDR no banco de dados
7. Backend: Disponibiliza CDR via API
8. Frontend: Exibe chamada no dashboard
\`\`\`

## Segurança

### Camada de Aplicação

- **Autenticação JWT**: Tokens com expiração
- **RBAC**: Controle de acesso baseado em papéis
- **Hash de senhas**: Bcrypt com 10 rounds
- **Validação de entrada**: Class-validator/Class-transformer
- **CORS**: Configuração restritiva

### Camada de Rede

- **Firewall UFW**: Portas específicas
- **Fail2ban**: Proteção contra brute force
- **HTTPS**: Certificado SSL/TLS (recomendado)
- **Asterisk Security**: ACL, permit/deny

### Camada de Dados

- **Isolamento multitenant**: WHERE tenantId em todas as queries
- **SQL Injection**: Queries parametrizadas (TypeORM)
- **Backup automático**: Scripts de backup diário

## Escalabilidade

### Horizontal

- Backend: Pode ser replicado com load balancer
- Frontend: Pode ser servido via CDN
- PostgreSQL: Replicação master-slave
- Asterisk: Cluster com banco de dados compartilhado

### Vertical

- Backend: Aumentar recursos do servidor
- Database: Otimização de queries e índices
- Asterisk: Aumentar capacidade de canais

## Monitoramento

### Métricas

- CPU, Memória, Disco
- Requisições HTTP (latência, taxa de erro)
- Consultas ao banco (tempo de execução)
- Chamadas ativas no Asterisk
- CDRs gerados

### Logs

- Backend: journalctl (systemd)
- Asterisk: /var/log/asterisk/
- PostgreSQL: /var/log/postgresql/
- Nginx: /var/log/nginx/

## Deploy

### Desenvolvimento

\`\`\`bash
# Backend
cd backend && npm run start:dev

# Frontend
cd frontend && npm run dev
\`\`\`

### Produção

\`\`\`bash
# Instalação automática
sudo bash install_pbx_moderno_enterprise.sh

# Serviços systemd
systemctl start pbx-backend
systemctl start asterisk
systemctl start postgresql
\`\`\`

## Backup e Disaster Recovery

### Estratégia de Backup

1. **Banco de dados**: Dump diário do PostgreSQL
2. **Configurações**: Tar.gz de /etc/asterisk/
3. **Gravações**: Sincronização para storage remoto
4. **Código**: Versionamento Git

### Recovery Time Objective (RTO)

- Banco de dados: < 30 minutos
- Serviços: < 15 minutos
- Sistema completo: < 1 hora

## Dependências Externas

- **PostgreSQL 15+**
- **Asterisk 20+**
- **Node.js 20+**
- **Operadoras SIP**: Para troncos externos

---

Para mais detalhes técnicos, consulte o código-fonte e comentários inline.
