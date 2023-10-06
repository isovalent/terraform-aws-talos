# Example CuTE for Talos Terraform Module

The data in this folder represents our best attempt at recreating an Talos Linux environment similar to Customer XY.

The Customer Reproduction Environment is based on the contents of:
* `03-cilium-values.yaml`
* `terraform.tfvars` <- to be created by you

These files will need to be updated if changes are made to the customer's environment. 

## Creating the CuTE

1. Ensure that [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli), the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), [talosctl](https://www.talos.dev/v1.5/learn-more/talosctl/) (via [Github releases](https://github.com/siderolabs/talos/releases)) and [kubectl](https://kubernetes.io/docs/tasks/tools/) are installed. You can verify these with:

```
terraform --version
aws --version
talosctl version
kubectl version
```

2. Create a `terraform.tfvars` file in the current directory containing something similar to the following:

```
cluster_name            = "talos-cute" // Optional
region                  = "<your-region>"
owner                   = "<your-name>"
```

For example:
```
cluster_name            = "talos-cute"
region                  = "eu-west-1"
owner                   = "philip"
```

3. Make sure the AWS user you have configured has enough privileges to create the necessary resources.
If necessary, grab the credentials for the AWS `terraform` user from [here](https://start.1password.com/open/i?a=JEHLBUMZZVGXXEGBEHTXZBCHCE&v=lgf2d25rbg3j2br3otrai6m63a&i=abtnwj6uurafhm4qs76taoaacm&h=isovalent.1password.com) and use that one.

4. Run the following commands: 

```
make apply
```

Please ping [@Philip](https://isovalent.slack.com/team/D04FW9CR8H5) or [#customer-success](https://isovalent.slack.com/archives/C03S3K4RJDA) for any questions.

## Using the CuTE

Once Terraform has completed creating the CuTE it will create a KubeConfig file you can use to access the CuTE. Use the following commmand to access the CuTE:

```bash
kubectl --kubeconfig $(terraform output --raw path_to_kubeconfig_file) get nodes
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

<!-- END_TF_DOCS -->