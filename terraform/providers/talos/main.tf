#  ┌┌┐┬─┐o┌┐┐
#  ││││─┤││││
#  ┘ ┘┘ ┘┘┘└┘

locals {
  certSANs = [
    var.ec2.public_ip,
    var.ec2.private_ip,
  ]
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "this" {
  cluster_name     = var.name
  machine_type     = "controlplane"
  cluster_endpoint = "https://${var.ec2.private_ip}:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_client_configuration" "this" {
  cluster_name         = var.name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = [var.ec2.private_ip]
  endpoints            = [var.ec2.public_ip]
}

resource "talos_machine_configuration_apply" "this" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = var.ec2.public_ip
  config_patches = [
    yamlencode({
      machine = {
        time = {
          servers = ["169.254.169.123"]
        }
        certSANs = local.certSANs
        kubelet = {
          nodeIP = {
            validSubnets = [
              "${var.ec2.private_ip}/32"
            ]
          }
        }
        install = {
          extraKernelArgs = [
            "talos.platform=aws",
          ]
        }
      }
      cluster = {
        allowSchedulingOnControlPlanes = true
        apiServer = {
          certSANs = local.certSANs
        }
      }
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.this
  ]
  node                 = var.ec2.public_ip
  client_configuration = talos_machine_secrets.this.client_configuration
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  node                 = var.ec2.public_ip
  client_configuration = talos_machine_secrets.this.client_configuration
}
