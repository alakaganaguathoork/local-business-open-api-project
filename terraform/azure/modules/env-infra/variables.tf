variable "environment" {
  description = "Environment string"
  type = string
}

variable "location" {
  description = "Location string (default is `northeurope`)"
  type = string
  default = "northeurope"
}

variable "subnets" {
  description = "Subnets map of object"
  type = any
}