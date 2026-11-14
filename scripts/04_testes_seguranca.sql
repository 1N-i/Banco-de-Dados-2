-- Arquivo: 04_testes_seguranca.sql
-- Descrição: Testes de tentativa de violação de privilégios para evidenciar o bloqueio de segurança

-- 1. Testar perfil de leitura (user_relatorios / role_leitura)
-- Este perfil deve conseguir ler os dados, mas NÃO deve conseguir inserir ou deletar.

SET ROLE user_relatorios;

-- DEVE FUNCIONAR (Permissão de Leitura concedida)
SELECT COUNT(*) FROM usuario;
SELECT * FROM usuario LIMIT 3;

-- DEVE FALHAR COM ERRO DE PERMISSÃO NEGADA (Tentativa de Inserção não autorizada)
INSERT INTO usuario (nome, email, data_cadastro) 
VALUES ('Tentativa Invasao', 'invasao@email.com', CURRENT_DATE);

-- DEVE FALHAR COM ERRO DE PERMISSÃO NEGADA (Tentativa de Exclusão não autorizada)
DELETE FROM usuario WHERE id_usuario = 1;

-- Retornar ao usuário administrador padrão
RESET ROLE;