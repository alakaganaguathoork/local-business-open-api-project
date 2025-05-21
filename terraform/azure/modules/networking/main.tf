resource "random_string" "random" {
  for_each = local.subnets

  length = 7
  numeric = true
  special = false  
}

resource "azurerm_resource_group" "vnet_rg" {
  name = "${local.environment}VnetRG"
  location = local.location
}

resource "azurerm_virtual_network" "vnet" {
  name = local.environment
  resource_group_name = azurerm_resource_group.vnet_rg.name
  location = azurerm_resource_group.vnet_rg.location
  address_space = [ "172.16.0.0/16" ]
}

resource "azurerm_subnet" "subnets" {
  for_each = local.subnets
  name = "subnet-${local.environment}-${random_string.random[each.key].result}"
  resource_group_name = azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = each.value.subnet

#   private_endpoint_network_policies = each.value.private_endpoint ? "Enabled" : null
#   
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