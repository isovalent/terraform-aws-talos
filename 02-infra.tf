# Public-facing security group for the external load balancer
module "nlb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name        = "${var.cluster_name}-nlb"
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
  description = "Intra-cluster & traffic from NLB"
  vpc_id      = var.vpc_id
  tags        = var.tags

  # Node-to-node communications
  ingress_with_self = [{ rule = "all-all" }]

  # Allow API traffic coming *from* the NLB (required for the health checks)
  ingress_with_source_security_group_id = [
    {
      from_port                = 6443
      to_port                  = 6443
      protocol                 = "tcp"
      description              = "Kubernetes API from NLB"
      source_security_group_id = module.nlb_sg.security_group_id
    },
    {
      from_port                = 50000
      to_port                  = 50000
      protocol                 = "tcp"
      description              = "Talos API from NLB"
      source_security_group_id = module.nlb_sg.security_group_id
    }
  ]

  # Allow API traffic directly from external clients (with preserved IPs through NLB)
  ingress_cidr_blocks = var.external_source_cidrs
  ingress_with_cidr_blocks = [
    {
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      description = "Kubernetes API from external clients"
    },
    {
      from_port   = 50000
      to_port     = 50000
      protocol    = "tcp"
      description = "Talos API from external clients"
    },
  ]

  egress_with_cidr_blocks = [{ rule = "all-all", cidr_blocks = "0.0.0.0/0" }]
}

# Network Load Balancer for Kubernetes & Talos API
resource "aws_lb" "api" {
  name = "${var.cluster_name}-api"

  load_balancer_type = "network"
  internal           = false

  subnets         = data.aws_subnets.public.ids
  security_groups = [module.nlb_sg.security_group_id]

  enable_cross_zone_load_balancing = true
  tags                             = merge(var.tags, local.cluster_required_tags)
}

# Target Group: Kubernetes API (6443)
resource "aws_lb_target_group" "k8s" {
  name_prefix        = "k8s-"
  port               = 6443
  protocol           = "TCP"
  preserve_client_ip = true
  vpc_id             = data.aws_vpc.vpc.id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 5
    protocol            = "TCP"
    port                = 6443
  }
  target_type = "instance"
  tags        = merge(var.tags, local.cluster_required_tags)
}

# Target Group: Talos API (50000)
resource "aws_lb_target_group" "talos" {
  name_prefix        = "tal-"
  port               = 50000
  protocol           = "TCP"
  preserve_client_ip = true
  vpc_id             = data.aws_vpc.vpc.id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 5
    protocol            = "TCP"
    port                = 50000
  }
  target_type = "instance"
  tags        = merge(var.tags, local.cluster_required_tags)
}

# Listener 443 -> TG k8s
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.api.arn
  port              = 443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s.arn
  }
}

# Listener 50000 -> TG talos
resource "aws_lb_listener" "talos" {
  load_balancer_arn = aws_lb.api.arn
  port              = 50000
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.talos.arn
  }
}

# Attach control-plane instances to both target groups
resource "aws_lb_target_group_attachment" "cp_k8s" {
  for_each         = { for idx, id in module.talos_control_plane_nodes.*.id : idx => id }
  target_group_arn = aws_lb_target_group.k8s.arn
  target_id        = each.value
  port             = 6443
}

resource "aws_lb_target_group_attachment" "cp_talos" {
  for_each         = { for idx, id in module.talos_control_plane_nodes.*.id : idx => id }
  target_group_arn = aws_lb_target_group.talos.arn
  target_id        = each.value
  port             = 50000
}
