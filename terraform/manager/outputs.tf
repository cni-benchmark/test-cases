#  ┌─┐┬ ┐┌┐┐┬─┐┬ ┐┌┐┐┐─┐
#  │ ││ │ │ │─┘│ │ │ └─┐
#  ┘─┘┘─┘ ┘ ┘  ┘─┘ ┘ ──┘

output "private_ip" {
  description = "EC2 instance private IP"
  value       = module.ec2.outputs.private_ip
}

output "kubeconfig" {
  description = "Cluster kubeconfig"
  value       = module.talos.kubeconfig
}

output "talosconfig" {
  description = "Cluster talosconfig"
  value       = module.talos.talosconfig
}
