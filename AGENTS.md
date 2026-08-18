# AGENTS.md — infra-bootstrap

Este repositório provisiona a fundação compartilhada da conta AWS. Seu escopo é
backend e state do Terraform, IAM e federação de CI, governança, auditoria,
segurança e pré-requisitos globais.

## Limites do produto

Pertencem a este repositório:

- bucket S3 compartilhado de state;
- provider OIDC do GitHub Actions;
- roles e policies de CI específicas por produto;
- configuração global de logging do API Gateway.

Não pertencem a este repositório:

- VPC, sub-redes, gateways, rotas, endpoints, conectividade ou DNS
  (`infra-network`);
- EKS e nodes (`infra-cluster`);
- serviços compartilhados Kubernetes (`infra-plataform`).

## Inventário

| Arquivo | Conteúdo |
|---|---|
| `versions.tf` | versões do Terraform e providers AWS/TLS |
| `providers.tf` | provider AWS e tags padrão |
| `backend.tf` | configuração parcial do backend S3 |
| `variables.tf` | região, ambiente, bucket e organização GitHub |
| `data.tf` | identidade AWS e certificado do endpoint OIDC |
| `terraform_state.tf` | bucket, versionamento, criptografia e bloqueio público |
| `github_oidc.tf` | provider OIDC e policies das roles de rede e plataforma |
| `github_actions_cluster.tf` | role/policy OIDC do pipeline do `infra-cluster` |
| `github_actions_bootstrap.tf` | role/policy OIDC do pipeline do bootstrap |
| `api_gateway_account.tf` | logging global do API Gateway na conta |
| `outputs.tf` | bucket e ARNs publicados |
| `.github/workflows/terraform.yml` | validação em PR e deploy OIDC em `main` |

## Decisões operacionais

- A primeira implantação e a adoção dos recursos preexistentes foram concluídas.
- O state está migrado para o backend S3 compartilhado.
- O backend usa locking nativo do S3 por arquivo `.tflock`.
- A chave remota do state deste produto é
  `bootstrap/dev/terraform.tfstate`.
- `prevent_destroy` protege o bucket de state.
- O prefixo SSM autorizado para o `infra-network` é `/infra-network/vpc/*`.
- A role do `infra-network` gerencia apenas EC2 de rede, o contrato SSM e seu
  prefixo de state; ela não substitui a role global do `infra-bootstrap`.
- `ssm:DescribeParameters` usa `Resource = "*"`; escrita e leitura de valores
  permanecem restritas a `/infra-network/vpc/*`.
- A trust policy do `infra-network` usa subjects OIDC imutáveis do GitHub e
  autoriza os environments `plan` e `production`, pois ambos assumem a mesma
  role no workflow atual.
- A role OIDC não altera automaticamente o workflow consumidor; o cutover
  ocorre depois do apply do bootstrap.
- A role do `infra-plataform` acessa somente o cluster `infra-cluster`, seu
  prefixo legado de state `platform/dev/*` e os environments `plan` e `production`.
- A autorização Kubernetes da role do `infra-plataform` pertence ao
  `infra-cluster` e deve existir antes do cutover do workflow consumidor.
- O ARN da role do `infra-plataform` é literal na policy de deploy do
  bootstrap para evitar dependência circular; a criação da role depende
  explicitamente da atualização de `TerraformInfraBootstrapPolicy`.
- A role OIDC do `infra-cluster` autoriza o state `cluster/dev/*`, leitura do
  contrato `/infra-network/vpc/*` e os recursos AWS declarados pelo produto.
- A criação da role do `infra-cluster` depende da atualização da policy do
  bootstrap para evitar falha de autorização no primeiro apply.
- A criação da service-linked role do EKS Fargate usa permissão dedicada,
  restrita a `eks-fargate.amazonaws.com`, e depende da atualização da policy
  do bootstrap.
- A service-linked role preexistente do EKS Fargate é adotada por um bloco de
  import declarativo usando seu ARN, evitando tentativa de recriação.
- A policy do bootstrap limita leitura, tags e exclusão ao ARN da service-linked
  role do EKS Fargate; somente a consulta do status assíncrono de exclusão usa
  `Resource = "*"`, pois a ação não oferece escopo por recurso.
- Recursos preexistentes foram importados para o state local antes da adoção do
  backend remoto.
- O deploy automático assume uma role dedicada e exige o environment protegido
  `production`.
- O deploy OIDC do `infra-bootstrap` foi executado com sucesso.
- As trust policies OIDC usam subjects imutáveis com IDs de owner e
  repositório.

Ao alterar Terraform, atualize este arquivo no mesmo PR.
