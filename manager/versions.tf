#  ┐ ┬┬─┐┬─┐┐─┐o┌─┐┌┐┐┐─┐
#  │┌┘├─ │┬┘└─┐││ ││││└─┐
#  └┘ ┴─┘┘└┘──┘┘┘─┘┘└┘──┘

terraform {
  required_version = "<= 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "<6.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "<5.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "<4.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "<3.0.0"
    }
  }
}
