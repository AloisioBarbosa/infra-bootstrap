# Roadmap

## Concluído

- Fundação da conta aplicada e recursos preexistentes incorporados ao state.
- Backend S3 preparado com versionamento e locking nativo por lockfile.
- Pipeline de deploy do bootstrap preparado com OIDC e environment protegido.
- Role OIDC independente publicada para o `infra-network`.

## Próximos passos

1. Migrar e validar o state local do bootstrap no backend S3.
2. Ativar proteção e aprovação obrigatória no environment `production`.
3. Migrar o pipeline do `infra-network` para a role OIDC publicada.
4. Criar roles de CI independentes para os demais produtos da plataforma.
5. Adotar KMS gerenciado para o backend se os requisitos exigirem.
6. Adicionar CloudTrail, AWS Config, GuardDuty, budgets e controles de segurança.
