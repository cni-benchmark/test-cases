#  ┐ ┬┬─┐┬─┐o┬─┐┬─┐┬  ┬─┐┐─┐
#  │┌┘│─┤│┬┘││─┤│─││  ├─ └─┐
#  └┘ ┘ ┘┘└┘┘┘ ┘┘─┘┘─┘┴─┘──┘

variable "name" {
  type        = string
  description = "Name prefix"
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "VPC private subnets IDs"
}

variable "database_url" {
  type        = string
  description = "Manager IP address to use"
}

variable "test_duration" {
  type        = number
  description = "Test duration in seconds"
  default     = 120
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Extra security groups to use"
  default     = []
}
