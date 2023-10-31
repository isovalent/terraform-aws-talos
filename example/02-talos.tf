module "talos" {
  #source = "git::https://github.com/isovalent/terraform-aws-talos?ref=<RELEASE_TAG>"
  source = "../"

  // Supported Talos versions (and therefore K8s versions) can be found here: https://github.com/siderolabs/talos/releases
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  cluster_name       = var.cluster_name
  cluster_id         = var.cluster_id
  region             = var.region
  tags               = local.tags
  # For single-node cluster support:
  #allow_workload_on_cp_nodes = true
  #controlplane_count         = 1
  #workers_count              = 0
  // VPC needs to be created in advance via https://github.com/isovalent/terraform-aws-vpc
  vpc_id       = module.vpc.id
  pod_cidr     = var.pod_cidr
  service_cidr = var.service_cidr
}