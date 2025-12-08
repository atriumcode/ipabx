# PBX Moderno Enterprise System

Sistema PBX (Private Branch Exchange) completo e moderno desenvolvido com NestJS, React e Asterisk, com suporte a múltiplos tenants (multitenant), interface web intuitiva e integração total com Asterisk PJSIP/SIP.

## Características Principais

- **Multitenant**: Suporte a múltiplas empresas/clientes em uma única instalação
- **Backend Robusto**: NestJS com TypeORM e PostgreSQL para alta performance
- **Frontend Moderno**: React com TailwindCSS e componentes reativos
- **Integração Asterisk**: Suporte completo a PJSIP e SIP legado via Realtime Database
- **Gerenciamento Completo**: Ramais, Troncos, Filas, URAs, Rotas e CDR
- **Dashboard em Tempo Real**: Estatísticas e monitoramento de chamadas
- **Autenticação JWT**: Sistema seguro de autenticação e autorização
- **API RESTful**: Endpoints documentados para integração

## Tecnologias Utilizadas

### Backend
- **NestJS 10**: Framework Node.js progressivo
- **TypeORM**: ORM para PostgreSQL
- **PostgreSQL 15+**: Banco de dados relacional
- **JWT**: Autenticação segura
- **Bcrypt**: Hash de senhas

### Frontend
- **React 18**: Biblioteca para interfaces
- **Vite**: Build tool moderno
- **TailwindCSS**: Framework CSS utility-first
- **Zustand**: Gerenciamento de estado
- **Axios**: Cliente HTTP

### Telefonia
- **Asterisk 20+**: PBX open source
- **PJSIP**: Stack SIP moderno
- **SIP Legacy**: Suporte a chan_sip
- **AMI**: Asterisk Manager Interface
- **ARI**: Asterisk REST Interface

## Arquitetura do Sistema

\`\`\`
pbx-moderno-enterprise/
├── backend/                 # API NestJS
│   ├── src/
│   │   ├── modules/        # Módulos da aplicação
│   │   │   ├── auth/       # Autenticação
│   │   │   ├── tenants/    # Gestão de tenants
│   │   │   ├── users/      # Usuários do sistema
│   │   │   ├── extensions/ # Ramais
│   │   │   ├── trunks/     # Troncos SIP
│   │   │   ├── queues/     # Filas de atendimento
│   │   │   ├── groups/     # Grupos de ramais
│   │   │   ├── ivr/        # URAs
│   │   │   ├── routes/     # Rotas de entrada/saída
│   │   │   ├── cdr/        # Call Detail Records
│   │   │   ├── recordings/ # Gravações
│   │   │   ├── dashboard/  # Dashboard e estatísticas
│   │   │   └── asterisk/   # Integração Asterisk
│   │   ├── common/         # Entidades e utilitários comuns
│   │   ├── main.ts         # Entry point
│   │   └── app.module.ts   # Módulo raiz
│   └── package.json
├── frontend/               # Interface React
│   ├── src/
│   │   ├── components/    # Componentes React
│   │   ├── pages/         # Páginas da aplicação
│   │   ├── stores/        # Zustand stores
│   │   ├── lib/           # Utilitários
│   │   └── main.tsx       # Entry point
│   └── package.json
├── asterisk/              # Configurações Asterisk
│   ├── pjsip.conf
│   ├── sip.conf
│   ├── extensions.conf
│   ├── queues.conf
│   └── ...
├── scripts/               # Scripts SQL e utilitários
│   ├── 01_criar_estrutura_banco.sql
│   ├── backup.sh
│   ├── restore.sh
│   └── update.sh
└── install_pbx_moderno_enterprise.sh
\`\`\`

## Instalação Rápida

### Pré-requisitos

- Ubuntu 24.04 LTS (recomendado)
- PostgreSQL 15+
- Asterisk 20+
- Node.js 20+
- Acesso root ou sudo

### Instalação Automática

\`\`\`bash
# Clone o repositório
git clone https://github.com/seu-usuario/pbx-moderno-enterprise.git
cd pbx-moderno-enterprise

# Execute o instalador
sudo bash install_pbx_moderno_enterprise.sh
\`\`\`

O instalador irá:
1. Instalar todas as dependências (PostgreSQL, Asterisk, Node.js)
2. Configurar o banco de dados
3. Instalar e configurar o backend NestJS
4. Instalar e compilar o frontend React
5. Configurar o Asterisk com Realtime Database
6. Criar serviços systemd
7. Configurar firewall

### Instalação Manual

Consulte o arquivo [INSTALLATION.md](./INSTALLATION.md) para instruções detalhadas de instalação manual.

## Configuração

### Variáveis de Ambiente

Crie um arquivo `.env` na pasta `backend/`:

\`\`\`env
# Servidor
NODE_ENV=production
PORT=3000

# Banco de Dados
DB_HOST=localhost
DB_PORT=5432
DB_USER=pbx_user
DB_PASSWORD=sua_senha_segura
DB_NAME=pbx_moderno

# JWT
JWT_SECRET=seu_secret_jwt_super_seguro_aqui
JWT_EXPIRES_IN=24h

# Asterisk
ASTERISK_AMI_HOST=localhost
ASTERISK_AMI_PORT=5038
ASTERISK_AMI_USER=admin
ASTERISK_AMI_PASSWORD=senha_ami

# CORS
CORS_ORIGIN=http://localhost:5173
\`\`\`

### Primeiro Acesso

Após a instalação, acesse:
- **Frontend**: http://seu-servidor:5173
- **Backend API**: http://seu-servidor:3000

**Credenciais Padrão:**
- Email: `admin@pbxmoderno.com`
- Senha: `Admin@123`

**IMPORTANTE**: Altere a senha padrão imediatamente após o primeiro acesso!

## Módulos e Funcionalidades

### Gestão de Ramais (Extensions)

- Criação e edição de ramais PJSIP e SIP
- Configuração de codecs, transporte e NAT
- Senha de autenticação
- Caller ID personalizado
- Status online/offline em tempo real
- Sincronização automática com Asterisk Realtime

### Gestão de Troncos (Trunks)

- Configuração de troncos SIP para operadoras
- Suporte a registro (register)
- Configuração de codecs e transporte
- Monitoramento de status
- Failover entre troncos

### Filas de Atendimento (Queues)

- Estratégias de distribuição: ringall, leastrecent, fewestcalls, random, rrmemory, linear
- Configuração de timeout e retry
- Wrapup time
- Limite de chamadas na fila
- Áudio de anúncio
- Música de espera
- Gerenciamento de membros

### URAs (IVR)

- Áudio de boas-vindas
- Múltiplas opções de navegação
- Timeout configurável
- Áudio de opção inválida
- Roteamento para ramais, filas ou grupos

### Rotas

**Rotas de Entrada (Inbound):**
- Mapeamento de DIDs
- Roteamento por padrão
- Priorização de rotas

**Rotas de Saída (Outbound):**
- Padrões de discagem
- Seleção de tronco
- Manipulação de dígitos (adicionar/remover prefixos)

### CDR (Call Detail Records)

- Registro completo de chamadas
- Filtros avançados
- Exportação de relatórios
- Estatísticas de chamadas atendidas/perdidas
- Duração média
- Link para gravações

### Dashboard

- Estatísticas em tempo real
- Ramais online/offline
- Troncos ativos
- Chamadas do dia
- Gráficos e métricas
- Chamadas recentes

## API REST

### Autenticação

\`\`\`bash
# Login
POST /auth/login
Content-Type: application/json

{
  "email": "admin@pbxmoderno.com",
  "senha": "Admin@123"
}

# Resposta
{
  "accessToken": "eyJhbGc...",
  "user": {
    "id": 1,
    "nome": "Administrador",
    "email": "admin@pbxmoderno.com",
    "perfil": "admin"
  }
}
\`\`\`

### Endpoints Principais

**Ramais:**
- `GET /extensions` - Lista todos os ramais
- `GET /extensions/:id` - Busca ramal por ID
- `POST /extensions` - Cria novo ramal
- `PATCH /extensions/:id` - Atualiza ramal
- `DELETE /extensions/:id` - Remove ramal

**Troncos:**
- `GET /trunks` - Lista todos os troncos
- `POST /trunks` - Cria novo tronco
- `PATCH /trunks/:id` - Atualiza tronco
- `DELETE /trunks/:id` - Remove tronco

**Filas:**
- `GET /queues` - Lista todas as filas
- `POST /queues` - Cria nova fila
- `PATCH /queues/:id` - Atualiza fila
- `POST /queues/:id/members/:extensionId` - Adiciona membro à fila
- `DELETE /queues/members/:memberId` - Remove membro da fila

**CDR:**
- `GET /cdr` - Lista CDRs com filtros
- `GET /cdr/stats` - Estatísticas de chamadas

**Dashboard:**
- `GET /dashboard/stats` - Estatísticas gerais
- `GET /dashboard/recent-calls` - Chamadas recentes

Consulte a documentação completa da API em [API.md](./docs/API.md).

## Desenvolvimento

### Backend

\`\`\`bash
cd backend
npm install
npm run start:dev
\`\`\`

### Frontend

\`\`\`bash
cd frontend
npm install
npm run dev
\`\`\`

### Banco de Dados

\`\`\`bash
# Executar migrations
cd scripts
psql -U pbx_user -d pbx_moderno -f 01_criar_estrutura_banco.sql
\`\`\`

## Backup e Restore

### Backup Completo

\`\`\`bash
sudo bash scripts/backup.sh
\`\`\`

O backup inclui:
- Banco de dados PostgreSQL
- Configurações do Asterisk
- Gravações de chamadas
- Configurações do sistema

### Restore

\`\`\`bash
sudo bash scripts/restore.sh /caminho/para/backup.tar.gz
\`\`\`

## Monitoramento

### Verificar Status dos Serviços

\`\`\`bash
sudo bash scripts/check-status.sh
\`\`\`

Verifica:
- PostgreSQL
- Asterisk
- Backend NestJS
- Frontend
- Uso de recursos

### Logs

\`\`\`bash
# Backend
journalctl -u pbx-backend -f

# Asterisk
tail -f /var/log/asterisk/full

# PostgreSQL
tail -f /var/log/postgresql/postgresql-15-main.log
\`\`\`

## Segurança

- Autenticação JWT com tokens com expiração
- Senhas hash com bcrypt (10 rounds)
- Isolamento por tenant (multitenant seguro)
- Firewall configurado (UFW)
- Fail2ban para proteção contra brute force
- HTTPS recomendado (use nginx como proxy reverso)

### Configurar HTTPS (Opcional)

\`\`\`bash
# Instalar certbot
sudo apt install certbot python3-certbot-nginx

# Obter certificado
sudo certbot --nginx -d seu-dominio.com
\`\`\`

## Troubleshooting

### Backend não inicia

\`\`\`bash
# Verificar logs
journalctl -u pbx-backend -n 50

# Verificar conexão com banco
psql -U pbx_user -d pbx_moderno -c "SELECT 1"
\`\`\`

### Asterisk não registra ramais

\`\`\`bash
# Verificar configuração PJSIP
asterisk -rx "pjsip show endpoints"

# Verificar Realtime
asterisk -rx "realtime load ps_endpoints 1000"

# Recarregar configuração
asterisk -rx "module reload res_pjsip.so"
\`\`\`

### Frontend não conecta ao backend

1. Verifique o arquivo `frontend/src/lib/api.ts`
2. Confirme que a URL da API está correta
3. Verifique CORS no backend

## Contribuindo

Contribuições são bem-vindas! Por favor:

1. Faça fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## Roadmap

- [ ] Integração WebRTC para softphone no navegador
- [ ] Relatórios avançados com gráficos
- [ ] Sistema de notificações em tempo real (WebSocket)
- [ ] Aplicativo mobile (React Native)
- [ ] Integração com CRM
- [ ] Gravação automática de chamadas
- [ ] Transcrição de chamadas com IA
- [ ] Dashboard analítico com BI

## Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](./LICENSE) para mais detalhes.

## Suporte

- **Email**: suporte@pbxmoderno.com
- **Documentação**: https://docs.pbxmoderno.com
- **Issues**: https://github.com/seu-usuario/pbx-moderno-enterprise/issues

## Autores

- Desenvolvido com tecnologias modernas e melhores práticas
- Contribuições da comunidade open source

---

**PBX Moderno Enterprise** - Sistema de telefonia empresarial completo e escalável
