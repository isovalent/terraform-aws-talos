# terraform-aws-talos

A Terraform module to manage a Talos-based Kubernetes on AWS (EC2 instances). Is uses the official [Talos Terraform provider](https://github.com/siderolabs/terraform-provider-talos) in the background. We mainly followed the provided [siderolabs/contrib](https://github.com/siderolabs/contrib/tree/main/examples/terraform/aws) example.

## Supported Features

- Install Talos Linux OS EC2 VMs
  - For now, it's only supported to deploy the VMs in public subnets with public IPs assigned
- Support for single- and multi-node cluster architectures
- Bootstrap Talos Kubernetes cluster with some infrastructure components:
  - [Talos' KubePrism](https://www.talos.dev/v1.5/kubernetes-guides/configuration/kubeprism/) to get an internal endpoint for the KAPI (used for [Cilium Kube-Proxy replacement](https://docs.cilium.io/en/stable/network/kubernetes/kubeproxy-free/))
  - [kubernetes-sigs/metrics-server](https://github.com/kubernetes-sigs/metrics-server/)
  - [alex1989hu/kubelet-serving-cert-approver](https://github.com/alex1989hu/kubelet-serving-cert-approver) inspired by [Talos' Deploying Metrics Server](https://www.talos.dev/v1.5/kubernetes-guides/configuration/deploy-metrics-server/) guide.
- Cilium features:
  - [Kube-Proxy replacement](https://docs.cilium.io/en/stable/network/kubernetes/kubeproxy-free/)
  - [IPAM modes](https://docs.cilium.io/en/stable/network/concepts/ipam/): `kubernetes`, `cluster-pool`

## Example Usage
```
// Create a Talos Linux cluster
module "talos" {
  source = "git::https://github.com/isovalent/terraform-aws-talos?ref=<RELEASE_TAG>"

  // Supported Talos versions (and therefore K8s versions) can be found here: https://github.com/siderolabs/talos/releases
  talos_version      = "v1.5.3"
  kubernetes_version = "1.27.3"
  cluster_name       = "talos-cute"
  region             = "eu-west-1"
  tags               = local.tags
  // VPC needs to be created in advance via https://github.com/isovalent/terraform-aws-vpc
  vpc_id             = module.vpc.id
  pod_cidr           = "100.64.0.0/14"
  service_cidr       = "100.68.0.0/16"
}
```

## Terraform Module Doc
<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.5 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.5.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.5 |
| <a name="provider_talos"></a> [talos](#provider\_talos) | 0.5.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster_sg"></a> [cluster\_sg](#module\_cluster\_sg) | terraform-aws-modules/security-group/aws | ~> 5.1 |
| <a name="module_elb_k8s_elb"></a> [elb\_k8s\_elb](#module\_elb\_k8s\_elb) | terraform-aws-modules/elb/aws | ~> 4.0 |
| <a name="module_kubernetes_api_sg"></a> [kubernetes\_api\_sg](#module\_kubernetes\_api\_sg) | terraform-aws-modules/security-group/aws//modules/https-443 | ~> 5.1 |
| <a name="module_talos_control_plane_nodes"></a> [talos\_control\_plane\_nodes](#module\_talos\_control\_plane\_nodes) | terraform-aws-modules/ec2-instance/aws | ~> 5.5 |
| <a name="module_talos_worker_group"></a> [talos\_worker\_group](#module\_talos\_worker\_group) | terraform-aws-modules/ec2-instance/aws | ~> 5.5 |

### Resources

| Name | Type |
|------|------|
| [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.talosconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.wait_for_public_subnets](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.workspace_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [talos_machine_bootstrap.this](https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/resources/machine_bootstrap) | resource |
| [talos_machine_configuration_apply.controlplane](https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_configuration_apply.worker_group](https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/resources/machine_secrets) | resource |
| [aws_ami.talos](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [talos_client_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/data-sources/client_configuration) | data source |
| [talos_cluster_kubeconfig.this](https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/data-sources/cluster_kubeconfig) | data source |
| [talos_machine_configuration.controlplane](https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/data-sources/machine_configuration) | data source |
| [talos_machine_configuration.worker_group](https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/data-sources/machine_configuration) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocate_node_cidrs"></a> [allocate\_node\_cidrs](#input\_allocate\_node\_cidrs) | Whether to assign PodCIDRs to Node resources or not. Only needed in case Cilium runs in 'kubernetes' IPAM mode. | `bool` | `true` | no |
| <a name="input_allow_workload_on_cp_nodes"></a> [allow\_workload\_on\_cp\_nodes](#input\_allow\_workload\_on\_cp\_nodes) | Allow workloads on CP nodes or not. Allowing it means Talos Linux default taints are removed from CP nodes. More details here: https://www.talos.dev/v1.5/talos-guides/howto/workers-on-controlplane/ | `bool` | `false` | no |
| <a name="input_cluster_architecture"></a> [cluster\_architecture](#input\_cluster\_architecture) | Cluster architecture. Choose 'arm64' or 'amd64'. If you choose 'arm64', ensure to also override the control\_plane.instance\_type and worker\_groups.instance\_type with an ARM64-based instance type like 'm7g.large'. | `string` | `"amd64"` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | The ID of the cluster. | `number` | `"1"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of cluster | `string` | n/a | yes |
| <a name="input_config_patch_files"></a> [config\_patch\_files](#input\_config\_patch\_files) | Path to talos config path files that applies to all nodes | `list(string)` | `[]` | no |
| <a name="input_control_plane"></a> [control\_plane](#input\_control\_plane) | Info for control plane that will be created | <pre>object({<br>    instance_type      = optional(string, "m5.large")<br>    config_patch_files = optional(list(string), [])<br>    tags               = optional(map(string), {})<br>  })</pre> | `{}` | no |
| <a name="input_controlplane_count"></a> [controlplane\_count](#input\_controlplane\_count) | Defines how many controlplane nodes are deployed in the cluster. | `number` | `3` | no |
| <a name="input_disable_kube_proxy"></a> [disable\_kube\_proxy](#input\_disable\_kube\_proxy) | Whether to deploy Kube-Proxy or not. By default, KP shouldn't be deployed. | `bool` | `true` | no |
| <a name="input_kubernetes_api_allowed_cidr"></a> [kubernetes\_api\_allowed\_cidr](#input\_kubernetes\_api\_allowed\_cidr) | The CIDR from which to allow to access the Kubernetes API | `string` | `"0.0.0.0/0"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version to use for the Talos cluster, if not set, the K8s version shipped with the selected Talos version will be used. Check https://www.talos.dev/v1.5/introduction/support-matrix/. For example '1.27.6'. | `string` | `""` | no |
| <a name="input_pod_cidr"></a> [pod\_cidr](#input\_pod\_cidr) | The CIDR to use for Pods. Only required in case allocate\_node\_cidrs is set to 'true'. Otherwise, simply configure it inside Cilium's Helm values. | `string` | `"100.64.0.0/14"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which to create the Talos Linux cluster. | `string` | n/a | yes |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | The CIDR to use for services. | `string` | `"100.68.0.0/16"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The set of tags to place on the cluster. | `map(string)` | n/a | yes |
| <a name="input_talos_api_allowed_cidr"></a> [talos\_api\_allowed\_cidr](#input\_talos\_api\_allowed\_cidr) | The CIDR from which to allow to access the Talos API | `string` | `"0.0.0.0/0"` | no |
| <a name="input_talos_version"></a> [talos\_version](#input\_talos\_version) | Talos version to use for the cluster, if not set, the newest Talos version. Check https://github.com/siderolabs/talos/releases for available releases. | `string` | `"v1.6.1"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The IPv4 CIDR block for the VPC. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where to place the VMs. | `string` | n/a | yes |
| <a name="input_worker_groups"></a> [worker\_groups](#input\_worker\_groups) | List of node worker node groups to create | <pre>list(object({<br>    name               = string<br>    instance_type      = optional(string, "m5.large")<br>    config_patch_files = optional(list(string), [])<br>    tags               = optional(map(string), {})<br>  }))</pre> | <pre>[<br>  {<br>    "name": "default"<br>  }<br>]</pre> | no |
| <a name="input_workers_count"></a> [workers\_count](#input\_workers\_count) | Defines how many worker nodes are deployed in the cluster. | `number` | `2` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of cluster |
| <a name="output_elb_dns_name"></a> [elb\_dns\_name](#output\_elb\_dns\_name) | Public ELB DNS name. |
| <a name="output_path_to_kubeconfig_file"></a> [path\_to\_kubeconfig\_file](#output\_path\_to\_kubeconfig\_file) | The generated kubeconfig. |
| <a name="output_path_to_talosconfig_file"></a> [path\_to\_talosconfig\_file](#output\_path\_to\_talosconfig\_file) | The generated talosconfig. |
<!-- END_TF_DOCS -->