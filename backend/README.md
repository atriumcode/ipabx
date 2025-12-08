# PBX Moderno Enterprise - Backend

Backend completo em NestJS para sistema PBX Enterprise Multitenant.

## Tecnologias

- NestJS 10
- TypeScript
- TypeORM
- PostgreSQL
- JWT Authentication
- Asterisk Integration (AMI/ARI)

## Instalação

\`\`\`bash
# Instalar dependências
npm install

# Copiar arquivo de configuração
cp .env.example .env

# Editar variáveis de ambiente
nano .env

# Executar migrations
npm run migration:run

# Iniciar em desenvolvimento
npm run start:dev

# Build para produção
npm run build
npm run start:prod
\`\`\`

## Estrutura de Módulos

- **auth** - Autenticação JWT
- **tenants** - Gerenciamento de empresas
- **users** - Usuários do sistema
- **extensions** - Ramais (PJSIP/SIP)
- **trunks** - Troncos SIP/PJSIP
- **queues** - Filas de atendimento
- **groups** - Grupos de chamada
- **ivr** - URAs
- **routes** - Rotas de entrada/saída
- **cdr** - Registros de chamadas
- **recordings** - Gravações
- **dashboard** - Dashboard e estatísticas
- **asterisk** - Integração com Asterisk

## API Endpoints

### Autenticação
- `POST /api/auth/login` - Login
- `GET /api/auth/me` - Perfil do usuário

### Ramais
- `GET /api/extensions` - Listar ramais
- `POST /api/extensions` - Criar ramal
- `GET /api/extensions/:id` - Detalhes do ramal
- `PATCH /api/extensions/:id` - Atualizar ramal
- `DELETE /api/extensions/:id` - Deletar ramal

### Troncos
- `GET /api/trunks` - Listar troncos
- `POST /api/trunks` - Criar tronco
- `GET /api/trunks/:id` - Detalhes do tronco
- `PATCH /api/troncos/:id` - Atualizar tronco
- `DELETE /api/trunks/:id` - Deletar tronco

### Filas
- `GET /api/queues` - Listar filas
- `POST /api/queues` - Criar fila
- `POST /api/queues/:id/members/:extensionId` - Adicionar membro
- `DELETE /api/queues/members/:memberId` - Remover membro

### Dashboard
- `GET /api/dashboard/stats` - Estatísticas
- `GET /api/dashboard/recent-calls` - Chamadas recentes

## Multitenant

O sistema suporta dois modos de operação:

1. **Banco Compartilhado** - Todas as tabelas possuem `tenant_id`
2. **Banco Separado** - Cada tenant possui seu próprio banco de dados

Configure via variável `MULTITENANT_MODE` no `.env`.

## Segurança

- Senhas hasheadas com bcrypt
- Autenticação JWT
- Guards por perfil de usuário
- Validação de DTOs
- Isolamento completo por tenant
