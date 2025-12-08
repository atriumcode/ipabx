# Guia de Solução de Problemas - PBX Moderno Enterprise

## Erro 500 Internal Server Error

O erro 500 do Nginx geralmente indica um dos seguintes problemas:

### 1. Backend não está rodando

**Verificar status:**
\`\`\`bash
sudo systemctl status pbx-backend
\`\`\`

**Se estiver parado, iniciar:**
\`\`\`bash
sudo systemctl start pbx-backend
\`\`\`

**Ver logs para identificar o problema:**
\`\`\`bash
sudo journalctl -u pbx-backend -n 50
\`\`\`

### 2. Backend não consegue conectar ao banco de dados

**Verificar se PostgreSQL está rodando:**
\`\`\`bash
sudo systemctl status postgresql
\`\`\`

**Verificar credenciais no arquivo .env:**
\`\`\`bash
cat /opt/pbx-moderno/backend/.env
\`\`\`

**Testar conexão manual:**
\`\`\`bash
psql -h localhost -U pbx_user -d pbx_moderno
\`\`\`

### 3. Problema de permissões

**Ajustar permissões do diretório:**
\`\`\`bash
sudo chown -R root:root /opt/pbx-moderno
sudo chmod -R 755 /opt/pbx-moderno
\`\`\`

### 4. Configuração incorreta do Nginx

**Testar configuração:**
\`\`\`bash
sudo nginx -t
\`\`\`

**Verificar configuração do site:**
\`\`\`bash
cat /etc/nginx/sites-available/pbx-moderno
\`\`\`

**Verificar se o link simbólico existe:**
\`\`\`bash
ls -la /etc/nginx/sites-enabled/pbx-moderno
\`\`\`

## Script de Diagnóstico Automático

Execute o script de diagnóstico para identificar rapidamente problemas:

\`\`\`bash
cd /opt/pbx-moderno
sudo bash diagnostico.sh
\`\`\`

## Solução Rápida - Reiniciar Todos os Serviços

\`\`\`bash
sudo systemctl restart pbx-backend
sudo systemctl restart postgresql
sudo systemctl restart asterisk
sudo systemctl restart nginx
\`\`\`

## Verificar Logs Específicos

### Backend
\`\`\`bash
# Logs em tempo real
sudo journalctl -u pbx-backend -f

# Últimas 100 linhas
sudo journalctl -u pbx-backend -n 100
\`\`\`

### Nginx
\`\`\`bash
# Log de erros
sudo tail -f /var/log/nginx/pbx-moderno-error.log

# Log de acesso
sudo tail -f /var/log/nginx/pbx-moderno-access.log
\`\`\`

### PostgreSQL
\`\`\`bash
sudo tail -f /var/log/postgresql/postgresql-*.log
\`\`\`

### Asterisk
\`\`\`bash
sudo asterisk -rvvv
\`\`\`

## Recompilar a Aplicação

Se houver problemas com o build:

### Backend
\`\`\`bash
cd /opt/pbx-moderno/backend
npm install
npx nest build
sudo systemctl restart pbx-backend
\`\`\`

### Frontend
\`\`\`bash
cd /opt/pbx-moderno/frontend
npm install
npm run build
sudo systemctl restart nginx
\`\`\`

## Verificar Conectividade

### Testar backend diretamente
\`\`\`bash
curl http://localhost:3001/api/health
\`\`\`

### Testar através do Nginx
\`\`\`bash
curl http://localhost/api/health
\`\`\`

## Portas Necessárias

Certifique-se de que as seguintes portas estão abertas:

- **80** - HTTP (Nginx)
- **443** - HTTPS (Nginx, se configurado SSL)
- **3001** - Backend API
- **5432** - PostgreSQL
- **5038** - Asterisk AMI
- **5060** - SIP UDP
- **5061** - SIP TCP/TLS
- **10000-20000** - RTP (mídia de voz)

Verificar portas abertas:
\`\`\`bash
sudo netstat -tulpn | grep -E '(80|443|3001|5432|5038|5060)'
\`\`\`

## Reinstalação do Backend (último recurso)

Se nada funcionar, reinstale o backend:

\`\`\`bash
cd /opt/pbx-moderno/backend
sudo systemctl stop pbx-backend
rm -rf node_modules dist
npm install
npx nest build
sudo systemctl start pbx-backend
sudo journalctl -u pbx-backend -f
\`\`\`

## Contato e Suporte

Se o problema persistir após todas as verificações:

1. Execute o script de diagnóstico: `sudo bash diagnostico.sh`
2. Salve a saída completa
3. Verifique todos os logs mencionados
4. Documente os passos já realizados

## Erros Comuns e Soluções

### "Cannot find module"
\`\`\`bash
cd /opt/pbx-moderno/backend
npm install
\`\`\`

### "ECONNREFUSED" ao conectar banco
\`\`\`bash
sudo systemctl start postgresql
# Verificar credenciais no .env
\`\`\`

### "Port already in use"
\`\`\`bash
# Identificar processo usando a porta
sudo lsof -i :3001
# Matar processo
sudo kill -9 <PID>
\`\`\`

### "Permission denied"
\`\`\`bash
sudo chown -R root:root /opt/pbx-moderno
sudo chmod -R 755 /opt/pbx-moderno
