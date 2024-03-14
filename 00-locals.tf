data "aws_ami" "talos" {
  owners      = ["540036508848"] # Sidero Labs
  most_recent = true
  name_regex  = "^talos-${var.talos_version}-.*-${var.cluster_architecture}$"

  filter {
    name   = "architecture"
    values = [local.instance_architecture]
  }
}

resource "random_string" "workspace_id" {
  length      = 6
  min_numeric = 1
  special     = false
  upper       = false
}

locals {

  instance_architecture    = var.cluster_architecture == "amd64" ? "x86_64" : var.cluster_architecture
  path_to_workspace_dir    = "${abspath(path.root)}/.terraform/.workspace-${random_string.workspace_id.id}"
  path_to_kubeconfig_file  = "${local.path_to_workspace_dir}/kubeconfig"
  path_to_talosconfig_file = "${local.path_to_workspace_dir}/talosconfig"

  common_config_patch = {
    cluster = {
      id          = var.cluster_id,
      clusterName = var.cluster_name,
      apiServer = {
        certSANs = [
          module.elb_k8s_elb.elb_dns_name
        ]
      },
      controllerManager = {
        extraArgs = {
          allocate-node-cidrs = var.allocate_node_cidrs
        }
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
        "https://raw.githubusercontent.com/isovalent/terraform-aws-talos/main/standalone-install.yaml",
        "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
      ],
      allowSchedulingOnControlPlanes = var.allow_workload_on_cp_nodes
    },
    machine = {
      kubelet = {
        registerWithFQDN = true
      },
      certSANs = [
        module.elb_k8s_elb.elb_dns_name
      ],
      kubelet = {
        extraArgs = {
          rotate-server-certificates = true
        }
      }
    }
  }

  # Used to configure Cilium Kube-Proxy replacement
  config_cilium_patch = {
    cluster = {
      proxy = {
        disabled = var.disable_kube_proxy
      }
    },
    machine = {
      features = {
        kubePrism = {
          enabled = true,
          port    = 7445
        }
      }
    }
  }

  config_patches_common = [
    for path in var.config_patch_files : file(path)
  ]

  cluster_required_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

}
