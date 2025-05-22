variable "environment" {
  description = "Environment string"
  type        = string
}

variable "location" {
  description = "Location string"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

}

variable "subnets" {
  description = "Subnets map of objects"
  type = map(object({
    address_prefixes                      = list(string)
    delegated                             = optional(bool, false)
    private_endpoint_policies_enabled     = optional(bool, false)
    private_link_service_policies_enabled = optional(bool, false)
  }))
}