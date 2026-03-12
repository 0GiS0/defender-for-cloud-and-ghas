# =============================================================================
# Storage Account - INTENTIONALLY INSECURE for Defender for Cloud Demo
# =============================================================================
# INSECURE: Public access, no encryption at rest configured, no soft delete
#
# This storage account is configured with multiple security misconfigurations
# to demonstrate Defender for Cloud CSPM findings and GHAS IaC scanning.
#
# ⚠️  DO NOT use this configuration in production.
# =============================================================================

resource "azurerm_storage_account" "main" {
  name                = var.storage_account_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  account_tier        = "Standard"

  # INSECURE: LRS provides no geo-redundancy - data loss risk if region fails
  # Defender Finding: "Geo-redundant storage should be enabled for Storage Accounts"
  account_replication_type = "LRS"

  # INSECURE: TLS 1.0 allows connections using deprecated, vulnerable TLS versions
  # TLS 1.0 and 1.1 have known vulnerabilities (BEAST, POODLE, etc.)
  # Defender Finding: "Storage accounts should have the specified minimum TLS version"
  # Defender Finding: "Storage account should use a minimum TLS version of 1.2"
  min_tls_version = "TLS1_0"

  # INSECURE: Allows unencrypted HTTP traffic to the storage account
  # Data in transit is not protected - susceptible to man-in-the-middle attacks
  # Defender Finding: "Secure transfer to storage accounts should be enabled"
  enable_https_traffic_only = false

  # INSECURE: Allows blobs to be publicly accessible via anonymous requests
  # Defender Finding: "Storage account public access should be disallowed"
  allow_nested_items_to_be_public = true

  # INSECURE: Storage account is accessible from the public internet
  # Defender Finding: "Storage accounts should restrict network access"
  # Defender Finding: "Storage accounts should use private link"
  public_network_access_enabled = true

  # INSECURE: Shared access keys are enabled - provides full access to the storage account
  # Shared keys should be disabled in favor of Azure AD authentication
  # Defender Finding: "Storage accounts should prevent shared key access"
  shared_access_key_enabled = true

  # INSECURE: No blob soft delete or versioning - accidental/malicious deletion is permanent
  # Defender Finding: "Soft delete should be enabled for Azure Blobs"
  # Defender Finding: "Blob versioning should be enabled"
  # blob_properties {
  #   delete_retention_policy {
  #     days = 30
  #   }
  #   container_delete_retention_policy {
  #     days = 30
  #   }
  #   versioning_enabled = true
  # }

  # INSECURE: No private endpoint - data travels over public internet
  # Defender Finding: "Storage accounts should use private link"

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Storage Containers - INTENTIONALLY PUBLIC for Defender for Cloud Demo
# -----------------------------------------------------------------------------

# INSECURE: Container with public blob-level access
# Anyone with the URL can read individual blobs without authentication
# Defender Finding: "Storage containers should not have public access"
resource "azurerm_storage_container" "sensitive_data" {
  name                  = "sensitive-data"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "blob"
}

# INSECURE: Container with full public container-level access
# Anyone can list AND read all blobs without authentication
# Defender Finding: "Storage containers should not have public access"
resource "azurerm_storage_container" "reports" {
  name                  = "reports"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "container"
}

# -----------------------------------------------------------------------------
# Upload sample data files to publicly accessible containers
# These represent sensitive data exposed via misconfigured storage
# -----------------------------------------------------------------------------

# Upload all CSV files from the data directory
resource "azurerm_storage_blob" "csv_files" {
  for_each = fileset("${path.module}/../data", "*.csv")

  name                   = each.value
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.sensitive_data.name
  type                   = "Block"
  source                 = "${path.module}/../data/${each.value}"

  # INSECURE: Sensitive data (CSV) uploaded to a publicly accessible container
  # Defender Finding: "Sensitive data in blob storage should be classified"
}

# Upload all JSON files from the data directory
resource "azurerm_storage_blob" "json_files" {
  for_each = fileset("${path.module}/../data", "*.json")

  name                   = each.value
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.sensitive_data.name
  type                   = "Block"
  source                 = "${path.module}/../data/${each.value}"

  # INSECURE: Sensitive data (JSON) uploaded to a publicly accessible container
  # Defender Finding: "Sensitive data in blob storage should be classified"
}
