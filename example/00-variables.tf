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

variable "cluster_architecture" {
  description = "Cluster architecture. Choose 'arm64' or 'amd64'. If you choose 'arm64', ensure to also override the control_plane.instance_type and worker_groups.instance_type with an ARM64-based instance type like 'm7g.large'."
  type        = string
  default     = "amd64"
}

variable "control_plane" {
  description = "Info for control plane that will be created"
  type = object({
    instance_type      = optional(string, "m5.large")
    config_patch_files = optional(list(string), [])
    tags               = optional(map(string), {})
  })

  default = {}
}

variable "worker_groups" {
  description = "List of node worker node groups to create"
  type = list(object({
    name               = string
    instance_type      = optional(string, "m5.large")
    config_patch_files = optional(list(string), [])
    tags               = optional(map(string), {})
  }))

  default = [{
    name = "default"
  }]
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
  default     = "v1.6.1"
  type        = string
  description = "Talos version to use for the cluster, if not set the newest Talos version. Check https://github.com/siderolabs/talos/releases for available releases."
}

variable "kubernetes_version" {
  default     = "1.27.6"
  type        = string
  description = "Kubernetes version to use for the Talos cluster, if not set, the K8s version shipped with the selected Talos version will be used. Check https://www.talos.dev/v1.5/introduction/support-matrix/."
}

variable "service_cidr" {
  default     = "100.68.0.0/16"
  description = "The CIDR to use for K8s Services"
  type        = string
}

variable "allocate_node_cidrs" {
  description = "Whether to assign PodCIDRs to Node resources or not. Only needed in case Cilium runs in 'kubernetes' IPAM mode."
  type        = bool
  default     = false
}

variable "pod_cidr" {
  default     = "100.64.0.0/14"
  description = "The CIDR to use for K8s Pods. Depending on if allocate_node_cidrs is set or not, it will either be configured on the controllerManager and assigned to Node resources or to CiliumNode CRs (in case Cilium runs with 'cluster-pool' IPAM mode)."
  type        = string
}

# Cilium module
variable "cilium_namespace" {
  default     = "kube-system"
  description = "The namespace in which to install Cilium."
  type        = string
}

variable "cilium_helm_chart" {
  default     = "cilium/cilium"
  type        = string
  description = "The name of the Helm chart to be used. The naming depends on the Helm repo naming on the local machine."
}

variable "cilium_helm_version" {
  default     = "1.14.6"
  type        = string
  description = "The version of the used Helm chart. Check https://github.com/cilium/cilium/releases to see available versions."
}

variable "cilium_helm_values_file_path" {
  default     = "03-cilium-values.yaml"
  description = "Cilium values file"
  type        = string
}

variable "cilium_helm_values_override_file_path" {
  default     = ""
  description = "Override Cilium values file"
  type        = string
}

variable "pre_cilium_install_script" {
  default     = ""
  description = "A script to be run before installing Cilium."
  type        = string
}