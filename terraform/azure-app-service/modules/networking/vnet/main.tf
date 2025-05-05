resource "azurerm_resource_group" "networking_rg" {
  name = "networking"
  location = var.location
}

resource "azurerm_virtual_network" "local_vnet" {
  name = "local"
  resource_group_name = azurerm_resource_group.networking_rg.name
  location = azurerm_resource_group.networking_rg.location
  address_space = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets
  name = each.value.name
  resource_group_name = azurerm_resource_group.networking_rg.name
  virtual_network_name = azurerm_virtual_network.local_vnet.name
  address_prefixes = each.value.address_prefixes

  private_endpoint_network_policies = each.value.private_endpoint ? "Enabled" : null
  
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