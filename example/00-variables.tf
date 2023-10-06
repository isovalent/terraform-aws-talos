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
    customer = "talos"
  }
  description = "The set of tags to place on the created resources. These will be merged with the default tags defined via local.tags in 00-locals.tf."
  type        = map(string)
}

# talos module
variable "talos_version" {
  default     = "v1.5.3"
  type        = string
  description = "Talos version to use for the cluster, if not set the newest Talos version. Check https://github.com/siderolabs/talos/releases for available releases."
}

variable "service_cidr" {
  default     = "100.68.0.0/16"
  description = "The CIDR to use for K8s Services"
  type        = string
}

# Cilium module
variable "pod_cidr" {
  default     = "100.64.0.0/14"
  description = "The CIDR to use for K8s Pods-"
  type        = string
}

variable "cilium_helm_chart" {
  default     = "isovalent/cilium"
  type        = string
  description = "The name of the Helm chart used by the customer."
}

variable "cilium_helm_version" {
  default     = "1.14.2-cee.beta.1"
  type        = string
  description = "The version of the Helm charts used by the customer."
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