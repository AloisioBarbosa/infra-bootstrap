output "terraform_state_bucket" {
  description = "Nome do bucket S3 que armazena os states Terraform dos produtos da plataforma."
  value       = aws_s3_bucket.terraform_state.id
}

output "infra_network_github_actions_role_arn" {
  description = "ARN da role OIDC usada pelo pipeline do infra-network."
  value       = aws_iam_role.github_actions_infra_network.arn
}

output "api_gateway_cloudwatch_role_arn" {
  description = "ARN da role global de logging do API Gateway."
  value       = aws_iam_role.api_gateway_logging.arn
}
