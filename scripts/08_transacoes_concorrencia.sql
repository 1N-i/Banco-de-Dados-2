-- PARTE 1: BLOCOS DE TRANSAÇÕES ACID COM BEGIN, COMMIT E ROLLBACK

-- Transação 1: Caso de Sucesso (COMMIT)
-- Registra um novo uso de aplicativo e atualiza o progresso do hábito de forma atômica
BEGIN TRANSACTION;

-- 1. Insere registro de uso de app
INSERT INTO RegistroUso (id_usuario, id_app, data_registro, tempo_uso_minutos)
VALUES (1, 1, CURRENT_DATE, 45);

-- 2. Insere a conclusão do hábito correspondente
INSERT INTO ProgressoHabito (id_habito, data_registro, concluido)
VALUES (1, CURRENT_DATE, TRUE);

COMMIT;


-- Transação 2: Caso de Erro (ROLLBACK)
-- Tenta registrar uso, mas simula uma falha de validação da regra de negócio
BEGIN TRANSACTION;

-- 1. Inserção válida temporária
INSERT INTO RegistroUso (id_usuario, id_app, data_registro, tempo_uso_minutos)
VALUES (1, 1, CURRENT_DATE, 30);

-- 2. Simulação de falha: O ROLLBACK desfaz a inserção acima mantendo o banco integro
ROLLBACK;


-- PARTE 2: TESTE DE NÍVEIS DE ISOLAMENTO E BLOQUEIOS (CONCORRÊNCIA)

-- CENÁRIO A: READ COMMITTED (Garante que alterações não commitadas não ocorram)
-- ABA 1 (Sessão A):
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
UPDATE RegistroUso SET tempo_uso_minutos = 999 WHERE id_registro = 1;
-- Manter a transação aberta sem dar COMMIT

-- ABA 2 (Sessão B - Ocorre em outro terminal):
SELECT tempo_uso_minutos FROM RegistroUso WHERE id_registro = 1;
-- Resultado na ABA 2: Lê o valor antigo (45), pois o 999 ainda não foi commitado.

-- ABA 1 (Sessão A):
ROLLBACK; -- Cancela o teste sem alterar a base


-- CENÁRIO B: SERIALIZABLE + SELECT FOR UPDATE (Bloqueio Pessimista de Linha)
-- ABA 1 (Sessão A):
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- Bloqueia a linha 1 explicitamente para atualização
SELECT * FROM RegistroUso WHERE id_registro = 1 FOR UPDATE;

-- ABA 2 (Sessão B - Ocorre em outro terminal):
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE RegistroUso SET tempo_uso_minutos = 120 WHERE id_registro = 1;
-- Resultado na ABA 2: A query fica aguardando a Sessão A terminar.

-- ABA 1 (Sessão A):
COMMIT; -- Desbloqueia o registo e permite que a Sessão B finalize.

-- ABA 2 (Sessão B):
COMMIT;