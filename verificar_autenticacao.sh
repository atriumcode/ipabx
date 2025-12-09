#!/bin/bash

echo "======================================"
echo "DIAGNÓSTICO DE AUTENTICAÇÃO"
echo "======================================"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

INSTALL_DIR="/opt/ipabx"

# Verificar se o backend está rodando
echo -e "\n${YELLOW}[1] Verificando Backend...${NC}"
if curl -s http://localhost:3001/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Backend está rodando na porta 3001${NC}"
else
    echo -e "${RED}✗ Backend não está respondendo${NC}"
    echo "Logs do backend (últimas 50 linhas):"
    journalctl -u pbx-backend -n 50 --no-pager
fi

# Verificar banco de dados
echo -e "\n${YELLOW}[2] Verificando Banco de Dados...${NC}"
DB_CHECK=$(sudo -u postgres psql -d pbx_moderno -c "SELECT COUNT(*) FROM system_users;" 2>&1)
if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✓ Banco de dados acessível${NC}"
    echo "$DB_CHECK"
else
    echo -e "${RED}✗ Erro ao acessar banco de dados${NC}"
    echo "$DB_CHECK"
fi

echo -e "\n${YELLOW}[3] Verificando Usuário Admin...${NC}"
ADMIN_EXISTS=$(sudo -u postgres psql -d pbx_moderno -t -c "SELECT email, nome, ativo FROM system_users WHERE email='admin@pbx.local';" 2>&1)
if [[ ! -z "$ADMIN_EXISTS" ]] && [[ "$ADMIN_EXISTS" != *"ERROR"* ]]; then
    echo -e "${GREEN}✓ Usuário admin existe:${NC}"
    echo "$ADMIN_EXISTS"
else
    echo -e "${RED}✗ Usuário admin não encontrado${NC}"
    echo "$ADMIN_EXISTS"
fi

echo -e "\n${YELLOW}[4] Verificando Tenants...${NC}"
TENANTS=$(sudo -u postgres psql -d pbx_moderno -t -c "SELECT id, nome, dominio, ativo FROM tenants;" 2>&1)
if [[ ! -z "$TENANTS" ]] && [[ "$TENANTS" != *"ERROR"* ]]; then
    echo -e "${GREEN}✓ Tenants encontrados:${NC}"
    echo "$TENANTS"
else
    echo -e "${RED}✗ Nenhum tenant encontrado${NC}"
    echo "$TENANTS"
fi

echo -e "\n${YELLOW}[5] Testando API de Login...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@pbx.local","senha":"admin123"}' 2>&1)
  
if echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
    echo -e "${GREEN}✓ Login bem-sucedido${NC}"
    echo "$LOGIN_RESPONSE" | jq '.' 2>/dev/null || echo "$LOGIN_RESPONSE"
else
    echo -e "${RED}✗ Erro no login:${NC}"
    echo "$LOGIN_RESPONSE"
fi

# Verificar variáveis de ambiente
echo -e "\n${YELLOW}[6] Verificando Variáveis de Ambiente...${NC}"
if [ -f $INSTALL_DIR/backend/.env ]; then
    echo -e "${GREEN}✓ Arquivo .env existe${NC}"
    echo "JWT_SECRET configurado: $(grep -q 'JWT_SECRET=' $INSTALL_DIR/backend/.env && echo 'Sim' || echo 'Não')"
    echo "DB_HOST: $(grep 'DB_HOST=' $INSTALL_DIR/backend/.env | cut -d'=' -f2)"
    echo "DB_NAME: $(grep 'DB_NAME=' $INSTALL_DIR/backend/.env | cut -d'=' -f2)"
    echo "PORT: $(grep 'PORT=' $INSTALL_DIR/backend/.env | cut -d'=' -f2)"
else
    echo -e "${RED}✗ Arquivo .env não encontrado em $INSTALL_DIR/backend/.env${NC}"
fi

# Verificar logs de erro do backend
echo -e "\n${YELLOW}[7] Últimos Erros do Backend...${NC}"
journalctl -u pbx-backend -p err -n 20 --no-pager

# Verificar status dos serviços
echo -e "\n${YELLOW}[8] Status dos Serviços...${NC}"
echo "Backend: $(systemctl is-active pbx-backend)"
echo "PostgreSQL: $(systemctl is-active postgresql)"
echo "Nginx: $(systemctl is-active nginx)"
echo "Asterisk: $(systemctl is-active asterisk)"

echo -e "\n${YELLOW}======================================"
echo "Diagnóstico completo!"
echo "======================================${NC}"
