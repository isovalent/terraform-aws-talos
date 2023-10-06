data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "talos" {
  owners      = ["540036508848"] # Sidero Labs
  most_recent = true
  name_regex  = "^talos-${var.talos_version}-${data.aws_availability_zones.available.id}-amd64$"
}

resource "random_string" "workspace_id" {
  length      = 6
  min_numeric = 1
  special     = false
  upper       = false
}

locals {

  path_to_workspace_dir    = "${abspath(path.root)}/.terraform/.workspace-${random_string.workspace_id.id}"
  path_to_kubeconfig_file  = "${local.path_to_workspace_dir}/kubeconfig"
  path_to_talosconfig_file = "${local.path_to_workspace_dir}/talosconfig"

  common_machine_config_patch = {
    machine = {
      kubelet = {
        registerWithFQDN = true
      }
    }
  }

  config_cilium_patch = {
    cluster = {
      id          = var.cluster_id,
      clusterName = var.cluster_name,
      proxy = {
        disabled = var.disable_kube_proxy
      },
      network = {
        cni = {
          name = "none"
        },
        podSubnets = [
          var.pod_cidr
        ],
        serviceSubnets = [
          var.service_cidr
        ]
      },
      extraManifests = [
        "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml",
        "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
      ]
    },
    machine = {
      certSANs = [
        module.elb_k8s_elb.elb_dns_name
      ],
      kubelet = {
        extraArgs = {
          rotate-server-certificates = true
        }
      },
      features = {
        kubePrism = {
          enabled = true,
          port    = 7445
        }
      }
    }
  }

  ccm_patch_cp = {
    cluster = {
      apiServer = {
        certSANs = [
          module.elb_k8s_elb.elb_dns_name
        ]
      },
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
