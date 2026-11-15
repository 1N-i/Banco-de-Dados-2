-- PostgreSQL / PLpgSQL | executar apos 01_schema e 02_seeds
-- 3 procedures, 3 functions e 3 triggers

-- PROCEDURE 1: cadastro seguro, sem concatenacao de SQL
CREATE OR REPLACE PROCEDURE sp_cadastrar_usuario(p_nome VARCHAR, p_email VARCHAR, p_data_cadastro DATE)
LANGUAGE plpgsql AS $$
BEGIN
    IF NULLIF(BTRIM(p_nome), '') IS NULL OR NULLIF(BTRIM(p_email), '') IS NULL OR p_data_cadastro IS NULL THEN
        RAISE EXCEPTION 'Nome, email e data de cadastro sao obrigatorios';
    END IF;
    INSERT INTO Usuario(nome, email, data_cadastro) VALUES (BTRIM(p_nome), BTRIM(p_email), p_data_cadastro);
END;
$$;

-- PROCEDURE 2: registra uso somente para aplicativo do usuario
CREATE OR REPLACE PROCEDURE sp_registrar_uso(p_id_usuario INT, p_id_app INT, p_data DATE, p_minutos INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM AppMonitorado WHERE id_app=p_id_app AND id_usuario=p_id_usuario) THEN
        RAISE EXCEPTION 'Aplicativo nao pertence ao usuario informado';
    END IF;
    INSERT INTO RegistroUso(id_usuario, id_app, data_registro, tempo_uso_minutos)
    VALUES (p_id_usuario, p_id_app, p_data, p_minutos);
END;
$$;

-- PROCEDURE 3: insere ou atualiza conclusao do habito na data
CREATE OR REPLACE PROCEDURE sp_atualizar_progresso(p_id_habito INT, p_data DATE, p_concluido BOOLEAN)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_data IS NULL OR p_concluido IS NULL THEN
        RAISE EXCEPTION 'Data e situacao sao obrigatorias';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM HabitoDesejado WHERE id_habito=p_id_habito) THEN
        RAISE EXCEPTION 'Habito inexistente';
    END IF;
    UPDATE ProgressoHabito SET concluido=p_concluido
    WHERE id_habito=p_id_habito AND data_registro=p_data;
    IF NOT FOUND THEN
        INSERT INTO ProgressoHabito(id_habito, data_registro, concluido)
        VALUES (p_id_habito, p_data, p_concluido);
    END IF;
END;
$$;

-- FUNCTION 1: minutos totais por usuario e data
CREATE OR REPLACE FUNCTION fn_tempo_total_usuario(p_id_usuario INT, p_data DATE)
RETURNS BIGINT LANGUAGE sql STABLE AS $$
    SELECT COALESCE(SUM(tempo_uso_minutos), 0)::BIGINT
    FROM RegistroUso WHERE id_usuario=p_id_usuario AND data_registro=p_data;
$$;

-- FUNCTION 2: informa se o usuario excedeu limite diario em minutos
CREATE OR REPLACE FUNCTION fn_excedeu_limite(p_id_usuario INT, p_data DATE, p_limite INT DEFAULT 120)
RETURNS BOOLEAN LANGUAGE plpgsql STABLE AS $$
BEGIN
    IF p_limite IS NULL OR p_limite < 0 THEN
        RAISE EXCEPTION 'Limite deve ser nao negativo';
    END IF;
    RETURN fn_tempo_total_usuario(p_id_usuario, p_data) > p_limite;
END;
$$;

-- FUNCTION 3: percentual de registros de habitos concluidos pelo usuario
CREATE OR REPLACE FUNCTION fn_percentual_habitos(p_id_usuario INT)
RETURNS NUMERIC LANGUAGE sql STABLE AS $$
    SELECT COALESCE(ROUND(100.0 * COUNT(*) FILTER (WHERE p.concluido) / NULLIF(COUNT(*),0), 2), 0)
    FROM HabitoDesejado h JOIN ProgressoHabito p ON p.id_habito=h.id_habito
    WHERE h.id_usuario=p_id_usuario;
$$;

-- TRIGGER 1: impede tempo de uso nulo ou negativo
CREATE OR REPLACE FUNCTION tg_validar_tempo() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.tempo_uso_minutos IS NULL OR NEW.tempo_uso_minutos < 0 THEN
        RAISE EXCEPTION 'Tempo de uso deve ser zero ou positivo';
    END IF;
    RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_validar_tempo ON RegistroUso;
CREATE TRIGGER trg_validar_tempo BEFORE INSERT OR UPDATE ON RegistroUso
FOR EACH ROW EXECUTE FUNCTION tg_validar_tempo();

-- TRIGGER 2: alerta quando total do usuario no dia ultrapassa 120 minutos
CREATE OR REPLACE FUNCTION tg_alertar_limite() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE v_total BIGINT;
BEGIN
    SELECT COALESCE(SUM(tempo_uso_minutos),0)::BIGINT INTO v_total FROM RegistroUso WHERE id_usuario=NEW.id_usuario AND data_registro=NEW.data_registro;
    IF v_total > 120 THEN
        RAISE NOTICE 'ALERTA: usuario % acumulou % minutos em % (limite: 120)',
            NEW.id_usuario, v_total, NEW.data_registro;
    END IF;
    RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_alertar_limite ON RegistroUso;
CREATE TRIGGER trg_alertar_limite AFTER INSERT OR UPDATE ON RegistroUso
FOR EACH ROW EXECUTE FUNCTION tg_alertar_limite();

-- TRIGGER 3: impede metas diarias nulas, zero ou negativas
CREATE OR REPLACE FUNCTION tg_validar_meta() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.meta_diaria_minutos IS NULL OR NEW.meta_diaria_minutos <= 0 THEN
        RAISE EXCEPTION 'Meta diaria deve ser maior que zero';
    END IF;
    RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_validar_meta ON HabitoDesejado;
CREATE TRIGGER trg_validar_meta BEFORE INSERT OR UPDATE ON HabitoDesejado
FOR EACH ROW EXECUTE FUNCTION tg_validar_meta();
