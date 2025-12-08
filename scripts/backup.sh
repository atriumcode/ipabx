#!/bin/bash

# ==================================================================
# SCRIPT DE BACKUP - PBX MODERNO ENTERPRISE
# Faz backup completo do banco de dados e configurações
# ==================================================================

set -e

# Configurações
BACKUP_DIR="/var/backups/pbx-moderno"
INSTALL_DIR="/opt/pbx-moderno"
DB_NAME="pbx_moderno"
DB_USER="pbx_user"
RETENTION_DAYS=30

# Criar diretório de backup
mkdir -p "$BACKUP_DIR"

# Data atual
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$DATE"

echo "[Backup] Iniciando backup do PBX Moderno Enterprise..."

# Backup do banco de dados
echo "[Backup] Fazendo backup do banco de dados..."
sudo -u postgres pg_dump -U $DB_USER -F c -b -v -f "${BACKUP_FILE}_database.dump" $DB_NAME

# Backup das configurações do Asterisk
echo "[Backup] Fazendo backup das configurações do Asterisk..."
tar -czf "${BACKUP_FILE}_asterisk.tar.gz" /etc/asterisk/

# Backup das gravações (últimos 7 dias)
echo "[Backup] Fazendo backup das gravações recentes..."
find /var/spool/asterisk/monitor -type f -mtime -7 -print0 | tar -czf "${BACKUP_FILE}_recordings.tar.gz" --null -T -

# Backup das configurações da aplicação
echo "[Backup] Fazendo backup das configurações da aplicação..."
tar -czf "${BACKUP_FILE}_configs.tar.gz" \
    "$INSTALL_DIR/backend/.env" \
    "$INSTALL_DIR/backend/package.json" \
    /etc/systemd/system/pbx-backend.service \
    /etc/nginx/sites-available/pbx-moderno

# Remover backups antigos
echo "[Backup] Removendo backups antigos (mais de $RETENTION_DAYS dias)..."
find "$BACKUP_DIR" -type f -mtime +$RETENTION_DAYS -delete

# Calcular tamanho do backup
BACKUP_SIZE=$(du -sh "$BACKUP_DIR/backup_$DATE"* | awk '{print $1}' | paste -sd+ | bc)

echo "[Backup] Backup concluído com sucesso!"
echo "[Backup] Arquivos criados em: $BACKUP_DIR"
echo "[Backup] Tamanho total: ${BACKUP_SIZE}"
echo "[Backup] Data: $(date)"
