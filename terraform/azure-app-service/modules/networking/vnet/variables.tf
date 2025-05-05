variable "location" {
  description = "Networking resource group's location"
  type = string
}

variable "subnets" {
  description = "Subnets object"
  type = map(object({
    name = string,
    address_prefixes = list(string),
    delegated = bool,
    private_endpoint = bool
  }))
}