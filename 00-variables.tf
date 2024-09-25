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
  default     = "amd64"
  description = "Cluster architecture. Choose 'arm64' or 'amd64'. If you choose 'arm64', ensure to also override the control_plane.instance_type and worker_groups.instance_type with an ARM64-based instance type like 'm7g.large'."
  type        = string
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
  default     = true
  description = "Whether to assign PodCIDRs to Node resources or not. Only needed in case Cilium runs in 'kubernetes' IPAM mode."
  type        = bool
}

variable "pod_cidr" {
  default     = "100.64.0.0/14"
  description = "The CIDR to use for Pods. Only required in case allocate_node_cidrs is set to 'true'. Otherwise, simply configure it inside Cilium's Helm values."
  type        = string
}

variable "service_cidr" {
  default     = "100.68.0.0/16"
  description = "The CIDR to use for services."
  type        = string
}

variable "disable_kube_proxy" {
  default     = true
  description = "Whether to deploy Kube-Proxy or not. By default, KP shouldn't be deployed."
  type        = bool
}

variable "allow_workload_on_cp_nodes" {
  default     = false
  description = "Allow workloads on CP nodes or not. Allowing it means Talos Linux default taints are removed from CP nodes. More details here: https://www.talos.dev/v1.5/talos-guides/howto/workers-on-controlplane/"
  type        = bool
}

variable "talos_version" {
  default     = "v1.8.0"
  description = "Talos version to use for the cluster, if not set, the newest Talos version. Check https://github.com/siderolabs/talos/releases for available releases."
  type        = string
  validation {
    condition     = can(regex("^v\\d+\\.\\d+\\.\\d+$", var.talos_version))
    error_message = "The talos_version value must be a valid Talos patch version, starting with 'v'."
  }
}

variable "kubernetes_version" {
  default     = ""
  description = "Kubernetes version to use for the Talos cluster, if not set, the K8s version shipped with the selected Talos version will be used. Check https://www.talos.dev/latest/introduction/support-matrix/. For example '1.29.3'."
  type        = string
  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.kubernetes_version))
    error_message = "The kubernetes_version value must be a valid Kubernetes patch version."
  }

}

variable "controlplane_count" {
  default     = 3
  description = "Defines how many controlplane nodes are deployed in the cluster."
  type        = number
}

variable "workers_count" {
  default     = 2
  description = "Defines how many worker nodes are deployed in the cluster."
  type        = number
}

variable "control_plane" {
  default = {}
  description = "Info for control plane that will be created"
  type = object({
    instance_type      = optional(string, "m5.large")
    config_patch_files = optional(list(string), [])
    tags               = optional(map(string), {})
  })
}

variable "worker_groups" {
  default = [{
    name = "default"
  }]
  description = "List of node worker node groups to create"
  type = list(object({
    name               = string
    instance_type      = optional(string, "m5.large")
    config_patch_files = optional(list(string), [])
    tags               = optional(map(string), {})
  }))
}

variable "vpc_id" {
  description = "ID of the VPC where to place the VMs."
  type        = string
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "The IPv4 CIDR block for the VPC."
  type        = string
}

variable "talos_api_allowed_cidr" {
  default     = "0.0.0.0/0"
  description = "The CIDR from which to allow to access the Talos API"
  type        = string
}

variable "kubernetes_api_allowed_cidr" {
  default     = "0.0.0.0/0"
  description = "The CIDR from which to allow to access the Kubernetes API"
  type        = string
}

variable "config_patch_files" {
  default     = []
  description = "Path to talos config path files that applies to all nodes"
  type        = list(string)
}