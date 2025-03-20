<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

// Habilitar exibição de erros para debug
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$host = 'localhost';
$user = 'root';
$pass = 'Sr@d750r';
$dbname = 'teste_tecnico';

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $user, $pass);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode(['erro' => 'Erro na conexão com o banco de dados: ' . $e->getMessage()]);
    exit;
}

// Verifica se é uma requisição para listar alunos
if (isset($_GET['listar_alunos'])) {
    try {
        $stmt = $conn->query("SELECT CODIGO, NOME FROM ALUNO ORDER BY CODIGO");
        $alunos = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($alunos);
        exit;
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['erro' => 'Erro ao listar alunos: ' . $e->getMessage()]);
        exit;
    }
}

// Se for uma requisição POST, é para cadastrar matrícula
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $dados = json_decode(file_get_contents('php://input'), true);
    
    try {
        // Primeiro verifica se o aluno existe
        $stmt = $conn->prepare("SELECT COUNT(*) FROM ALUNO WHERE CODIGO = ?");
        $stmt->execute([$dados['codigoAluno']]);
        $alunoExiste = $stmt->fetchColumn() > 0;

        if (!$alunoExiste) {
            throw new Exception("O código do aluno informado não existe.");
        }

        // Depois tenta cadastrar a matrícula
        $stmt = $conn->prepare("CALL cadastrar_matricula(?, ?, ?, ?, ?)");
        $stmt->execute([
            $dados['codigo'],
            $dados['codigoAluno'],
            $dados['ano'],
            $dados['semestre'],
            $dados['dataMatricula']
        ]);
        echo json_encode(['mensagem' => 'Matrícula cadastrada com sucesso']);
    } catch(Exception $e) {
        http_response_code(500);
        echo json_encode(['erro' => 'Erro ao cadastrar matrícula: ' . $e->getMessage()]);
    }
    exit;
}

$acao = $_GET['acao'] ?? '';

switch($acao) {
    case 'listar_matriculas':
        try {
            // Consulta direta em vez de stored procedure
            $stmt = $conn->query("
                SELECT 
                    m.CODIGO_ALUNO,
                    a.NOME,
                    m.ANO,
                    m.SEMESTRE
                FROM MATRICULA m
                INNER JOIN ALUNO a ON m.CODIGO_ALUNO = a.CODIGO
                ORDER BY a.NOME
            ");
            $matriculas = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($matriculas);
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(['erro' => 'Erro ao listar matrículas: ' . $e->getMessage()]);
        }
        break;

    case 'excluir_matricula':
        $codigo = $_GET['codigo'] ?? '';
        if (!$codigo) {
            http_response_code(400);
            echo json_encode(['erro' => 'Código do aluno não fornecido']);
            break;
        }

        try {
            // Primeiro, verificamos se a matrícula existe
            $stmt = $conn->prepare("SELECT COUNT(*) FROM MATRICULA WHERE CODIGO_ALUNO = ?");
            $stmt->execute([$codigo]);
            $existe = $stmt->fetchColumn() > 0;

            if (!$existe) {
                http_response_code(404);
                echo json_encode(['erro' => 'Matrícula não encontrada']);
                break;
            }

            // Se existe, excluímos a matrícula
            $stmt = $conn->prepare("DELETE FROM MATRICULA WHERE CODIGO_ALUNO = ?");
            $stmt->execute([$codigo]);
            
            echo json_encode(['mensagem' => 'Matrícula excluída com sucesso']);
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(['erro' => 'Erro ao excluir matrícula: ' . $e->getMessage()]);
        }
        break;

    case 'buscar_aluno':
        $codigo = $_GET['codigo'] ?? '';
        if (!$codigo) {
            http_response_code(400);
            echo json_encode(['erro' => 'Código do aluno não fornecido']);
            break;
        }

        try {
            $stmt = $conn->prepare("SELECT * FROM ALUNO WHERE CODIGO = ?");
            $stmt->execute([$codigo]);
            $aluno = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($aluno) {
                echo json_encode($aluno);
            } else {
                http_response_code(404);
                echo json_encode(['erro' => 'Aluno não encontrado']);
            }
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(['erro' => 'Erro ao buscar aluno: ' . $e->getMessage()]);
        }
        break;

    default:
        if (!isset($_GET['listar_alunos'])) {
            http_response_code(400);
            echo json_encode(['erro' => 'Ação não especificada']);
        }
        break;
}
?> 