variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "cluster" {
  type = object({
    name = string
    k8s_version = string
  })
}