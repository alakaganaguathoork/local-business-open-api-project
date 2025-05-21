variable "environment" {
  description = "Environment string"
  type = string
}

variable "location" {
  description = "Location string"
  type = string
}

variable "instances" {
  description = ""
  type = map(object({
    subnet = string
    delegated = bool 
  }))
}