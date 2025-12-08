#!/bin/bash

# ==================================================================
# INSTALADOR PBX MODERNO ENTERPRISE
# Script de instalação automatizada para Ubuntu 24.04 LTS
# ==================================================================

set -e  # Parar em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

# Função para exibir mensagens
print_message() {
    echo -e "${GREEN}[PBX Moderno]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[PASSO $1/$2]${NC} $3"
}

# Verificar se é root
if [ "$EUID" -ne 0 ]; then 
    print_error "Este script deve ser executado como root (sudo)"
    exit 1
fi

# Verificar versão do Ubuntu
if ! grep -q "24.04" /etc/os-release; then
    print_warning "Este script foi testado no Ubuntu 24.04 LTS"
    read -p "Deseja continuar mesmo assim? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        exit 1
    fi
fi

clear
cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║        PBX MODERNO ENTERPRISE - INSTALADOR v1.0           ║
║                                                            ║
║     Sistema PBX Multitenant Completo com Asterisk         ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
EOF

echo ""
print_message "Bem-vindo ao instalador do PBX Moderno Enterprise!"
echo ""

# ==================================================================
# CONFIGURAÇÕES
# ==================================================================

print_step 1 10 "Configuração do Sistema"
echo ""

# Modo multitenant
echo "Selecione o modo de operação multitenant:"
echo "1) Banco compartilhado (tenant_id em todas as tabelas) - RECOMENDADO"
echo "2) Banco separado por tenant (um banco para cada empresa)"
read -p "Escolha [1-2]: " MULTITENANT_MODE
MULTITENANT_MODE=${MULTITENANT_MODE:-1}

if [ "$MULTITENANT_MODE" == "1" ]; then
    MULTITENANT_MODE="shared"
    print_message "Modo selecionado: Banco Compartilhado"
else
    MULTITENANT_MODE="separated"
    print_message "Modo selecionado: Banco Separado"
fi

echo ""

# Diretório de instalação
read -p "Diretório de instalação [/opt/pbx-moderno]: " INSTALL_DIR
INSTALL_DIR=${INSTALL_DIR:-/opt/pbx-moderno}

# Senha do PostgreSQL
read -sp "Senha para o usuário do banco de dados PostgreSQL: " DB_PASSWORD
echo ""
DB_PASSWORD=${DB_PASSWORD:-pbx_password_seguro}

# JWT Secret
JWT_SECRET=$(openssl rand -base64 32)

# Asterisk AMI Password
read -sp "Senha para Asterisk AMI: " AMI_PASSWORD
echo ""
AMI_PASSWORD=${AMI_PASSWORD:-$(openssl rand -base64 16)}

# IP Externo
EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || echo "SEU_IP_EXTERNO")
print_message "IP Externo detectado: $EXTERNAL_IP"
read -p "Confirmar IP externo ou digitar outro [$EXTERNAL_IP]: " CUSTOM_IP
EXTERNAL_IP=${CUSTOM_IP:-$EXTERNAL_IP}

echo ""
print_message "Configurações salvas! Iniciando instalação..."
sleep 2

# ==================================================================
# PASSO 2: Atualizar sistema
# ==================================================================

print_step 2 10 "Atualizando sistema operacional"
apt-get update -qq
apt-get upgrade -y -qq
print_message "Sistema atualizado com sucesso!"

# ==================================================================
# PASSO 3: Instalar dependências básicas
# ==================================================================

print_step 3 10 "Instalando dependências básicas"
apt-get install -y -qq \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    ufw \
    fail2ban \
    unzip

print_message "Dependências básicas instaladas!"

# ==================================================================
# PASSO 4: Instalar Node.js 22
# ==================================================================

print_step 4 10 "Instalando Node.js 22"
curl -fsSL https://deb.nodesource.com/setup_22.x | bash - > /dev/null 2>&1
apt-get install -y -qq nodejs
node --version
npm --version
print_message "Node.js instalado com sucesso!"

# ==================================================================
# PASSO 5: Instalar PostgreSQL
# ==================================================================

print_step 5 10 "Instalando PostgreSQL"
apt-get install -y -qq postgresql postgresql-contrib postgresql-client
systemctl start postgresql
systemctl enable postgresql

# Criar usuário e banco
sudo -u postgres psql << EOF
CREATE USER pbx_user WITH PASSWORD '$DB_PASSWORD';
ALTER USER pbx_user CREATEDB;
CREATE DATABASE pbx_moderno OWNER pbx_user;
\q
EOF

print_message "PostgreSQL instalado e configurado!"

# ==================================================================
# PASSO 6: Instalar Asterisk 22
# ==================================================================

print_step 6 10 "Instalando Asterisk 22 (isso pode demorar alguns minutos)"

# Dependências do Asterisk
apt-get install -y -qq \
    asterisk \
    asterisk-modules \
    asterisk-config \
    asterisk-moh-opsound-wav \
    sox \
    libsox-fmt-all

# Se não estiver disponível via apt, compilar
if ! command -v asterisk &> /dev/null; then
    print_warning "Asterisk não encontrado no repositório, compilando da fonte..."
    
    cd /usr/src
    wget https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-22-current.tar.gz -q --show-progress
    tar -xzf asterisk-22-current.tar.gz
    cd asterisk-22.*/
    
    contrib/scripts/install_prereq install -y
    ./configure --with-pjproject-bundled --with-jansson-bundled
    make menuselect.makeopts
    menuselect/menuselect --enable CORE-SOUNDS-PT-BR-WAV --enable MOH-OPSOUND-WAV menuselect.makeopts
    make -j$(nproc)
    make install
    make samples
    make config
    ldconfig
    
    # Criar usuário asterisk
    useradd -r -d /var/lib/asterisk -s /bin/bash asterisk 2>/dev/null || true
    chown -R asterisk:asterisk /etc/asterisk /var/lib/asterisk /var/spool/asterisk /var/log/asterisk /var/run/asterisk
fi

systemctl start asterisk
systemctl enable asterisk

print_message "Asterisk instalado com sucesso!"

# ==================================================================
# PASSO 7: Instalar Nginx
# ==================================================================

print_step 7 10 "Instalando Nginx"
apt-get install -y -qq nginx
systemctl start nginx
systemctl enable nginx
print_message "Nginx instalado!"

# ==================================================================
# PASSO 8: Clonar e configurar aplicação
# ==================================================================

print_step 8 10 "Configurando aplicação PBX Moderno"

# Criar diretório
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

print_message "Copiando arquivos da aplicação..."
# Nota: Em produção, aqui seria feito git clone do repositório
# git clone https://github.com/seu-usuario/pbx-moderno-enterprise.git .

# Por enquanto, assumimos que os arquivos já estão no diretório atual
# ou foram copiados manualmente

# Configurar Backend
print_message "Configurando backend..."
cd "$INSTALL_DIR/backend"

# Criar .env
cat > .env << EOF
NODE_ENV=production
PORT=3001

DB_HOST=localhost
DB_PORT=5432
DB_USER=pbx_user
DB_PASSWORD=$DB_PASSWORD
DB_NAME=pbx_moderno
DB_LOGGING=false

MULTITENANT_MODE=$MULTITENANT_MODE

JWT_SECRET=$JWT_SECRET
JWT_EXPIRES_IN=24h
JWT_REFRESH_SECRET=$(openssl rand -base64 32)
JWT_REFRESH_EXPIRES_IN=7d

ASTERISK_HOST=localhost
ASTERISK_AMI_PORT=5038
ASTERISK_AMI_USER=admin
ASTERISK_AMI_PASSWORD=$AMI_PASSWORD
ASTERISK_ARI_URL=http://localhost:8088/ari
ASTERISK_ARI_USER=asterisk
ASTERISK_ARI_PASSWORD=$(openssl rand -base64 16)

FRONTEND_URL=http://localhost

RECORDINGS_PATH=/var/spool/asterisk/monitor
RECORDINGS_URL=http://localhost/recordings

MAX_FILE_SIZE=10485760

SYSTEM_NAME=PBX Moderno Enterprise
SYSTEM_VERSION=1.0.0
EOF

# Instalar dependências
npm install --production --silent

# Build
npm run build

print_message "Backend configurado!"

# Configurar Frontend
print_message "Configurando frontend..."
cd "$INSTALL_DIR/frontend"

npm install --silent
npm run build

print_message "Frontend configurado!"

# ==================================================================
# PASSO 9: Configurar banco de dados
# ==================================================================

print_step 9 10 "Configurando banco de dados"

# Executar scripts SQL
cd "$INSTALL_DIR/scripts"

print_message "Criando estrutura do banco..."
sudo -u postgres psql -d pbx_moderno -f 01_criar_estrutura_banco.sql > /dev/null 2>&1

print_message "Criando tabelas Asterisk Realtime..."
sudo -u postgres psql -d pbx_moderno -f 02_criar_tabelas_asterisk_realtime.sql > /dev/null 2>&1

print_message "Banco de dados configurado!"

# ==================================================================
# PASSO 10: Configurar Asterisk
# ==================================================================

print_step 10 10 "Configurando Asterisk"

# Backup das configurações originais
cp -r /etc/asterisk /etc/asterisk.backup.$(date +%Y%m%d_%H%M%S)

# Copiar configurações
cp "$INSTALL_DIR/asterisk"/*.conf /etc/asterisk/

# Ajustar configurações
sed -i "s/<SEU_IP_EXTERNO>/$EXTERNAL_IP/g" /etc/asterisk/pjsip.conf
sed -i "s/<SEU_IP_EXTERNO>/$EXTERNAL_IP/g" /etc/asterisk/sip.conf
sed -i "s/asterisk_admin_password/$AMI_PASSWORD/g" /etc/asterisk/manager.conf
sed -i "s/pbx_password_seguro/$DB_PASSWORD/g" /etc/asterisk/res_pgsql.conf

# Permissões
chown -R asterisk:asterisk /etc/asterisk
chmod 640 /etc/asterisk/*.conf

# Reiniciar Asterisk
systemctl restart asterisk

print_message "Asterisk configurado!"

# ==================================================================
# Configurar serviços systemd
# ==================================================================

print_message "Configurando serviços systemd..."

# Serviço Backend
cat > /etc/systemd/system/pbx-backend.service << EOF
[Unit]
Description=PBX Moderno Enterprise - Backend
After=network.target postgresql.service

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR/backend
ExecStart=/usr/bin/node dist/main.js
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=pbx-backend
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# Habilitar e iniciar serviço
systemctl daemon-reload
systemctl enable pbx-backend
systemctl start pbx-backend

# Configurar Nginx
cat > /etc/nginx/sites-available/pbx-moderno << 'EOF'
server {
    listen 80;
    server_name _;

    # Frontend
    location / {
        root /opt/pbx-moderno/frontend/dist;
        try_files $uri $uri/ /index.html;
        expires 1d;
        add_header Cache-Control "public, immutable";
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Gravações
    location /recordings {
        alias /var/spool/asterisk/monitor;
        autoindex off;
        add_header Content-Disposition 'attachment';
    }

    # Logs
    access_log /var/log/nginx/pbx-moderno-access.log;
    error_log /var/log/nginx/pbx-moderno-error.log;
}
EOF

ln -sf /etc/nginx/sites-available/pbx-moderno /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx

# ==================================================================
# Configurar Firewall
# ==================================================================

print_message "Configurando firewall..."

ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 5060/udp  # SIP
ufw allow 5061/tcp  # SIP TLS
ufw allow 10000:20000/udp  # RTP

print_message "Firewall configurado!"

# ==================================================================
# Fail2ban
# ==================================================================

print_message "Configurando Fail2ban..."

cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[asterisk]
enabled = true
port = 5060,5061
protocol = udp
filter = asterisk
logpath = /var/log/asterisk/messages
maxretry = 5

[sshd]
enabled = true
port = 22
logpath = %(sshd_log)s
maxretry = 5
EOF

systemctl restart fail2ban
systemctl enable fail2ban

print_message "Fail2ban configurado!"

# ==================================================================
# Finalização
# ==================================================================

clear
cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║        INSTALAÇÃO CONCLUÍDA COM SUCESSO!                  ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
EOF

echo ""
print_message "PBX Moderno Enterprise foi instalado com sucesso!"
echo ""
echo "INFORMAÇÕES DE ACESSO:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Interface Web: http://$EXTERNAL_IP"
echo "Usuário: admin@pbx.local"
echo "Senha: admin123"
echo ""
echo "SERVIÇOS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Backend: systemctl status pbx-backend"
echo "Asterisk: systemctl status asterisk"
echo "PostgreSQL: systemctl status postgresql"
echo "Nginx: systemctl status nginx"
echo ""
echo "LOGS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Backend: journalctl -u pbx-backend -f"
echo "Asterisk: asterisk -rvvv"
echo "Nginx: tail -f /var/log/nginx/pbx-moderno-error.log"
echo ""
echo "PRÓXIMOS PASSOS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Acesse a interface web e faça login"
echo "2. Altere a senha padrão do administrador"
echo "3. Configure seus ramais, troncos e rotas"
echo "4. Configure SSL/TLS para produção (Certbot)"
echo "5. Configure backup automático do banco de dados"
echo ""
echo "DOCUMENTAÇÃO:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Acesse: $INSTALL_DIR/DOCUMENTATION.md"
echo ""
print_message "Obrigado por usar PBX Moderno Enterprise!"
echo ""
