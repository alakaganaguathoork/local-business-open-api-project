variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "security_groups" {
  type    = any
  default = {}
}

variable "create_secretmanager_endpoint" {
  type    = bool
  default = false
}

variable "secrets" {
  type    = map(any)
  default = {}
}
