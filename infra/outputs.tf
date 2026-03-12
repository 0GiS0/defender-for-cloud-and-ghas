# =============================================================================
# Outputs - Defender for Cloud & GHAS Security Demo
# =============================================================================

# --- Resource Group ---

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

# --- AKS Cluster ---

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_kube_config" {
  description = "Kubeconfig for the AKS cluster (contains credentials)"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

# --- Azure Container Registry ---

output "acr_login_server" {
  description = "The login server URL for the ACR"
  value       = azurerm_container_registry.main.login_server
}

output "acr_admin_username" {
  description = "The admin username for the ACR (insecure - admin account is enabled)"
  value       = azurerm_container_registry.main.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "The admin password for the ACR (insecure - admin account is enabled)"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}

# --- Storage Account ---

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_connection_string" {
  description = "The connection string for the storage account (contains access key)"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "storage_primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}
