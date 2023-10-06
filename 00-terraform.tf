terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.4.0-alpha.0"
    }
  }
  required_version = ">= 1.4.0"
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}