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
  default     = 2
}

variable "vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS - intentionally outdated to trigger Defender findings"
  type        = string
  default     = "1.27.7"
  # INSECURE: Using an outdated Kubernetes version with known CVEs
  # Defender Finding: "Kubernetes Services should be upgraded to a non-vulnerable Kubernetes version"
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
