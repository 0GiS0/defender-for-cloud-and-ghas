locals {
  api_image_name = "sensitive-data-api:latest"
  web_image_name = "sensitive-data-web:latest"
}

resource "terraform_data" "api_build_revision" {
  triggers_replace = [data.archive_file.api_build_context.output_sha256]
}

resource "terraform_data" "web_build_revision" {
  triggers_replace = [data.archive_file.web_build_context.output_sha256]
}

data "archive_file" "api_build_context" {
  type        = "tar.gz"
  source_dir  = "${path.module}/../src/api"
  output_path = "${path.module}/.terraform/build-contexts/api.tar.gz"
  excludes = [
    "bin/**",
    "obj/**"
  ]
}

data "archive_file" "web_build_context" {
  type        = "tar.gz"
  source_dir  = "${path.module}/../src/web"
  output_path = "${path.module}/.terraform/build-contexts/web.tar.gz"
  excludes = [
    "dist/**",
    "node_modules/**"
  ]
}

resource "azurerm_storage_container" "build_contexts" {
  name                  = "build-contexts"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "api_build_context" {
  name                   = "api-build-context.tar.gz"
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.build_contexts.name
  type                   = "Block"
  source                 = data.archive_file.api_build_context.output_path

  depends_on = [data.archive_file.api_build_context]
}

resource "azurerm_storage_blob" "web_build_context" {
  name                   = "web-build-context.tar.gz"
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.build_contexts.name
  type                   = "Block"
  source                 = data.archive_file.web_build_context.output_path

  depends_on = [data.archive_file.web_build_context]
}

data "azurerm_storage_account_blob_container_sas" "build_contexts" {
  connection_string = azurerm_storage_account.main.primary_connection_string
  container_name    = azurerm_storage_container.build_contexts.name
  https_only        = true
  start             = timestamp()
  expiry            = timeadd(timestamp(), "24h")

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }
}

resource "azurerm_container_registry_task" "api_build" {
  name                  = "api-build"
  container_registry_id = azurerm_container_registry.main.id
  enabled               = true

  platform {
    os = "Linux"
  }

  docker_step {
    dockerfile_path      = "Dockerfile"
    context_path         = azurerm_storage_blob.api_build_context.url
    context_access_token = data.azurerm_storage_account_blob_container_sas.build_contexts.sas
    image_names          = [local.api_image_name]
    push_enabled         = true
    cache_enabled        = true
  }

  tags = var.tags
}

resource "azurerm_container_registry_task" "web_build" {
  name                  = "web-build"
  container_registry_id = azurerm_container_registry.main.id
  enabled               = true

  platform {
    os = "Linux"
  }

  docker_step {
    dockerfile_path      = "Dockerfile"
    context_path         = azurerm_storage_blob.web_build_context.url
    context_access_token = data.azurerm_storage_account_blob_container_sas.build_contexts.sas
    image_names          = [local.web_image_name]
    push_enabled         = true
    cache_enabled        = true
  }

  tags = var.tags
}

resource "azurerm_container_registry_task_schedule_run_now" "api_build" {
  container_registry_task_id = azurerm_container_registry_task.api_build.id

  lifecycle {
    replace_triggered_by = [terraform_data.api_build_revision]
  }
}

resource "azurerm_container_registry_task_schedule_run_now" "web_build" {
  container_registry_task_id = azurerm_container_registry_task.web_build.id

  lifecycle {
    replace_triggered_by = [terraform_data.web_build_revision]
  }
}