
variable "talos_config_version" {
  type        = string
  description = <<-EOT
    This is the Talos version that will be used to generate machine configuration.
    Typically, this will be the version of Talos that is installed when the cluster
    is created, and allows for generating machine configurations with older
    versions of Talos.

    You may specify only the major.minor version, such as `v1.9`.
  EOT
}

variable "cluster_name" {
  type        = string
  default     = "talos"
  description = "The name of the cluster in the generated config"
}

variable "cluster_endpoint" {
  type        = string
  default     = null
  description = "Then endpoint for the cluster."
}

variable "cluster_health_check" {
  type = object({
    enabled                = optional(bool, true)
    skip_kubernetes_checks = optional(bool, false)
    timeout                = optional(string, "10m")
  })
  default     = {}
  nullable    = false
  description = <<-EOT
    Set to `enabled = false` to disable the `talos_cluster_health` data from
    being pulled. This can be necessary if the cluster is in an unhealthy
    state and you are trying to destroy it, as the health check failing
    can block the destroy operation.
  EOT
}

/*******************************************************************************
  Shared Node Configuration
 ******************************************************************************/

variable "kubernetes_version" {
  type        = string
  default     = null
  description = "The default `kubernetes_version` for all nodes."
}

variable "apply_mode" {
  type        = string
  default     = "auto"
  nullable    = false
  description = "The default `apply_mode` behavior for all nodes."

  validation {
    condition     = contains(["auto", "no-reboot", "reboot", "staged", "try"], var.apply_mode)
    error_message = <<-EOT
      Invalid apply_mode, must be one of:
      auto, no-reboot, reboot, staged, or try
    EOT
  }
}

variable "on_destroy" {
  type = object({
    graceful = optional(bool, true)
    reboot   = optional(bool, false)
    reset    = optional(bool, false)
  })
  default     = {}
  nullable    = false
  description = "The default `on_destroy` behavior for all nodes."
}

variable "config_patches" {
  type = object({
    common        = optional(list(string), [])
    control_plane = optional(list(string), [])
    worker        = optional(list(string), [])
  })
  default     = {}
  nullable    = false
  description = <<-EOT
    Config patches to apply to all nodes (`common`), to all `control_plane`
    nodes, or to all `worker` nodes.
  EOT
}

/*******************************************************************************
  Control Plane Configuration
 ******************************************************************************/

variable "control_plane_nodes" {
  type = map(object({
    node                 = string
    endpoint             = optional(string)
    config_patches       = optional(list(string), [])
    config_apply_trigger = optional(map(any), {})
    kubernetes_version   = optional(string)
    apply_mode           = optional(string)
    on_destroy = optional(object({
      graceful = optional(bool, true)
      reboot   = optional(bool, false)
      reset    = optional(bool, false)
    }))
  }))
  default     = {}
  nullable    = false
  description = "Configuration for the control plane nodes."
}

/*******************************************************************************
  Worker Configuration
 ******************************************************************************/

variable "worker_nodes" {
  type = map(object({
    node                 = string
    endpoint             = optional(string)
    config_patches       = optional(list(string), [])
    config_apply_trigger = optional(map(any), {})
    kubernetes_version   = optional(string)
    apply_mode           = optional(string)
    on_destroy = optional(object({
      graceful = optional(bool, true)
      reboot   = optional(bool, false)
      reset    = optional(bool, false)
    }))
  }))
  default     = {}
  nullable    = false
  description = "Configuration for the worker nodes."
}
