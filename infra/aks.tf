# =============================================================================
# AKS Cluster - INTENTIONALLY INSECURE for Defender for Cloud Demo
# =============================================================================
# This AKS cluster is configured with multiple security misconfigurations
# to demonstrate Defender for Cloud CSPM findings and GHAS IaC scanning.
#
# ⚠️  DO NOT use this configuration in production.
# =============================================================================

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.cluster_name
  sku_tier            = "Free"

  lifecycle {
    ignore_changes = [
      api_server_access_profile,
      default_node_pool[0].upgrade_settings,
      microsoft_defender,
    ]
  }

  # INSECURE: Using an outdated Kubernetes version with known vulnerabilities
  # Defender Finding: "Kubernetes Services should be upgraded to a non-vulnerable Kubernetes version"
  kubernetes_version = var.kubernetes_version

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
    os_disk_size_gb = var.os_disk_size_gb

    # INSECURE: Auto-scaling is disabled - no resilience to load spikes
    # Defender Finding: "Kubernetes cluster should use auto-scaling"
    # enable_auto_scaling = true  # Intentionally omitted
  }

  identity {
    type = "SystemAssigned"
  }

  # INSECURE: RBAC is disabled - any authenticated user has full cluster access
  # Defender Finding: "Role-Based Access Control should be used on Kubernetes Services"
  role_based_access_control_enabled = false

  # NOTE: The legacy HTTP application routing add-on is no longer supported
  # for new AKS clusters by Azure, so it cannot be enabled in current subscriptions.

  network_profile {
    # INSECURE: Using kubenet instead of Azure CNI
    # kubenet provides less network isolation and doesn't support Network Policies natively
    # Defender Finding: "Azure CNI networking should be configured in Kubernetes clusters"
    network_plugin = "kubenet"
  }

  # INSECURE: API server is accessible from ANY IP address (empty authorized ranges = open to all)
  # Defender Finding: "Authorized IP ranges should be defined on Kubernetes Services"
  api_server_access_profile {
    authorized_ip_ranges = []
  }

  # INSECURE: Azure Policy is NOT enabled - no policy enforcement on the cluster
  # Defender Finding: "Azure Policy Add-on for Kubernetes should be installed and enabled on your clusters"
  # azure_policy_enabled = true  # Intentionally omitted (defaults to false)

  # INSECURE: No OMS agent configured - no monitoring or log collection
  # Defender Finding: "Azure Kubernetes Service clusters should have Defender profile enabled"
  # oms_agent {
  #   log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  # }

  # INSECURE: Microsoft Defender for Containers is NOT enabled
  # Defender Finding: "Microsoft Defender for Containers should be enabled"
  # microsoft_defender {
  #   log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  # }

  tags = var.tags
}
