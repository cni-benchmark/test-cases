#  ┌─┐┬ ┐┌┐┐┬─┐┬ ┐┌┐┐┐─┐
#  │ ││ │ │ │─┘│ │ │ └─┐
#  ┘─┘┘─┘ ┘ ┘  ┘─┘ ┘ ──┘

output "region" {
  description = "Current region name"
  value       = data.aws_region.this.name
}

output "available_azs" {
  description = "Available AZs names in the region"
  value       = data.aws_availability_zones.available.names
}

output "ami" {
  description = "AMI for different OSes"
  value       = data.aws_ami.this
}

output "tests_install_manifest_url" {
  description = "URL to manifest with tests-installer job"
  value       = "https://github.com/cni-benchmark/test-cases/raw/refs/heads/main/kubernetes/runner/install.yaml"
}
