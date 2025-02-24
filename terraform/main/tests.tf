#  ┌┐┐┬─┐┐─┐┌┐┐┐─┐
#   │ ├─ └─┐ │ └─┐
#   ┘ ┴─┘──┘ ┘ ──┘

module "test_talos" {
  source = "../tests/talos"

  name                = local.name
  database_url        = "postgresql://username:password@${module.manager.private_ip}:5432/database"
  vpc_private_subnets = module.vpc.private_subnets
  vpc_security_group_ids = compact([
    aws_security_group.egress.id,
    aws_security_group.intranet.id
  ])
}

resource "local_sensitive_file" "test_talos_kubeconfig" {
  for_each        = module.test_talos.talos
  filename        = "${path.module}/tests/talos/${each.key}/kubeconfig.yaml"
  content         = each.value.kubeconfig
  file_permission = "0600"
}

resource "local_sensitive_file" "test_talos_talosconfig" {
  for_each        = module.test_talos.talos
  filename        = "${path.module}/tests/talos/${each.key}/talosconfig.yaml"
  content         = each.value.talosconfig
  file_permission = "0600"
}
