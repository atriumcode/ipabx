-- ==================================================================
-- TABELAS ADICIONAIS PARA ASTERISK REALTIME
-- Complemento às tabelas já criadas no script 01
-- ==================================================================

\c pbx_moderno

-- ==================================================================
-- TABELAS CHAN_SIP (Compatibilidade Legada)
-- ==================================================================

-- Usuários SIP (chan_sip)
CREATE TABLE IF NOT EXISTS sip_users (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(40) UNIQUE NOT NULL,
    defaultuser VARCHAR(40),
    secret VARCHAR(40),
    md5secret VARCHAR(32),
    context VARCHAR(40) DEFAULT 'from-internal',
    callerid VARCHAR(100),
    host VARCHAR(40) DEFAULT 'dynamic',
    type VARCHAR(10) DEFAULT 'friend',
    nat VARCHAR(20) DEFAULT 'force_rport,comedia',
    port INTEGER DEFAULT 5060,
    qualify VARCHAR(10) DEFAULT 'yes',
    qualifyfreq INTEGER DEFAULT 60,
    transport VARCHAR(20) DEFAULT 'udp',
    dtmfmode VARCHAR(20) DEFAULT 'rfc2833',
    directmedia VARCHAR(10) DEFAULT 'no',
    insecure VARCHAR(40),
    canreinvite VARCHAR(10) DEFAULT 'no',
    disallow VARCHAR(100) DEFAULT 'all',
    allow VARCHAR(100) DEFAULT 'alaw,ulaw,g729',
    videosupport VARCHAR(10) DEFAULT 'no',
    maxcallbitrate INTEGER DEFAULT 384,
    encryption VARCHAR(10) DEFAULT 'no',
    avpf VARCHAR(10) DEFAULT 'no',
    icesupport VARCHAR(10) DEFAULT 'no',
    callgroup VARCHAR(40),
    pickupgroup VARCHAR(40),
    mailbox VARCHAR(100),
    subscribemwi VARCHAR(10) DEFAULT 'yes',
    vmexten VARCHAR(20),
    language VARCHAR(10) DEFAULT 'pt_BR',
    accountcode VARCHAR(40),
    setvar TEXT,
    fullcontact VARCHAR(255),
    ipaddr VARCHAR(45),
    regserver VARCHAR(100),
    lastms INTEGER DEFAULT 0,
    defaultip VARCHAR(45),
    regexten VARCHAR(40)
);

CREATE INDEX idx_sip_users_tenant ON sip_users(tenant_id);
CREATE INDEX idx_sip_users_name ON sip_users(name);
CREATE INDEX idx_sip_users_host ON sip_users(host);
CREATE INDEX idx_sip_users_ipaddr ON sip_users(ipaddr);

-- Peers SIP (chan_sip) - Para troncos
CREATE TABLE IF NOT EXISTS sip_peers (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(40) UNIQUE NOT NULL,
    defaultuser VARCHAR(40),
    secret VARCHAR(40),
    context VARCHAR(40) DEFAULT 'from-trunk',
    host VARCHAR(40) NOT NULL,
    type VARCHAR(10) DEFAULT 'peer',
    nat VARCHAR(20) DEFAULT 'force_rport,comedia',
    port INTEGER DEFAULT 5060,
    qualify VARCHAR(10) DEFAULT 'yes',
    qualifyfreq INTEGER DEFAULT 60,
    transport VARCHAR(20) DEFAULT 'udp',
    dtmfmode VARCHAR(20) DEFAULT 'rfc2833',
    directmedia VARCHAR(10) DEFAULT 'no',
    insecure VARCHAR(40) DEFAULT 'port,invite',
    canreinvite VARCHAR(10) DEFAULT 'no',
    disallow VARCHAR(100) DEFAULT 'all',
    allow VARCHAR(100) DEFAULT 'alaw,ulaw,g729',
    fromdomain VARCHAR(100),
    fromuser VARCHAR(100),
    sendrpid VARCHAR(10) DEFAULT 'yes',
    trustrpid VARCHAR(10) DEFAULT 'yes',
    progressinband VARCHAR(20) DEFAULT 'no',
    promiscredir VARCHAR(10) DEFAULT 'no',
    useclientcode VARCHAR(10) DEFAULT 'no',
    accountcode VARCHAR(40),
    setvar TEXT,
    callingpres VARCHAR(20) DEFAULT 'allowed_not_screened',
    outboundproxy VARCHAR(100),
    callbackextension VARCHAR(40),
    registertrying VARCHAR(10) DEFAULT 'yes',
    timert1 INTEGER DEFAULT 500,
    timerb INTEGER DEFAULT 32000,
    session-timers VARCHAR(20) DEFAULT 'accept',
    session-expires INTEGER DEFAULT 1800,
    session-minse INTEGER DEFAULT 90,
    session-refresher VARCHAR(10) DEFAULT 'uas'
);

CREATE INDEX idx_sip_peers_tenant ON sip_peers(tenant_id);
CREATE INDEX idx_sip_peers_name ON sip_peers(name);
CREATE INDEX idx_sip_peers_host ON sip_peers(host);

-- ==================================================================
-- TABELAS ADICIONAIS PJSIP
-- ==================================================================

-- Contatos PJSIP (registros ativos)
CREATE TABLE IF NOT EXISTS ps_contacts (
    id VARCHAR(40) PRIMARY KEY,
    uri VARCHAR(256),
    expiration_time BIGINT,
    qualify_frequency INTEGER DEFAULT 0,
    authenticate_qualify VARCHAR(10) DEFAULT 'no',
    outbound_proxy VARCHAR(256),
    path TEXT,
    user_agent VARCHAR(256),
    via_addr VARCHAR(40),
    via_port INTEGER,
    call_id VARCHAR(256),
    endpoint VARCHAR(40),
    prune_on_boot VARCHAR(10) DEFAULT 'no'
);

CREATE INDEX idx_ps_contacts_endpoint ON ps_contacts(endpoint);

-- Domain Aliases PJSIP
CREATE TABLE IF NOT EXISTS ps_domain_aliases (
    id VARCHAR(40) PRIMARY KEY,
    domain VARCHAR(80)
);

-- Identificação por IP
CREATE TABLE IF NOT EXISTS ps_endpoint_id_ips (
    id VARCHAR(40) PRIMARY KEY,
    endpoint VARCHAR(40),
    match VARCHAR(80),
    srv_lookups VARCHAR(10) DEFAULT 'yes'
);

CREATE INDEX idx_ps_endpoint_id_ips_match ON ps_endpoint_id_ips(match);

-- ==================================================================
-- VOICEMAIL
-- ==================================================================

CREATE TABLE IF NOT EXISTS voicemail_users (
    uniqueid SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    context VARCHAR(80) DEFAULT 'default',
    mailbox VARCHAR(80) NOT NULL,
    password VARCHAR(80) NOT NULL,
    fullname VARCHAR(150),
    email VARCHAR(150),
    pager VARCHAR(150),
    attach VARCHAR(10) DEFAULT 'yes',
    attachfmt VARCHAR(20) DEFAULT 'wav',
    serveremail VARCHAR(150),
    language VARCHAR(20) DEFAULT 'pt_BR',
    timezone VARCHAR(50) DEFAULT 'America/Sao_Paulo',
    deletevoicemail VARCHAR(10) DEFAULT 'no',
    saycid VARCHAR(10) DEFAULT 'yes',
    sendvoicemail VARCHAR(10) DEFAULT 'yes',
    review VARCHAR(10) DEFAULT 'no',
    tempgreetwarn VARCHAR(10) DEFAULT 'yes',
    operator VARCHAR(10) DEFAULT 'yes',
    envelope VARCHAR(10) DEFAULT 'no',
    sayduration VARCHAR(10) DEFAULT 'yes',
    saydurationm INTEGER DEFAULT 1,
    forcename VARCHAR(10) DEFAULT 'no',
    forcegreetings VARCHAR(10) DEFAULT 'no',
    callback VARCHAR(80),
    dialout VARCHAR(80),
    exitcontext VARCHAR(80),
    maxmsg INTEGER DEFAULT 100,
    volgain NUMERIC(5,2) DEFAULT 0.00,
    imapuser VARCHAR(150),
    imappassword VARCHAR(150),
    imapserver VARCHAR(150),
    imapport INTEGER DEFAULT 143,
    imapflags VARCHAR(150),
    stamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT voicemail_users_mailbox_context_unique UNIQUE (mailbox, context)
);

CREATE INDEX idx_voicemail_users_tenant ON voicemail_users(tenant_id);
CREATE INDEX idx_voicemail_users_mailbox ON voicemail_users(mailbox);

-- ==================================================================
-- MUSIC ON HOLD
-- ==================================================================

CREATE TABLE IF NOT EXISTS musiconhold (
    name VARCHAR(80) PRIMARY KEY,
    mode VARCHAR(80) DEFAULT 'files',
    directory VARCHAR(255),
    application VARCHAR(255),
    digit VARCHAR(1),
    sort VARCHAR(10) DEFAULT 'alpha',
    format VARCHAR(10) DEFAULT 'wav'
);

-- Inserir classe padrão
INSERT INTO musiconhold (name, mode, directory) VALUES
('default', 'files', '/var/lib/asterisk/moh')
ON CONFLICT (name) DO NOTHING;

-- ==================================================================
-- PERMISSÕES
-- ==================================================================

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pbx_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO pbx_user;
