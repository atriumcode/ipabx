#!/bin/bash

# ==================================================================
# SCRIPT DE ATUALIZAÇÃO - PBX MODERNO ENTERPRISE
# Atualiza o sistema para a versão mais recente
# ==================================================================

set -e

INSTALL_DIR="/opt/pbx-moderno"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)

echo "[Atualização] PBX Moderno Enterprise - Sistema de Atualização"
echo "[Atualização] Versão atual: $(cat $INSTALL_DIR/VERSION 2>/dev/null || echo 'Desconhecida')"
echo ""

# Fazer backup antes de atualizar
echo "[Atualização] Criando backup de segurança..."
bash "$INSTALL_DIR/scripts/backup.sh"

# Parar serviços
echo "[Atualização] Parando serviços..."
systemctl stop pbx-backend

# Atualizar código
echo "[Atualização] Baixando atualização..."
cd "$INSTALL_DIR"

# Em produção, fazer git pull
# git pull origin main

# Atualizar dependências do backend
echo "[Atualização] Atualizando dependências do backend..."
cd "$INSTALL_DIR/backend"
npm install --production

# Build do backend
echo "[Atualização] Compilando backend..."
npm run build

# Atualizar dependências do frontend
echo "[Atualização] Atualizando dependências do frontend..."
cd "$INSTALL_DIR/frontend"
npm install

# Build do frontend
echo "[Atualização] Compilando frontend..."
npm run build

# Executar migrations do banco
echo "[Atualização] Executando migrations do banco de dados..."
cd "$INSTALL_DIR/backend"
npm run migration:run

# Reiniciar serviços
echo "[Atualização] Reiniciando serviços..."
systemctl start pbx-backend
systemctl restart nginx

echo "[Atualização] Atualização concluída com sucesso!"
echo "[Atualização] Nova versão: $(cat $INSTALL_DIR/VERSION)"
