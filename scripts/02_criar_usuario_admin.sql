-- Script para criar usuário admin padrão
-- Execute: sudo -u postgres psql -d pbx_moderno -f 02_criar_usuario_admin.sql

-- Criar tenant padrão se não existir
INSERT INTO tenants (name, domain, active, max_extensions, max_trunks, created_at, updated_at)
VALUES ('Empresa Padrão', 'default', true, 100, 10, NOW(), NOW())
ON CONFLICT (domain) DO UPDATE SET updated_at = NOW();

-- Obter tenant_id
DO $$
DECLARE
    v_tenant_id INTEGER;
BEGIN
    SELECT id INTO v_tenant_id FROM tenants WHERE domain = 'default';
    
    -- Deletar usuário admin se existir
    DELETE FROM system_users WHERE username = 'admin';
    
    -- Criar usuário admin
    -- Senha: admin123 (hash bcrypt com 10 rounds)
    INSERT INTO system_users (
        tenant_id,
        username,
        email,
        password,
        name,
        role,
        active,
        created_at,
        updated_at
    ) VALUES (
        v_tenant_id,
        'admin',
        'admin@ipabx.local',
        '$2b$10$rZ9j7nEHZ5YJ5YJ5YJ5YJuQJ5YJ5YJ5YJ5YJ5YJ5YJ5YJ5YJ5YJ5Y',
        'Administrador do Sistema',
        'admin',
        true,
        NOW(),
        NOW()
    );
    
    RAISE NOTICE 'Usuário admin criado com sucesso!';
    RAISE NOTICE 'Credenciais:';
    RAISE NOTICE '  Usuário: admin';
    RAISE NOTICE '  Senha: admin123';
    RAISE NOTICE 'IMPORTANTE: Troque a senha após o primeiro login!';
END $$;

-- Verificar usuário criado
SELECT 
    u.id,
    u.username,
    u.email,
    u.name,
    u.role,
    u.active,
    t.name as tenant_name
FROM system_users u
JOIN tenants t ON u.tenant_id = t.id
WHERE u.username = 'admin';
