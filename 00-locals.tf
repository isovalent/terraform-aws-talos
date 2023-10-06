data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "talos" {
  owners      = ["540036508848"] # Sidero Labs
  most_recent = true
  name_regex  = "^talos-${var.talos_version}-${data.aws_availability_zones.available.id}-amd64$"
}

locals {
  common_machine_config_patch = {
    machine = {
      kubelet = {
        registerWithFQDN = true
      }
    }
  }

  ccm_patch_cp = {
    cluster = {
      externalCloudProvider = {
        enabled = true
        manifests = [
          "https://raw.githubusercontent.com/siderolabs/contrib/main/examples/terraform/aws/manifests/ccm.yaml"
        ]
      }
    }
  }

  ccm_patch_worker = {
    cluster = {
      externalCloudProvider = {
        enabled = true
      }
    }
  }

  config_patches_common = [
    for path in var.config_patch_files : file(path)
  ]

  config_patches_controlplane = var.ccm ? [yamlencode(local.ccm_patch_cp)] : []

  config_patches_worker = var.ccm ? [yamlencode(local.ccm_patch_worker)] : []

  cluster_required_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}
