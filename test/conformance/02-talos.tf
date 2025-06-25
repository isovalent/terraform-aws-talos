module "talos" {
  source = "../../"

  // Supported Talos versions (and therefore K8s versions) can be found here: https://github.com/siderolabs/talos/releases
  talos_version              = var.talos_version
  kubernetes_version         = var.kubernetes_version
  cluster_name               = var.cluster_name
  cluster_id                 = var.cluster_id
  region                     = var.region
  tags                       = local.tags
  workers_count              = 1
  controlplane_count         = 1
  allow_workload_on_cp_nodes = true
  # Limit which source IP is able to access ingress port 6443 and 50000 (configured on the SG):
  external_source_cidrs = ["${data.external.public_ip.result.ip}/32"]

  // VPC needs to be created in advance via https://github.com/isovalent/terraform-aws-vpc
  vpc_id             = module.vpc.id
  pod_cidr           = var.pod_cidr
  service_cidr       = var.service_cidr
  disable_kube_proxy = var.disable_kube_proxy
}
