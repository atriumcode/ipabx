#!/bin/bash

# ==================================================================
# SCRIPT DE DIAGNÓSTICO - PBX MODERNO ENTERPRISE
# ==================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     DIAGNÓSTICO PBX MODERNO ENTERPRISE                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Verificar serviços
echo -e "${BLUE}[1/7] Verificando status dos serviços${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

services=("pbx-backend" "postgresql" "asterisk" "nginx")
for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo -e "${GREEN}✓${NC} $service: RODANDO"
    else
        echo -e "${RED}✗${NC} $service: PARADO"
        echo "  Para iniciar: sudo systemctl start $service"
    fi
done
echo ""

# Verificar portas
echo -e "${BLUE}[2/7] Verificando portas${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ports=("80:Nginx" "3001:Backend" "5432:PostgreSQL" "5038:Asterisk AMI" "5060:SIP")
for port_info in "${ports[@]}"; do
    port="${port_info%%:*}"
    name="${port_info##*:}"
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo -e "${GREEN}✓${NC} Porta $port ($name): ABERTA"
    else
        echo -e "${RED}✗${NC} Porta $port ($name): FECHADA"
    fi
done
echo ""

# Verificar logs do backend
echo -e "${BLUE}[3/7] Últimas 10 linhas do log do backend${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if systemctl is-active --quiet pbx-backend; then
    journalctl -u pbx-backend -n 10 --no-pager
else
    echo -e "${RED}Serviço pbx-backend não está rodando${NC}"
fi
echo ""

# Verificar logs do Nginx
echo -e "${BLUE}[4/7] Últimas 5 linhas do log de erro do Nginx${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f /var/log/nginx/pbx-moderno-error.log ]; then
    tail -n 5 /var/log/nginx/pbx-moderno-error.log
else
    echo -e "${YELLOW}Arquivo de log não encontrado${NC}"
fi
echo ""

# Verificar configuração Nginx
echo -e "${BLUE}[5/7] Testando configuração do Nginx${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
nginx -t 2>&1
echo ""

# Verificar conectividade backend
echo -e "${BLUE}[6/7] Testando conectividade com backend${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if curl -s http://localhost:3001/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Backend respondendo em http://localhost:3001"
    curl -s http://localhost:3001/api/health | head -n 5
else
    echo -e "${RED}✗${NC} Backend NÃO está respondendo em http://localhost:3001"
    echo "  Verifique os logs: sudo journalctl -u pbx-backend -n 50"
fi
echo ""

# Verificar arquivos frontend
echo -e "${BLUE}[7/7] Verificando arquivos do frontend${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
INSTALL_DIR="/opt/ipabx"
FRONTEND_DIR="$INSTALL_DIR/frontend/dist"
if [ -d "$FRONTEND_DIR" ]; then
    echo -e "${GREEN}✓${NC} Diretório frontend existe: $FRONTEND_DIR"
    if [ -f "$FRONTEND_DIR/index.html" ]; then
        echo -e "${GREEN}✓${NC} index.html encontrado"
    else
        echo -e "${RED}✗${NC} index.html NÃO encontrado"
    fi
else
    echo -e "${RED}✗${NC} Diretório frontend NÃO existe: $FRONTEND_DIR"
    echo "  Execute: cd $INSTALL_DIR/frontend && npm run build"
fi
echo ""

# Resumo e recomendações
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     COMANDOS ÚTEIS                                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Reiniciar backend:"
echo "  sudo systemctl restart pbx-backend"
echo ""
echo "Ver logs do backend em tempo real:"
echo "  sudo journalctl -u pbx-backend -f"
echo ""
echo "Reiniciar Nginx:"
echo "  sudo systemctl restart nginx"
echo ""
echo "Verificar status de todos os serviços:"
echo "  sudo systemctl status pbx-backend postgresql asterisk nginx"
echo ""
echo "Testar backend diretamente:"
echo "  curl http://localhost:3001/api/health"
echo ""
