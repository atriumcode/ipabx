#!/bin/bash

set -e

echo "================================"
echo "SCRIPT DE CORREÇÃO DO BACKEND"
echo "================================"
echo ""

cd /opt/ipabx/backend

echo "[1/6] Parando serviço do backend..."
sudo systemctl stop pbx-backend

echo "[2/6] Instalando dependências..."
npm install

echo "[3/6] Recompilando o backend..."
npm run build

echo "[4/6] Verificando arquivo .env..."
if [ ! -f .env ]; then
    echo "Criando arquivo .env..."
    cat > .env << 'EOF'
NODE_ENV=production
PORT=3000

# Database
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=pbx_user
DB_PASSWORD=pbx_secure_password_2024
DB_DATABASE=pbx_moderno

# JWT
JWT_SECRET=super_secret_jwt_key_change_in_production_2024
JWT_EXPIRES_IN=24h

# Asterisk AMI
ASTERISK_HOST=localhost
ASTERISK_PORT=5038
ASTERISK_USERNAME=admin
ASTERISK_SECRET=asterisk_ami_secret_2024

# Asterisk ARI
ARI_HOST=localhost
ARI_PORT=8088
ARI_USERNAME=asterisk
ARI_PASSWORD=asterisk_ari_secret_2024
EOF
    echo "✓ Arquivo .env criado"
else
    echo "✓ Arquivo .env já existe"
fi

echo "[5/6] Testando conexão com banco de dados..."
if sudo -u postgres psql -d pbx_moderno -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✓ Conexão com banco OK"
else
    echo "✗ Erro ao conectar no banco!"
    exit 1
fi

echo "[6/6] Reiniciando serviço do backend..."
sudo systemctl start pbx-backend

echo ""
echo "Aguardando 5 segundos..."
sleep 5

echo ""
echo "Status do serviço:"
sudo systemctl status pbx-backend --no-pager -l

echo ""
echo "================================"
echo "CORREÇÃO CONCLUÍDA"
echo "================================"
echo ""
echo "Se ainda houver erros, execute:"
echo "  sudo bash verificar_logs.sh"
