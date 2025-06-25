output "path_to_talosconfig_file" {
  description = "The generated talosconfig."
  value       = local.path_to_talosconfig_file
}

output "path_to_kubeconfig_file" {
  description = "The generated kubeconfig."
  value       = local.path_to_kubeconfig_file
}

output "lb_dns_name" {
  description = "Public NLB DNS name."
  value       = aws_lb.api.dns_name
}

output "elb_dns_name" {
  description = "[DEPRECATED: Use lb_dns_name instead] Public load balancer DNS name."
  value       = aws_lb.api.dns_name
}

output "lb_zone_id" {
  description = "The zone_id of the NLB for Route53 alias records."
  value       = aws_lb.api.zone_id
}

output "lb_arn" {
  description = "The ARN of the Network Load Balancer."
  value       = aws_lb.api.arn
}

output "cluster_name" {
  description = "Name of cluster"
  value       = var.cluster_name
}

output "kubeconfig" {
  description = "Kubeconfig content"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
}
