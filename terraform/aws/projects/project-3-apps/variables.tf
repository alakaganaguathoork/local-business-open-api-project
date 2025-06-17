variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "A valid region indentifier (a default is 'eu-north-1')"
}

variable "availability_zone" {
  type    = string
  default = "eu-west-1b"
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnet_cidr_block" {
  type = string
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}