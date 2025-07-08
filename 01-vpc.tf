// Used to make sure the VPC has been created and introduce proper dependencies between 'data' blocks.
data "aws_region" "current" {}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

// Used to list all public subnets in the VPC.
data "aws_subnets" "public" {
  depends_on = [
    null_resource.wait_for_subnets,
  ]
  filter {
    name = "vpc-id"
    values = [
      data.aws_vpc.vpc.id
    ]
  }
  filter {
    name = "tag:type"
    values = [
      "public"
    ]
  }
}

// Used to list all private subnets in the VPC.
data "aws_subnets" "private" {
  depends_on = [
    null_resource.wait_for_subnets,
  ]
  filter {
    name = "vpc-id"
    values = [
      data.aws_vpc.vpc.id
    ]
  }
  filter {
    name = "tag:type"
    values = [
      "private"
    ]
  }
}

// Used to wait for at least one of the subnets to exist.
resource "null_resource" "wait_for_subnets" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/wait-for-subnets.sh -v ${data.aws_vpc.vpc.id} -r ${data.aws_region.current.region} -t public"
  }
}
