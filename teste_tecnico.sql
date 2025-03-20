-- Criação do banco de dados
CREATE DATABASE IF NOT EXISTS teste_tecnico;
USE teste_tecnico;

-- Criação da tabela ALUNO
CREATE TABLE ALUNO (
    CODIGO INT PRIMARY KEY,
    NOME VARCHAR(50),
    ENDERECO VARCHAR(200)
);

-- Criação da tabela MATRICULA
CREATE TABLE MATRICULA (
    CODIGO INT PRIMARY KEY,
    CODIGO_ALUNO INT,
    ANO INT,
    SEMESTRE INT,
    DT_MATRICULA DATETIME,
    FOREIGN KEY (CODIGO_ALUNO) REFERENCES ALUNO(CODIGO)
);

-- Inserção dos dados na tabela ALUNO
INSERT INTO ALUNO (CODIGO, NOME, ENDERECO) VALUES
    (1, 'Pedro', 'Rua Imperatriz, 10 – Centro'),
    (2, 'Matheus', 'Rua Inácio, 15 – Centro'),
    (3, 'João', 'Rua Agnaldo, 18 – Centro'),
    (4, 'Vinicius', 'Rua Fortaleza, 100 – Centro'),
    (5, 'Jorge', 'Rua Teodomiro, 155 – Centro');

-- Inserção dos dados na tabela MATRICULA
INSERT INTO MATRICULA (CODIGO, CODIGO_ALUNO, ANO, SEMESTRE, DT_MATRICULA) VALUES
    (1, 1, 2022, 2, '2022-05-01'),
    (2, 2, 2022, 1, '2022-01-05'),
    (3, 3, 2021, 2, '2021-06-15'),
    (4, 4, 2021, 2, '2022-05-31'),
    (5, 5, 2021, 1, '2022-04-01');

-- Criação do trigger para verificar o ano da matrícula
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

-- Criação da stored procedure para listar matrículas
DELIMITER //
CREATE PROCEDURE listar_matriculas()
BEGIN
    SELECT 
        m.CODIGO,
        a.NOME as NOME_ALUNO,
        m.ANO,
        m.SEMESTRE,
        m.DT_MATRICULA
    FROM 
        MATRICULA m
        INNER JOIN ALUNO a ON m.CODIGO_ALUNO = a.CODIGO
    ORDER BY 
        a.NOME;
END //
DELIMITER ;

-- Criação da stored procedure para cadastrar matrícula
DELIMITER //
CREATE PROCEDURE cadastrar_matricula(
    IN p_codigo INT,
    IN p_codigo_aluno INT,
    IN p_ano INT,
    IN p_semestre INT,
    IN p_data_matricula DATETIME
)
BEGIN
    INSERT INTO MATRICULA (CODIGO, CODIGO_ALUNO, ANO, SEMESTRE, DT_MATRICULA)
    VALUES (p_codigo, p_codigo_aluno, p_ano, p_semestre, p_data_matricula);
END //
DELIMITER ;

-- Script para atualizar ano e semestre para matrículas entre 30/05/2022 e 01/06/2022
UPDATE MATRICULA 
SET ANO = 2022, SEMESTRE = 2 
WHERE DT_MATRICULA > '2022-05-30' 
AND DT_MATRICULA < '2022-06-01'; 