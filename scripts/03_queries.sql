-- Consulta Simples 1
SELECT id_usuario, nome, email, data_cadastro
FROM Usuario
WHERE data_cadastro BETWEEN '2026-08-01' AND '2026-08-15'
ORDER BY data_cadastro ASC;

-- Consulta Simples 2
SELECT id_habito, id_usuario, titulo, meta_diaria_minutos
FROM HabitoDesejado
WHERE meta_diaria_minutos >= 45
ORDER BY meta_diaria_minutos DESC;

-- Consulta Simples 3
SELECT id_app, id_usuario, nome_app, categoria
FROM AppMonitorado
WHERE categoria = 'Redes Sociais'
ORDER BY nome_app ASC;

-- Consulta Simples 4
SELECT id_registro, id_usuario, id_app, data_registro, tempo_uso_minutos
FROM RegistroUso
WHERE tempo_uso_minutos > 120
ORDER BY tempo_uso_minutos DESC;

-- Consulta Simples 5
SELECT id_habito, titulo, descricao, meta_diaria_minutos
FROM HabitoDesejado
WHERE titulo ILIKE '%Estudo%' OR descricao ILIKE '%Estudo%'
ORDER BY titulo ASC;


-- Consulta JOIN 1: Tempo total acumulado por aplicativo por usuário
SELECT 
    u.nome AS usuario,
    a.nome_app,
    a.categoria,
    SUM(r.tempo_uso_minutos) AS tempo_total_minutos
FROM Usuario u
JOIN AppMonitorado a ON u.id_usuario = a.id_usuario
JOIN RegistroUso r ON u.id_usuario = r.id_usuario AND a.id_app = r.id_app
GROUP BY u.nome, a.nome_app, a.categoria
ORDER BY tempo_total_minutos DESC;

-- Consulta JOIN 2: Média e total de minutos gastos por categoria de aplicativo (filtrando categorias com mais de 300 min acumulados)
SELECT 
    a.categoria,
    COUNT(r.id_registro) AS qtd_sessoes,
    SUM(r.tempo_uso_minutos) AS total_minutos,
    ROUND(AVG(r.tempo_uso_minutos), 2) AS media_minutos_por_sessao
FROM AppMonitorado a
JOIN RegistroUso r ON a.id_app = r.id_app
GROUP BY a.categoria
HAVING SUM(r.tempo_uso_minutos) > 300
ORDER BY total_minutos DESC;

-- Consulta JOIN 3: Quantidade de hábitos concluídos vs. não concluídos por usuário
SELECT 
    u.nome AS usuario,
    h.titulo AS habito,
    COUNT(p.id_progresso) AS total_registros,
    COUNT(*) FILTER (WHERE p.concluido = TRUE) AS dias_concluidos,
    COUNT(*) FILTER (WHERE p.concluido = FALSE) AS dias_nao_concluidos
FROM Usuario u
JOIN HabitoDesejado h ON u.id_usuario = h.id_usuario
JOIN ProgressoHabito p ON h.id_habito = p.id_habito
GROUP BY u.nome, h.titulo
ORDER BY dias_concluidos DESC, u.nome ASC;


-- Subconsulta 1 (Operador de Comparação >)
SELECT 
    r.id_registro,
    u.nome,
    r.data_registro,
    r.tempo_uso_minutos
FROM RegistroUso r
JOIN Usuario u ON r.id_usuario = u.id_usuario
WHERE r.tempo_uso_minutos > (
    SELECT AVG(tempo_uso_minutos) 
    FROM RegistroUso
)
ORDER BY r.tempo_uso_minutos DESC;

-- Subconsulta 2 (Operador IN)
SELECT id_usuario, nome, email
FROM Usuario
WHERE id_usuario IN (
    SELECT DISTINCT id_usuario
    FROM AppMonitorado
    WHERE categoria IN ('Jogos', 'Streaming')
)
ORDER BY nome ASC;

-- Subconsulta 3 (Operador EXISTS):
SELECT h.id_habito, h.titulo, h.meta_diaria_minutos
FROM HabitoDesejado h
WHERE EXISTS (
    SELECT 1
    FROM ProgressoHabito p
    WHERE p.id_habito = h.id_habito
      AND p.concluido = TRUE
)
ORDER BY h.id_habito ASC;
