variable "region" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "eu-west-1b"
}

variable "apps" {
  type = map(object({
    name = string
    #    instance_type     = string
    #    os_type      = "linux"
    subnet_cidr = string
    #    delegation    = "app"
    #    keyvault_ip  = "10.0.100.11/32"
    #    db_ip        = "10.0.300.11/32"
  }))
}