output "path_to_talosconfig_file" {
  description = "The generated talosconfig."
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "path_to_kubeconfig_file" {
  description = "The generated kubeconfig."
  value       = data.talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}