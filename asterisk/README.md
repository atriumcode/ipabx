# Configuração Asterisk - PBX Moderno Enterprise

Arquivos de configuração do Asterisk para integração com o sistema PBX Moderno.

## Arquivos Principais

- **pjsip.conf** - Configuração PJSIP (protocolo moderno)
- **sip.conf** - Configuração SIP legado (chan_sip)
- **extensions.conf** - Dialplan (plano de discagem)
- **queues.conf** - Configuração de filas
- **extconfig.conf** - Mapeamento Realtime
- **sorcery.conf** - Configuração Sorcery (PJSIP Realtime)
- **res_pgsql.conf** - Conexão PostgreSQL
- **manager.conf** - AMI (Asterisk Manager Interface)
- **ari.conf** - ARI (Asterisk REST Interface)
- **http.conf** - Servidor HTTP para ARI
- **voicemail.conf** - Correio de voz
- **modules.conf** - Módulos carregados

## Instalação

1. Copiar arquivos para `/etc/asterisk/`:

\`\`\`bash
sudo cp asterisk/*.conf /etc/asterisk/
\`\`\`

2. Ajustar permissões:

\`\`\`bash
sudo chown -R asterisk:asterisk /etc/asterisk/
sudo chmod 640 /etc/asterisk/*.conf
\`\`\`

3. Editar configurações sensíveis:
   - Alterar senhas em `manager.conf` e `ari.conf`
   - Configurar IP externo em `pjsip.conf` e `sip.conf`
   - Ajustar credenciais do banco em `res_pgsql.conf`

4. Reiniciar Asterisk:

\`\`\`bash
sudo systemctl restart asterisk
\`\`\`

## Realtime

O sistema utiliza PostgreSQL Realtime para:

- **PJSIP**: ps_endpoints, ps_auths, ps_aors
- **SIP**: sip_users, sip_peers
- **Filas**: queues, queue_members
- **CDR**: cdr
- **Voicemail**: voicemail_users

## Dialplan

O dialplan está organizado em contextos:

- **from-internal** - Chamadas de ramais internos
- **from-internal-outbound** - Rotas de saída
- **from-trunk** - Chamadas recebidas de troncos
- **from-did-XXXX** - Rotas de entrada por DID
- **ura-XXXX** - URAs (IVR)
- **emergency** - Números de emergência

## AMI (Asterisk Manager Interface)

Porta: 5038
Usuários configurados:
- **admin** - Acesso completo
- **pbx_app** - Acesso para aplicação

## ARI (Asterisk REST Interface)

Porta: 8088
URL: http://localhost:8088/ari/
Usuário: asterisk

## Segurança

- Altere todas as senhas padrão
- Configure ACLs apropriadas
- Use TLS para conexões externas
- Mantenha o Asterisk atualizado

## Troubleshooting

Ver logs do Asterisk:
\`\`\`bash
sudo asterisk -rvvv
\`\`\`

Recarregar configurações:
\`\`\`bash
asterisk -rx "core reload"
asterisk -rx "pjsip reload"
asterisk -rx "sip reload"
\`\`\`

Verificar status:
\`\`\`bash
asterisk -rx "pjsip show endpoints"
asterisk -rx "sip show peers"
asterisk -rx "queue show"
\`\`\`
