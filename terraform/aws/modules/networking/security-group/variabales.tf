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
    cidr_ipv4   = optional(string)
    from_port   = optional(number, 0)
    ip_protocol = string
    to_port     = optional(number, 0)
    self        = optional(bool, false)
  }))
}

variable "egress_rule" {
  type = map(object({
    cidr_ipv4   = string
    from_port   = optional(number, null)
    ip_protocol = stringgi
    to_port     = optional(number, null)
    self        = optional(bool, false)
  }))
}