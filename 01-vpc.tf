// Used to make sure the VPC has been created and introduce proper dependencies between 'data' blocks.
data "aws_vpc" "vpc" {
  id = var.vpc_id
}

// Used to list all public subnets in the VPC.
data "aws_subnets" "public" {
  depends_on = [
    null_resource.wait_for_public_subnets,
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

// Used to wait for at least one of the subnets to exist.
// Unfortunately there doesn't seem to be a better way to do this in Terraform.
resource "null_resource" "wait_for_public_subnets" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/wait-for-public-subnets.sh ${data.aws_vpc.vpc.id} ${data.aws_region.current.name}"
  }
}