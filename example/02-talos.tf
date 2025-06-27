# Used for ingress SG restrictions
data "external" "public_ip" {
  program = ["sh", "-c", "curl -s https://api.ipify.org?format=json"]
}

module "talos" {
  #source = "git::https://github.com/isovalent/terraform-aws-talos?ref=<RELEASE_TAG>"
  source = "../"

  // Supported Talos versions (and therefore K8s versions) can be found here: https://github.com/siderolabs/talos/releases
  talos_version                  = var.talos_version
  kubernetes_version             = var.kubernetes_version
  cluster_name                   = var.cluster_name
  cluster_id                     = var.cluster_id
  cluster_architecture           = var.cluster_architecture
  control_plane                  = var.control_plane
  worker_groups                  = var.worker_groups
  region                         = var.region
  tags                           = local.tags
  allocate_node_cidrs            = var.allocate_node_cidrs
  disable_kube_proxy             = var.disable_kube_proxy
  disable_containerd_nri_plugins = var.disable_containerd_nri_plugins
  # Limit which source IP is able to access ingress port 6443 and 50000 (configured on the SG):
  external_source_cidrs = ["${data.external.public_ip.result.ip}/32"]
  # For single-node cluster support:
  allow_workload_on_cp_nodes = var.allow_workload_on_cp_nodes
  controlplane_count         = var.controlplane_count
  workers_count              = var.workers_count
  // VPC needs to be created in advance via https://github.com/isovalent/terraform-aws-vpc
  vpc_id                                      = module.vpc.id
  pod_cidr                                    = var.pod_cidr
  service_cidr                                = var.service_cidr
  enable_external_cloud_provider              = var.enable_external_cloud_provider
  deploy_external_cloud_provider_iam_policies = var.deploy_external_cloud_provider_iam_policies
  external_cloud_provider_manifest            = var.external_cloud_provider_manifest
}