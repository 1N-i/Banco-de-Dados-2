-- Consulta 1: Tempo total acumulado por aplicativo por usuário
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

-- Consulta 2: Registros de uso acima da média geral de tempo
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