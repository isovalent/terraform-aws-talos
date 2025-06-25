output "cluster_name" {
  description = "Cluster name"
  value       = var.cluster_name
}

output "path_to_kubeconfig_file" {
  description = "Path to the kubeconfig of the Talos Linux cluster"
  value       = module.talos.path_to_kubeconfig_file
}

output "path_to_talosconfig_file" {
  description = "Path to the talosconfig of the Talos Linux cluster"
  value       = module.talos.path_to_talosconfig_file
}

output "lb_dns_name" {
  description = "Public NLB DNS name."
  value       = module.talos.lb_dns_name
}

output "region" {
  description = "AWS region used for the infra"
  value       = var.region
}

output "vpc_id" {
  value = module.vpc.id
}
