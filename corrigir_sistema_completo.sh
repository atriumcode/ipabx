#!/bin/bash

echo "=========================================="
echo "CORREÇÃO COMPLETA DO SISTEMA PBX MODERNO"
echo "=========================================="

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Verificar se é root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Por favor, execute como root (sudo)${NC}"
    exit 1
fi

INSTALL_DIR="/opt/ipabx"

# ==================================================================
# 1. Parar serviços
# ==================================================================
echo -e "\n${BLUE}[1/7] Parando serviços...${NC}"
systemctl stop pbx-backend 2>/dev/null || true
sleep 2
echo -e "${GREEN}✓ Serviços parados${NC}"

# ==================================================================
# 2. Corrigir arquivo .env
# ==================================================================
echo -e "\n${BLUE}[2/7] Corrigindo arquivo .env...${NC}"

if [ ! -f "$INSTALL_DIR/backend/.env" ]; then
    echo -e "${YELLOW}⚠ Arquivo .env não existe, criando...${NC}"
fi

# Gerar secrets se necessário
JWT_SECRET=$(openssl rand -base64 32)
JWT_REFRESH_SECRET=$(openssl rand -base64 32)
AMI_PASSWORD=$(openssl rand -base64 16)
ARI_PASSWORD=$(openssl rand -base64 16)

# Pedir senha do banco
read -sp "Digite a senha do PostgreSQL (pbx_user) [ou Enter para usar padrão]: " DB_PASSWORD
echo ""
DB_PASSWORD=${DB_PASSWORD:-pbx_password_seguro}

cat > $INSTALL_DIR/backend/.env << EOF
NODE_ENV=production
PORT=3001

# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=pbx_user
DB_PASSWORD=$DB_PASSWORD
DB_NAME=pbx_moderno
DB_LOGGING=false

# Multitenant
MULTITENANT_MODE=shared

# JWT
JWT_SECRET=$JWT_SECRET
JWT_EXPIRES_IN=24h
JWT_REFRESH_SECRET=$JWT_REFRESH_SECRET
JWT_REFRESH_EXPIRES_IN=7d

# Asterisk
ASTERISK_HOST=localhost
ASTERISK_AMI_PORT=5038
ASTERISK_AMI_USER=admin
ASTERISK_AMI_PASSWORD=$AMI_PASSWORD
ASTERISK_ARI_URL=http://localhost:8088/ari
ASTERISK_ARI_USER=asterisk
ASTERISK_ARI_PASSWORD=$ARI_PASSWORD

# Frontend
FRONTEND_URL=http://localhost

# Recordings
RECORDINGS_PATH=/var/spool/asterisk/monitor
RECORDINGS_URL=http://localhost/recordings

# Upload
MAX_FILE_SIZE=10485760

# System
SYSTEM_NAME=PBX Moderno Enterprise
SYSTEM_VERSION=1.0.0
EOF

echo -e "${GREEN}✓ Arquivo .env criado/atualizado${NC}"

# ==================================================================
# 3. Reinstalar dependências do backend
# ==================================================================
echo -e "\n${BLUE}[3/7] Reinstalando dependências do backend...${NC}"
cd $INSTALL_DIR/backend

# Limpar node_modules e cache
rm -rf node_modules package-lock.json
npm cache clean --force

# Reinstalar
npm install --silent

echo -e "${GREEN}✓ Dependências instaladas${NC}"

# ==================================================================
# 4. Recompilar backend
# ==================================================================
echo -e "\n${BLUE}[4/7] Recompilando backend...${NC}"
npx nest build

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Backend compilado com sucesso${NC}"
else
    echo -e "${RED}✗ Erro na compilação do backend${NC}"
    exit 1
fi

# ==================================================================
# 5. Verificar banco de dados
# ==================================================================
echo -e "\n${BLUE}[5/7] Verificando banco de dados...${NC}"

# Testar conexão
if sudo -u postgres psql -d pbx_moderno -c "SELECT 1;" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Banco de dados acessível${NC}"
    
    # Verificar se tenant existe
    TENANT_COUNT=$(sudo -u postgres psql -d pbx_moderno -t -c "SELECT COUNT(*) FROM tenants;")
    TENANT_COUNT=$(echo $TENANT_COUNT | xargs)
    
    if [ "$TENANT_COUNT" -eq "0" ]; then
        echo -e "${YELLOW}⚠ Nenhum tenant encontrado, criando tenant padrão...${NC}"
        sudo -u postgres psql -d pbx_moderno <<EOF
INSERT INTO tenants (nome, dominio, ativo, plano, max_ramais, max_troncos)
VALUES ('Empresa Padrão', 'principal.pbx', true, 'enterprise', 100, 10)
ON CONFLICT (dominio) DO NOTHING;
EOF
        echo -e "${GREEN}✓ Tenant criado${NC}"
    else
        echo -e "${GREEN}✓ Tenants existentes: $TENANT_COUNT${NC}"
    fi
    
    # Verificar se usuário admin existe
    ADMIN_COUNT=$(sudo -u postgres psql -d pbx_moderno -t -c "SELECT COUNT(*) FROM system_users WHERE email='admin@pbx.local';")
    ADMIN_COUNT=$(echo $ADMIN_COUNT | xargs)
    
    if [ "$ADMIN_COUNT" -eq "0" ]; then
        echo -e "${YELLOW}⚠ Usuário admin não encontrado, criando...${NC}"
        bash $INSTALL_DIR/criar_usuario_admin.sh
    else
        echo -e "${GREEN}✓ Usuário admin existe${NC}"
    fi
else
    echo -e "${RED}✗ Erro ao acessar banco de dados${NC}"
    exit 1
fi

# ==================================================================
# 6. Reiniciar serviços
# ==================================================================
echo -e "\n${BLUE}[6/7] Reiniciando serviços...${NC}"

systemctl daemon-reload
systemctl restart pbx-backend
sleep 5

if systemctl is-active --quiet pbx-backend; then
    echo -e "${GREEN}✓ Backend iniciado${NC}"
else
    echo -e "${RED}✗ Erro ao iniciar backend${NC}"
    echo "Logs:"
    journalctl -u pbx-backend -n 50 --no-pager
    exit 1
fi

systemctl restart nginx
echo -e "${GREEN}✓ Nginx reiniciado${NC}"

# ==================================================================
# 7. Testar sistema
# ==================================================================
echo -e "\n${BLUE}[7/7] Testando sistema...${NC}"

# Aguardar backend ficar pronto
sleep 3

# Testar API health
if curl -s http://localhost:3001/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ API respondendo${NC}"
else
    echo -e "${RED}✗ API não está respondendo${NC}"
fi

# Testar login
LOGIN_TEST=$(curl -s -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@pbx.local","senha":"admin123"}')

if echo "$LOGIN_TEST" | grep -q "access_token"; then
    echo -e "${GREEN}✓ Login funcionando${NC}"
else
    echo -e "${YELLOW}⚠ Login retornou erro:${NC}"
    echo "$LOGIN_TEST"
fi

# ==================================================================
# Relatório Final
# ==================================================================
echo ""
echo "=========================================="
echo "CORREÇÃO CONCLUÍDA!"
echo "=========================================="
echo ""
echo "STATUS DOS SERVIÇOS:"
echo "----------------------------------------"
echo "Backend: $(systemctl is-active pbx-backend)"
echo "PostgreSQL: $(systemctl is-active postgresql)"
echo "Nginx: $(systemctl is-active nginx)"
echo "Asterisk: $(systemctl is-active asterisk)"
echo ""
echo "CREDENCIAIS DE ACESSO:"
echo "----------------------------------------"
echo "URL: http://seu-servidor"
echo "Email: admin@pbx.local"
echo "Senha: admin123"
echo ""
echo "COMANDOS ÚTEIS:"
echo "----------------------------------------"
echo "Ver logs: journalctl -u pbx-backend -f"
echo "Reiniciar: systemctl restart pbx-backend"
echo "Status: systemctl status pbx-backend"
echo ""
echo -e "${GREEN}Sistema corrigido e funcionando!${NC}"
