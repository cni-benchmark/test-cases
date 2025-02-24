#  ┐ ┬┬─┐┬─┐o┬─┐┬─┐┬  ┬─┐┐─┐
#  │┌┘│─┤│┬┘││─┤│─││  ├─ └─┐
#  └┘ ┘ ┘┘└┘┘┘ ┘┘─┘┘─┘┴─┘──┘

variable "name" {
  type        = string
  description = "Name prefix"
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Works in private subnet as well"
  default     = true
}

variable "ami" {
  type        = string
  description = "AMI ID"
}

variable "vpc_subnet_id" {
  type        = string
  description = "VPC Subnet ID to use"
}

variable "instance_type" {
  type        = string
  description = "Instance size"
  default     = "t4g.small"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Security groups to connect to"
  default     = []
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile name"
  default     = ""
}

variable "user_data" {
  type        = string
  description = "User data script"
  default     = ""
}

variable "root_size" {
  type        = number
  description = "Root device disk size"
  default     = 10
}
