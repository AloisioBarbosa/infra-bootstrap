# Changelog

## [Unreleased]

### Added

- Backend S3 parcial para migração do state local com locking nativo.
- Role e policy OIDC dedicadas ao deploy do `infra-bootstrap`.
- Deploy via GitHub Actions em pushes para `main`, protegido pelo environment
  `production`.
- Documentação do bootstrap inicial, migração do state e configuração do GitHub.

### Changed

- O workflow agora valida pull requests e executa plan/apply após merge em
  `main`.
- Roadmap atualizado com o estado atual da implantação.

### Adopted

- Bucket `orange-ks8-logs` e suas configurações de ownership, acesso público,
  criptografia e versionamento.
- Provider OIDC `token.actions.githubusercontent.com`.
- Configuração da conta do API Gateway e roles IAM preexistentes.
