#  ┐ ┬┬─┐┬─┐o┬─┐┬─┐┬  ┬─┐┐─┐
#  │┌┘│─┤│┬┘││─┤│─││  ├─ └─┐
#  └┘ ┘ ┘┘└┘┘┘ ┘┘─┘┘─┘┴─┘──┘

variable "tenant" {
  type        = string
  description = "Environment name"
  default     = "cnib"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-central-1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block"
  default     = "172.16.0.0/21"
}
