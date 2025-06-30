// Create the VPC.

resource "random_id" "cluster" {
  byte_length = 4
}

# Used for ingress SG restrictions
data "external" "public_ip" {
  program = ["sh", "-c", "curl -s https://api.ipify.org?format=json"]
}

module "vpc" {
  source = "git::https://github.com/isovalent/terraform-aws-vpc.git?ref=v1.13"

  cidr                = var.vpc_cidr
  name                = "${var.cluster_name}-${random_id.cluster.dec}"
  access_ip_addresses = ["${data.external.public_ip.result.ip}/32"]
  region              = var.region
  tags                = local.tags
}