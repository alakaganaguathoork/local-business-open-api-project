variable "availability_zone" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnets" {
  type = map(object({
    subnet_cidr = string
  }))
}