variable "keyvault_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "object_id" {
  type = string
}

variable "principal_id" {
  type = string
}

variable "general_keyvault_access_policies" {
  description = "Key vault access policies for Azur CLI to be assigned"
  type = object({
    key_permissions     = optional(list(string), null)
    secret_permissions  = optional(list(string), null)
    storage_permissions = optional(list(string), null)
  })
  default = {}
}

variable "principal_keyvault_access_policies" {
  description = "Key vault access policies for an app to access a key vault"
  type = object({
    key_permissions     = optional(list(string), null)
    secret_permissions  = optional(list(string), null)
    storage_permissions = optional(list(string), null)
  })
  default = {}
}