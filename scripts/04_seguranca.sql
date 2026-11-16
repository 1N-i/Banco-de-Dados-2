-- 1. Criação das Roles (Papéis) de banco de dados
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='role_admin') THEN CREATE ROLE role_admin; END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='role_app') THEN CREATE ROLE role_app; END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='role_leitura') THEN CREATE ROLE role_leitura; END IF;
END $$;

-- 2. Conceder permissão de uso no schema public logo após a criação das roles
GRANT USAGE ON SCHEMA public TO role_admin, role_app, role_leitura;

-- 3. Criação dos usuários de demonstração (substituir senhas antes de uso real).
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='admin_db') THEN CREATE USER admin_db PASSWORD 'SenhaForteAdmin123!'; END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='user_backend') THEN CREATE USER user_backend PASSWORD 'SenhaForteApp456!'; END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='user_relatorios') THEN CREATE USER user_relatorios PASSWORD 'SenhaForteRead789!'; END IF;
END $$;

-- 4. Associa os usuários aos seus respectivos papéis
GRANT role_admin TO admin_db;
GRANT role_app TO user_backend;
GRANT role_leitura TO user_relatorios;

-- 5. Restrição de segurança padrão (Revoga acessos públicos indesejados)
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;

-- Garante que o schema public continue acessível de forma controlada pelas roles
GRANT USAGE ON SCHEMA public TO role_admin, role_app, role_leitura;

-- 6. Atribuição de privilégios para tabelas e sequências existentes
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO role_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO role_admin;

GRANT SELECT, INSERT, UPDATE, DELETE ON 
    Usuario, HabitoDesejado, AppMonitorado, RegistroUso, ProgressoHabito 
TO role_app;

GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO role_app;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO role_leitura;

-- 7. Privilégios Padrão para Tabelas Futuras 
-- (Garante que se novas tabelas forem criadas depois, as roles já herdam os acessos)
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO role_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO role_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO role_leitura;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO role_app;