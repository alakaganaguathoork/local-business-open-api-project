variable "environment" {
  description = "Environment string"
  type        = string
}

variable "location" {
  description = "Location string (default is `northeurope`)"
  type        = string
  default     = "northeurope"
}

variable "vpc_cidr" {
  description = "CIDR block for Vnet"
  type        = string
}

variable "env_data" {
  description = "Apps data"
  type = object({
    keyvault_subnet = map(object({
      service_type = string
      name         = string
      private      = bool
    }))
    services = object({
      apps = map(object({
        name     = string
        os_type  = string
        sku_name = string
        subnet = object({
          service_type = string
          name         = string
          delegated    = optional(bool)
          private      = optional(bool)
        })
        keyvault = object({
          service_type = string
          name         = string
          sku_name     = string
        })
      }))
    })
    nsg_rules = any
  })
}