# Contributing

- Execute `terraform fmt -check -recursive` e `terraform validate`.
- Anexe o Terraform plan ao Pull Request.
- Não execute apply sem aprovação explícita.
- Não commite states, planos binários, credenciais ou `terraform.tfvars`.
- Mudanças em IAM, OIDC, backend e recursos globais exigem revisão de segurança.
