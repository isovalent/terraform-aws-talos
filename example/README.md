# Example CuTE for Talos Terraform Module

The Customer Reproduction Environment is based on the contents of:
* `03-cilium-values.yaml`
* `terraform.tfvars` <- to be created by you

These files will need to be updated if changes are made to the customer's environment.

## Creating the CuTE

1. Ensure that [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli), the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), [talosctl](https://www.talos.dev/v1.5/learn-more/talosctl/) (via [Github releases](https://github.com/siderolabs/talos/releases)) and [kubectl](https://kubernetes.io/docs/tasks/tools/) are installed. You can verify these with:

```
terraform --version
aws --version
talosctl version --client
kubectl version --client
```

2. Create a `terraform.tfvars` file in the current directory containing something similar to the following:

```
cluster_name = "talos-cute" // Optional
region       = "<your-region>"
owner        = "<your-name>"
```

For example:
```
cluster_name = "talos-cute"
region       = "eu-west-1"
owner        = "philip"
```

3. Make sure the AWS user you have configured has enough privileges to create the necessary resources.
If necessary, grab the credentials for the AWS `terraform` user from [here](https://start.1password.com/open/i?a=JEHLBUMZZVGXXEGBEHTXZBCHCE&v=lgf2d25rbg3j2br3otrai6m63a&i=abtnwj6uurafhm4qs76taoaacm&h=isovalent.1password.com) and use that one.

4. Run the following commands:

```
make apply
```

### ARM64 CuTE
In order to start an ARM64-based Talos cluster, add the following values to your `terraform.tfvars`:
```
cluster_name         = "talos-cute" // Optional
region               = "<your-region>"
owner                = "<your-name>"
cluster_architecture = "arm64"
control_plane = {
  instance_type = "m7g.large"
}
worker_groups = [{
  name          = "default",
  instance_type = "m7g.large"
}]
```

## Using the CuTE

Once Terraform has completed creating the CuTE it will create a KubeConfig file you can use to access the CuTE. Use the following commands to access the CuTE:

```bash
# Working the the K8s cluster:
KUBECONFIG=$(terraform output --raw path_to_kubeconfig_file)
kubectl get nodes
# Working with talosctl
TALOSCONFIG=$(terraform output --raw path_to_talosconfig_file)
talosctl info
talosctl version
talosctl health -n <specific-node-ip>
talosctl service
talosctl get members
# Optionally, print the Talos machineconfig:
talosctl get machineconfig -o yaml
```

## Destroying the CuTE

Once you are done using the CuTE please tear it down using the following commands:

```
make destroy
```

If the above destroy command fails, consider deleting the remaining resources using the [AWS-Delete-VPC tool](https://github.com/isovalent/aws-delete-vpc):
```
aws-delete-vpc -cluster-name <Name of your cluster>
```

## Terraform Module Doc
<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.7 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.7 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cilium"></a> [cilium](#module\_cilium) | git::https://github.com/isovalent/terraform-k8s-cilium.git | v1.6.6 |
| <a name="module_talos"></a> [talos](#module\_talos) | ../ | n/a |
| <a name="module_tetragon"></a> [tetragon](#module\_tetragon) | git::https://github.com/isovalent/terraform-k8s-tetragon.git | v0.6.1 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git::https://github.com/isovalent/terraform-aws-vpc.git | v1.17 |

### Resources

| Name | Type |
|------|------|
| [random_id.cluster](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [external_external.public_ip](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocate_node_cidrs"></a> [allocate\_node\_cidrs](#input\_allocate\_node\_cidrs) | Whether to assign PodCIDRs to Node resources or not. Only needed in case Cilium runs in 'kubernetes' IPAM mode. | `bool` | `false` | no |
| <a name="input_allow_workload_on_cp_nodes"></a> [allow\_workload\_on\_cp\_nodes](#input\_allow\_workload\_on\_cp\_nodes) | Allow workloads on CP nodes or not. Allowing it means Talos Linux default taints are removed from CP nodes which is typically required for single-node clusters. More details here: https://www.talos.dev/v1.5/talos-guides/howto/workers-on-controlplane/ | `bool` | `false` | no |
| <a name="input_cilium_helm_chart"></a> [cilium\_helm\_chart](#input\_cilium\_helm\_chart) | The name of the Helm chart to be used. The naming depends on the Helm repo naming on the local machine. | `string` | `"cilium/cilium"` | no |
| <a name="input_cilium_helm_values_file_path"></a> [cilium\_helm\_values\_file\_path](#input\_cilium\_helm\_values\_file\_path) | Cilium values file | `string` | `"03-cilium-values.yaml"` | no |
| <a name="input_cilium_helm_values_override_file_path"></a> [cilium\_helm\_values\_override\_file\_path](#input\_cilium\_helm\_values\_override\_file\_path) | Override Cilium values file | `string` | `""` | no |
| <a name="input_cilium_helm_version"></a> [cilium\_helm\_version](#input\_cilium\_helm\_version) | The version of the used Helm chart. Check https://github.com/cilium/cilium/releases to see available versions. | `string` | `"1.17.4"` | no |
| <a name="input_cilium_namespace"></a> [cilium\_namespace](#input\_cilium\_namespace) | The namespace in which to install Cilium. | `string` | `"kube-system"` | no |
| <a name="input_cluster_architecture"></a> [cluster\_architecture](#input\_cluster\_architecture) | Cluster architecture. Choose 'arm64' or 'amd64'. If you choose 'arm64', ensure to also override the control\_plane.instance\_type and worker\_groups.instance\_type with an ARM64-based instance type like 'm7g.large'. | `string` | `"amd64"` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | The (Cilium) ID of the cluster. Must be unique for Cilium ClusterMesh and between 0-255. | `number` | `"1"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster. | `string` | `"talos-cute"` | no |
| <a name="input_control_plane"></a> [control\_plane](#input\_control\_plane) | Info for control plane that will be created | <pre>object({<br/>    instance_type      = optional(string, "m5.large")<br/>    config_patch_files = optional(list(string), [])<br/>    tags               = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| <a name="input_controlplane_count"></a> [controlplane\_count](#input\_controlplane\_count) | Defines how many controlplane nodes are deployed in the cluster. | `number` | `3` | no |
| <a name="input_deploy_external_cloud_provider_iam_policies"></a> [deploy\_external\_cloud\_provider\_iam\_policies](#input\_deploy\_external\_cloud\_provider\_iam\_policies) | Whether to auto-deploy the externalCloudProvider-required IAM policies. See https://cloud-provider-aws.sigs.k8s.io/prerequisites/. | `bool` | `false` | no |
| <a name="input_disable_containerd_nri_plugins"></a> [disable\_containerd\_nri\_plugins](#input\_disable\_containerd\_nri\_plugins) | Whether to disable the Talos containerd NRI plugins or not. Talos disables it by default. See https://www.talos.dev/latest/talos-guides/configuration/containerd/#enabling-nri-plugins. Supported since Talos v1.9.2 (see https://github.com/siderolabs/talos/discussions/10068). | `bool` | `true` | no |
| <a name="input_disable_kube_proxy"></a> [disable\_kube\_proxy](#input\_disable\_kube\_proxy) | Whether to deploy Kube-Proxy or not. By default, KP shouldn't be deployed. | `bool` | `true` | no |
| <a name="input_enable_external_cloud_provider"></a> [enable\_external\_cloud\_provider](#input\_enable\_external\_cloud\_provider) | Whether to enable or disable externalCloudProvider support. See https://kubernetes.io/docs/tasks/administer-cluster/running-cloud-controller/. | `bool` | `false` | no |
| <a name="input_external_cloud_provider_manifest"></a> [external\_cloud\_provider\_manifest](#input\_external\_cloud\_provider\_manifest) | externalCloudProvider manifest to be applied if var.enable\_external\_cloud\_provider is enabled. If you want to deploy it manually (e.g., via Helm chart), enable var.enable\_external\_cloud\_provider but set this value to an empty string (""). See https://kubernetes.io/docs/tasks/administer-cluster/running-cloud-controller/. | `string` | `"https://raw.githubusercontent.com/isovalent/terraform-aws-talos/main/manifests/aws-cloud-controller.yaml"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version to use for the Talos cluster, if not set, the K8s version shipped with the selected Talos version will be used. Check https://www.talos.dev/latest/introduction/support-matrix/. | `string` | `"1.34.1"` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner for resource tagging | `string` | n/a | yes |
| <a name="input_pod_cidr"></a> [pod\_cidr](#input\_pod\_cidr) | The CIDR to use for K8s Pods. Depending on if allocate\_node\_cidrs is set or not, it will either be configured on the controllerManager and assigned to Node resources or to CiliumNode CRs (in case Cilium runs with 'cluster-pool' IPAM mode). | `string` | `"100.64.0.0/14"` | no |
| <a name="input_pre_cilium_install_script"></a> [pre\_cilium\_install\_script](#input\_pre\_cilium\_install\_script) | A script to be run before installing Cilium. | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which to create the cluster. | `string` | n/a | yes |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | The CIDR to use for K8s Services | `string` | `"100.68.0.0/16"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The set of tags to place on the created resources. These will be merged with the default tags defined via local.tags in 00-locals.tf. | `map(string)` | <pre>{<br/>  "platform": "talos",<br/>  "usage": "cute"<br/>}</pre> | no |
| <a name="input_talos_version"></a> [talos\_version](#input\_talos\_version) | Talos version to use for the cluster, if not set the newest Talos version. Check https://github.com/siderolabs/talos/releases for available releases. | `string` | `"v1.11.2"` | no |
| <a name="input_tetragon_helm_chart"></a> [tetragon\_helm\_chart](#input\_tetragon\_helm\_chart) | The name of the Helm chart to use to install Tetragon. It is assumed that the Helm repository containing this chart has been added beforehand (e.g. using 'helm repo add'). | `string` | `"cilium/tetragon"` | no |
| <a name="input_tetragon_helm_values_file_path"></a> [tetragon\_helm\_values\_file\_path](#input\_tetragon\_helm\_values\_file\_path) | The path to the file containing the values to use when installing Tetragon. | `string` | `"04-tetragon-values.yaml"` | no |
| <a name="input_tetragon_helm_values_override_file_path"></a> [tetragon\_helm\_values\_override\_file\_path](#input\_tetragon\_helm\_values\_override\_file\_path) | The path to the file containing the values to use when installing Tetragon. These values will override the ones in 'tetragon\_helm\_values\_file\_path'. | `string` | `""` | no |
| <a name="input_tetragon_helm_version"></a> [tetragon\_helm\_version](#input\_tetragon\_helm\_version) | The version of the Tetragon Helm chart to install. | `string` | `"1.4.0"` | no |
| <a name="input_tetragon_namespace"></a> [tetragon\_namespace](#input\_tetragon\_namespace) | The namespace in which to install Tetragon. | `string` | `"kube-system"` | no |
| <a name="input_tetragon_tracingpolicy_directory"></a> [tetragon\_tracingpolicy\_directory](#input\_tetragon\_tracingpolicy\_directory) | Path to the directory where TracingPolicy files are stored which should automatically be applied. The directory can contain one or multiple valid TracingPoliciy YAML files. | `string` | `""` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR to use for the VPC. Currently it must be a /16 or /24. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_worker_groups"></a> [worker\_groups](#input\_worker\_groups) | List of node worker node groups to create | <pre>list(object({<br/>    name               = string<br/>    instance_type      = optional(string, "m5.large")<br/>    config_patch_files = optional(list(string), [])<br/>    tags               = optional(map(string), {})<br/>  }))</pre> | <pre>[<br/>  {<br/>    "name": "default"<br/>  }<br/>]</pre> | no |
| <a name="input_workers_count"></a> [workers\_count](#input\_workers\_count) | Defines how many worker nodes are deployed in the cluster. | `number` | `2` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cilium_namespace"></a> [cilium\_namespace](#output\_cilium\_namespace) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Cluster name |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | Public NLB DNS name. |
| <a name="output_path_to_kubeconfig_file"></a> [path\_to\_kubeconfig\_file](#output\_path\_to\_kubeconfig\_file) | Path to the kubeconfig of the Talos Linux cluster |
| <a name="output_path_to_talosconfig_file"></a> [path\_to\_talosconfig\_file](#output\_path\_to\_talosconfig\_file) | Path to the talosconfig of the Talos Linux cluster |
| <a name="output_region"></a> [region](#output\_region) | AWS region used for the infra |
<!-- END_TF_DOCS -->
