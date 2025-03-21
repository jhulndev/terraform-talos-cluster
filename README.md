# Talos Cluster Terraform module

Terraform module to configuration a Talos Cluster.

## Examples


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.73 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | >= 0.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_talos"></a> [talos](#provider\_talos) | >= 0.7 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [talos_cluster_kubeconfig.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/cluster_kubeconfig) | resource |
| [talos_machine_bootstrap.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_bootstrap) | resource |
| [talos_machine_configuration_apply.control_plane](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_configuration_apply.worker](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_secrets) | resource |
| [terraform_data.control_plane_config_apply_trigger](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.kubeconfig_trigger](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.worker_config_apply_trigger](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [talos_client_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/client_configuration) | data source |
| [talos_cluster_health.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/cluster_health) | data source |
| [talos_machine_configuration.control_plane](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/machine_configuration) | data source |
| [talos_machine_configuration.worker](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/machine_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_talos_config_version"></a> [talos\_config\_version](#input\_talos\_config\_version) | This is the Talos version that will be used to generate machine configuration.<br/>Typically, this will be the version of Talos that is installed when the cluster<br/>is created, and allows for generating machine configurations with older<br/>versions of Talos.<br/><br/>You may specify only the major.minor version, such as `v1.9`. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster in the generated config | `string` | `"talos"` | no |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | Then endpoint for the cluster. | `string` | `null` | no |
| <a name="input_cluster_health_check"></a> [cluster\_health\_check](#input\_cluster\_health\_check) | Set to `enabled = false` to disable the `talos_cluster_health` data from<br/>being pulled. This can be necessary if the cluster is in an unhealthy<br/>state and you are trying to destroy it, as the health check failing<br/>can block the destroy operation. | <pre>object({<br/>    enabled                = optional(bool, true)<br/>    skip_kubernetes_checks = optional(bool, false)<br/>    timeout                = optional(string, "10m")<br/>  })</pre> | `{}` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The default `kubernetes_version` for all nodes. | `string` | `null` | no |
| <a name="input_apply_mode"></a> [apply\_mode](#input\_apply\_mode) | The default `apply_mode` behavior for all nodes. | `string` | `"auto"` | no |
| <a name="input_on_destroy"></a> [on\_destroy](#input\_on\_destroy) | The default `on_destroy` behavior for all nodes. | <pre>object({<br/>    graceful = optional(bool, true)<br/>    reboot   = optional(bool, false)<br/>    reset    = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_config_patches"></a> [config\_patches](#input\_config\_patches) | Config patches to apply to all nodes (`common`), to all `control_plane`<br/>nodes, or to all `worker` nodes. | <pre>object({<br/>    common        = optional(list(string), [])<br/>    control_plane = optional(list(string), [])<br/>    worker        = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_control_plane_nodes"></a> [control\_plane\_nodes](#input\_control\_plane\_nodes) | Configuration for the control plane nodes. | <pre>map(object({<br/>    node                 = string<br/>    endpoint             = optional(string)<br/>    config_patches       = optional(list(string), [])<br/>    config_apply_trigger = optional(map(any), {})<br/>    kubernetes_version   = optional(string)<br/>    apply_mode           = optional(string)<br/>    on_destroy = optional(object({<br/>      graceful = optional(bool, true)<br/>      reboot   = optional(bool, false)<br/>      reset    = optional(bool, false)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_worker_nodes"></a> [worker\_nodes](#input\_worker\_nodes) | Configuration for the worker nodes. | <pre>map(object({<br/>    node                 = string<br/>    endpoint             = optional(string)<br/>    config_patches       = optional(list(string), [])<br/>    config_apply_trigger = optional(map(any), {})<br/>    kubernetes_version   = optional(string)<br/>    apply_mode           = optional(string)<br/>    on_destroy = optional(object({<br/>      graceful = optional(bool, true)<br/>      reboot   = optional(bool, false)<br/>      reset    = optional(bool, false)<br/>    }))<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | The Kubeconfig file for the cluster. |
| <a name="output_talos_config"></a> [talos\_config](#output\_talos\_config) | The Talos configuration file for the cluster. |
<!-- END_TF_DOCS -->
