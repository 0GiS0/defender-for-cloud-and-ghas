# =============================================================================
# Variables - Defender for Cloud & GHAS Security Demo
# =============================================================================

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-defender-ghas-demo"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "westeurope"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-vulnerable-demo"
}

variable "storage_account_name" {
  description = "Name of the Storage Account (must be globally unique, 3-24 chars, lowercase alphanumeric only)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 characters, lowercase letters and numbers only."
  }
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique, 5-50 chars, alphanumeric only)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.acr_name))
    error_message = "ACR name must be 5-50 characters, alphanumeric only."
  }
}

variable "node_count" {
  description = "Number of nodes in the AKS default node pool"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "os_disk_size_gb" {
  description = "OS disk size for AKS nodes"
  type        = number
  default     = 30
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS - pinned to a supported version so the demo remains deployable"
  type        = string
  default     = "1.32.10"
  # NOTE: The original demo version is no longer accepted for new clusters in West Europe.
  # This keeps the demo deployable on the standard support plan in current subscriptions.
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "demo"
    Purpose     = "security-posture-demo"
    ManagedBy   = "terraform"
    Warning     = "intentionally-misconfigured"
  }
}
