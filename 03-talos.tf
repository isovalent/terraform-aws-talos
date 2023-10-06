module "talos_control_plane_nodes" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.5"

  count = var.control_plane.num_instances

  name                        = "${var.cluster_name}-control-plane-${count.index}"
  ami                         = var.control_plane.ami_id == null ? data.aws_ami.talos.id : var.control_plane.ami_id
  monitoring                  = true
  instance_type               = var.control_plane.instance_type
  subnet_id                   = element(data.aws_subnets.public.ids, count.index)
  iam_role_use_name_prefix    = false
  create_iam_instance_profile = var.ccm ? true : false
  iam_role_policies = var.ccm ? {
    "${var.cluster_name}-control-plane-ccm-policy" : aws_iam_policy.control_plane_ccm_policy[0].arn,
  } : {}
  tags = merge(var.tags, local.cluster_required_tags)

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

  for_each = merge([for info in var.worker_groups : { for index in range(0, info.num_instances) : "${info.name}.${index}" => info }]...)

  name                        = "${var.cluster_name}-worker-group-${each.value.name}-${trimprefix(each.key, "${each.value.name}.")}"
  ami                         = each.value.ami_id == null ? data.aws_ami.talos.id : each.value.ami_id
  monitoring                  = true
  instance_type               = each.value.instance_type
  subnet_id                   = element(data.aws_subnets.public.ids, tonumber(trimprefix(each.key, "${each.value.name}.")))
  iam_role_use_name_prefix    = false
  create_iam_instance_profile = var.ccm ? true : false
  iam_role_policies = var.ccm ? {
    "${var.cluster_name}-worker-ccm-policy" : aws_iam_policy.worker_ccm_policy[0].arn,
  } : {}
  tags = merge(each.value.tags, var.tags, local.cluster_required_tags)

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
  docs               = false
  examples           = false
  config_patches = concat(
    local.config_patches_common,
    local.config_patches_controlplane,
    [yamlencode(local.common_machine_config_patch)],
    [for path in var.control_plane.config_patch_files : file(path)]
  )
}

data "talos_machine_configuration" "worker_group" {
  for_each = merge([for info in var.worker_groups : { for index in range(0, info.num_instances) : "${info.name}.${index}" => info }]...)

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${module.elb_k8s_elb.elb_dns_name}"
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.kubernetes_version
  docs               = false
  examples           = false
  config_patches = concat(
    local.config_patches_common,
    local.config_patches_worker,
    [yamlencode(local.common_machine_config_patch)],
    [for path in each.value.config_patch_files : file(path)]
  )
}

resource "talos_machine_configuration_apply" "controlplane" {
  count = var.control_plane.num_instances

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  endpoint                    = module.talos_control_plane_nodes[count.index].public_ip
  node                        = module.talos_control_plane_nodes[count.index].private_ip
}

resource "talos_machine_configuration_apply" "worker_group" {
  for_each = merge([for info in var.worker_groups : { for index in range(0, info.num_instances) : "${info.name}.${index}" => info }]...)

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

data "talos_cluster_kubeconfig" "this" {
  depends_on = [talos_machine_bootstrap.this]

  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = module.talos_control_plane_nodes.0.public_ip
  node                 = module.talos_control_plane_nodes.0.private_ip
}

data "talos_cluster_health" "this" {
  depends_on = [data.talos_cluster_kubeconfig.this]

  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = module.talos_control_plane_nodes.*.public_ip
  control_plane_nodes  = module.talos_control_plane_nodes.*.private_ip
  worker_nodes         = [for node in module.talos_worker_group : node.private_ip]
}