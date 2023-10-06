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