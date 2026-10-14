import concurrent.futures
from datetime import date
import psycopg2

# Configuração de conexão utilizando as credenciais da aplicação (role_app)[cite: 8]
DB_CONFIG = {
    "dbname": "banco_dados_2",
    "user": "user_backend",
    "password": "SenhaForteApp456!",
    "host": "localhost",
    "port": "5432"
}

def simular_insercao_concorrente(thread_id):
    """Simula uma transação simultânea inserindo registros de uso de aplicativo."""
    conexao = None
    try:
        conexao = psycopg2.connect(**DB_CONFIG)
        cursor = conexao.cursor()
        
        # Executa inserção simultânea mapeada no schema relacional[cite: 5]
        cursor.execute(
            """
            INSERT INTO RegistroUso (id_usuario, id_app, data_registro, tempo_uso_minutos) 
            VALUES (%s, %s, %s, %s);
            """,
            (1, 1, date.today(), 20 + thread_id)
        )
        conexao.commit()
        print(f"[Thread {thread_id}] Sucesso: Inserção simultânea executada e commitada.")
        
        cursor.close()
    except Exception as e:
        if conexao:
            conexao.rollback()
        print(f"[Thread {thread_id}] Conflito/Erro de concorrência capturado: {e}")
    finally:
        if conexao:
            conexao.close()

if __name__ == "__main__":
    print("=== INICIANDO SIMULAÇÃO MULTITHREAD DE CONCORRÊNCIA ===")
    
    # Dispara 5 threads concorrentes simulando acessos simultâneos ao SGBD
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        executor.map(simular_insercao_concorrente, range(1, 6))
        
    print("=== SIMULAÇÃO CONCLUÍDA ===")