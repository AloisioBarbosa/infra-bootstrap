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
- serviços compartilhados Kubernetes (`infra-platform`).

## Inventário

| Arquivo | Conteúdo |
|---|---|
| `versions.tf` | versões do Terraform e providers AWS/TLS |
| `providers.tf` | provider AWS e tags padrão |
| `variables.tf` | região, ambiente, bucket e organização GitHub |
| `data.tf` | identidade AWS e certificado do endpoint OIDC |
| `terraform_state.tf` | bucket, versionamento, criptografia e bloqueio público |
| `github_oidc.tf` | provider OIDC e role/policy do `infra-network` |
| `api_gateway_account.tf` | logging global do API Gateway na conta |
| `outputs.tf` | bucket e ARNs publicados |
| `.github/workflows/terraform.yml` | formatação e validação sem acesso à AWS |

## Decisões operacionais

- A primeira implantação usa state local porque o backend ainda não existe.
- Depois do primeiro apply, o state deve ser migrado para o bucket S3.
- `prevent_destroy` protege o bucket de state.
- O prefixo SSM autorizado para o `infra-network` é `/infra-network/vpc/*`.
- A trust policy do `infra-network` usa o subject OIDC imutável do GitHub e
  autoriza somente o environment `production`.
- A role OIDC não altera automaticamente o workflow consumidor; o cutover
  ocorre depois do apply do bootstrap.
- Nenhum recurso estava implantado na AWS nesta separação, portanto não há
  migração de state entre repositórios.

Ao alterar Terraform, atualize este arquivo no mesmo PR.
