-- ==================================================================
-- PBX MODERNO ENTERPRISE - ESTRUTURA DO BANCO DE DADOS
-- Sistema Multitenant Completo
-- ==================================================================

-- Criação do usuário do banco (se não existir)
DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'pbx_user') THEN
      CREATE ROLE pbx_user WITH LOGIN PASSWORD 'pbx_password_seguro';
   END IF;
END
$$;

-- Criação do banco de dados
CREATE DATABASE pbx_moderno
    WITH 
    OWNER = pbx_user
    ENCODING = 'UTF8'
    LC_COLLATE = 'pt_BR.UTF-8'
    LC_CTYPE = 'pt_BR.UTF-8'
    TEMPLATE = template0;

\c pbx_moderno

-- Habilitar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ==================================================================
-- TABELAS GLOBAIS (Sistema)
-- ==================================================================

-- Tabela de Tenants (Empresas/Inquilinos)
CREATE TABLE tenants (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    nome VARCHAR(255) NOT NULL,
    dominio VARCHAR(255) UNIQUE,
    ativo BOOLEAN DEFAULT true,
    plano VARCHAR(50) DEFAULT 'basico',
    max_ramais INTEGER DEFAULT 10,
    max_troncos INTEGER DEFAULT 2,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    configuracoes JSONB DEFAULT '{}'::jsonb,
    CONSTRAINT chk_plano CHECK (plano IN ('basico', 'profissional', 'enterprise', 'ilimitado'))
);

CREATE INDEX idx_tenants_ativo ON tenants(ativo);
CREATE INDEX idx_tenants_dominio ON tenants(dominio);

-- Tabela de Usuários do Sistema
CREATE TABLE system_users (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    tenant_id INTEGER REFERENCES tenants(id) ON DELETE CASCADE,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    perfil VARCHAR(50) DEFAULT 'operador',
    ativo BOOLEAN DEFAULT true,
    ultimo_login TIMESTAMP,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    permissoes JSONB DEFAULT '{}'::jsonb,
    CONSTRAINT chk_perfil CHECK (perfil IN ('root', 'admin', 'operador', 'leitura'))
);

CREATE INDEX idx_system_users_email ON system_users(email);
CREATE INDEX idx_system_users_tenant ON system_users(tenant_id);
CREATE INDEX idx_system_users_perfil ON system_users(perfil);

-- Tabela de Configurações do Sistema
CREATE TABLE system_settings (
    id SERIAL PRIMARY KEY,
    chave VARCHAR(255) UNIQUE NOT NULL,
    valor TEXT,
    tipo VARCHAR(50) DEFAULT 'string',
    descricao TEXT,
    categoria VARCHAR(100),
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==================================================================
-- TABELAS POR TENANT (Todas com tenant_id)
-- ==================================================================

-- Ramais (Extensions) - PJSIP
CREATE TABLE extensions (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    numero VARCHAR(50) NOT NULL,
    nome VARCHAR(255) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    caller_id VARCHAR(255),
    tipo VARCHAR(20) DEFAULT 'pjsip',
    context VARCHAR(100) DEFAULT 'from-internal',
    mailbox VARCHAR(50),
    codecs VARCHAR(255) DEFAULT 'alaw,ulaw,g729',
    transporte VARCHAR(50) DEFAULT 'udp',
    nat VARCHAR(50) DEFAULT 'yes',
    dtmf_mode VARCHAR(50) DEFAULT 'rfc4733',
    max_contacts INTEGER DEFAULT 1,
    qualifyfreq INTEGER DEFAULT 60,
    ativo BOOLEAN DEFAULT true,
    online BOOLEAN DEFAULT false,
    ultimo_registro TIMESTAMP,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    configuracoes JSONB DEFAULT '{}'::jsonb,
    CONSTRAINT extensions_tenant_numero_unique UNIQUE (tenant_id, numero),
    CONSTRAINT chk_tipo CHECK (tipo IN ('pjsip', 'sip'))
);

CREATE INDEX idx_extensions_tenant ON extensions(tenant_id);
CREATE INDEX idx_extensions_numero ON extensions(numero);
CREATE INDEX idx_extensions_ativo ON extensions(ativo);

-- Troncos SIP/PJSIP
CREATE TABLE trunks (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    nome VARCHAR(255) NOT NULL,
    tipo VARCHAR(20) DEFAULT 'pjsip',
    host VARCHAR(255) NOT NULL,
    porta INTEGER DEFAULT 5060,
    usuario VARCHAR(255),
    senha VARCHAR(255),
    registrar BOOLEAN DEFAULT true,
    context VARCHAR(100) DEFAULT 'from-trunk',
    transporte VARCHAR(50) DEFAULT 'udp',
    codecs VARCHAR(255) DEFAULT 'alaw,ulaw,g729',
    dtmf_mode VARCHAR(50) DEFAULT 'rfc4733',
    sendrpid VARCHAR(50) DEFAULT 'yes',
    fromdomain VARCHAR(255),
    fromuser VARCHAR(255),
    ativo BOOLEAN DEFAULT true,
    online BOOLEAN DEFAULT false,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    configuracoes JSONB DEFAULT '{}'::jsonb,
    CONSTRAINT trunks_tenant_nome_unique UNIQUE (tenant_id, nome),
    CONSTRAINT chk_tipo_trunk CHECK (tipo IN ('pjsip', 'sip'))
);

CREATE INDEX idx_trunks_tenant ON trunks(tenant_id);
CREATE INDEX idx_trunks_ativo ON trunks(ativo);

-- Filas (Queues)
CREATE TABLE queues (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    nome VARCHAR(255) NOT NULL,
    numero VARCHAR(50) NOT NULL,
    estrategia VARCHAR(50) DEFAULT 'ringall',
    timeout INTEGER DEFAULT 15,
    retry INTEGER DEFAULT 5,
    wrapuptime INTEGER DEFAULT 15,
    maxlen INTEGER DEFAULT 0,
    announce VARCHAR(255),
    context VARCHAR(100) DEFAULT 'from-internal',
    musiconhold VARCHAR(100) DEFAULT 'default',
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    configuracoes JSONB DEFAULT '{}'::jsonb,
    CONSTRAINT queues_tenant_numero_unique UNIQUE (tenant_id, numero),
    CONSTRAINT chk_estrategia CHECK (estrategia IN ('ringall', 'leastrecent', 'fewestcalls', 'random', 'rrmemory', 'linear'))
);

CREATE INDEX idx_queues_tenant ON queues(tenant_id);
CREATE INDEX idx_queues_numero ON queues(numero);

-- Membros das Filas
CREATE TABLE queue_members (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    queue_id INTEGER NOT NULL REFERENCES queues(id) ON DELETE CASCADE,
    extension_id INTEGER NOT NULL REFERENCES extensions(id) ON DELETE CASCADE,
    interface VARCHAR(255) NOT NULL,
    penalty INTEGER DEFAULT 0,
    paused BOOLEAN DEFAULT false,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_queue_members_queue ON queue_members(queue_id);
CREATE INDEX idx_queue_members_extension ON queue_members(extension_id);

-- Grupos (Ring Groups)
CREATE TABLE groups (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    nome VARCHAR(255) NOT NULL,
    numero VARCHAR(50) NOT NULL,
    estrategia VARCHAR(50) DEFAULT 'ringall',
    timeout INTEGER DEFAULT 20,
    context VARCHAR(100) DEFAULT 'from-internal',
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    membros JSONB DEFAULT '[]'::jsonb,
    CONSTRAINT groups_tenant_numero_unique UNIQUE (tenant_id, numero)
);

CREATE INDEX idx_groups_tenant ON groups(tenant_id);

-- URAs (IVR)
CREATE TABLE ivr (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    nome VARCHAR(255) NOT NULL,
    numero VARCHAR(50) NOT NULL,
    timeout INTEGER DEFAULT 10,
    mensagem_audio VARCHAR(255),
    mensagem_invalida VARCHAR(255),
    mensagem_timeout VARCHAR(255),
    max_tentativas INTEGER DEFAULT 3,
    context VARCHAR(100) DEFAULT 'from-internal',
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ivr_tenant_numero_unique UNIQUE (tenant_id, numero)
);

CREATE INDEX idx_ivr_tenant ON ivr(tenant_id);

-- Opções da URA
CREATE TABLE ivr_options (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    ivr_id INTEGER NOT NULL REFERENCES ivr(id) ON DELETE CASCADE,
    digito VARCHAR(1) NOT NULL,
    tipo_destino VARCHAR(50) NOT NULL,
    destino VARCHAR(255) NOT NULL,
    descricao VARCHAR(255),
    CONSTRAINT ivr_options_ivr_digito_unique UNIQUE (ivr_id, digito),
    CONSTRAINT chk_tipo_destino CHECK (tipo_destino IN ('extension', 'queue', 'group', 'ivr', 'external'))
);

CREATE INDEX idx_ivr_options_ivr ON ivr_options(ivr_id);

-- Rotas de Entrada (Inbound Routes)
CREATE TABLE inbound_routes (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    nome VARCHAR(255) NOT NULL,
    did VARCHAR(255) NOT NULL,
    trunk_id INTEGER REFERENCES trunks(id) ON DELETE SET NULL,
    tipo_destino VARCHAR(50) NOT NULL,
    destino VARCHAR(255) NOT NULL,
    prioridade INTEGER DEFAULT 1,
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    configuracoes JSONB DEFAULT '{}'::jsonb,
    CONSTRAINT chk_tipo_destino_inbound CHECK (tipo_destino IN ('extension', 'queue', 'group', 'ivr', 'external'))
);

CREATE INDEX idx_inbound_routes_tenant ON inbound_routes(tenant_id);
CREATE INDEX idx_inbound_routes_did ON inbound_routes(did);

-- Rotas de Saída (Outbound Routes)
CREATE TABLE outbound_routes (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    nome VARCHAR(255) NOT NULL,
    dial_pattern VARCHAR(255) NOT NULL,
    trunk_id INTEGER NOT NULL REFERENCES trunks(id) ON DELETE CASCADE,
    trunk_fallback_id INTEGER REFERENCES trunks(id) ON DELETE SET NULL,
    prefixo_remover VARCHAR(50),
    prefixo_adicionar VARCHAR(50),
    prioridade INTEGER DEFAULT 1,
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_outbound_routes_tenant ON outbound_routes(tenant_id);

-- CDR (Call Detail Records)
CREATE TABLE cdr (
    id BIGSERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    calldate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    clid VARCHAR(80),
    src VARCHAR(80),
    dst VARCHAR(80),
    dcontext VARCHAR(80),
    channel VARCHAR(80),
    dstchannel VARCHAR(80),
    lastapp VARCHAR(80),
    lastdata VARCHAR(80),
    duration INTEGER DEFAULT 0,
    billsec INTEGER DEFAULT 0,
    disposition VARCHAR(45),
    amaflags INTEGER,
    accountcode VARCHAR(20),
    uniqueid VARCHAR(150),
    userfield VARCHAR(255),
    recordingfile VARCHAR(255)
);

CREATE INDEX idx_cdr_tenant ON cdr(tenant_id);
CREATE INDEX idx_cdr_calldate ON cdr(calldate);
CREATE INDEX idx_cdr_src ON cdr(src);
CREATE INDEX idx_cdr_dst ON cdr(dst);
CREATE INDEX idx_cdr_uniqueid ON cdr(uniqueid);

-- Gravações
CREATE TABLE recordings (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    nome VARCHAR(255) NOT NULL,
    arquivo VARCHAR(255) NOT NULL,
    formato VARCHAR(10) DEFAULT 'wav',
    duracao INTEGER,
    tamanho BIGINT,
    tipo VARCHAR(50) DEFAULT 'custom',
    cdr_id BIGINT REFERENCES cdr(id) ON DELETE SET NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    configuracoes JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_recordings_tenant ON recordings(tenant_id);
CREATE INDEX idx_recordings_tipo ON recordings(tipo);

-- ==================================================================
-- TABELAS ASTERISK REALTIME (PJSIP)
-- ==================================================================

-- ps_endpoints (PJSIP)
CREATE TABLE ps_endpoints (
    id VARCHAR(40) PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    transport VARCHAR(40),
    aors VARCHAR(200),
    auth VARCHAR(40),
    context VARCHAR(40),
    disallow VARCHAR(200),
    allow VARCHAR(200),
    direct_media VARCHAR(10) DEFAULT 'no',
    direct_media_method VARCHAR(20) DEFAULT 'invite',
    connected_line_method VARCHAR(20) DEFAULT 'invite',
    disable_direct_media_on_nat VARCHAR(10) DEFAULT 'no',
    dtmf_mode VARCHAR(20) DEFAULT 'rfc4733',
    external_media_address VARCHAR(40),
    force_rport VARCHAR(10) DEFAULT 'yes',
    ice_support VARCHAR(10) DEFAULT 'no',
    identify_by VARCHAR(20) DEFAULT 'username',
    mailboxes VARCHAR(100),
    moh_suggest VARCHAR(100) DEFAULT 'default',
    outbound_auth VARCHAR(40),
    outbound_proxy VARCHAR(256),
    rewrite_contact VARCHAR(10) DEFAULT 'no',
    rtp_ipv6 VARCHAR(10) DEFAULT 'no',
    rtp_symmetric VARCHAR(10) DEFAULT 'yes',
    send_diversion VARCHAR(10) DEFAULT 'yes',
    send_pai VARCHAR(10) DEFAULT 'yes',
    send_rpid VARCHAR(10) DEFAULT 'yes',
    timers_min_se INTEGER DEFAULT 90,
    timers VARCHAR(20) DEFAULT 'yes',
    timers_sess_expires INTEGER DEFAULT 1800,
    callerid VARCHAR(100),
    from_user VARCHAR(100),
    from_domain VARCHAR(100),
    trust_id_inbound VARCHAR(10) DEFAULT 'no',
    trust_id_outbound VARCHAR(10) DEFAULT 'no',
    use_ptime VARCHAR(10) DEFAULT 'no',
    use_avpf VARCHAR(10) DEFAULT 'no',
    media_encryption VARCHAR(20) DEFAULT 'no',
    inband_progress VARCHAR(10) DEFAULT 'no',
    call_group VARCHAR(40),
    pickup_group VARCHAR(40),
    named_call_group VARCHAR(40),
    named_pickup_group VARCHAR(40),
    device_state_busy_at INTEGER DEFAULT 1,
    t38_udptl VARCHAR(10) DEFAULT 'no',
    t38_udptl_ec VARCHAR(20) DEFAULT 'none',
    t38_udptl_maxdatagram INTEGER DEFAULT 0,
    fax_detect VARCHAR(10) DEFAULT 'no',
    t38_udptl_nat VARCHAR(10) DEFAULT 'no',
    t38_udptl_ipv6 VARCHAR(10) DEFAULT 'no',
    tone_zone VARCHAR(40),
    language VARCHAR(40) DEFAULT 'pt_BR',
    one_touch_recording VARCHAR(10) DEFAULT 'no',
    record_on_feature VARCHAR(40) DEFAULT 'automixmon',
    record_off_feature VARCHAR(40) DEFAULT 'automixmon',
    rtp_engine VARCHAR(40) DEFAULT 'asterisk',
    allow_transfer VARCHAR(10) DEFAULT 'yes',
    allow_subscribe VARCHAR(10) DEFAULT 'yes',
    sdp_owner VARCHAR(40) DEFAULT '-',
    sdp_session VARCHAR(40) DEFAULT 'Asterisk PBX',
    tos_audio VARCHAR(10),
    tos_video VARCHAR(10),
    cos_audio INTEGER,
    cos_video INTEGER,
    sub_min_expiry INTEGER DEFAULT 60,
    from_domain_tag VARCHAR(100),
    message_context VARCHAR(40),
    accountcode VARCHAR(80)
);

CREATE INDEX idx_ps_endpoints_tenant ON ps_endpoints(tenant_id);

-- ps_auths (Autenticação PJSIP)
CREATE TABLE ps_auths (
    id VARCHAR(40) PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    auth_type VARCHAR(20) DEFAULT 'userpass',
    nonce_lifetime INTEGER DEFAULT 32,
    md5_cred VARCHAR(256),
    password VARCHAR(256),
    realm VARCHAR(40),
    username VARCHAR(40)
);

CREATE INDEX idx_ps_auths_tenant ON ps_auths(tenant_id);

-- ps_aors (Address of Record PJSIP)
CREATE TABLE ps_aors (
    id VARCHAR(40) PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    contact VARCHAR(256),
    default_expiration INTEGER DEFAULT 3600,
    mailboxes VARCHAR(100),
    max_contacts INTEGER DEFAULT 1,
    minimum_expiration INTEGER DEFAULT 60,
    remove_existing VARCHAR(10) DEFAULT 'no',
    qualify_frequency INTEGER DEFAULT 60,
    qualify_timeout NUMERIC(4, 2) DEFAULT 3.0,
    authenticate_qualify VARCHAR(10) DEFAULT 'no',
    maximum_expiration INTEGER DEFAULT 7200,
    outbound_proxy VARCHAR(256),
    support_path VARCHAR(10) DEFAULT 'no',
    voicemail_extension VARCHAR(40)
);

CREATE INDEX idx_ps_aors_tenant ON ps_aors(tenant_id);

-- ==================================================================
-- DADOS INICIAIS
-- ==================================================================

-- Tenant padrão
INSERT INTO tenants (nome, dominio, ativo, plano, max_ramais, max_troncos) 
VALUES ('Tenant Principal', 'principal.pbx', true, 'enterprise', 1000, 100);

-- Usuário root
INSERT INTO system_users (tenant_id, nome, email, senha, perfil, ativo) 
VALUES (
    1, 
    'Administrador', 
    'admin@pbx.local', 
    '$2b$10$xJwQqKk8TLqVY7XqR9Zp4.xKYqSHe3YmxjGfLmOXJQPpKqE5KqZQG', -- senha: admin123
    'root', 
    true
);

-- Configurações do sistema
INSERT INTO system_settings (chave, valor, tipo, descricao, categoria) VALUES
('sistema.nome', 'PBX Moderno Enterprise', 'string', 'Nome do sistema', 'geral'),
('sistema.versao', '1.0.0', 'string', 'Versão do sistema', 'geral'),
('sistema.timezone', 'America/Sao_Paulo', 'string', 'Fuso horário do sistema', 'geral'),
('asterisk.versao_minima', '18.0', 'string', 'Versão mínima do Asterisk suportada', 'asterisk'),
('cdr.retencao_dias', '90', 'integer', 'Dias de retenção de CDR', 'cdr'),
('gravacoes.retencao_dias', '30', 'integer', 'Dias de retenção de gravações', 'gravacoes'),
('gravacoes.formato_padrao', 'wav', 'string', 'Formato padrão de gravações', 'gravacoes');

-- Permissões e privilégios
GRANT ALL PRIVILEGES ON DATABASE pbx_moderno TO pbx_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pbx_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO pbx_user;

-- ==================================================================
-- FIM DO SCRIPT
-- ==================================================================
