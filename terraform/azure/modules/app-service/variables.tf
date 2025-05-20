variable "instances" {
  description = "value"
  type = map(object({
    environment = string
    os_type = string
    location = string
    sku_name = string
    subnet = string
  }))
}