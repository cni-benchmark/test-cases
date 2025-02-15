#  ┌┌┐┬─┐o┌┐┐
#  ││││─┤││││
#  ┘ ┘┘ ┘┘┘└┘

module "manager" {
  source = "../manager"

  name          = local.name
  vpc_subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = compact([
    aws_security_group.egress.id,
    aws_security_group.intranet.id,
    try(aws_security_group.admin[0].id, ""),
  ])
}

resource "local_sensitive_file" "manager_kubeconfig" {
  filename        = "${path.module}/kubeconfig.yaml"
  content         = module.manager.kubeconfig
  file_permission = "0600"
}

resource "local_sensitive_file" "manager_talosconfig" {
  filename        = "${path.module}/talosconfig.yaml"
  content         = module.manager.talosconfig
  file_permission = "0600"
}
