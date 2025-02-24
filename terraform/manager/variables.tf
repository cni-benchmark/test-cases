#  ┐ ┬┬─┐┬─┐o┬─┐┬─┐┬  ┬─┐┐─┐
#  │┌┘│─┤│┬┘││─┤│─││  ├─ └─┐
#  └┘ ┘ ┘┘└┘┘┘ ┘┘─┘┘─┘┴─┘──┘

variable "name" {
  type        = string
  description = "Name prefix"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block"
}

variable "vpc_subnet_id" {
  type        = string
  description = "VPC Subnet ID to use"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Security groups to connect to"
  default     = []
}
