variable "environment" {
  description = "Environments string"
  type        = string
}

variable "location" {
  description = "Location string (default is `northeurope`)"
  type        = string
  default     = "northeurope"
}

variable "keyvaults" {
  description = "Key Vault object"
  type = map(object({
    service_type = string
    name         = string
    sku_name     = string
  }))
}

variable "subnet" {
  description = "Subnet object"
  type = map(object({
    id                  = string
    name                = string
    resource_group_name = string
    address_prefixes    = list(string)

  }))
}