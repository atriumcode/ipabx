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

echo -e "\n${YELLOW}[1] Verificando/Criando Tenant Padrão...${NC}"
sudo -u postgres psql -d pbx_moderno <<EOF
-- Inserir tenant padrão se não existir
INSERT INTO tenants (nome, dominio, ativo, plano, max_ramais, max_troncos)
VALUES ('Empresa Padrão', 'principal.pbx', true, 'enterprise', 100, 10)
ON CONFLICT (dominio) DO NOTHING;

-- Mostrar tenant criado
SELECT id, nome, dominio FROM tenants WHERE dominio = 'principal.pbx';
EOF

# Obter ID do tenant
TENANT_ID=$(sudo -u postgres psql -d pbx_moderno -t -c "SELECT id FROM tenants WHERE dominio='principal.pbx' LIMIT 1;")
TENANT_ID=$(echo $TENANT_ID | xargs)

if [ -z "$TENANT_ID" ]; then
    echo -e "${RED}✗ Erro ao obter ID do tenant${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Tenant ID: $TENANT_ID${NC}"

echo -e "\n${YELLOW}[2] Criando/Atualizando Usuário Admin...${NC}"

sudo -u postgres psql -d pbx_moderno <<EOF
-- Deletar usuário admin se existir
DELETE FROM system_users WHERE email = 'admin@pbx.local';

-- Criar novo usuário admin
-- Senha: admin123 (hash bcrypt com 10 rounds)
INSERT INTO system_users (tenant_id, nome, email, senha, perfil, ativo, data_criacao, data_atualizacao)
VALUES (
    $TENANT_ID,
    'Administrador',
    'admin@pbx.local',
    '\$2b\$10\$xJwQqKk8TLqVY7XqR9Zp4.xKYqSHe3YmxjGfLmOXJQPpKqE5KqZQG',
    'root',
    true,
    NOW(),
    NOW()
);

-- Mostrar usuário criado
SELECT id, email, nome, perfil, ativo FROM system_users WHERE email = 'admin@pbx.local';
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Usuário admin criado com sucesso!${NC}"
    echo ""
    echo "======================================"
    echo "CREDENCIAIS DE ACESSO:"
    echo "======================================"
    echo "Email: admin@pbx.local"
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
sleep 5

if systemctl is-active --quiet pbx-backend; then
    echo -e "${GREEN}✓ Backend reiniciado com sucesso${NC}"
    
    # Testar login
    echo -e "\n${YELLOW}[4] Testando login...${NC}"
    sleep 2
    TESTE_LOGIN=$(curl -s -X POST http://localhost:3001/api/auth/login \
      -H "Content-Type: application/json" \
      -d '{"email":"admin@pbx.local","senha":"admin123"}')
    
    if echo "$TESTE_LOGIN" | grep -q "access_token"; then
        echo -e "${GREEN}✓ Login testado com sucesso!${NC}"
    else
        echo -e "${YELLOW}⚠ Login retornou erro. Verifique os logs:${NC}"
        echo "$TESTE_LOGIN"
    fi
else
    echo -e "${RED}✗ Erro ao reiniciar backend${NC}"
    echo "Logs:"
    journalctl -u pbx-backend -n 30 --no-pager
fi

echo -e "\n${GREEN}Configuração concluída!${NC}"
echo "Acesse: http://seu-servidor"
