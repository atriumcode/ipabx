#!/bin/bash

echo "=========================================="
echo "TESTE MANUAL DO BACKEND"
echo "=========================================="
echo ""

cd /opt/ipabx/backend

echo "[1/3] Parando serviço atual..."
sudo systemctl stop pbx-backend

echo ""
echo "[2/3] Carregando variáveis de ambiente..."
export $(cat .env | grep -v '^#' | xargs)

echo ""
echo "[3/3] Executando backend em modo debug..."
echo "Pressione Ctrl+C para parar"
echo "----------------------------------------"
node dist/main.js
