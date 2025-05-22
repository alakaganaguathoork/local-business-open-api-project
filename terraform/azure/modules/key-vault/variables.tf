variable "environment" {
  description = "Environments string"
  type        = string
}

variable "location" {
  description = "Location string (default is `northeurope`)"
  type        = string
  default     = "northeurope"
}

variable "keyvault" {
  description = "Key Vault object"
  type = object({
    sku_name   = string
    access_policies = map(object({
        key_permissions = list(string)
    }))
  })
}

variable "subnet" {
  description = "Subnet object"
  type = object({
    id                  = string
    name                = string
    resource_group_name = string
  })
}