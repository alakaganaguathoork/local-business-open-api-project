# resource "random_string" "random" {
# for_each = var.subnets
# 
# length  = 7
# numeric = true
# special = false
# }

resource "azurerm_resource_group" "networking" {
  name     = "${var.environment}-vnetRG"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.environment}-vnet"
  resource_group_name = azurerm_resource_group.networking.name
  location            = azurerm_resource_group.networking.location
  address_space       = toset([var.vpc_cidr])
}

# resource "azurerm_subnet" "subnet" {
# for_each = var.subnets
# 
# name                 = "${each.value.name}-${var.environment}-subnet"
# resource_group_name  = azurerm_resource_group.networking.name
# virtual_network_name = azurerm_virtual_network.vnet.name
# address_prefixes     = each.value.address_prefixes

# private_endpoint_network_policies             = each.value.private_endpoint_policies_enabled ? "Enabled" : null
# private_link_service_network_policies_enabled = each.value.private_link_service_policies_enabled

# dynamic "delegation" {
# for_each = each.value.delegated ? [1] : []
# content {
# name = "delegation"
# service_delegation {
# name = "Microsoft.Web/serverFarms"
# }
# }
# }
# }

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = "${each.value.name}-${var.environment}-subnet"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.vpc_cidr, 8, index(keys(var.subnets), each.key))]

  # private_endpoint_network_policies             = each.value.private ? "Enabled" : null
  # private_link_service_network_policies_enabled = each.value.private_link_service_policies_enabled

  dynamic "delegation" {
    for_each = each.value.delegated ? [1] : []
    content {
      name = "delegation"
      service_delegation {
        name = "Microsoft.Web/serverFarms"
      }
    }
  }
}