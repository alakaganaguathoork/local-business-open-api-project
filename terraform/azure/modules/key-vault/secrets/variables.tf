variable "keyvault_id" {
  type = string
}

variable "keys" {
  type = list(object({
    name     = string
    key_type = string
    key_size = number
    key_opts = list(string)
  }))
  default = []
}

variable "secrets" {
  type = list(object({
    name         = string
    content_type = string
    value        = string
  }))
  default = []
}