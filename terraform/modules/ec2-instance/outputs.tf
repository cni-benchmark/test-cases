#  ┌─┐┬ ┐┌┐┐┬─┐┬ ┐┌┐┐┐─┐
#  │ ││ │ │ │─┘│ │ │ └─┐
#  ┘─┘┘─┘ ┘ ┘  ┘─┘ ┘ ──┘

output "outputs" {
  description = "EC2 instance module outputs"
  value       = module.ec2
}
