#  ┌┌┐┬─┐o┌┐┐
#  ││││─┤││││
#  ┘ ┘┘ ┘┘┘└┘

locals {
  name          = substr("${var.name}-talos-${each.key}", 0, 63)
  pod_cidr      = "10.244.0.0/16"
  service_cidr  = "10.96.0.0/12"
  talos_version = "1.9.4"
  mgr_info = {
    MGR_ADDRESS = var.manager_address
  }
  k8s_info = {
    K8S_PROVIDER         = "talos"
    K8S_VERSION          = local.talos_version
    K8S_SERVICE_HOSTNAME = "localhost"
    K8S_SERVICE_PORT     = "7445"
    K8S_POD_CIDR_IPV4    = local.pod_cidr
  }
  cni_root = "${path.root}/../../kubernetes/cnis"
  cni = {
    for file in fileset("${path.root}/../../kubernetes/cnis", "**/cni-info.env") :
    replace(dirname(file), "/[^a-zA-Z0-9_-]/", "-") => abspath("${local.cni_root}/${dirname(file)}")
  }
}

data "kubectl_kustomize_documents" "cni" {
  for_each = local.cni
  target   = each.value
}

module "ec2" {
  for_each = data.kubectl_kustomize_documents.cni
  source   = "../../modules/ec2-instance"

  name                   = local.name
  instance_type          = "t4g.medium"
  ami                    = module.data.ami.talos_arm64.image_id
  vpc_subnet_id          = var.vpc_public_subnets[0]
  vpc_security_group_ids = var.vpc_security_group_ids
  root_size              = 20
}

module "talos" {
  for_each = data.kubectl_kustomize_documents.cni
  source   = "../../providers/talos"

  name          = local.name
  ec2           = module.ec2[each.key].outputs
  talos_version = local.talos_version
  pod_cidr      = local.pod_cidr
  service_cidr  = local.service_cidr
  config_patches = [
    yamlencode(merge(
      {
        cluster = {
          network = { cni = { name = "none" } }
          proxy = {
            # Disable kube-proxy if CNI has the respective requirement
            disabled = length(regexall("CNI_K8S_REQ: .*kubeProxyReplacement.*", join("---\n", each.value.documents))) > 0
          }
          inlineManifests = [
            {
              name = "ConfigMaps"
              contents = join("\n---\n", [
                yamlencode({
                  apiVersion = "v1"
                  kind       = "ConfigMap"
                  metadata = {
                    name      = "k8s-info"
                    namespace = "default"
                  }
                  data = local.k8s_info
                }),
                yamlencode({
                  apiVersion = "v1"
                  kind       = "ConfigMap"
                  metadata = {
                    name      = "mgr-info"
                    namespace = "default"
                  }
                  data = local.mgr_info
                })
              ])
            },
            {
              name     = "cni-install"
              contents = join("---\n", each.value.documents)
            }
          ]
        }
      },
    ))
  ]
}
