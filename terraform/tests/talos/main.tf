#  ┌┌┐┬─┐o┌┐┐
#  ││││─┤││││
#  ┘ ┘┘ ┘┘┘└┘

locals {
  pod_cidr           = "10.244.0.0/16"
  service_cidr       = "10.96.0.0/12"
  talos_version      = "1.9.4"
  kubernetes_version = "1.32.2"
  mgr_info = {
    MGR_DATABASE_URL  = var.database_url
    MGR_TEST_DURATION = tostring(var.test_duration)
  }
  os_info = {
    OS_NAME    = "talos"
    OS_VERSION = local.talos_version
  }
  k8s_info = {
    K8S_PROVIDER         = "talos"
    K8S_PROVIDER_VERSION = local.talos_version
    K8S_VERSION          = local.kubernetes_version
    K8S_SERVICE_HOSTNAME = "localhost"
    K8S_SERVICE_PORT     = "7445"
    K8S_POD_CIDR_IPV4    = local.pod_cidr
  }
  cni_root = abspath("${path.root}/../../kubernetes/cnis")
  cni = {
    for file in fileset(local.cni_root, "**/cni-info.env") :
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

  name                   = substr("${var.name}-talos-${each.key}", 0, 63)
  instance_type          = "t4g.medium"
  ami                    = module.data.ami.talos_arm64.image_id
  vpc_subnet_id          = var.vpc_public_subnets[0]
  vpc_security_group_ids = var.vpc_security_group_ids
  root_size              = 20
}

module "talos" {
  for_each = data.kubectl_kustomize_documents.cni
  source   = "../../providers/talos"

  name               = substr("${var.name}-talos-${each.key}", 0, 63)
  ec2                = module.ec2[each.key].outputs
  talos_version      = local.talos_version
  kubernetes_version = local.kubernetes_version
  pod_cidr           = local.pod_cidr
  service_cidr       = local.service_cidr
  config_patches = [
    yamlencode(merge(
      {
        cluster = {
          network = { cni = { name = "none" } }
          proxy = {
            # Disable kube-proxy if CNI has the respective requirement
            disabled = length(regexall("CNI_K8S_REQ: .*kubeProxyReplacement.*", join("---\n", each.value.documents))) > 0
          }
          extraManifests = [
            module.data.tests_install_manifest_url
          ]
          inlineManifests = [
            {
              name = "ConfigMaps"
              contents = join("\n---\n", [
                yamlencode({
                  apiVersion = "v1"
                  kind       = "ConfigMap"
                  metadata = {
                    name      = "os-info"
                    namespace = "default"
                  }
                  data = local.os_info
                }),
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
              name     = "CNI-Install"
              contents = join("---\n", each.value.documents)
            }
          ]
        }
      },
    ))
  ]
}
