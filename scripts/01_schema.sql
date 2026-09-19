-- Criação das Tabelas
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