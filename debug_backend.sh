#!/bin/bash

echo "=========================================="
echo "DEBUG DO BACKEND - PBX MODERNO ENTERPRISE"
echo "=========================================="
echo ""

echo "[1/5] Verificando logs do systemd (últimas 100 linhas)..."
echo "=========================================="
sudo journalctl -u pbx-backend -n 100 --no-pager
echo ""

echo "[2/5] Verificando arquivo .env..."
echo "=========================================="
cat /opt/ipabx/backend/.env
echo ""

echo "[3/5] Testando conexão com PostgreSQL..."
echo "=========================================="
DB_HOST=$(grep DB_HOST /opt/ipabx/backend/.env | cut -d '=' -f2)
DB_PORT=$(grep DB_PORT /opt/ipabx/backend/.env | cut -d '=' -f2)
DB_USER=$(grep DB_USER /opt/ipabx/backend/.env | cut -d '=' -f2)
DB_PASS=$(grep DB_PASSWORD /opt/ipabx/backend/.env | cut -d '=' -f2)
DB_NAME=$(grep DB_DATABASE /opt/ipabx/backend/.env | cut -d '=' -f2)

echo "Conectando: $DB_USER@$DB_HOST:$DB_PORT/$DB_NAME"
PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 'Conexão OK' as status;" 2>&1
echo ""

echo "[4/5] Verificando estrutura de arquivos compilados..."
echo "=========================================="
if [ -f "/opt/ipabx/backend/dist/main.js" ]; then
    echo "✓ dist/main.js existe"
    ls -lh /opt/ipabx/backend/dist/main.js
else
    echo "✗ dist/main.js NÃO EXISTE"
fi
echo ""

echo "[5/5] Tentando executar manualmente (modo verbose)..."
echo "=========================================="
cd /opt/ipabx/backend
export $(cat .env | xargs)
timeout 10 node dist/main.js 2>&1 || echo "Processo terminou com erro"
echo ""

echo "=========================================="
echo "DEBUG COMPLETO"
echo "=========================================="
