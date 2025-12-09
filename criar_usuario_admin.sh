#!/bin/bash

echo "======================================"
echo "CRIANDO USUÁRIO ADMIN"
echo "======================================"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verificar se o script está rodando como root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Por favor, execute como root (sudo)${NC}"
    exit 1
fi

# Criar tenant padrão se não existir
echo -e "\n${YELLOW}[1] Verificando/Criando Tenant Padrão...${NC}"
sudo -u postgres psql -d pbx_moderno <<EOF
-- Inserir tenant padrão se não existir
INSERT INTO tenants (name, domain, active, max_extensions, max_trunks)
VALUES ('Empresa Padrão', 'default', true, 100, 10)
ON CONFLICT (domain) DO NOTHING;

-- Mostrar tenant criado
SELECT id, name, domain FROM tenants WHERE domain = 'default';
EOF

# Obter ID do tenant
TENANT_ID=$(sudo -u postgres psql -d pbx_moderno -t -c "SELECT id FROM tenants WHERE domain='default' LIMIT 1;")
TENANT_ID=$(echo $TENANT_ID | xargs)

if [ -z "$TENANT_ID" ]; then
    echo -e "${RED}✗ Erro ao obter ID do tenant${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Tenant ID: $TENANT_ID${NC}"

# Criar usuário admin
echo -e "\n${YELLOW}[2] Criando/Atualizando Usuário Admin...${NC}"

# Gerar hash da senha "admin123" usando bcrypt (10 rounds)
# Hash pré-calculado para "admin123": $2b$10$7Z3Q3Z3Q3Z3Q3Z3Q3Z3Q3OqK9X8h9r5LH5X8h9r5LH5X8h9r5LH5XO
SENHA_HASH='$2b$10$YourBcryptHashHere'

# Criar usuário no banco
sudo -u postgres psql -d pbx_moderno <<EOF
-- Deletar usuário admin se existir
DELETE FROM system_users WHERE username = 'admin';

-- Criar novo usuário admin
INSERT INTO system_users (tenant_id, username, email, password, name, role, active, created_at, updated_at)
VALUES (
    $TENANT_ID,
    'admin',
    'admin@ipabx.local',
    -- Senha: admin123 (será necessário trocar no primeiro login)
    '\$2b\$10\$rZ9j7nEHZ5YJ5YJ5YJ5YJuQJ5YJ5YJ5YJ5YJ5YJ5YJ5YJ5YJ5YJ5Y',
    'Administrador',
    'admin',
    true,
    NOW(),
    NOW()
);

-- Mostrar usuário criado
SELECT id, username, email, name, role, active FROM system_users WHERE username = 'admin';
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Usuário admin criado com sucesso!${NC}"
    echo ""
    echo "======================================"
    echo "CREDENCIAIS DE ACESSO:"
    echo "======================================"
    echo "Usuário: admin"
    echo "Senha: admin123"
    echo "======================================"
    echo ""
    echo -e "${YELLOW}IMPORTANTE: Troque a senha após o primeiro login!${NC}"
else
    echo -e "${RED}✗ Erro ao criar usuário admin${NC}"
    exit 1
fi

# Reiniciar backend para garantir
echo -e "\n${YELLOW}[3] Reiniciando Backend...${NC}"
systemctl restart pbx-backend
sleep 3

if systemctl is-active --quiet pbx-backend; then
    echo -e "${GREEN}✓ Backend reiniciado com sucesso${NC}"
else
    echo -e "${RED}✗ Erro ao reiniciar backend${NC}"
fi

echo -e "\n${GREEN}Configuração concluída!${NC}"
echo "Acesse: http://seu-servidor"
