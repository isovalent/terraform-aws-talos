# Public-facing security group for the external load balancer
module "elb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name        = "${var.cluster_name}-elb"
  description = "Public-facing LB for Kubernetes and Talos API"
  vpc_id      = var.vpc_id
  tags        = var.tags

  # Allow API traffic from the configured external CIDRs
  ingress_cidr_blocks = var.external_source_cidrs
  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Kubernetes API (TLS)"
    },
    {
      from_port   = 50000
      to_port     = 50000
      protocol    = "tcp"
      description = "Talos API"
    },
  ]

  egress_with_cidr_blocks = [{ rule = "all-all", cidr_blocks = "0.0.0.0/0" }]
}

# Internal security group for Talos control-plane and worker nodes
module "cluster_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name        = var.cluster_name
  description = "Intra-cluster & traffic from ELB"
  vpc_id      = var.vpc_id
  tags        = var.tags

  # Node-to-node communications
  ingress_with_self = [{ rule = "all-all" }]

  # Allow API traffic coming *from* the ELB
  ingress_with_source_security_group_id = [
    {
      from_port                = 6443
      to_port                  = 6443
      protocol                 = "tcp"
      description              = "Kubernetes API from ELB"
      source_security_group_id = module.elb_sg.security_group_id
    },
    {
      from_port                = 50000
      to_port                  = 50000
      protocol                 = "tcp"
      description              = "Talos API from ELB"
      source_security_group_id = module.elb_sg.security_group_id
    },
  ]

  egress_with_cidr_blocks = [{ rule = "all-all", cidr_blocks = "0.0.0.0/0" }]
}

module "elb_k8s_elb" {
  source  = "terraform-aws-modules/elb/aws"
  version = "~> 4.0"

  name            = "${var.cluster_name}-k8s-api"
  subnets         = data.aws_subnets.public.ids
  tags            = merge(var.tags, local.cluster_required_tags)
  security_groups = [module.elb_sg.security_group_id]

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
    target              = "tcp:50000"
    interval            = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 2
  }

  number_of_instances = var.controlplane_count
  instances           = module.talos_control_plane_nodes.*.id
}
