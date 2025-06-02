variable "environment" {
  description = "Configuration envrinoment (string)"
  type        = string
}

variable "location" {
  description = "Location for deploying network security group/s (string)"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "subnets" {
  description = "Map of generated subnet IDs"
  type = map(any)
}

variable "custom_rules" {
  description = "Map of network security rules"
  type = list(object({
    name                                       = string
    direction                                  = string
    access                                     = string
    priority                                   = string
    protocol                                   = string
    source_port_range                          = optional(string)
    source_port_ranges                         = optional(set(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(set(string))
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(set(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(set(string))
    source_application_security_group_ids      = optional(set(string))
    destination_application_security_group_ids = optional(set(string))
  }))
}