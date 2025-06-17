variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ingress_rule" {
  type = map(object({
    cidr_ipv4   = string
    from_port   = optional(number)
    ip_protocol = string
    to_port     = optional(number)
  }))
}

variable "egress_rule" {
  type = map(object({
    cidr_ipv4   = string
    from_port   = optional(string)
    ip_protocol = string
    to_port     = optional(string)
  }))
}