# Contributing

- Execute `terraform fmt -check -recursive` e `terraform validate`.
- Resuma o Terraform plan no Pull Request sem commitar o plano binário.
- O apply em `main` deve passar pela aprovação do environment `production`.
- Não commite states, planos binários, credenciais ou `terraform.tfvars`.
- Mudanças em IAM, OIDC, backend e recursos globais exigem revisão de segurança.
