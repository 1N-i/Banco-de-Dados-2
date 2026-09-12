# Banco de Dados 2
## 📌 Requisitos do Sistema

### 🛠 Requisitos Funcionais (RF)
Descrevem as funcionalidades e ações que o aplicativo deve executar:

* **RF1 - Gerenciamento de Usuários:** O sistema deve permitir o cadastro, autenticação (login) e atualização de perfil dos usuários.
* **RF2 - Gerenciamento de Hábitos:** O usuário deve conseguir cadastrar, editar, listar e excluir hábitos que deseja cultivar (ex: leitura, exercícios, meditação), definindo metas de tempo ou frequência diária/semanal.
* **RF3 - Cadastro de Aplicativos e Atividades Monitoradas:** O sistema deve permitir o cadastro de aplicativos ou categorias de distrações (ex: Redes Sociais, Jogos, Streaming) com a estipulação de um limite máximo diário de tempo de uso.
* **RF4 - Registro de Tempo de Uso:** O sistema deve registrar os logs de uso (início, fim e duração) de cada aplicativo ou atividade monitorada por usuário.
* **RF5 - Regra de Equivalência de Tempo:** O sistema deve calcular a conversão comparativa do tempo gasto em distrações em relação a hábitos produtivos (ex: *2 horas no TikTok equivalem a ler 40 páginas de um livro*).
* **RF6 - Alertas e Notificações de Estouro de Limite:** O sistema deve disparar um alerta ou notificação automática (via *Trigger* no banco) sempre que o usuário atingir ou ultrapassar 100% do tempo limite diário estipulado para uma categoria/app.
* **RF7 - Relatórios de Produtividade e Desperdício:** O sistema deve gerar relatórios consolidados do histórico de tempo gasto por período (dia, semana e mês), comparando o tempo desperdiçado VS metas de hábitos cumpridas.

---

### 📐 Requisitos Não Funcionais (RNF)
Descrevem as restrições técnicas, arquitetura, qualidade e critérios do ambiente de banco de dados:

* **RNF1 - Modelo Relacional:** A base de dados principal deve ser relacional (SGBD SQL como PostgreSQL/MySQL/Oracle) contendo no mínimo **5 tabelas** normalizadas no Modelo Lógico.
* **RNF2 - Automação Procedural:** O banco de dados deve utilizar programação procedural (mínimo de 3 *Procedures*, 3 *Functions* e 3 *Triggers*) para garantir a execução eficiente de regras de negócio complexas e auditoria diretamente no SGBD.
* **RNF3 - Controle de Concorrência e Transações (ACID):** O banco de dados deve garantir atomicidade e consistência no registro simultâneo de múltiplos logs de tempo de uso através de transações seguras.
* **RNF4 - Segurança e Controle de Acesso:** O acesso ao banco de dados deve ser restrito através de papéis (*roles*), perfis e privilégios específicos de usuários, garantindo a proteção contra injeção de código (SQL Injection) e mascaramento de senhas.
* **RNF5 - Desempenho e Indexação:** O tempo de resposta para consultas de histórico e relatórios de uso deve ser otimizado através da criação e análise de Índices e planos de execução (`EXPLAIN`), mantendo resposta abaixo de 2 segundos.
* **RNF6 - Integração NoSQL:** O sistema deve utilizar uma base não relacional (ex: MongoDB) para o armazenamento e ingestão de grandes volumes de logs brutos não estruturados/semiestruturados de tempo de uso enviados pelo aplicativo.
* **RNF7 - Suporte à Tomada de Decisão (Data Warehouse/ETL):** O sistema deve possuir uma estrutura dimensional de Data Warehouse e processo de ETL para alimentar relatórios e *dashboards* analíticos de acompanhamento de hábitos.
* **RNF8 - Versionamento e Documentação:** Todo o código SQL, DDL, DML, scripts procedurais e documentação de modelagem devem estar versionados e organizados no repositório GitHub do projeto.
