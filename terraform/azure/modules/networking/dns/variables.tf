variable "environment" {
  description = "Environment string"
  type        = string
}

variable "location" {
  description = "Location string"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "existing_dns_zone" {
  type = string
  default = ""
}

variable "zone_name" {
  description = "Private DNS zone name string"
  type        = string
}

variable "vnet_id" {
  description = "Vnet object"
  type        = string
}

# variable "records_a" {
  # description = "IP addresses records to create in DNS"
  # type = map(object({
    # name   = string
    # record = string
  # }))
# }