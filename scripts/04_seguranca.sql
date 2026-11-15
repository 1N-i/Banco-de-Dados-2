-- Seguranca: executar como administrador apos schema e seeds.
DO $$ BEGIN
 IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='role_admin') THEN CREATE ROLE role_admin; END IF;
 IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='role_app') THEN CREATE ROLE role_app; END IF;
 IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='role_leitura') THEN CREATE ROLE role_leitura; END IF;
END $$;
-- Criacao dos usuarios de demonstracao (substituir senhas antes de uso real).
DO $$ BEGIN
 IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='admin_db') THEN CREATE USER admin_db PASSWORD 'SenhaForteAdmin123!'; END IF;
 IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='user_backend') THEN CREATE USER user_backend PASSWORD 'SenhaForteApp456!'; END IF;
 IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='user_relatorios') THEN CREATE USER user_relatorios PASSWORD 'SenhaForteRead789!'; END IF;
END $$;
GRANT role_admin TO admin_db;
GRANT role_app TO user_backend;
GRANT role_leitura TO user_relatorios;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO role_admin, role_app, role_leitura;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO role_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Usuario, HabitoDesejado, AppMonitorado, RegistroUso, ProgressoHabito TO role_app;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO role_app;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO role_leitura;
