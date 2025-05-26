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
    name = string
    kv_ip = string
    sku_name   = string
    # access_policies = map(object({
        # key_permissions = list(string)
    # }))
  }))
}

variable "subnet" {
  description = "Subnet object"
  type = map(object({
    id                  = string
    name                = string
    resource_group_name = string
  }))
}