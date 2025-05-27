variable "environment" {
  description = "Environment string"
  type        = string
}

variable "location" {
  description = "Location string (default is `northeurope`)"
  type        = string
  default     = "northeurope"
}

variable "private_dns_zone_name" {
  description = "Private DNS zone name string"
  type        = string
  default     = "local.business"
}

variable "vnet" {
  description = "Vnet object"
  type = object({
    id                  = string
    name                = string
    location            = string
    resource_group_name = string
  })
}

variable "dns_a_records" {
  description = "IP addresses records to create in DNS"
  type = map(object({
    name       = string
    private_ip_address = string
  }))
}