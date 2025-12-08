# Guia de Instalação - PBX Moderno Enterprise

## Requisitos do Sistema

### Mínimo
- Ubuntu 24.04 LTS (Server ou Desktop)
- 2 CPU cores
- 4 GB RAM
- 50 GB de espaço em disco
- Conexão com internet

### Recomendado
- Ubuntu 24.04 LTS Server
- 4+ CPU cores
- 8+ GB RAM
- 100+ GB de espaço em disco (SSD)
- IP público fixo
- Largura de banda dedicada

## Instalação Rápida

### Passo 1: Baixar o instalador

\`\`\`bash
wget https://github.com/seu-repo/pbx-moderno/releases/latest/download/install.sh
chmod +x install.sh
\`\`\`

### Passo 2: Executar instalação

\`\`\`bash
sudo ./install.sh
\`\`\`

O instalador irá:
1. Verificar requisitos do sistema
2. Solicitar configurações básicas
3. Instalar todas as dependências
4. Configurar banco de dados
5. Instalar e configurar Asterisk
6. Configurar frontend e backend
7. Configurar Nginx e SSL
8. Configurar firewall
9. Criar serviços systemd

## Instalação Manual

Se preferir instalar manualmente, siga os passos detalhados:

### 1. Preparar o Sistema

\`\`\`bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl wget git build-essential
\`\`\`

### 2. Instalar Node.js 22

\`\`\`bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
\`\`\`

### 3. Instalar PostgreSQL

\`\`\`bash
sudo apt install -y postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
\`\`\`

### 4. Instalar Asterisk 22

\`\`\`bash
sudo apt install -y asterisk asterisk-modules asterisk-config
sudo systemctl start asterisk
sudo systemctl enable asterisk
\`\`\`

### 5. Clonar Repositório

\`\`\`bash
cd /opt
sudo git clone https://github.com/seu-repo/pbx-moderno-enterprise.git pbx-moderno
cd pbx-moderno
\`\`\`

### 6. Configurar Banco de Dados

\`\`\`bash
sudo -u postgres psql << EOF
CREATE USER pbx_user WITH PASSWORD 'sua_senha_segura';
CREATE DATABASE pbx_moderno OWNER pbx_user;
\\q
EOF

sudo -u postgres psql -d pbx_moderno -f scripts/01_criar_estrutura_banco.sql
sudo -u postgres psql -d pbx_moderno -f scripts/02_criar_tabelas_asterisk_realtime.sql
\`\`\`

### 7. Configurar Backend

\`\`\`bash
cd /opt/pbx-moderno/backend
cp .env.example .env
nano .env  # Editar configurações
npm install
npm run build
\`\`\`

### 8. Configurar Frontend

\`\`\`bash
cd /opt/pbx-moderno/frontend
npm install
npm run build
\`\`\`

### 9. Configurar Asterisk

\`\`\`bash
sudo cp /opt/pbx-moderno/asterisk/*.conf /etc/asterisk/
sudo nano /etc/asterisk/pjsip.conf  # Ajustar IP externo
sudo systemctl restart asterisk
\`\`\`

### 10. Configurar Nginx

\`\`\`bash
sudo apt install -y nginx
sudo cp /opt/pbx-moderno/nginx/pbx-moderno.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/pbx-moderno.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
\`\`\`

### 11. Criar Serviço Systemd

\`\`\`bash
sudo nano /etc/systemd/system/pbx-backend.service
# Copiar conteúdo do arquivo de exemplo
sudo systemctl daemon-reload
sudo systemctl enable pbx-backend
sudo systemctl start pbx-backend
\`\`\`

## Pós-Instalação

### 1. Verificar Status

\`\`\`bash
sudo bash /opt/pbx-moderno/scripts/check-status.sh
\`\`\`

### 2. Acessar Interface

Abra no navegador: http://seu-ip/

**Credenciais padrão:**
- Usuário: admin@pbx.local
- Senha: admin123

### 3. Configurar SSL (Produção)

\`\`\`bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d seu-dominio.com
\`\`\`

### 4. Configurar Backup Automático

\`\`\`bash
sudo crontab -e
# Adicionar linha para backup diário às 2h da manhã:
0 2 * * * /opt/pbx-moderno/scripts/backup.sh
\`\`\`

## Solução de Problemas

### Backend não inicia

\`\`\`bash
sudo journalctl -u pbx-backend -f
\`\`\`

### Asterisk não registra ramais

\`\`\`bash
sudo asterisk -rvvv
pjsip show endpoints
pjsip reload
\`\`\`

### Erro de conexão com banco

\`\`\`bash
sudo -u postgres psql -d pbx_moderno -c "SELECT 1"
\`\`\`

## Atualização

\`\`\`bash
cd /opt/pbx-moderno
sudo bash scripts/update.sh
\`\`\`

## Desinstalação

\`\`\`bash
sudo bash /opt/pbx-moderno/scripts/uninstall.sh
\`\`\`

## Suporte

Para suporte e documentação adicional:
- Documentação: /opt/pbx-moderno/DOCUMENTATION.md
- Issues: https://github.com/seu-repo/pbx-moderno/issues
