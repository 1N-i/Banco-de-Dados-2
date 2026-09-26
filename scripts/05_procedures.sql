-- Arquivo: 05_procedures.sql
-- Descrição: Procedures para regras de negócio e proteção contra SQLi

-- Procedure para cadastrar usuário com segurança (Filtra injeção SQL)
CREATE OR REPLACE PROCEDURE sp_cadastrar_usuario(
    p_nome VARCHAR,
    p_email VARCHAR,
    p_data_cadastro DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Usuario (nome, email, data_cadastro)
    VALUES (p_nome, p_email, p_data_cadastro);
END;
$$;