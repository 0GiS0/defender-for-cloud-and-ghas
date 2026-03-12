# =============================================================================
# Defender for Cloud & GHAS Security Demo - Main Configuration
# =============================================================================
# PURPOSE: This infrastructure is INTENTIONALLY misconfigured to demonstrate
# Microsoft Defender for Cloud CSPM (Cloud Security Posture Management) findings
# and how GitHub Advanced Security (GHAS) can detect IaC misconfigurations
# via code scanning (e.g., Checkov, tfsec, Terrascan).
#
# ⚠️  DO NOT deploy this in production environments.
# =============================================================================

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group - the only "secure" resource in this demo
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
