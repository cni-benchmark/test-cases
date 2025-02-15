#  ┌─┐┬ ┐┌┐┐┬─┐┬ ┐┌┐┐┐─┐
#  │ ││ │ │ │─┘│ │ │ └─┐
#  ┘─┘┘─┘ ┘ ┘  ┘─┘ ┘ ──┘

output "kubeconfig" {
  description = "Cluster kubeconfig"
  value       = module.talos.kubeconfig
}

output "talosconfig" {
  description = "Cluster talosconfig"
  value       = module.talos.talosconfig
}
