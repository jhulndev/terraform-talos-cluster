
locals {
  control_plane_node_refs = values(var.control_plane_nodes)[*].node
  worker_node_refs        = values(var.worker_nodes)[*].node
  all_node_refs           = concat(local.control_plane_node_refs, local.worker_node_refs)

  cluster_endpoint = coalesce(var.cluster_endpoint, local.control_plane_node_refs[0])
}

resource "talos_machine_secrets" "this" {
  talos_version = var.talos_config_version
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = local.all_node_refs
  endpoints            = local.control_plane_node_refs
}

/*******************************************************************************
  Control Plane
 ******************************************************************************/

data "talos_machine_configuration" "control_plane" {
  for_each = var.control_plane_nodes

  talos_version = var.talos_config_version

  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${local.cluster_endpoint}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  kubernetes_version = (
    each.value.kubernetes_version != null
    ? each.value.kubernetes_version : var.kubernetes_version
  )

  config_patches = concat(
    var.config_patches.common,
    var.config_patches.control_plane,
    each.value.config_patches
  )

}

resource "terraform_data" "control_plane_config_apply_trigger" {
  for_each = var.control_plane_nodes

  input = merge(
    {
      machine_configuration = data.talos_machine_configuration.control_plane[each.key].machine_configuration
      node                  = each.value.node
    },
    each.value.config_apply_trigger
  )
}

resource "talos_machine_configuration_apply" "control_plane" {
  for_each = var.control_plane_nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_plane[each.key].machine_configuration
  node                        = each.value.node
  endpoint                    = each.value.endpoint
  apply_mode                  = coalesce(each.value.apply_mode, var.apply_mode)
  on_destroy                  = coalesce(each.value.on_destroy, var.on_destroy)

  lifecycle {
    replace_triggered_by = [
      terraform_data.control_plane_config_apply_trigger[each.key]
    ]
  }
}

# Choose one to bootstrap from
resource "talos_machine_bootstrap" "this" {
  node                 = local.control_plane_node_refs[0]
  endpoint             = local.cluster_endpoint
  client_configuration = talos_machine_secrets.this.client_configuration

  depends_on = [
    talos_machine_configuration_apply.control_plane
  ]
}

/*******************************************************************************
  Workers
 ******************************************************************************/

data "talos_machine_configuration" "worker" {
  for_each = var.worker_nodes

  talos_version = var.talos_config_version

  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${local.cluster_endpoint}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  kubernetes_version = (
    each.value.kubernetes_version != null
    ? each.value.kubernetes_version : var.kubernetes_version
  )

  config_patches = concat(
    var.config_patches.common,
    var.config_patches.worker,
    each.value.config_patches
  )

}

resource "terraform_data" "worker_config_apply_trigger" {
  for_each = var.worker_nodes

  input = merge(
    {
      machine_configuration = data.talos_machine_configuration.worker[each.key].machine_configuration
      node                  = each.value.node
    },
    each.value.config_apply_trigger
  )
}

resource "talos_machine_configuration_apply" "worker" {
  for_each = var.worker_nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[each.key].machine_configuration
  node                        = each.value.node
  endpoint                    = each.value.endpoint
  apply_mode                  = coalesce(each.value.apply_mode, var.apply_mode)
  on_destroy                  = coalesce(each.value.on_destroy, var.on_destroy)

  lifecycle {
    replace_triggered_by = [
      terraform_data.worker_config_apply_trigger[each.key]
    ]
  }
}

/*******************************************************************************
 * Health Check
 ******************************************************************************/

# NOTE: Possible Provider Bug
# If the cluster is unhealthy, this will hold up plans, preventing you from
# making any modifications to try to fix or destroy the cluster.
#
# Workaround:
# Set `enable_cluster_health_check = false`.

data "talos_cluster_health" "this" {
  count = var.cluster_health_check.enabled ? 1 : 0

  client_configuration   = data.talos_client_configuration.this.client_configuration
  endpoints              = data.talos_client_configuration.this.endpoints
  control_plane_nodes    = local.control_plane_node_refs
  worker_nodes           = local.worker_node_refs
  skip_kubernetes_checks = var.cluster_health_check.skip_kubernetes_checks

  timeouts = {
    read = var.cluster_health_check.timeout
  }
  depends_on = [
    talos_machine_configuration_apply.control_plane,
    talos_machine_configuration_apply.worker,
    talos_machine_bootstrap.this,
  ]
}

/*******************************************************************************
 * KubeConfig
 ******************************************************************************/

# NOTE: Possible Provider Bug
# If the endpoint or node changes, the output kubeconfig isn't regenerated.
#
# Workaround:
# Using terraform_data and replace_triggered_by to trigger replacement. Not
# sure if all of the fields need to be included in the `input`, just being safe.

resource "terraform_data" "kubeconfig_trigger" {
  input = {
    client_configuration = talos_machine_secrets.this.client_configuration
    endpoint             = local.cluster_endpoint
  }
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.control_plane_node_refs[0]
  endpoint             = local.cluster_endpoint

  depends_on = [
    talos_machine_bootstrap.this,
    data.talos_cluster_health.this,
  ]

  timeouts = {
    read = "1m"
  }

  lifecycle {
    replace_triggered_by = [
      terraform_data.kubeconfig_trigger
    ]
  }

}
