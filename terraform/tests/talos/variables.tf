#  ┐ ┬┬─┐┬─┐o┬─┐┬─┐┬  ┬─┐┐─┐
#  │┌┘│─┤│┬┘││─┤│─││  ├─ └─┐
#  └┘ ┘ ┘┘└┘┘┘ ┘┘─┘┘─┘┴─┘──┘

variable "name" {
  type        = string
  description = "Name prefix"
}

variable "manager_address" {
  type        = string
  description = "Manager IP address to use"
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "VPC public subnets IDs"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Extra security groups to use"
  default     = []
}
