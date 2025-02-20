#  ┌─┐┬ ┐┌┐┐┬─┐┬ ┐┌┐┐┐─┐
#  │ ││ │ │ │─┘│ │ │ └─┐
#  ┘─┘┘─┘ ┘ ┘  ┘─┘ ┘ ──┘

output "machine_configuration" {
  description = "Talos machine configuration"
  value       = talos_machine_configuration_apply.this.machine_configuration
  sensitive   = true
}

output "kubeconfig" {
  description = "Cluster kubeconfig"
  value       = replace(talos_cluster_kubeconfig.this.kubeconfig_raw, var.ec2.private_ip, var.ec2.public_ip)
}

output "talosconfig" {
  description = "Cluster talosconfig"
  value       = data.talos_client_configuration.this.talos_config
}

output "pod_cidr" {
  description = "var.pod_cidr"
  value       = var.pod_cidr
}

output "service_cidr" {
  description = "var.service_cidr"
  value       = var.service_cidr
}

output "dns_ip" {
  description = "kube-dns service IP"
  value       = local.dns_ip
}
