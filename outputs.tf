
output "kubeconfig" {
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
  description = "The Kubeconfig file for the cluster."
}

output "talos_config" {
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
  description = "The Talos configuration file for the cluster."
}
