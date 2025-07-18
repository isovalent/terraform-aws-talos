variable "cluster_name" {
  description = "Name of cluster"
  type        = string
}

variable "cluster_id" {
  default     = "1"
  description = "The ID of the cluster."
  type        = number
}

variable "iam_instance_profile_control_plane" {
  description = "IAM instance profile to attach to the control plane instances to give AWS CCM the sufficient rights to execute."
  type        = string
  default     = null
}

variable "iam_instance_profile_worker" {
  description = "IAM instance profile to attach to the worker instances to give AWS CCM the sufficient rights to execute."
  type        = string
  default     = null
}

variable "metadata_options" {
  description = "Metadata to attach to the instances."
  type        = map(string)
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 1
  }
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

variable "disable_containerd_nri_plugins" {
  default     = true
  description = "Whether to disable the Talos containerd NRI plugins or not. Talos disables it by default. See https://www.talos.dev/latest/talos-guides/configuration/containerd/#enabling-nri-plugins. Supported since Talos v1.9.2 (see https://github.com/siderolabs/talos/discussions/10068)."
  type        = bool
}

variable "allow_workload_on_cp_nodes" {
  default     = false
  description = "Allow workloads on CP nodes or not. Allowing it means Talos Linux default taints are removed from CP nodes which is typically required for single-node clusters. More details here: https://www.talos.dev/v1.5/talos-guides/howto/workers-on-controlplane/"
  type        = bool
}

variable "talos_version" {
  default     = "v1.10.4"
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
    # Accept empty value or enforce semantic version pattern if set
    condition     = var.kubernetes_version == "" || can(regex("^\\d+\\.\\d+\\.\\d+$", var.kubernetes_version))
    error_message = "The kubernetes_version value must be either empty or a valid Kubernetes patch version (e.g., 1.29.3)."
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
  default     = {}
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

variable "external_source_cidrs" {
  description = "Specify the external source CIDRs (use /32 for specific IP addresses) allowed for inbound traffic."
  type        = list(string)
}

variable "config_patch_files" {
  default     = []
  description = "Path to talos config path files that applies to all nodes"
  type        = list(string)
}

variable "admission_plugins" {
  description = "List of admission plugins to enable"
  type        = string
  default     = "MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ServiceAccount"
}

variable "enable_external_cloud_provider" {
  default     = false
  description = "Whether to enable or disable externalCloudProvider support. See https://kubernetes.io/docs/tasks/administer-cluster/running-cloud-controller/."
  type        = bool
}

variable "deploy_external_cloud_provider_iam_policies" {
  default     = false
  description = "Whether to auto-deploy the externalCloudProvider-required IAM policies. See https://cloud-provider-aws.sigs.k8s.io/prerequisites/."
  type        = bool
  validation {
    condition     = (var.deploy_external_cloud_provider_iam_policies && var.enable_external_cloud_provider) || (!var.deploy_external_cloud_provider_iam_policies)
    error_message = "externalCloudProvider support needs to be enabled when trying to deploy the externalCloudProvider-required IAM policies."
  }
}

variable "external_cloud_provider_manifest" {
  default     = "https://raw.githubusercontent.com/isovalent/terraform-aws-talos/main/manifests/aws-cloud-controller.yaml"
  description = "externalCloudProvider manifest to be applied if var.enable_external_cloud_provider is enabled. If you want to deploy it manually (e.g., via Helm chart), enable var.enable_external_cloud_provider but set this value to an empty string (\"\"). See https://kubernetes.io/docs/tasks/administer-cluster/running-cloud-controller/."
  type        = string
}
