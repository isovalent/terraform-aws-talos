// Create the VPC.

resource "random_id" "cluster" {
  byte_length = 4
}

module "vpc" {
  source = "git::https://github.com/isovalent/terraform-aws-vpc.git?ref=v1.13"

  cidr   = var.vpc_cidr
  name   = "${var.cluster_name}-${random_id.cluster.dec}"
  region = var.region
  tags   = local.tags
}