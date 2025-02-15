#  ┌─┐┬ ┐┌┐┐┬─┐┬ ┐┌┐┐┐─┐
#  │ ││ │ │ │─┘│ │ │ └─┐
#  ┘─┘┘─┘ ┘ ┘  ┘─┘ ┘ ──┘

output "kubeconfig" {
  description = "Cluster kubeconfig"
  value       = replace(talos_cluster_kubeconfig.this.kubeconfig_raw, var.ec2.private_ip, var.ec2.public_ip)
}

output "talosconfig" {
  description = "Cluster talosconfig"
  value       = data.talos_client_configuration.this.talos_config
}
