#!/bin/bash

# Script para resetar senha do administrador

set -e

echo "=========================================="
echo "Resetar Senha - Administrador"
echo "=========================================="

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Execute como root (sudo)${NC}"
    exit 1
fi

# Carregar .env
if [ -f /opt/ipabx/backend/.env ]; then
    export $(grep -v '^#' /opt/ipabx/backend/.env | xargs)
else
    echo -e "${RED}Arquivo .env não encontrado!${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Digite a nova senha para admin@sistema.local:${NC}"
read -s NOVA_SENHA

echo ""
echo -e "${YELLOW}Confirme a nova senha:${NC}"
read -s CONFIRMA_SENHA

if [ "$NOVA_SENHA" != "$CONFIRMA_SENHA" ]; then
    echo -e "${RED}Senhas não conferem!${NC}"
    exit 1
fi

# Gerar hash bcrypt (usando node.js)
cd /opt/ipabx/backend

SENHA_HASH=$(node -e "
const bcrypt = require('bcrypt');
bcrypt.hash('$NOVA_SENHA', 10, (err, hash) => {
  if (err) {
    console.error(err);
    process.exit(1);
  }
  console.log(hash);
});
")

echo ""
echo -e "${YELLOW}Atualizando senha no banco de dados...${NC}"

PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d pbx_moderno -c "
UPDATE system_users 
SET senha = '$SENHA_HASH', updated_at = NOW()
WHERE email = 'admin@sistema.local';
"

echo -e "${GREEN}✓ Senha atualizada com sucesso!${NC}"
echo ""
echo "Nova credencial:"
echo "Email: admin@sistema.local"
echo "Senha: <a que você definiu>"
echo ""
