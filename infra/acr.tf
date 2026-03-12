# =============================================================================
# Azure Container Registry - INTENTIONALLY INSECURE for Defender for Cloud Demo
# =============================================================================
# This ACR is configured with multiple security misconfigurations
# to demonstrate Defender for Cloud CSPM findings and GHAS IaC scanning.
#
# ⚠️  DO NOT use this configuration in production.
# =============================================================================

resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  # INSECURE: Basic SKU does not support vulnerability scanning, private endpoints,
  # content trust, retention policies, or customer-managed encryption keys
  # Defender Finding: "Container registries should use private link"
  # Defender Finding: "Container registry images should have vulnerability findings resolved"
  sku = "Basic"

  # INSECURE: Admin account enabled - provides a shared username/password
  # instead of using Azure AD / RBAC for authentication
  # Defender Finding: "Container registries should not have admin user enabled"
  admin_enabled = true

  # INSECURE: Public network access is enabled - registry is accessible from the internet
  # Defender Finding: "Container registries should not allow unrestricted network access"
  # Defender Finding: "Public network access should be disabled for Container registries"
  public_network_access_enabled = true

  # INSECURE: No retention policy configured - old/vulnerable images persist indefinitely
  # Basic SKU does not support retention_policy, but even if it did, it's not set
  # Defender Finding: "Container registries should have retention policy enabled"

  # INSECURE: No content trust / trust_policy configured
  # Images are not verified for integrity before deployment
  # Defender Finding: "Container registries should have content trust enabled"

  # INSECURE: No customer-managed encryption key configured
  # Data at rest uses platform-managed keys only
  # Defender Finding: "Container registries should be encrypted with a customer-managed key"

  tags = var.tags
}

# Grant AKS cluster pull access to ACR
# This is the correct way to connect AKS to ACR, but the ACR itself is insecure
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}
