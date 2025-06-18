variable "region" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnet_cidr" {
  type = string
}
variable "app_name" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "build_context" {
  type = string
}