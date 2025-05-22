variable "environment" {
  description = "Environments string"
  type = string
}

variable "location" {
  description = "Location string (default is `northeurope`)"
  type = string
  default = "northeurope"
}