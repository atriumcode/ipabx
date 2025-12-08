#!/bin/bash

# ==================================================================
# SCRIPT DE DESINSTALAÇÃO - PBX MODERNO ENTERPRISE
# Remove completamente o sistema
# ==================================================================

set -e

echo "ATENÇÃO: Este script irá remover COMPLETAMENTE o PBX Moderno Enterprise"
echo "Incluindo banco de dados, configurações e gravações."
echo ""
read -p "Deseja fazer backup antes de desinstalar? (s/N): " BACKUP

if [[ $BACKUP =~ ^[Ss]$ ]]; then
    bash /opt/pbx-moderno/scripts/backup.sh
    echo "Backup criado em /var/backups/pbx-moderno/"
fi

echo ""
read -p "Digite 'REMOVER TUDO' para confirmar a desinstalação: " CONFIRM

if [ "$CONFIRM" != "REMOVER TUDO" ]; then
    echo "Operação cancelada."
    exit 0
fi

echo "[Desinstalação] Parando serviços..."
systemctl stop pbx-backend
systemctl disable pbx-backend
systemctl stop asterisk
systemctl disable asterisk

echo "[Desinstalação] Removendo serviços..."
rm -f /etc/systemd/system/pbx-backend.service
systemctl daemon-reload

echo "[Desinstalação] Removendo banco de dados..."
sudo -u postgres dropdb --if-exists pbx_moderno
sudo -u postgres dropuser --if-exists pbx_user

echo "[Desinstalação] Removendo aplicação..."
rm -rf /opt/pbx-moderno

echo "[Desinstalação] Removendo configurações do Nginx..."
rm -f /etc/nginx/sites-enabled/pbx-moderno
rm -f /etc/nginx/sites-available/pbx-moderno
systemctl restart nginx

echo "[Desinstalação] Removendo Asterisk..."
apt-get remove -y asterisk asterisk-*
rm -rf /etc/asterisk
rm -rf /var/lib/asterisk
rm -rf /var/spool/asterisk
rm -rf /var/log/asterisk

echo "[Desinstalação] Removendo PostgreSQL (opcional)..."
read -p "Deseja remover o PostgreSQL completamente? (s/N): " REMOVE_PG
if [[ $REMOVE_PG =~ ^[Ss]$ ]]; then
    apt-get remove -y postgresql postgresql-contrib
    rm -rf /var/lib/postgresql
fi

echo "[Desinstalação] PBX Moderno Enterprise foi removido completamente."
echo "[Desinstalação] Backups permanecem em /var/backups/pbx-moderno/ (se criados)"
