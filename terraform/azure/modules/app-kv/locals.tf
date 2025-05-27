# Vnet module locals
locals {
  apps_subnets_to_create = {
    for key, value in var.env_data.services.apps :
    key => {
      name      = value.subnet.name
      delegated = value.subnet.delegated
      private   = value.subnet.private
    }
  }

  keyvault_subnet_to_create = { for key, value in var.env_data.keyvault_subnet : key => value }

  subnets_to_create = merge(local.apps_subnets_to_create, local.keyvault_subnet_to_create)
}

# Network Security Groups module locals
locals {
  nsg_rules = var.env_data.nsg_rules
}

# locals {
# app_subnets = {
# for key, value in module.vnet.subnets :
# key => {
# id = value.id
# }
# if value.name != "keyvault"
# }
# }
# 
# locals {
# keyvault_subnet = {
# for key, value in module.vnet.subnets :
# key => {
# id = values(value.id)
# name = value.name
# resource_group_name = values(value.resource_group_name)
# }
# if value.name == "keyvault"
# }
# }

# App module locals
locals {
  apps = {
    for key, value in var.env_data.services.apps :
    key => {
      name     = value.name
      os_type  = value.os_type
      sku_name = value.sku_name
    }
  }
}

# Keyvault module locals
locals {
  keyvaults = {
    for key, value in var.env_data.services.apps :
    key => {
      service_type = value.keyvault.service_type
      name         = "${value.name}-${value.keyvault.name}"
      sku_name     = value.keyvault.sku_name
    }
  }
}