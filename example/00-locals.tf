locals {
  expiry = file("${path.module}/.timestamp")
  # The default tags defined here are merged with extra tags defined via var.tags in 00-variables.tf.
  tags = merge(
    tomap({
      "expiry" : local.expiry,
      "owner" : var.owner
    }),
    var.tags
  )
  extra_provisioner_environment_variables = {
    CLUSTER_NAME                 = var.cluster_name
    CLUSTER_ID                   = var.cluster_id
    POD_CIDR                     = var.pod_cidr
    SERVICE_CIDR                 = var.service_cidr
    KUBECONFIG                   = module.kubeadm.path_to_kubeconfig_file
  }
}