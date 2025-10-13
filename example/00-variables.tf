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
  default     = "amd64"
  description = "Cluster architecture. Choose 'arm64' or 'amd64'. If you choose 'arm64', ensure to also override the control_plane.instance_type and worker_groups.instance_type with an ARM64-based instance type like 'm7g.large'."
  type        = string
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
  default     = "v1.11.2"
  description = "Talos version to use for the cluster, if not set the newest Talos version. Check https://github.com/siderolabs/talos/releases for available releases."
  type        = string
}

variable "kubernetes_version" {
  default     = "1.34.1"
  description = "Kubernetes version to use for the Talos cluster, if not set, the K8s version shipped with the selected Talos version will be used. Check https://www.talos.dev/latest/introduction/support-matrix/."
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

# Cilium module
variable "cilium_namespace" {
  default     = "kube-system"
  description = "The namespace in which to install Cilium."
  type        = string
}

variable "cilium_helm_chart" {
  default     = "cilium/cilium"
  description = "The name of the Helm chart to be used. The naming depends on the Helm repo naming on the local machine."
  type        = string
}

variable "cilium_helm_version" {
  default     = "1.17.4"
  description = "The version of the used Helm chart. Check https://github.com/cilium/cilium/releases to see available versions."
  type        = string
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

# Tetragon
variable "tetragon_namespace" {
  default     = "kube-system"
  description = "The namespace in which to install Tetragon."
  type        = string
}

variable "tetragon_helm_chart" {
  default     = "cilium/tetragon"
  description = "The name of the Helm chart to use to install Tetragon. It is assumed that the Helm repository containing this chart has been added beforehand (e.g. using 'helm repo add')."
  type        = string
}

variable "tetragon_helm_values_file_path" {
  default     = "04-tetragon-values.yaml"
  description = "The path to the file containing the values to use when installing Tetragon."
  type        = string
}

variable "tetragon_helm_values_override_file_path" {
  default     = ""
  description = "The path to the file containing the values to use when installing Tetragon. These values will override the ones in 'tetragon_helm_values_file_path'."
  type        = string
}

variable "tetragon_tracingpolicy_directory" {
  default     = ""
  description = "Path to the directory where TracingPolicy files are stored which should automatically be applied. The directory can contain one or multiple valid TracingPoliciy YAML files."
  type        = string
}

variable "tetragon_helm_version" {
  default     = "1.4.0"
  description = "The version of the Tetragon Helm chart to install."
  type        = string
}
