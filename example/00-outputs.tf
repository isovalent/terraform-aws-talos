output "cluster_name" {
  description = "Cluster name"
  value       = var.cluster_name
}

output "path_to_kubeconfig_file" {
  description = "Path to the kubeconfig of the Talos Linux cluster"
  value       = module.talos.path_to_kubeconfig_file
  sensitive   = true
}

output "path_to_talosconfig_file" {
  description = "Path to the talosconfig of the Talos Linux cluster"
  value       = module.talos.path_to_talosconfig_file
  sensitive   = true
}

output "region" {
  description = "AWS region used for the infra"
  value       = var.region
}

output "cilium_namespace" {
  value = var.cilium_namespace
}