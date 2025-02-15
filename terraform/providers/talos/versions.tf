#  ┐ ┬┬─┐┬─┐┐─┐o┌─┐┌┐┐┐─┐
#  │┌┘├─ │┬┘└─┐││ ││││└─┐
#  └┘ ┴─┘┘└┘──┘┘┘─┘┘└┘──┘

terraform {
  required_version = "<2.0.0"
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "<1.0.0"
    }
  }
}
