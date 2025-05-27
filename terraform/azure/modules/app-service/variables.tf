variable "environment" {
  description = "Environment string"
  type        = string
}

variable "location" {
  description = "Location string"
  type        = string
}

variable "apps" {
  description = "Apps data"
  type = map(object({
    name     = string
    os_type  = string
    sku_name = string
  }))
}

variable "subnet_ids" {
  description = "Generated subnet IDs"
  type = map(object({
    id = string
  }))
}