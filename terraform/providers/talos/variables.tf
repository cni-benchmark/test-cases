#  ┐ ┬┬─┐┬─┐o┬─┐┬─┐┬  ┬─┐┐─┐
#  │┌┘│─┤│┬┘││─┤│─││  ├─ └─┐
#  └┘ ┘ ┘┘└┘┘┘ ┘┘─┘┘─┘┴─┘──┘

variable "name" {
  type        = string
  description = "Name prefix"
}

variable "ec2" {
  type        = any
  description = "EC2 module outputs"
}

variable "config_patches" {
  type        = list(string)
  description = "List of valid YAMLs patches for machine configuration"
  default     = []

  validation {
    condition = alltrue([
      for str in var.config_patches :
      try(yamldecode(str), false) != false
    ])
    error_message = "Config patches contain invalid YAML patch(es)"
  }
}
