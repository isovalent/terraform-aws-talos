terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100" # https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/issues/434
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0-alpha.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
  required_version = ">= 1.4.0"
}
