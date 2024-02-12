variable "cluster_name" {
  description = "Name of cluster"
  type        = string
}

variable "cluster_id" {
  default     = "1"
  description = "The ID of the cluster."
  type        = number
}

variable "cluster_architecture" {
  description = "Cluster architecture. Choose 'arm64' or 'amd64'. If you choose 'arm64', ensure to also override the control_plane.instance_type and worker_groups.instance_type with an ARM64-based instance type like 'm7g.large'."
  type        = string
  default     = "amd64"

  validation {
    condition     = can(regex("^a(rm|md)64$", var.cluster_architecture))
    error_message = "The cluster_architecture value must be a valid architecture. Allowed values are 'arm64' and 'amd64'."
  }
}

variable "region" {
  description = "The region in which to create the Talos Linux cluster."
  type        = string
}

variable "tags" {
  description = "The set of tags to place on the cluster."
  type        = map(string)
}

variable "allocate_node_cidrs" {
  description = "Whether to assign PodCIDRs to Node resources or not. Only needed in case Cilium runs in 'kubernetes' IPAM mode."
  type        = bool
  default     = true
}

variable "pod_cidr" {
  description = "The CIDR to use for Pods. Only required in case allocate_node_cidrs is set to 'true'. Otherwise, simply configure it inside Cilium's Helm values."
  default     = "100.64.0.0/14"
  type        = string
}

variable "service_cidr" {
  description = "The CIDR to use for services."
  default     = "100.68.0.0/16"
  type        = string
}

variable "disable_kube_proxy" {
  description = "Whether to deploy Kube-Proxy or not. By default, KP shouldn't be deployed."
  type        = bool
  default     = true
}

variable "allow_workload_on_cp_nodes" {
  description = "Allow workloads on CP nodes or not. Allowing it means Talos Linux default taints are removed from CP nodes. More details here: https://www.talos.dev/v1.5/talos-guides/howto/workers-on-controlplane/"
  type        = bool
  default     = false
}

variable "talos_version" {
  description = "Talos version to use for the cluster, if not set, the newest Talos version. Check https://github.com/siderolabs/talos/releases for available releases."
  type        = string
  default     = "v1.6.1"

  validation {
    condition     = can(regex("^v\\d+\\.\\d+\\.\\d+$", var.talos_version))
    error_message = "The talos_version value must be a valid Talos patch version, starting with 'v'."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the Talos cluster, if not set, the K8s version shipped with the selected Talos version will be used. Check https://www.talos.dev/v1.5/introduction/support-matrix/. For example '1.27.6'."
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.kubernetes_version))
    error_message = "The kubernetes_version value must be a valid Kubernetes patch version."
  }

}

variable "controlplane_count" {
  description = "Defines how many controlplane nodes are deployed in the cluster."
  default     = 3
  type        = number
}

variable "workers_count" {
  description = "Defines how many worker nodes are deployed in the cluster."
  default     = 2
  type        = number
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

variable "vpc_id" {
  description = "ID of the VPC where to place the VMs."
  type        = string
}

variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "talos_api_allowed_cidr" {
  description = "The CIDR from which to allow to access the Talos API"
  type        = string
  default     = "0.0.0.0/0"
}

variable "kubernetes_api_allowed_cidr" {
  description = "The CIDR from which to allow to access the Kubernetes API"
  type        = string
  default     = "0.0.0.0/0"
}

variable "config_patch_files" {
  description = "Path to talos config path files that applies to all nodes"
  type        = list(string)
  default     = []
}