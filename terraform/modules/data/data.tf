#  ┬─┐┬─┐┌┐┐┬─┐
#  │ ││─┤ │ │─┤
#  ┘─┘┘ ┘ ┘ ┘ ┘

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "this" {}

locals {
  ami_map = {
    ubuntu = {
      owner = "099720109477"
      arch = {
        amd64 = "^ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-.+$"
        arm64 = "^ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-.+$"
      }
    }
    talos = {
      owner = "540036508848"
      arch = {
        amd64 = "^talos-.+-${data.aws_region.this.name}-amd64$"
        arm64 = "^talos-.+-${data.aws_region.this.name}-arm64$"
      }
    }
  }
}

data "aws_ami" "this" {
  for_each = merge([
    for os, spec in local.ami_map : {
      for arch, name_regex in spec.arch :
      "${os}_${arch}" => {
        name_regex = name_regex
        owners     = [spec.owner]
      }
    }
  ]...)
  most_recent = true
  name_regex  = each.value.name_regex
  owners      = each.value.owners
}
