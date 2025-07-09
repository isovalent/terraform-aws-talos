# vpc module & general
variable "cluster_name" {
  default     = "talos-cute"
  description = "The name of the cluster."
  type        = string
}

variable "cluster_id" {
  default     = "1"
  description = "The (Cilium) ID of the cluster. Must be unique for Cilium ClusterMesh and between 0-255."
  type        = number
}

variable "region" {
  description = "The region in which to create the cluster."
  type        = string
}

variable "owner" {
  description = "Owner for resource tagging"
  type        = string
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "The CIDR to use for the VPC. Currently it must be a /16 or /24."
  type        = string
}

variable "tags" {
  default = {
    usage    = "cute",
    platform = "talos"
  }
  description = "The set of tags to place on the created resources. These will be merged with the default tags defined via local.tags in 00-locals.tf."
  type        = map(string)
}

# talos module
variable "talos_version" {
  description = "Talos version to use for the cluster, if not set the newest Talos version. Check https://github.com/siderolabs/talos/releases for available releases."
  type        = string
}

variable "service_cidr" {
  default     = "100.68.0.0/16"
  description = "The CIDR to use for K8s Services"
  type        = string
}

variable "allocate_node_cidrs" {
  default     = false
  description = "Whether to assign PodCIDRs to Node resources or not. Only needed in case Cilium runs in 'kubernetes' IPAM mode."
  type        = bool
}

variable "pod_cidr" {
  default     = "100.64.0.0/14"
  description = "The CIDR to use for K8s Pods. Depending on if allocate_node_cidrs is set or not, it will either be configured on the controllerManager and assigned to Node resources or to CiliumNode CRs (in case Cilium runs with 'cluster-pool' IPAM mode)."
  type        = string
}

variable "disable_kube_proxy" {
  type = bool
}

variable "run_id" {
  type = string
}

variable "run_number" {
  type = string
}

variable "test_name" {
  type = string
}

variable "cilium_version" {
  type = string
}
