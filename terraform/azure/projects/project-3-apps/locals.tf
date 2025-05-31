# Environment
locals {
  environment = terraform.workspace != "default" ? terraform.workspace : var.environment
}

locals {
  # App subnets  
  app_subnets = {
    for key, app in var.apps :
    key => {
      name             = app.name
      address_prefixes = [app.subnet_cidr]
      delegated        = app.delegated
    }
  }
  # Key Vault single subnet
  keyvault_subnet = {
    keyvault = {
      name                                     = "keyvault"
      address_prefixes                         = [var.keyvault_defaults.subnet_cidr]
      enable_private_endpoint_network_policies = true
    }
  }
  # Merged subnets
  subnets = merge(local.app_subnets, local.keyvault_subnet)
}

# Key Vaults
locals {
  # Key Vault object
  keyvaults = {
    for key, app in local.apps :
    key => {
      name                      = app.name
      sku_name                  = var.keyvault_defaults.sku_name
      private_ip                = app.keyvault_ip
      general_access_policies   = var.keyvault_access_policies.general
      principal_access_policies = var.keyvault_access_policies.principal
      secrets                   = var.secrets
      keys                      = var.keys
    }
  }
}

# Apps
locals {
    apps = {
    for key, value in var.apps : 
    key => {
      name         = value.name
      sku_name     = var.app_defaults.sku_name
      docker_image = var.app_defaults.docker_image
      os_type      = value.os_type
      subnet_cidr  = value.subnet_cidr
      keyvault_ip  = value.keyvault_ip
    }
  }
}