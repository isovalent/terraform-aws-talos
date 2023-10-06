# terraform-aws-talos

A Terraform module to manage a Talos-based Kubernetes on AWS (EC2 instances). Is uses the official [Talos Terraform provider](https://github.com/siderolabs/terraform-provider-talos) in the background. In addition, we mainly followed the [siderolabs/contrib example](https://github.com/siderolabs/contrib/tree/main/examples/terraform/aws) on how to use this upstream provider on AWS.

## Supported Features

- Install Talos Linux OS EC2 VMs
  - It's only supported to deploy them in public subnets
- Bootstrap Talos Kubernetes cluster
- Cilium Kube-Proxy replacement
- Install AWS Cloud Controller Manager

## Example Usage
```
// Create a Talos Linux cluster
module "talos" {
  source = "git::https://github.com/isovalent/terraform-aws-talos?ref=<RELEASE_TAG>"

  // Supported Talos versions (and therefore K8s versions) can be found here: https://github.com/siderolabs/talos/releases
  talos_version = "v1.5.3"
  cluster_name  = "talos-cute"
  region        = "eu-west-1"
  tags          = local.tags
  // VPC needs to be created in advance via https://github.com/isovalent/terraform-aws-vpc
  vpc_id        = module.vpc.id
  pod_cidr      = "100.64.0.0/14"
  service_cidr  = "100.68.0.0/16"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.4.0-alpha.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_talos"></a> [talos](#provider\_talos) | 0.4.0-alpha.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster_sg"></a> [cluster\_sg](#module\_cluster\_sg) | terraform-aws-modules/security-group/aws | ~> 5.1 |
| <a name="module_elb_k8s_elb"></a> [elb\_k8s\_elb](#module\_elb\_k8s\_elb) | terraform-aws-modules/elb/aws | ~> 4.0 |
| <a name="module_kubernetes_api_sg"></a> [kubernetes\_api\_sg](#module\_kubernetes\_api\_sg) | terraform-aws-modules/security-group/aws//modules/https-443 | ~> 5.1 |
| <a name="module_talos_control_plane_nodes"></a> [talos\_control\_plane\_nodes](#module\_talos\_control\_plane\_nodes) | terraform-aws-modules/ec2-instance/aws | ~> 5.5 |
| <a name="module_talos_worker_group"></a> [talos\_worker\_group](#module\_talos\_worker\_group) | terraform-aws-modules/ec2-instance/aws | ~> 5.5 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.control_plane_ccm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.worker_ccm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [null_resource.wait_for_public_subnets](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [talos_machine_bootstrap.this](https://registry.terraform.io/providers/siderolabs/talos/0.4.0-alpha.0/docs/resources/machine_bootstrap) | resource |
| [talos_machine_configuration_apply.controlplane](https://registry.terraform.io/providers/siderolabs/talos/0.4.0-alpha.0/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_configuration_apply.worker_group](https://registry.terraform.io/providers/siderolabs/talos/0.4.0-alpha.0/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/0.4.0-alpha.0/docs/resources/machine_secrets) | resource |
| [aws_ami.talos](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [talos_client_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/0.4.0-alpha.0/docs/data-sources/client_configuration) | data source |
| [talos_cluster_health.this](https://registry.terraform.io/providers/siderolabs/talos/0.4.0-alpha.0/docs/data-sources/cluster_health) | data source |
| [talos_cluster_kubeconfig.this](https://registry.terraform.io/providers/siderolabs/talos/0.4.0-alpha.0/docs/data-sources/cluster_kubeconfig) | data source |
| [talos_machine_configuration.controlplane](https://registry.terraform.io/providers/siderolabs/talos/0.4.0-alpha.0/docs/data-sources/machine_configuration) | data source |
| [talos_machine_configuration.worker_group](https://registry.terraform.io/providers/siderolabs/talos/0.4.0-alpha.0/docs/data-sources/machine_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ccm"></a> [ccm](#input\_ccm) | Whether to deploy aws cloud controller manager | `bool` | `false` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of cluster | `string` | n/a | yes |
| <a name="input_config_patch_files"></a> [config\_patch\_files](#input\_config\_patch\_files) | Path to talos config path files that applies to all nodes | `list(string)` | `[]` | no |
| <a name="input_control_plane"></a> [control\_plane](#input\_control\_plane) | Info for control plane that will be created | <pre>object({<br>    instance_type      = optional(string, "m5.large")<br>    ami_id             = optional(string, null)<br>    num_instances      = optional(number, 3)<br>    config_patch_files = optional(list(string), [])<br>    tags               = optional(map(string), {})<br>  })</pre> | `{}` | no |
| <a name="input_kubernetes_api_allowed_cidr"></a> [kubernetes\_api\_allowed\_cidr](#input\_kubernetes\_api\_allowed\_cidr) | The CIDR from which to allow to access the Kubernetes API | `string` | `"0.0.0.0/0"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version to use for the Talos cluster, if not set, the K8s version shipped with the selected Talos version will be used. Check https://www.talos.dev/v1.5/introduction/support-matrix/. For example '1.27.3'. | `string` | `""` | no |
| <a name="input_pod_cidr"></a> [pod\_cidr](#input\_pod\_cidr) | The CIDR to use for pods. | `string` | `"100.64.0.0/14"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which to create the RKE2 cluster. | `string` | n/a | yes |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | The CIDR to use for services. | `string` | `"100.68.0.0/16"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The set of tags to place on the cluster. | `map(string)` | n/a | yes |
| <a name="input_talos_api_allowed_cidr"></a> [talos\_api\_allowed\_cidr](#input\_talos\_api\_allowed\_cidr) | The CIDR from which to allow to access the Talos API | `string` | `"0.0.0.0/0"` | no |
| <a name="input_talos_version"></a> [talos\_version](#input\_talos\_version) | Talos version to use for the cluster, if not set, the newest Talos version. Check https://github.com/siderolabs/talos/releases for available releases. | `string` | `"v1.5.3"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The IPv4 CIDR block for the VPC. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where to place the VMs. | `string` | n/a | yes |
| <a name="input_worker_groups"></a> [worker\_groups](#input\_worker\_groups) | List of node worker node groups to create | <pre>list(object({<br>    name               = string<br>    instance_type      = optional(string, "m5.large")<br>    ami_id             = optional(string, null)<br>    num_instances      = optional(number, 2)<br>    config_patch_files = optional(list(string), [])<br>    tags               = optional(map(string), {})<br>  }))</pre> | <pre>[<br>  {<br>    "name": "default"<br>  }<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_path_to_kubeconfig_file"></a> [path\_to\_kubeconfig\_file](#output\_path\_to\_kubeconfig\_file) | The generated kubeconfig. |
| <a name="output_path_to_talosconfig_file"></a> [path\_to\_talosconfig\_file](#output\_path\_to\_talosconfig\_file) | The generated talosconfig. |
<!-- END_TF_DOCS -->