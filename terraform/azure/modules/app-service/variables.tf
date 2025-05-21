variable "environment" {
  description = "Environment string"
  type = string
}

variable "location" {
  description = "Location string"
  type = string
}

variable "instances" {
  description = "value"
  type = map(object({
    os_type = string
    location = string
    sku_name = string
    subnet = string
  }))
}

variable "subnets" {
  type = map(object({
    id = string
  }))
}