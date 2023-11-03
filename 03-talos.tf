module "talos_control_plane_nodes" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.5"

  count = var.controlplane_count

  name                        = "${var.cluster_name}-control-plane-${count.index}"
  ami                         = local.ami_id
  monitoring                  = true
  instance_type               = var.control_plane.instance_type
  subnet_id                   = element(data.aws_subnets.public.ids, count.index)
  associate_public_ip_address = true
  tags                        = merge(var.tags, local.cluster_required_tags)

  vpc_security_group_ids = [module.cluster_sg.security_group_id]

  root_block_device = [
    {
      volume_size = 50
    }
  ]
}

module "talos_worker_group" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.5"

  for_each = merge([for info in var.worker_groups : { for index in range(0, var.workers_count) : "${info.name}.${index}" => info }]...)

  name                        = "${var.cluster_name}-worker-group-${each.value.name}-${trimprefix(each.key, "${each.value.name}.")}"
  ami                         = local.ami_id
  monitoring                  = true
  instance_type               = each.value.instance_type
  subnet_id                   = element(data.aws_subnets.public.ids, tonumber(trimprefix(each.key, "${each.value.name}.")))
  associate_public_ip_address = true
  tags                        = merge(each.value.tags, var.tags, local.cluster_required_tags)

  vpc_security_group_ids = [module.cluster_sg.security_group_id]

  root_block_device = [
    {
      volume_size = 50
    }
  ]
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${module.elb_k8s_elb.elb_dns_name}"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.kubernetes_version
  talos_version      = var.talos_version
  docs               = false
  examples           = false
  config_patches = concat(
    local.config_patches_common,
    [yamlencode(local.common_config_patch)],
    [yamlencode(local.config_cilium_patch)],
    [for path in var.control_plane.config_patch_files : file(path)]
  )
}

data "talos_machine_configuration" "worker_group" {
  for_each = merge([for info in var.worker_groups : { for index in range(0, var.workers_count) : "${info.name}.${index}" => info }]...)

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${module.elb_k8s_elb.elb_dns_name}"
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.kubernetes_version
  talos_version      = var.talos_version
  docs               = false
  examples           = false
  config_patches = concat(
    local.config_patches_common,
    [yamlencode(local.common_config_patch)],
    [yamlencode(local.config_cilium_patch)],
    [for path in each.value.config_patch_files : file(path)]
  )
}

resource "talos_machine_configuration_apply" "controlplane" {
  count = var.controlplane_count

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  endpoint                    = module.talos_control_plane_nodes[count.index].public_ip
  node                        = module.talos_control_plane_nodes[count.index].private_ip
}

resource "talos_machine_configuration_apply" "worker_group" {
  for_each = merge([for info in var.worker_groups : { for index in range(0, var.workers_count) : "${info.name}.${index}" => info }]...)

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker_group[each.key].machine_configuration
  endpoint                    = module.talos_worker_group[each.key].public_ip
  node                        = module.talos_worker_group[each.key].private_ip
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = module.talos_control_plane_nodes.0.public_ip
  node                 = module.talos_control_plane_nodes.0.private_ip
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = module.talos_control_plane_nodes.*.public_ip
}

resource "local_file" "talosconfig" {
  content  = nonsensitive(data.talos_client_configuration.this.talos_config)
  filename = local.path_to_talosconfig_file
}

data "talos_cluster_kubeconfig" "this" {
  depends_on = [talos_machine_bootstrap.this]

  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = module.talos_control_plane_nodes.0.public_ip
  node                 = module.talos_control_plane_nodes.0.private_ip
}

resource "local_file" "kubeconfig" {
  content  = nonsensitive(data.talos_cluster_kubeconfig.this.kubeconfig_raw)
  filename = local.path_to_kubeconfig_file
}

# Does currently not work because of the nodes reachability from the internet.
# data "talos_cluster_health" "this" {
#   depends_on = [data.talos_cluster_kubeconfig.this]

#   client_configuration = talos_machine_secrets.this.client_configuration
#   endpoints            = module.talos_control_plane_nodes.*.public_ip
#   control_plane_nodes  = module.talos_control_plane_nodes.*.private_ip
#   worker_nodes         = [for node in module.talos_worker_group : node.private_ip]
# }