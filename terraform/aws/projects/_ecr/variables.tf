variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "build_context" {
  type = string
}

variable "apps" {
  type = map(object({
    name = string
    subnet = string
    image_tag = string
    allow_ingress_connections_on_ports = optional(list(number), [])
  }))
}
