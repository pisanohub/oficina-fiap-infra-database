# Infraestrutura de Banco de Dados — Oficina FIAP (Fase 3)

## Descrição

Este repositório provisiona, via Terraform, o banco de dados gerenciado (Amazon RDS PostgreSQL) utilizado pela aplicação principal do Tech Challenge Fase 3.

## Tecnologias utilizadas

- Terraform (>= 1.5)
- Amazon RDS (PostgreSQL 16)
- GitHub Actions (CI/CD)
- Backend remoto S3 para o state do Terraform

## Arquitetura

```mermaid
flowchart LR
    subgraph aws["AWS - VPC padrao"]
        sg["Security Group
porta 5432 liberada so
para o CIDR da VPC"]
        subnetgroup["DB Subnet Group
2 subnets, 2 AZs"]
        rds[("RDS PostgreSQL 16
privado, sem acesso publico")]
        sg --> rds
        subnetgroup --> rds
    end
    app["Aplicacao principal / Lambda
dentro da VPC"] -->|JDBC :5432| rds
```

A justificativa completa da escolha do PostgreSQL/RDS (incluindo alternativas consideradas) está no [ADR-002](https://github.com/pisanohub/oficina_fiap/blob/main/documentacao/decisoes/ADR-002-postgresql-rds.md), no repositório `oficina_fiap`.

## Diagrama Entidade-Relacionamento (DER)

```mermaid
erDiagram
    CLIENTE ||--o{ VEICULO : possui
    VEICULO ||--o{ ORDEM_DE_SERVICO : gera
    SERVICO ||--o{ ORDEM_DE_SERVICO : "e associado a"
    ORDEM_DE_SERVICO ||--o{ ITEM_OS : contem
    SERVICO ||--o{ ITEM_OS : referencia
    ITEM_ESTOQUE ||--o{ ITEM_OS : "e consumido em"

    CLIENTE {
        bigint id PK
        varchar nome
        varchar cpf_cnpj UK
        varchar email
        varchar telefone
        text endereco
        boolean ativo
    }
    VEICULO {
        bigint id PK
        varchar placa UK
        varchar marca
        varchar modelo
        int ano
        bigint cliente_id FK
    }
    ORDEM_DE_SERVICO {
        bigint id PK
        varchar numero UK
        bigint veiculo_id FK
        bigint servico_id FK
        varchar status
        timestamp data_abertura
        timestamp data_fechamento
        text descricao_problema
        decimal valor_total
    }
    SERVICO {
        bigint id PK
        varchar nome UK
        text descricao
        decimal preco
        int tempo_estimado_minutos
        boolean ativo
    }
    ITEM_OS {
        bigint id PK
        bigint ordem_servico_id FK
        bigint servico_id FK
        bigint item_estoque_id FK
        int quantidade
        decimal preco_unitario
        decimal subtotal
    }
    ITEM_ESTOQUE {
        bigint id PK
        varchar nome
        int quantidade_estoque
        decimal preco_unitario
        varchar tipo
        boolean ativo
    }
    USUARIO {
        bigint id PK
        varchar username UK
        varchar cpf UK
        varchar password
    }
```

### Explicação dos relacionamentos

- **Cliente → Veículo (1:N)**: um cliente pode ter vários veículos cadastrados; cada veículo pertence a um único cliente.
- **Veículo → Ordem de Serviço (1:N)**: cada ordem de serviço é aberta para um veículo específico; um veículo pode ter várias ordens ao longo do tempo.
- **Serviço → Ordem de Serviço (1:N, opcional)**: uma ordem de serviço pode estar associada a um serviço principal (campo opcional, preenchido quando o diagnóstico já identifica o tipo de serviço).
- **Ordem de Serviço → Item OS (1:N)**: cada ordem de serviço é composta por vários itens (mão de obra e/ou peças).
- **Serviço → Item OS (1:N)** e **Item de Estoque → Item OS (1:N)**: cada item de uma ordem de serviço referencia o serviço executado e, quando aplicável, a peça retirada do estoque.
- **Usuário**: tabela independente, sem relacionamento com as demais — armazena as credenciais dos funcionários (autenticação administrativa via login/senha), separada do cadastro de clientes (que se autenticam por CPF via Lambda).

## Passos para execução e deploy

### Pré-requisitos

- Conta AWS Academy Learner Lab ativa
- Terraform >= 1.5

### Execução local

```bash
terraform init
terraform plan
terraform apply
```

Variável necessária: `db_password` (via `TF_VAR_db_password`, sensível — nunca commitada).

### CI/CD

O pipeline (`.github/workflows/terraform.yml`) roda automaticamente:

- `terraform plan` em todo push/PR para a `main`
- `terraform apply` automático após merge na `main`
- Pode também ser disparado manualmente via `workflow_dispatch`
- Exibe o endpoint do banco (`terraform output`) diretamente no log do pipeline

A branch `main` é protegida: exige Pull Request e o check `terraform` com sucesso antes de qualquer merge.

## Observações

- O RDS **não** é encerrado automaticamente entre sessões do AWS Academy (diferente do cluster Kubernetes) — mas ainda depende de uma sessão ativa para ser gerenciado via Terraform.
- O banco não é publicamente acessível; só aceita conexões vindas de dentro da própria VPC (aplicação principal e Lambda de autenticação).
