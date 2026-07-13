variable "environment" {
  description = "Environment name (dev, test, prod) — used in resource naming and tags"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region to deploy into"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Base name for the resource group (environment gets appended)"
  type        = string
  default     = "rg-aks-gitops"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    project   = "aks-gitops"
    managedBy = "terraform"
  }
}
variable "kubernetes_cluster_name" {
  description = "Base name for the AKS cluster (environment gets appended)"
  type        = string
  default     = "aks-gitops"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.29"
}

variable "vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "node_min_count" {
  description = "Minimum node count for cluster autoscaler"
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum node count for cluster autoscaler"
  type        = number
  default     = 3
}

variable "key_vault_sku" {
  description = "Key Vault SKU (standard or premium)"
  type        = string
  default     = "standard"
}

variable "postgres_username" {
  description = "Username stored in Key Vault for the Postgres database"
  type        = string
  default     = "postgres"
}

variable "postgres_database" {
  description = "Database name stored in Key Vault"
  type        = string
  default     = "appdb"
}

variable "gitops_repo_url" {
  description = "URL of the GitOps repo containing your Kubernetes manifests (the one ArgoCD watches)"
  type        = string
  # No default — you must set this in terraform.tfvars to YOUR repo
}

variable "gitops_repo_path" {
  description = "Path inside the GitOps repo where the manifests/kustomization.yaml live"
  type        = string
  default     = "manifest-files/3tire-configs"
}
