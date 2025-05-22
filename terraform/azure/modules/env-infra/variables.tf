variable "environment" {
  description = "Environment string"
  type        = string
}

variable "location" {
  description = "Location string (default is `northeurope`)"
  type        = string
  default     = "northeurope"
}

variable "apps" {
  description = "Apps map of objects"
  type        = any
}

variable "keyvault" {
  description = "Key Vault object"
  type = any
}

variable "subnets" {
  description = "Subnets map of object"
  type        = any
}