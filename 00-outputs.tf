output "path_to_talosconfig_file" {
  description = "The generated talosconfig."
  value       = local.path_to_talosconfig_file
}

output "path_to_kubeconfig_file" {
  description = "The generated kubeconfig."
  value       = local.path_to_kubeconfig_file
}

output "elb_dns_name" {
  description = "Public ELB DNS name."
  value       = module.elb_k8s_elb.elb_dns_name
}

output "cluster_name" {
  description = "Name of cluster"
  value       = var.cluster_name
}

output "kubeconfig" {
  description = "Kubeconfig content"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
}
