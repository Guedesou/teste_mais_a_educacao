-- Criação do banco de dados
CREATE DATABASE IF NOT EXISTS teste_tecnico;
USE teste_tecnico;

-- Remover tabelas se existirem (para evitar erros ao executar novamente)
DROP TABLE IF EXISTS MATRICULA;
DROP TABLE IF EXISTS ALUNO;

-- 1. Criação das tabelas ALUNO e MATRICULA
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

-- 2. População das tabelas com os dados fornecidos
INSERT INTO ALUNO (CODIGO, NOME, ENDERECO) VALUES
    (1, 'Pedro', 'Rua Imperatriz, 10 - Centro'),
    (2, 'Matheus', 'Rua Inácio, 15 - Centro'),
    (3, 'João', 'Rua Agnaldo, 18 - Centro'),
    (4, 'Vinicius', 'Rua Fortaleza, 100 - Centro'),
    (5, 'Jorge', 'Rua Teodomiro, 155 - Centro');

INSERT INTO MATRICULA (CODIGO, CODIGO_ALUNO, ANO, SEMESTRE, DT_MATRICULA) VALUES
    (1, 1, 2022, 2, '2022-05-01'),
    (2, 2, 2022, 1, '2022-01-05'),
    (3, 3, 2021, 2, '2021-06-15'),
    (4, 4, 2021, 2, '2022-05-31'),
    (5, 5, 2021, 1, '2022-04-01');

-- 3. Criar a trigger (execute este comando separadamente)
DELIMITER //
DROP TRIGGER IF EXISTS TR_VERIFICA_ANO;

CREATE TRIGGER TR_VERIFICA_ANO
BEFORE INSERT ON MATRICULA
FOR EACH ROW
BEGIN
    IF NEW.ANO < 2022 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Não é possível cadastrar matrículas anteriores ao ano de 2022';
    END IF;
END //
DELIMITER ;

-- 4. Script para atualizar matrículas específicas
UPDATE MATRICULA
SET 
    ANO = 2022, 
    SEMESTRE = 2
WHERE 
    DT_MATRICULA > '2022-05-30' 
    AND DT_MATRICULA < '2022-06-01';

-- 5. Procedure para atualizar nome do aluno (execute este comando separadamente)
DELIMITER //
DROP PROCEDURE IF EXISTS SP_ATUALIZA_NOME_ALUNO;

CREATE PROCEDURE SP_ATUALIZA_NOME_ALUNO(
    IN p_CODIGO INT,
    IN p_NOME VARCHAR(50)
)
BEGIN
    UPDATE ALUNO
    SET NOME = p_NOME
    WHERE CODIGO = p_CODIGO;
END //
DELIMITER ;

-- 6. Execução da procedure para alterar Matheus para Felipe
SET @Cod_Matheus = (SELECT CODIGO FROM ALUNO WHERE NOME = 'Matheus');
CALL SP_ATUALIZA_NOME_ALUNO(@Cod_Matheus, 'Felipe');

-- 7. Script de consulta ordenada por Nome
SELECT 
    a.CODIGO as 'Código do Aluno',
    a.NOME as 'Nome',
    m.ANO as 'Ano',
    m.SEMESTRE as 'Semestre'
FROM 
    ALUNO a
    INNER JOIN MATRICULA m ON a.CODIGO = m.CODIGO_ALUNO
ORDER BY 
    a.NOME;
