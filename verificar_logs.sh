#!/bin/bash

echo "================================"
echo "VERIFICAÇÃO DE LOGS DO BACKEND"
echo "================================"
echo ""

echo "1. Últimos 50 linhas do log do systemd:"
echo "----------------------------------------"
sudo journalctl -u pbx-backend -n 50 --no-pager

echo ""
echo ""
echo "2. Verificando arquivo .env:"
echo "----------------------------------------"
if [ -f /opt/ipabx/backend/.env ]; then
    echo "✓ Arquivo .env existe"
    echo "Variáveis configuradas:"
    grep -v "PASSWORD\|SECRET\|KEY" /opt/ipabx/backend/.env | grep -v "^#" | grep -v "^$"
else
    echo "✗ Arquivo .env NÃO encontrado!"
fi

echo ""
echo ""
echo "3. Testando conexão com banco de dados:"
echo "----------------------------------------"
sudo -u postgres psql -c "SELECT version();" pbx_moderno 2>&1

echo ""
echo ""
echo "4. Verificando estrutura do banco:"
echo "----------------------------------------"
sudo -u postgres psql -d pbx_moderno -c "\dt" 2>&1

echo ""
echo ""
echo "5. Verificando se o dist foi compilado:"
echo "----------------------------------------"
if [ -f /opt/ipabx/backend/dist/main.js ]; then
    echo "✓ dist/main.js existe"
    ls -lh /opt/ipabx/backend/dist/main.js
else
    echo "✗ dist/main.js NÃO existe!"
    echo "O backend precisa ser compilado."
fi

echo ""
echo ""
echo "6. Tentando iniciar manualmente para ver erro completo:"
echo "----------------------------------------"
cd /opt/ipabx/backend
echo "Executando: node dist/main.js"
timeout 5 node dist/main.js 2>&1 || echo "Backend falhou ao iniciar"

echo ""
echo ""
echo "================================"
echo "FIM DA VERIFICAÇÃO"
echo "================================"
