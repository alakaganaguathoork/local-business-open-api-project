variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "security_groups" {
  type = map(
    map(
      object({
        type                       = string
        from_port                  = number
        to_port                    = number
        protocol                   = string
        cidr_blocks                = optional(list(string))
        source_security_group_name = optional(string)
      })
    )
  )
}

variable "apps" {
  type = map(object({
    name = string
    instance_type = string
    subnet_cidr = string
    availability_zone = string
  }))
}