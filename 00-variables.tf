variable "cluster_name" {
  description = "Name of cluster"
  type        = string
}

variable "region" {
  description = "The region in which to create the RKE2 cluster."
  type        = string
}

variable "tags" {
  description = "The set of tags to place on the cluster."
  type        = map(string)
}

variable "pod_cidr" {
  description = "The CIDR to use for pods."
  default     = "100.64.0.0/14"
  type        = string
}

variable "service_cidr" {
  description = "The CIDR to use for services."
  default     = "100.68.0.0/16"
  type        = string
}

variable "kube_proxy" {
  description = "Whether to deploy Kube-Proxy or not. By default, KP shouldn't be deployed."
  type        = bool
  default     = false
}

variable "ccm" {
  description = "Whether to deploy aws cloud controller manager"
  type        = bool
  default     = false
}

variable "talos_version" {
  description = "Talos version to use for the cluster, if not set, the newest Talos version. Check https://github.com/siderolabs/talos/releases for available releases."
  type        = string
  default     = "v1.5.3"

  validation {
    condition     = can(regex("^v\\d+\\.\\d+\\.\\d+$", var.talos_version))
    error_message = "The talos_version value must be a valid Talos patch version, starting with 'v'."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the Talos cluster, if not set, the K8s version shipped with the selected Talos version will be used. Check https://www.talos.dev/v1.5/introduction/support-matrix/. For example '1.27.3'."
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.kubernetes_version))
    error_message = "The kubernetes_version value must be a valid Kubernetes patch version."
  }

}

variable "control_plane" {
  description = "Info for control plane that will be created"
  type = object({
    instance_type      = optional(string, "m5.large")
    ami_id             = optional(string, null)
    num_instances      = optional(number, 3)
    config_patch_files = optional(list(string), [])
    tags               = optional(map(string), {})
  })

  validation {
    condition     = var.control_plane.ami_id != null ? (length(var.control_plane.ami_id) > 4 && substr(var.control_plane.ami_id, 0, 4) == "ami-") : true
    error_message = "The ami_id value must be a valid AMI id, starting with \"ami-\"."
  }

  default = {}
}

variable "worker_groups" {
  description = "List of node worker node groups to create"
  type = list(object({
    name               = string
    instance_type      = optional(string, "m5.large")
    ami_id             = optional(string, null)
    num_instances      = optional(number, 2)
    config_patch_files = optional(list(string), [])
    tags               = optional(map(string), {})
  }))

  validation {
    condition = (
      alltrue([
        for wg in var.worker_groups : (
          wg.ami_id != null ? (length(wg.ami_id) > 4 && substr(wg.ami_id, 0, 4) == "ami-") : true
        )
      ])
    )
    error_message = "The ami_id value must be a valid AMI id, starting with \"ami-\"."
  }
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
  default     = ["./manifests/cilium-patch.yaml"]
}