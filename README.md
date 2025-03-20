# <h1 align="center">🎓 Mini-Sistema De Alunos Grupo +A</h1>

<p align="center">
  <a href="#-tecnologias">Tecnologias</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#-projeto">Projeto</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#-funcionalidades">Funcionalidades</a>
</p>

## 🚀 Tecnologias

Este projeto foi desenvolvido com as seguintes tecnologias:

- HTML
- CSS
- JavaScript
- PHP
- MySQL
- Stored Procedures
- Triggers

## 💻 Projeto

O Mini-Sistema de Alunos é uma aplicação web desenvolvida como parte de um teste técnico. O sistema permite o gerenciamento de matrículas de alunos, com funcionalidades de cadastro, listagem e exclusão de registros.

## ✨ Funcionalidades

- **Cadastro de Matrículas**: Interface para registrar novas matrículas com validação de ano (>= 2022)
- **Listagem de Matrículas**: Exibição de todas as matrículas ordenadas por nome do aluno
- **Detalhes do Aluno**: Visualização de informações detalhadas de cada aluno
- **Exclusão de Matrícula**: Possibilidade de remover matrículas do sistema
- **Validações**: 
  - Trigger que impede cadastro de matrículas anteriores a 2022
  - Verificação de existência do aluno antes do cadastro
  - Formatação de dados e validações no frontend

## 🎲 Banco de Dados

O sistema utiliza um banco de dados MySQL com:
- Tabela `ALUNO`: Armazena informações dos alunos
- Tabela `MATRICULA`: Registra as matrículas dos alunos
- Stored Procedures para operações principais
- Trigger para validação de regras de negócio

## 🔧 Instalação

1. Clone o repositório
```bash
git clone https://github.com/Guedesou/teste_mais_a_educacao.git
```

2. Configure o banco de dados MySQL
```sql
source teste_tecnico.sql
```

3. Configure o arquivo de conexão (`conexao.php`) com suas credenciais

4. Inicie o servidor PHP
```bash
php -S localhost:8000
```

5. Acesse o sistema em `http://localhost:8000`

## 👨‍💻 Autor

- [@Guedesou](https://github.com/Guedesou) 