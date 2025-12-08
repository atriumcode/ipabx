#!/bin/bash

# ==================================================================
# SCRIPT DE RESTAURAÇÃO - PBX MODERNO ENTERPRISE
# Restaura backup do banco de dados e configurações
# ==================================================================

set -e

# Verificar argumentos
if [ -z "$1" ]; then
    echo "Uso: $0 <data_do_backup>"
    echo "Exemplo: $0 20241208_143022"
    echo ""
    echo "Backups disponíveis:"
    ls -lh /var/backups/pbx-moderno/ | grep backup_
    exit 1
fi

BACKUP_DATE=$1
BACKUP_DIR="/var/backups/pbx-moderno"
BACKUP_FILE="$BACKUP_DIR/backup_$BACKUP_DATE"
DB_NAME="pbx_moderno"
DB_USER="pbx_user"

# Verificar se backup existe
if [ ! -f "${BACKUP_FILE}_database.dump" ]; then
    echo "Erro: Backup não encontrado: ${BACKUP_FILE}_database.dump"
    exit 1
fi

echo "[Restauração] ATENÇÃO: Esta operação irá sobrescrever os dados atuais!"
read -p "Deseja continuar? (digite 'SIM' para confirmar): " CONFIRM

if [ "$CONFIRM" != "SIM" ]; then
    echo "Operação cancelada."
    exit 0
fi

echo "[Restauração] Iniciando restauração do backup $BACKUP_DATE..."

# Parar serviços
echo "[Restauração] Parando serviços..."
systemctl stop pbx-backend
systemctl stop asterisk

# Restaurar banco de dados
echo "[Restauração] Restaurando banco de dados..."
sudo -u postgres dropdb --if-exists $DB_NAME
sudo -u postgres createdb -O $DB_USER $DB_NAME
sudo -u postgres pg_restore -U $DB_USER -d $DB_NAME -v "${BACKUP_FILE}_database.dump"

# Restaurar configurações do Asterisk
if [ -f "${BACKUP_FILE}_asterisk.tar.gz" ]; then
    echo "[Restauração] Restaurando configurações do Asterisk..."
    tar -xzf "${BACKUP_FILE}_asterisk.tar.gz" -C /
fi

# Restaurar gravações
if [ -f "${BACKUP_FILE}_recordings.tar.gz" ]; then
    echo "[Restauração] Restaurando gravações..."
    tar -xzf "${BACKUP_FILE}_recordings.tar.gz" -C /
fi

# Restaurar configurações da aplicação
if [ -f "${BACKUP_FILE}_configs.tar.gz" ]; then
    echo "[Restauração] Restaurando configurações da aplicação..."
    tar -xzf "${BACKUP_FILE}_configs.tar.gz" -C /
fi

# Reiniciar serviços
echo "[Restauração] Reiniciando serviços..."
systemctl start asterisk
systemctl start pbx-backend

echo "[Restauração] Restauração concluída com sucesso!"
echo "[Restauração] Verifique se todos os serviços estão funcionando:"
echo "  - systemctl status pbx-backend"
echo "  - systemctl status asterisk"
