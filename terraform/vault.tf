variable "hvn_id" {
  description = "The ID of the HCP HVN."
  type        = string
  default     = "dropbox"
}

variable "cluster_id" {
  description = "The ID of the HCP Vault cluster."
  type        = string
  default     = "dropbox"
}

variable "region" {
  description = "The region of the HCP HVN and Vault cluster."
  type        = string
  default     = "eu-central-1"
}

variable "cloud_provider" {
  description = "The cloud provider of the HCP HVN and Vault cluster."
  type        = string
  default     = "aws"
}

variable "tier" {
  description = "Tier of the HCP Vault cluster. Valid options for tiers."
  type        = string
  default     = "dev"
}

# HCP_CLIENT_ID and HCP_CLIENT_SECRET are set as environment variables
provider "hcp" {}

resource "hcp_hvn" "dropbox_hvn" {
  hvn_id         = var.hvn_id
  cloud_provider = var.cloud_provider
  region         = var.region
}

resource "hcp_vault_cluster" "dropbox" {
  hvn_id     = hcp_hvn.dropbox_hvn.hvn_id
  cluster_id = var.cluster_id
  tier       = var.tier
  public_endpoint = true
}

resource "hcp_vault_cluster_admin_token" "vault_admin_token" {
  cluster_id = hcp_vault_cluster.dropbox.cluster_id
}

resource "local_file" "public_endpoint" {
    content  = hcp_vault_cluster.dropbox.vault_public_endpoint_url
    filename = "temp_data/vault_public_endpoint_url"
}

resource "local_file" "vault_admin_token" {
    content  = hcp_vault_cluster_admin_token.vault_admin_token.token
    filename = "temp_data/vault_admin_token"
}

# The default namespace when creating a HCP cluster
resource "local_file" "vault_admin_namespace" {
    content  = "admin"
    filename = "temp_data/vault_admin_namespace"
}

output "vault_admin_token" {
   description = "Admin Token of the HCP Vault Cluster"
   value       = hcp_vault_cluster_admin_token.vault_admin_token.token
   sensitive   = true
}

output "vault_public_endpoint" {
   description = "Public endpoint of Vault cluster"
   value       = hcp_vault_cluster.dropbox.vault_public_endpoint_url
}

output "vault_admin_namespace" {
   description = "Initial Vault namespace"
   value       = hcp_vault_cluster.dropbox.namespace
}
