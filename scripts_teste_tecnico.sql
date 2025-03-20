-- 1. Criação das tabelas
CREATE DATABASE IF NOT EXISTS teste_tecnico;
USE teste_tecnico;

-- Removendo objetos existentes
DROP PROCEDURE IF EXISTS listar_matriculas;
DROP TRIGGER IF EXISTS verificar_ano_matricula;
DROP TABLE IF EXISTS MATRICULA;
DROP TABLE IF EXISTS ALUNO;

CREATE TABLE ALUNO (
    CODIGO INT PRIMARY KEY,
    NOME VARCHAR(50),
    ENDERECO VARCHAR(200)
);

CREATE TABLE MATRICULA (
    CODIGO INT PRIMARY KEY,
    CODIGO_ALUNO INT,
    ANO INT,
    SEMESTRE INT,
    DT_MATRICULA DATETIME,
    FOREIGN KEY (CODIGO_ALUNO) REFERENCES ALUNO(CODIGO)
);

-- 2. Inserção dos dados nas tabelas
INSERT INTO ALUNO (CODIGO, NOME, ENDERECO) VALUES
    (1, 'Pedro', 'Rua Imperatriz, 10 – Centro'),
    (2, 'Matheus', 'Rua Inácio, 15 – Centro'),
    (3, 'João', 'Rua Agnaldo, 18 – Centro'),
    (4, 'Vinicius', 'Rua Fortaleza, 100 – Centro'),
    (5, 'Jorge', 'Rua Teodomiro, 155 – Centro');

INSERT INTO MATRICULA (CODIGO, CODIGO_ALUNO, ANO, SEMESTRE, DT_MATRICULA) VALUES
    (1, 1, 2022, 2, '2022-05-01'),
    (2, 2, 2022, 1, '2022-01-05'),
    (3, 3, 2021, 2, '2021-06-15'),
    (4, 4, 2021, 2, '2022-05-31'),
    (5, 5, 2021, 1, '2022-04-01');

-- 3. Criação do trigger para validar o ano da matrícula
DELIMITER //
CREATE TRIGGER verificar_ano_matricula
BEFORE INSERT ON MATRICULA
FOR EACH ROW
BEGIN
    IF NEW.ANO < 2022 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível cadastrar matrículas anteriores ao ano de 2022';
    END IF;
END //
DELIMITER ;

-- 4. Criação da stored procedure para listar matrículas
DELIMITER //
CREATE PROCEDURE listar_matriculas()
BEGIN
    SELECT 
        m.CODIGO_ALUNO,
        a.NOME,
        m.ANO,
        m.SEMESTRE,
        m.DT_MATRICULA
    FROM 
        MATRICULA m
        INNER JOIN ALUNO a ON m.CODIGO_ALUNO = a.CODIGO
    ORDER BY 
        m.ANO DESC, m.SEMESTRE DESC;
END //
DELIMITER ;

-- 5. Script para atualizar ano e semestre
UPDATE MATRICULA 
SET ANO = 2022, SEMESTRE = 2 
WHERE DT_MATRICULA BETWEEN '2022-05-30' AND '2022-06-01';

-- 6. Teste do trigger (tentativa de inserir matrícula com ano < 2022)
-- Este comando deve falhar devido ao trigger
INSERT INTO MATRICULA (CODIGO, CODIGO_ALUNO, ANO, SEMESTRE, DT_MATRICULA)
VALUES (6, 1, 2021, 1, '2021-01-01');

-- 7. Teste da stored procedure
CALL listar_matriculas(); 