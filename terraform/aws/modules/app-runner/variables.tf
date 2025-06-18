variable "region" {
  type = string
}

variable "app_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = list(string)
}

variable "image_identifier" {
  type = string
}

variable "repository_url" {
  type = string
}
