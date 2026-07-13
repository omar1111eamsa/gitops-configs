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
