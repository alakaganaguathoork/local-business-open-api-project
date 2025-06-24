variable "vpc_cidr_block" {
  type = string
}

variable "public_subnets" {
  type = map(object({
    subnet_cidr = string 
  }))
  default = {}
}

variable "private_subnets" {
  type = map(object({
    subnet_cidr = string
  }))
  default = {}
}

variable "enable_nat" {
  type = bool
}

variable "enable_gateway" {
  type = bool
}