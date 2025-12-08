#!/bin/bash

# ==================================================================
# SCRIPT DE VERIFICAÇÃO - PBX MODERNO ENTERPRISE
# Verifica status de todos os componentes do sistema
# ==================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "╔════════════════════════════════════════════════════════════╗"
echo "║        PBX MODERNO ENTERPRISE - STATUS DO SISTEMA         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Função para verificar serviço
check_service() {
    if systemctl is-active --quiet $1; then
        echo -e "  $2: ${GREEN}ATIVO${NC}"
        return 0
    else
        echo -e "  $2: ${RED}INATIVO${NC}"
        return 1
    fi
}

# Verificar serviços
echo "SERVIÇOS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_service "pbx-backend" "Backend"
check_service "asterisk" "Asterisk"
check_service "postgresql" "PostgreSQL"
check_service "nginx" "Nginx"
echo ""

# Verificar conexão com banco
echo "BANCO DE DADOS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if sudo -u postgres psql -d pbx_moderno -c "SELECT 1" > /dev/null 2>&1; then
    echo -e "  Conexão: ${GREEN}OK${NC}"
    TENANT_COUNT=$(sudo -u postgres psql -d pbx_moderno -t -c "SELECT COUNT(*) FROM tenants")
    USER_COUNT=$(sudo -u postgres psql -d pbx_moderno -t -c "SELECT COUNT(*) FROM system_users")
    EXT_COUNT=$(sudo -u postgres psql -d pbx_moderno -t -c "SELECT COUNT(*) FROM extensions")
    echo "  Tenants: $TENANT_COUNT"
    echo "  Usuários: $USER_COUNT"
    echo "  Ramais: $EXT_COUNT"
else
    echo -e "  Conexão: ${RED}FALHA${NC}"
fi
echo ""

# Verificar Asterisk
echo "ASTERISK:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if pgrep -x "asterisk" > /dev/null; then
    echo -e "  Status: ${GREEN}RODANDO${NC}"
    echo "  Versão: $(asterisk -V)"
    PJSIP_ENDPOINTS=$(asterisk -rx "pjsip show endpoints" 2>/dev/null | grep -c "Endpoint:" || echo "0")
    echo "  Endpoints PJSIP: $PJSIP_ENDPOINTS"
else
    echo -e "  Status: ${RED}PARADO${NC}"
fi
echo ""

# Verificar portas
echo "PORTAS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_port() {
    if netstat -tuln | grep -q ":$1 "; then
        echo -e "  $1 ($2): ${GREEN}ABERTA${NC}"
    else
        echo -e "  $1 ($2): ${RED}FECHADA${NC}"
    fi
}

check_port "80" "HTTP"
check_port "3001" "Backend"
check_port "5038" "Asterisk AMI"
check_port "5060" "SIP/PJSIP"
check_port "5432" "PostgreSQL"
check_port "8088" "Asterisk ARI"
echo ""

# Uso de disco
echo "ARMAZENAMENTO:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
df -h / | tail -1 | awk '{print "  Disco: "$3" usado de "$2" ("$5")"}'
RECORDINGS_SIZE=$(du -sh /var/spool/asterisk/monitor 2>/dev/null | cut -f1)
echo "  Gravações: ${RECORDINGS_SIZE:-0B}"
echo ""

# Memória
echo "MEMÓRIA:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
free -h | grep Mem | awk '{print "  Total: "$2" | Usado: "$3" | Livre: "$4}'
echo ""

# Última atualização
echo "SISTEMA:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Uptime: $(uptime -p)"
echo "  Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo ""

echo "Verificação concluída!"
