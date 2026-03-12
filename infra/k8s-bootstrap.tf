locals {
  api_image_full        = "${azurerm_container_registry.main.login_server}/${local.api_image_name}"
  web_image_full        = "${azurerm_container_registry.main.login_server}/${local.web_image_name}"
  sql_connection_string = "Server=tcp:sql-demo.database.windows.net;Database=customersdb;User ID=sqladmin;Password=P@ssw0rd123!;"

  rendered_namespace_manifest = file("${path.module}/../k8s/namespace.yaml")
  rendered_api_service_manifest = file("${path.module}/../k8s/api-service.yaml")
  rendered_web_service_manifest = file("${path.module}/../k8s/web-service.yaml")

  rendered_api_deployment_manifest = templatefile("${path.module}/templates/api-deployment.yaml.tftpl", {
    api_image                 = local.api_image_full
    storage_connection_string = azurerm_storage_account.main.primary_connection_string
    sql_connection_string     = local.sql_connection_string
  })

  rendered_web_deployment_manifest = templatefile("${path.module}/templates/web-deployment.yaml.tftpl", {
    web_image                 = local.web_image_full
    storage_connection_string = azurerm_storage_account.main.primary_connection_string
    sql_connection_string     = local.sql_connection_string
  })
}

resource "terraform_data" "deploy_k8s_manifests" {
  triggers_replace = [
    azurerm_kubernetes_cluster.main.id,
    sha256(local.rendered_namespace_manifest),
    sha256(local.rendered_api_deployment_manifest),
    sha256(local.rendered_api_service_manifest),
    sha256(local.rendered_web_deployment_manifest),
    sha256(local.rendered_web_service_manifest),
    azurerm_container_registry_task_schedule_run_now.api_build.id,
    azurerm_container_registry_task_schedule_run_now.web_build.id,
  ]

  depends_on = [
    azurerm_role_assignment.aks_acr_pull,
    azurerm_container_registry_task_schedule_run_now.api_build,
    azurerm_container_registry_task_schedule_run_now.web_build,
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-lc"]
    command = <<-EOT
      set -euo pipefail

      manifest_dir="${path.module}/.terraform/rendered-k8s"
      mkdir -p "$manifest_dir"

      kubeconfig_file="$manifest_dir/kubeconfig"
      cat > "$kubeconfig_file" <<'KUBECONFIG'
${azurerm_kubernetes_cluster.main.kube_config_raw}
KUBECONFIG

      cat > "$manifest_dir/namespace.yaml" <<'YAML'
${local.rendered_namespace_manifest}
YAML

      cat > "$manifest_dir/api-deployment.yaml" <<'YAML'
${local.rendered_api_deployment_manifest}
YAML

      cat > "$manifest_dir/api-service.yaml" <<'YAML'
${local.rendered_api_service_manifest}
YAML

      cat > "$manifest_dir/web-deployment.yaml" <<'YAML'
${local.rendered_web_deployment_manifest}
YAML

      cat > "$manifest_dir/web-service.yaml" <<'YAML'
${local.rendered_web_service_manifest}
YAML

      KUBECONFIG="$kubeconfig_file" kubectl apply \
        -f "$manifest_dir/namespace.yaml" \
        -f "$manifest_dir/api-deployment.yaml" \
        -f "$manifest_dir/api-service.yaml" \
        -f "$manifest_dir/web-deployment.yaml" \
        -f "$manifest_dir/web-service.yaml"

      KUBECONFIG="$kubeconfig_file" kubectl -n sensitive-data-app rollout status deployment/sensitive-data-api --timeout=180s
      KUBECONFIG="$kubeconfig_file" kubectl -n sensitive-data-app rollout status deployment/sensitive-data-web --timeout=180s
    EOT
  }
}