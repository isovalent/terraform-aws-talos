module "tetragon" {
  source = "git::https://github.com/isovalent/terraform-k8s-tetragon.git?ref=v0.5"

  # Wait until Cilium CNI is done.
  depends_on = [
    module.cilium
  ]

  tetragon_helm_release_name              = "tetragon"
  tetragon_helm_values_file_path          = var.tetragon_helm_values_file_path
  tetragon_helm_version                   = var.tetragon_helm_version
  tetragon_helm_chart                     = var.tetragon_helm_chart
  tetragon_namespace                      = var.tetragon_namespace
  path_to_kubeconfig_file                 = module.talos.path_to_kubeconfig_file
  tetragon_helm_values_override_file_path = var.tetragon_helm_values_override_file_path
  tetragon_tracingpolicy_directory        = var.tetragon_tracingpolicy_directory
  extra_provisioner_environment_variables = local.extra_provisioner_environment_variables
}