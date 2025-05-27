variable "environment" {
  description = "Environment string"
  type        = string
}

variable "location" {
  description = "Location string"
  type        = string
}

variable "apps" {
  description = "value"
  type = map(object({
    name     = string
    os_type  = string
    sku_name = string
  }))
}

variable "subnets" {
  type = map(object({
    id = string
  }))
}