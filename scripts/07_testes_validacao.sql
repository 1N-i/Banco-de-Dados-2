-- Testes de sucesso: executar apos 06_programacao_procedural.sql
-- BEGIN/ROLLBACK impedem alteracoes permanentes nos dados de teste
BEGIN;
CALL sp_cadastrar_usuario('Usuario Teste Procedural', 'teste.procedural@example.com', CURRENT_DATE);
-- Utiliza usuario/app existentes nos seeds (id 1)
CALL sp_registrar_uso(1, 1, DATE '2026-10-09', 130);
CALL sp_atualizar_progresso(1, DATE '2026-10-09', TRUE);
SELECT fn_tempo_total_usuario(1, DATE '2026-10-09') AS total_esperado_130;
SELECT fn_excedeu_limite(1, DATE '2026-10-09', 120) AS excedeu_esperado_true;
SELECT fn_percentual_habitos(1) AS percentual_conclusao;
SELECT COUNT(*) AS usuario_criado_esperado_1 FROM Usuario WHERE email='teste.procedural@example.com';
SELECT concluido AS progresso_esperado_true FROM ProgressoHabito WHERE id_habito=1 AND data_registro=DATE '2026-10-09';
ROLLBACK;

-- Testes de erro: cada bloco captura a excecao esperada e continua
DO $$
BEGIN
    BEGIN
        INSERT INTO RegistroUso(id_usuario,id_app,data_registro,tempo_uso_minutos) VALUES(1,1,CURRENT_DATE,-1);
        RAISE EXCEPTION USING ERRCODE='ZX001', MESSAGE='FALHA: tempo negativo foi aceito';
    EXCEPTION WHEN SQLSTATE 'P0001' THEN
        RAISE NOTICE 'OK: tempo negativo recusado pelo trigger';
    WHEN SQLSTATE 'ZX001' THEN
        RAISE EXCEPTION 'FALHA: operacao invalida foi aceita';
    END;
    BEGIN
        INSERT INTO HabitoDesejado(id_usuario,titulo,meta_diaria_minutos) VALUES(1,'Meta invalida',0);
        RAISE EXCEPTION USING ERRCODE='ZX001', MESSAGE='FALHA: meta zero foi aceita';
    EXCEPTION WHEN SQLSTATE 'P0001' THEN
        RAISE NOTICE 'OK: meta zero recusada pelo trigger';
    WHEN SQLSTATE 'ZX001' THEN
        RAISE EXCEPTION 'FALHA: operacao invalida foi aceita';
    END;
    BEGIN
        CALL sp_registrar_uso(2,1,CURRENT_DATE,10);
        RAISE EXCEPTION USING ERRCODE='ZX001', MESSAGE='FALHA: aplicativo de outro usuario foi aceito';
    EXCEPTION WHEN SQLSTATE 'P0001' THEN
        RAISE NOTICE 'OK: vinculo usuario/aplicativo validado';
    WHEN SQLSTATE 'ZX001' THEN
        RAISE EXCEPTION 'FALHA: operacao invalida foi aceita';
    END;
END;
$$;
