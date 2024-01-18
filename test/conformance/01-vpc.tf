// Create the VPC.

resource "random_id" "cluster" {
  byte_length = 4
}

module "vpc" {
  source = "git::https://github.com/isovalent/terraform-aws-vpc.git?ref=v1.7"

  # TODO: Do we need to support beta features, like ipv6 masquerade?
  #enable_ipv6         = true
  #vpc_ipv6_cidr_block = "2600:1f18:abcd:1234::/56"
  cidr   = var.vpc_cidr
  name   = "${var.cluster_name}-${random_id.cluster.dec}"
  region = var.region
  tags   = local.tags
}
