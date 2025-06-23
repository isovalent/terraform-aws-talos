module "cluster_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name        = var.cluster_name
  description = "Allow all intra-cluster and egress traffic"
  vpc_id      = var.vpc_id
  tags        = var.tags

  ingress_with_self = [
    {
      rule = "all-all"
    },
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 50000
      to_port     = 50000
      protocol    = "tcp"
      cidr_blocks = var.talos_api_allowed_cidr
      description = "Talos API Access"
    },
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "kubernetes_api_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/https-443"
  version = "~> 5.3"

  name                = "${var.cluster_name}-k8s-api"
  description         = "Allow access to the Kubernetes API"
  vpc_id              = var.vpc_id
  ingress_cidr_blocks = [var.kubernetes_api_allowed_cidr]
  tags                = var.tags
}

module "elb_k8s_elb" {
  source  = "terraform-aws-modules/elb/aws"
  version = "~> 4.0"

  name    = "${var.cluster_name}-k8s-api"
  subnets = data.aws_subnets.public.ids
  tags    = merge(var.tags, local.cluster_required_tags)
  security_groups = [
    module.cluster_sg.security_group_id,
    module.kubernetes_api_sg.security_group_id,
  ]

  listener = [
    {
      lb_port           = 443
      lb_protocol       = "tcp"
      instance_port     = 6443
      instance_protocol = "tcp"
    },
    {
      lb_port           = 50000
      lb_protocol       = "tcp"
      instance_port     = 50000
      instance_protocol = "tcp"
    }
  ]

  health_check = {
    target              = "tcp:6443"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  number_of_instances = var.controlplane_count
  instances           = module.talos_control_plane_nodes.*.id
}
