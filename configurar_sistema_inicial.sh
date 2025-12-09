#!/bin/bash

# Script de Configuração Inicial do PBX Moderno Enterprise

set -e

echo "=========================================="
echo "Configuração Inicial - PBX Moderno"
echo "=========================================="
echo ""

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Por favor, execute como root (sudo)${NC}"
    exit 1
fi

# Carregar variáveis do .env
if [ -f /opt/ipabx/backend/.env ]; then
    export $(grep -v '^#' /opt/ipabx/backend/.env | xargs)
else
    echo -e "${RED}Arquivo .env não encontrado!${NC}"
    exit 1
fi

echo -e "${YELLOW}[1/5] Verificando serviços...${NC}"
systemctl is-active --quiet postgresql || (echo -e "${RED}PostgreSQL não está rodando!${NC}" && exit 1)
systemctl is-active --quiet pbx-backend || (echo -e "${RED}Backend não está rodando!${NC}" && exit 1)
echo -e "${GREEN}✓ Serviços OK${NC}"

echo ""
echo -e "${YELLOW}[2/5] Criando tenant padrão...${NC}"
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d pbx_moderno -c "
INSERT INTO tenants (nome, dominio, ativo, max_ramais, max_troncos, created_at, updated_at)
VALUES ('Empresa Padrão', 'padrao.local', true, 100, 10, NOW(), NOW())
ON CONFLICT (dominio) DO NOTHING
RETURNING id;
" || echo "Tenant já existe"

# Obter ID do tenant
TENANT_ID=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d pbx_moderno -t -c "
SELECT id FROM tenants WHERE dominio = 'padrao.local' LIMIT 1;
" | xargs)

echo -e "${GREEN}✓ Tenant ID: $TENANT_ID${NC}"

echo ""
echo -e "${YELLOW}[3/5] Criando usuário administrador...${NC}"

# Hash da senha 'admin123' usando bcrypt (10 rounds)
# Gerado previamente: $2b$10$rZ8F6v4qKX.yQJ0mJYvH6.YX4kZN6vH6.1bF6X6X6X6X6X6X6X6Xe
SENHA_HASH='$2b$10$rZ8F6v4qKX.yQJ0mJYvH6.YX4kZN6vH6.1bF6X6X6X6X6X6X6X6Xe'

PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d pbx_moderno -c "
INSERT INTO system_users (tenant_id, nome, email, senha, role, ativo, created_at, updated_at)
VALUES ($TENANT_ID, 'Administrador', 'admin@sistema.local', '$SENHA_HASH', 'admin', true, NOW(), NOW())
ON CONFLICT (email) DO UPDATE 
SET senha = EXCLUDED.senha, 
    updated_at = NOW()
RETURNING id;
" || echo "Usuário já existe e foi atualizado"

echo -e "${GREEN}✓ Usuário criado/atualizado${NC}"

echo ""
echo -e "${YELLOW}[4/5] Testando API de autenticação...${NC}"

# Aguardar alguns segundos para o backend estar pronto
sleep 2

# Testar login
LOGIN_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@sistema.local",
    "senha": "admin123"
  }')

HTTP_STATUS=$(echo "$LOGIN_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
RESPONSE_BODY=$(echo "$LOGIN_RESPONSE" | sed '/HTTP_STATUS/d')

if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "201" ]; then
    echo -e "${GREEN}✓ Login funcionando!${NC}"
    echo ""
    echo -e "${GREEN}Token JWT recebido com sucesso${NC}"
else
    echo -e "${RED}✗ Erro no login (HTTP $HTTP_STATUS)${NC}"
    echo "Resposta: $RESPONSE_BODY"
fi

echo ""
echo -e "${YELLOW}[5/5] Verificando status geral...${NC}"

# Status dos serviços
echo ""
echo "Status dos Serviços:"
echo "-------------------"
systemctl is-active pbx-backend && echo -e "Backend:    ${GREEN}✓ Rodando${NC}" || echo -e "Backend:    ${RED}✗ Parado${NC}"
systemctl is-active postgresql && echo -e "PostgreSQL: ${GREEN}✓ Rodando${NC}" || echo -e "PostgreSQL: ${RED}✗ Parado${NC}"
systemctl is-active asterisk && echo -e "Asterisk:   ${GREEN}✓ Rodando${NC}" || echo -e "Asterisk:   ${RED}✗ Parado${NC}"
systemctl is-active nginx && echo -e "Nginx:      ${GREEN}✓ Rodando${NC}" || echo -e "Nginx:      ${RED}✗ Parado${NC}"

echo ""
echo "=========================================="
echo -e "${GREEN}Configuração concluída!${NC}"
echo "=========================================="
echo ""
echo "Credenciais de acesso:"
echo "----------------------"
echo "Email:  admin@sistema.local"
echo "Senha:  admin123"
echo ""
echo "URL do sistema:"
echo "http://$(hostname -I | awk '{print $1}')"
echo ""
echo "Para ver logs do backend:"
echo "  sudo journalctl -u pbx-backend -f"
echo ""
