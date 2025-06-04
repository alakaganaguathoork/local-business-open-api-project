# Environment
locals {
  environment           = terraform.workspace != "default" ? terraform.workspace : var.environment
  private_dns_zone_name = "${var.company}.${local.environment}"
}

#Subnets
locals {
  # App subnets  
  app_subnets = {
    for key, app in var.apps :
    key => {
      name             = app.name
      address_prefixes = [app.subnet_cidr]
      delegation        = app.delegation
    }
  }
  # Key Vault single subnet just because
  keyvault_subnet = {
    keyvault = {
      name                                     = "keyvault"
      address_prefixes                         = [var.keyvault_defaults.subnet_cidr]
      enable_private_endpoint_network_policies = true
    }
  }

  # Storage single subnet just because
  storage_account_subnet = {
    storage = {
      name                                     = "storage"
      address_prefixes                         = [var.storage_account_defaults.subnet_cidr]
      service_endpoints                        = ["Microsoft.Storage"]
      enable_private_endpoint_network_policies = true
    }
  }

  database_subnet = {
    database = {
      name             = "database"
      address_prefixes                         = [var.database_defaults.subnet_cidr]
      service_endpoints                        = ["Microsoft.MSql"]
      enable_private_endpoint_network_policies = true
    }
  }

  # Merged subnets
  subnets = merge(local.app_subnets, local.keyvault_subnet, local.storage_account_subnet, local.database_subnet)
}

# DNS zones
locals {
  dns_zones = {
   keyvault = "${var.environment}.${var.company}.vaultcore.azure.net"
   storage  = "${var.environment}.${var.company}.storage.azure.com"
  }  
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
      db_ip        = value.db_ip
    }
  }
}

locals {
  nsg_keyvault_access_rules = [
    for value in var.apps :
    {
      name                         = "AllowConnectionToKeyvaultFor${value.name}"
      direction                    = "Inbound"
      access                       = "Allow"
      priority                     = 110 + index(values(var.apps), value)
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "443"
      source_address_prefix        = value.subnet_cidr
      destination_address_prefixes = [value.keyvault_ip]
    }
  ]

  nsg_storage_access_rule = [
    for value in var.apps :
    {
      name                         = "AllowConnectionToStorageFor${value.name}"
      direction                    = "Inbound"
      access                       = "Allow"
      priority                     = 200 + index(values(var.apps), value)
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "443"
      source_address_prefix        = value.subnet_cidr
      destination_address_prefixes = ["10.0.200.10/32"]
    }
  ]

  nsg_database_access_rules = [
    for value in var.apps :
    {
      name                         = "AllowConnectionToDatabseFor${value.name}"
      direction                    = "Inbound"
      access                       = "Allow"
      priority                     = 310 + index(values(var.apps), value)
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "443"
      source_address_prefix        = value.subnet_cidr
      destination_address_prefixes = [value.db_ip]      
    }
  ]

  nsg_custom_rules = concat(local.nsg_keyvault_access_rules, local.nsg_storage_access_rule, local.nsg_database_access_rules)
}
