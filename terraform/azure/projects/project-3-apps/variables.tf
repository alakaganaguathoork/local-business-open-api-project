variable "company" {
  type    = string
  default = "mishap"
}

variable "environment" {
  type = string
}

variable "location" {
  type    = string
  default = "northeurope"
}

variable "app_defaults" {
  type = object({
    sku_name     = string
    docker_image = string
  })
}

variable "networking_defaults" {
  type = object({
    my_ip              = string
    vnet_address_space = list(string)
  })
}

variable "keyvault_defaults" {
  type = object({
    sku_name    = string
    subnet_cidr = string
  })
}

variable "storage_account_defaults" {
  type = object({
    subnet_cidr = string
  })
}

variable "database_defaults" {
  type = object({
    subnet_cidr = string
  })
}

variable "apps" {
  type = map(object({
    name         = string
    sku_name     = string
    os_type      = string
    subnet_cidr  = string
    delegation    = string
    keyvault_ip  = string
    db_ip        = string
    docker_image = string
  }))
}

variable "keyvault_access_policies" {
  type = map(object({
    secret_permissions  = list(string)
    key_permissions     = list(string)
    storage_permissions = list(string)
  }))
}

variable "keys" {
  type = list(object({
    name     = string
    key_type = string
    key_size = number
    key_opts = list(string)
  }))
}

variable "secrets" {
  type = list(object({
    name         = string
    content_type = string
    value        = string
  }))
}