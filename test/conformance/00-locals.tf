locals {
  expiry = file("${path.module}/.timestamp")
  # The default tags defined here are merged with extra tags defined via var.tags in 00-variables.tf.
  tags = merge(
    tomap({
      "expiry" : local.expiry,
      "owner" : var.owner,
      "run_id" : "https://github.com/isovalent/terraform-aws-talos/actions/runs/${var.run_id}",
      "run_number" : var.run_number,
      "test_name" : var.test_name,
      "cilium_version" : var.cilium_version,
    }),
    var.tags
  )
  extra_provisioner_environment_variables = {
    CLUSTER_NAME = var.cluster_name
    CLUSTER_ID   = var.cluster_id
    POD_CIDR     = var.pod_cidr
    SERVICE_CIDR = var.service_cidr
    KUBECONFIG   = module.talos.path_to_kubeconfig_file
    # See https://www.talos.dev/v1.5/kubernetes-guides/network/deploying-cilium/ 
    KUBE_APISERVER_HOST = "localhost"
    KUBE_APISERVER_PORT = "7445"
  }
}
