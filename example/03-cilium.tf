module "cilium" {
  source = "git::https://github.com/isovalent/terraform-k8s-cilium.git?ref=v1.6.1"

  depends_on = [
    module.talos
  ]

  cilium_helm_release_name           = "cilium"
  wait_for_total_control_plane_nodes = true
  # For single-node cluster support:
  #total_control_plane_nodes               = 1
  cilium_helm_values_file_path            = var.cilium_helm_values_file_path
  cilium_helm_version                     = var.cilium_helm_version
  cilium_helm_chart                       = var.cilium_helm_chart
  path_to_kubeconfig_file                 = module.talos.path_to_kubeconfig_file
  cilium_helm_values_override_file_path   = var.cilium_helm_values_override_file_path
  pre_cilium_install_script               = file("${path.module}/scripts/pre-cilium-install-script.sh")
  post_cilium_install_script              = file("${path.module}/scripts/post-cilium-install-script.sh")
  extra_provisioner_environment_variables = local.extra_provisioner_environment_variables
}