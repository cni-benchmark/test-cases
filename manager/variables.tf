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

variable "admin_cidr_blocks" {
  type        = list(string)
  description = "CIDRs to whitelist for SSH access"
  default     = []
}
