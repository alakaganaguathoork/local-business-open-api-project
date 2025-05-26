variable "environment" {
  description = "Environment string"
  type        = string
}

variable "location" {
  description = "Location string (default is `northeurope`)"
  type        = string
  default     = "northeurope"
}
variable "apps_data" {
  description = "Apps data"
  type = map(object({
    name = string
    os_type = string
    sku_name = string
    kv_ip = string
    address_prefixes = list(string)
    delegated = bool
  }))
}