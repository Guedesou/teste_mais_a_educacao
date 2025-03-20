// Função para verificar se o ano é válido (trigger)
function verificarAno(ano) {
    if (ano < 2022) {
        alert('ATENÇÃO: Conforme regra do sistema, não é possível cadastrar matrículas com ano anterior a 2022.\n\nPor favor, utilize um ano igual ou superior a 2022.');
        return false;
    }
    return true;
}

// Variável global para armazenar o código do aluno atual
let codigoAlunoAtual = null;

document.addEventListener('DOMContentLoaded', function() {
    carregarAlunos();
    carregarMatriculas();

    // Configurar data atual como padrão
    document.getElementById('dataMatricula').value = new Date().toISOString().split('T')[0];

    // Fechar modal quando clicar no X
    const closeBtn = document.querySelector('.close');
    if (closeBtn) {
        closeBtn.addEventListener('click', function() {
            document.getElementById('modalDetalhes').style.display = 'none';
        });
    }

    // Fechar modal quando clicar fora dele
    window.addEventListener('click', function(event) {
        const modal = document.getElementById('modalDetalhes');
        if (event.target === modal) {
            modal.style.display = 'none';
        }
    });

    // Configurar o formulário de cadastro
    const form = document.getElementById('matriculaForm');
    if (form) {
        form.addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const dados = {
                codigo: document.getElementById('codigo').value,
                codigoAluno: document.getElementById('codigoAluno').value,
                ano: document.getElementById('ano').value,
                semestre: document.getElementById('semestre').value,
                dataMatricula: document.getElementById('dataMatricula').value
            };

            try {
                const response = await fetch('conexao.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(dados)
                });

                if (!response.ok) {
                    const errorData = await response.json();
                    throw new Error(errorData.erro || 'Erro ao cadastrar matrícula');
                }

                const data = await response.json();
                alert(data.mensagem || 'Matrícula cadastrada com sucesso');
                form.reset();
                document.getElementById('dataMatricula').value = new Date().toISOString().split('T')[0];
                carregarMatriculas();
            } catch (erro) {
                console.error('Erro ao cadastrar matrícula:', erro);
                alert('Erro ao cadastrar matrícula: ' + erro.message);
            }
        });
    }
});

async function carregarAlunos() {
    try {
        const response = await fetch('conexao.php?listar_alunos=1');
        if (!response.ok) {
            throw new Error('Erro ao carregar lista de alunos');
        }
        
        const alunos = await response.json();
        const select = document.getElementById('codigoAluno');
        
        if (select) {
            select.innerHTML = '<option value="">Selecione um aluno</option>';
            alunos.forEach(aluno => {
                const option = document.createElement('option');
                option.value = aluno.CODIGO;
                option.textContent = `${aluno.CODIGO} - ${aluno.NOME}`;
                select.appendChild(option);
            });
        }
    } catch (erro) {
        console.error('Erro ao carregar alunos:', erro);
        alert('Erro ao carregar lista de alunos');
    }
}

async function carregarMatriculas() {
    try {
        const response = await fetch('conexao.php?acao=listar_matriculas');
        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.erro || 'Erro ao carregar matrículas');
        }
        
        const data = await response.json();
        const tbody = document.getElementById('matriculasBody');
        tbody.innerHTML = '';
        
        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" style="text-align: center;">Nenhuma matrícula encontrada</td></tr>';
            return;
        }
        
        data.forEach(matricula => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${matricula.CODIGO_ALUNO}</td>
                <td>${matricula.NOME}</td>
                <td>${matricula.ANO}</td>
                <td>${matricula.SEMESTRE}</td>
                <td>
                    <button class="btn-detalhes" onclick="mostrarDetalhes(${matricula.CODIGO_ALUNO})">
                        Ver Detalhes
                    </button>
                </td>
            `;
            tbody.appendChild(tr);
        });
    } catch (erro) {
        console.error('Erro ao carregar matrículas:', erro);
        document.getElementById('matriculasBody').innerHTML = 
            '<tr><td colspan="5" style="text-align: center; color: red;">Erro ao carregar matrículas. Por favor, tente novamente.</td></tr>';
    }
}

async function mostrarDetalhes(codigoAluno) {
    try {
        codigoAlunoAtual = codigoAluno;
        const response = await fetch(`conexao.php?acao=buscar_aluno&codigo=${codigoAluno}`);
        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.erro || 'Erro ao buscar detalhes do aluno');
        }
        
        const aluno = await response.json();
        document.getElementById('alunoCodigo').textContent = aluno.CODIGO;
        document.getElementById('alunoNome').textContent = aluno.NOME;
        document.getElementById('alunoEndereco').textContent = aluno.ENDERECO;
        document.getElementById('modalDetalhes').style.display = 'block';
    } catch (erro) {
        console.error('Erro ao buscar detalhes do aluno:', erro);
        alert('Erro ao carregar os detalhes do aluno. Por favor, tente novamente.');
    }
}

async function excluirMatricula() {
    if (!codigoAlunoAtual) {
        alert('Erro: Código do aluno não encontrado');
        return;
    }

    if (!confirm('Tem certeza que deseja excluir esta matrícula?')) {
        return;
    }

    try {
        const response = await fetch(`conexao.php?acao=excluir_matricula&codigo=${codigoAlunoAtual}`);
        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.erro || 'Erro ao excluir matrícula');
        }
        
        const data = await response.json();
        alert(data.mensagem || 'Matrícula excluída com sucesso');
        document.getElementById('modalDetalhes').style.display = 'none';
        carregarMatriculas(); // Recarrega a lista
    } catch (erro) {
        console.error('Erro ao excluir matrícula:', erro);
        alert('Erro ao excluir a matrícula. Por favor, tente novamente.');
    }
} 