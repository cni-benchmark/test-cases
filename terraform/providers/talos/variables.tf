#  ┐ ┬┬─┐┬─┐o┬─┐┬─┐┬  ┬─┐┐─┐
#  │┌┘│─┤│┬┘││─┤│─││  ├─ └─┐
#  └┘ ┘ ┘┘└┘┘┘ ┘┘─┘┘─┘┴─┘──┘

variable "name" {
  type        = string
  description = "Name prefix"
}

variable "talos_version" {
  type        = string
  description = "Talos version"
  default     = "1.9.4"
}

variable "ec2" {
  type        = any
  description = "EC2 module outputs"
}

variable "pod_cidr" {
  type        = string
  description = "Cluster Pod CIDR"
  default     = "10.244.0.0/16"

  validation {
    condition     = try(cidrnetmask(var.pod_cidr), "") != ""
    error_message = "Pod CIDR value is invalid"
  }
}

variable "service_cidr" {
  type        = string
  description = "Cluster Service CIDR"
  default     = "10.96.0.0/12"

  validation {
    condition     = try(cidrnetmask(var.service_cidr), "") != ""
    error_message = "Service CIDR value is invalid"
  }
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
