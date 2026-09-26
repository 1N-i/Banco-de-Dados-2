
-- Arquivo: 04_seguranca.sql
-- Descrição: Configuração de roles, usuários e permissões de acesso

-- Criação dos perfis de acesso (Roles)
CREATE ROLE role_admin;
CREATE ROLE role_app;
CREATE ROLE role_leitura;

-- Criação de usuários com senhas
CREATE USER admin_db WITH PASSWORD 'SenhaForteAdmin123!';
CREATE USER user_backend WITH PASSWORD 'SenhaForteApp456!';
CREATE USER user_relatorios WITH PASSWORD 'SenhaForteRead789!';

-- Associação dos usuários aos perfis
GRANT role_admin TO admin_db;
GRANT role_app TO user_backend;
GRANT role_leitura TO user_relatorios;

-- Revogar privilégios públicos por segurança
REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- Permissões do Admin (Acesso total)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO role_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO role_admin;

-- Permissões da Aplicação (Apenas operações DML necessárias)
GRANT SELECT, INSERT, UPDATE, DELETE ON 
    Usuario, HabitoDesejado, AppMonitorado, RegistroUso, ProgressoHabito 
TO role_app;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO role_app;

-- Permissões de Leitura (Para relatórios / Data Warehouse)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO role_leitura;