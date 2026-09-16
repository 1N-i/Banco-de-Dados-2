# Criação das Tabelas
CREATE TABLE Usuario (
    id_usuario SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    data_cadastro DATE NOT NULL
);

CREATE TABLE HabitoDesejado (
    id_habito SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT,
    meta_diaria_minutos INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);

CREATE TABLE AppMonitorado (
    id_app SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    nome_app VARCHAR(50) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);

CREATE TABLE RegistroUso (
    id_registro SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_app INT NOT NULL,
    data_registro DATE NOT NULL,
    tempo_uso_minutos INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_app) REFERENCES AppMonitorado(id_app) ON DELETE CASCADE
);

CREATE TABLE ProgressoHabito (
    id_progresso SERIAL PRIMARY KEY,
    id_habito INT NOT NULL,
    data_registro DATE NOT NULL,
    concluido BOOLEAN NOT NULL,
    FOREIGN KEY (id_habito) REFERENCES HabitoDesejado(id_habito) ON DELETE CASCADE
);

# Consultas

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