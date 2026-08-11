variable "project_name" {
  type        = string
  description = "Nome do produto usado para identificação e tagging dos recursos globais."
  default     = "infra-bootstrap"
}

variable "region" {
  type        = string
  description = "Região AWS primária para recursos regionais e para o backend Terraform."
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "region deve usar um identificador válido, como us-east-1."
  }
}

variable "environment" {
  type        = string
  description = "Ambiente associado aos recursos provisionados."
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment deve ser dev, staging ou prod."
  }
}

variable "terraform_state_bucket" {
  type        = string
  description = "Nome globalmente único do bucket S3 compartilhado para states Terraform."
  default     = "orange-ks8-logs"
}

variable "github_organization" {
  type        = string
  description = "Organização GitHub autorizada a assumir as roles de CI via OIDC."
  default     = "AloisioBarbosa"
}

variable "github_owner_id" {
  type        = string
  description = "ID imutável do owner GitHub usado no subject OIDC."

  validation {
    condition     = can(regex("^[0-9]+$", var.github_owner_id))
    error_message = "github_owner_id deve conter apenas dígitos."
  }
}

variable "infra_network_repository_id" {
  type        = string
  description = "ID imutável do repositório infra-network usado no subject OIDC."

  validation {
    condition     = can(regex("^[0-9]+$", var.infra_network_repository_id))
    error_message = "infra_network_repository_id deve conter apenas dígitos."
  }
}

variable "infra_bootstrap_repository_id" {
  type        = string
  description = "ID imutável do repositório infra-bootstrap usado no subject OIDC."

  validation {
    condition     = can(regex("^[0-9]+$", var.infra_bootstrap_repository_id))
    error_message = "infra_bootstrap_repository_id deve conter apenas dígitos."
  }
}
