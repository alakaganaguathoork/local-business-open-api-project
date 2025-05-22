variable "environment" {
  description = "Environment string"
  type = string
}

variable "location" {
  description = "Location string"
  type = string
}

# variable "instances" {
  # description = "Networking-related parameters"
  # type = map(object({
    # networking =object({
      # subnet = string
      # public_ip = bool
      # private_endpoint = bool
      # delegated = optional(bool, false)
    # })
  # }))
  # default = {
  #   networking = {
  #     delegated = false
  #   }
  # }
# }

variable "subnets" {
  description = "Subnets map of objects"
  type = map(object({
    address_prefixes = list(string)
    delegated = bool
    private_endpoint = bool
  }))
}