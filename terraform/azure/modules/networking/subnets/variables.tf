variable "environment" {
  description = "Environment string"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "virtual_network_name" {
  description = "Vnet name"
  type        = string
}

variable "subnet" {
  type = object({
    name                                     = string
    address_prefixes                         = list(string)
    service_endpoints                        = optional(list(string), [])
    delegation                               = optional(string, "")
    private                                  = optional(bool, true)
    enable_private_endpoint_network_policies = optional(bool, false)
  })

  validation {
    condition = contains(["", "app", "storage"], var.subnet.delegation)
    error_message = "Incorrect `delegation` was provided. Possible values: [ '', 'app', 'storage' ]."
  }
}