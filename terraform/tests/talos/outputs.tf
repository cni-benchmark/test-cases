#  ┌─┐┬ ┐┌┐┐┬─┐┬ ┐┌┐┐┐─┐
#  │ ││ │ │ │─┘│ │ │ └─┐
#  ┘─┘┘─┘ ┘ ┘  ┘─┘ ┘ ──┘

output "ec2" {
  description = "EC2 instance outputs"
  value = {
    for key, value in module.ec2 :
    key => value.outputs
  }
  sensitive = true
}

output "talos" {
  description = "Cluster kubeconfig"
  value       = module.talos
  sensitive   = true
}
